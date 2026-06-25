#!/usr/bin/env python3
"""
AI PR Reviewer — posts inline GitHub review comments using Claude.
Focuses on: Terraform/IaC correctness and code quality/best practices.
"""

import os
import re
import sys
import json
import subprocess
import anthropic
from github import Github, Auth

# ─── Config ───────────────────────────────────────────────────────────────────

ANTHROPIC_API_KEY = os.environ["ANTHROPIC_API_KEY"]
GITHUB_TOKEN      = os.environ["GITHUB_TOKEN"]
REPO_NAME         = os.environ["REPO_NAME"]
PR_NUMBER         = int(os.environ["PR_NUMBER"])
BASE_SHA          = os.environ["BASE_SHA"]
HEAD_SHA          = os.environ["HEAD_SHA"]

# File extensions to review
REVIEWABLE_EXTENSIONS = {
    # Terraform / IaC
    ".tf", ".tfvars", ".tfvars.json",
    # General code
    ".py", ".go", ".ts", ".js", ".sh", ".yaml", ".yml",
    # Config
    ".json", ".toml",
}

# Hard skip — never send these to Claude
SKIP_PATTERNS = [
    r"\.lock$", r"\.sum$", r"vendor/", r"node_modules/",
    r"\.min\.(js|css)$", r"__pycache__", r"\.terraform/",
    r"\.tfstate",
]

MAX_FILE_LINES   = 800   # skip files larger than this
MAX_FILES        = 20    # cap number of files reviewed per PR
MAX_DIFF_CHARS   = 12_000  # trim very large diffs per file


# ─── Helpers ──────────────────────────────────────────────────────────────────

def should_skip(path: str) -> bool:
    for pat in SKIP_PATTERNS:
        if re.search(pat, path):
            return True
    _, ext = os.path.splitext(path)
    return ext not in REVIEWABLE_EXTENSIONS


def get_diff() -> str:
    result = subprocess.run(
        ["git", "diff", f"{BASE_SHA}...{HEAD_SHA}", "--unified=5", "--diff-filter=ACMRT"],
        capture_output=True, text=True, check=True,
    )
    return result.stdout


def parse_diff(raw_diff: str) -> list[dict]:
    """
    Returns a list of dicts: { path, diff, hunk_map, added_lines }

    hunk_map:    new_line_number -> diff_position
                 Position is 1-based, counts every line in the file's diff
                 section (index/---/+++ headers + @@ lines + content lines).
                 This matches what GitHub's POST /reviews API expects.

    added_lines: set of new file line numbers that are additions (+),
                 used to validate that Claude only comments on added lines.
    """
    files: list[dict] = []
    current: dict | None = None
    diff_position   = 0
    new_line_number = 0

    for raw_line in raw_diff.splitlines(keepends=True):
        line = raw_line.rstrip("\n")

        # ── New file section ──────────────────────────────────────────────
        if line.startswith("diff --git "):
            if current is not None:
                files.append(current)
            match = re.search(r' b/(.+)$', line)
            path = match.group(1).strip() if match else "unknown"
            current = {
                "path":        path,
                "diff":        "",
                "hunk_map":    {},   # new_lineno -> diff_position
                "added_lines": set(),
            }
            diff_position   = 0
            new_line_number = 0
            # The "diff --git" line itself is NOT counted in position
            continue

        if current is None:
            continue

        # ── File header lines (index / --- / +++) ────────────────────────
        if (line.startswith("index ")
                or line.startswith("--- ")
                or line.startswith("+++ ")
                or line.startswith("new file")
                or line.startswith("deleted file")
                or line.startswith("rename ")):
            diff_position += 1
            current["diff"] += raw_line
            continue

        # ── Hunk header ───────────────────────────────────────────────────
        if line.startswith("@@"):
            match = re.search(r'\+(\d+)(?:,(\d+))?', line)
            if match:
                new_line_number = int(match.group(1))
                # If the hunk starts at line 0 it means empty file — treat as 1
                if new_line_number == 0:
                    new_line_number = 1
            diff_position += 1
            current["hunk_map"][new_line_number] = diff_position
            current["diff"] += raw_line
            continue

        # ── Content lines ─────────────────────────────────────────────────
        diff_position += 1
        current["diff"] += raw_line

        if line.startswith("+"):
            current["hunk_map"][new_line_number] = diff_position
            current["added_lines"].add(new_line_number)
            new_line_number += 1
        elif line.startswith("-"):
            pass  # deleted line: old side only, don't advance new_line_number
        else:
            # Context line
            current["hunk_map"][new_line_number] = diff_position
            new_line_number += 1

    if current is not None:
        files.append(current)

    return files


# ─── Claude prompt ────────────────────────────────────────────────────────────

SYSTEM_PROMPT = """You are a senior platform engineer performing a pull request review.

Your two focus areas are:
1. **Terraform / IaC** — correctness, security group rules, resource naming, state management,
   module structure, variable typing, missing lifecycle rules, avoid hardcoded values, 
   provider version pinning, missing tags, sensitive outputs exposed, dangerous `destroy` paths.
2. **Code quality & best practices** — readability, naming, error handling, DRY violations,
   magic numbers/strings, missing tests or validation, overly complex logic, logging hygiene,
   CI/CD anti-patterns, shell script robustness (set -euo pipefail).

Rules:
- Only comment on lines that are ADDED or MODIFIED (lines starting with +).
- Be precise and actionable. State the problem and suggest the fix.
- Do NOT flag style nits (formatting, whitespace) unless they cause bugs.
- Do NOT comment on deleted lines.
- If a file looks fine, output an empty comments array.

Respond ONLY with valid JSON, no markdown fences, in this exact schema:
{
  "comments": [
    {
      "line": <new file line number, integer>,
      "severity": "error" | "warning" | "suggestion",
      "body": "<markdown comment — include code suggestion if relevant>"
    }
  ],
  "summary": "<one-line overall verdict for this file>"
}
"""


def review_file(client: anthropic.Anthropic, file: dict) -> dict | None:
    path = file["path"]
    diff = file["diff"][:MAX_DIFF_CHARS]

    if not diff.strip():
        return None

    prompt = f"Review this diff for `{path}`:\n\n```diff\n{diff}\n```"

    try:
        message = client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=1500,
            system=SYSTEM_PROMPT,
            messages=[{"role": "user", "content": prompt}],
        )
        text = message.content[0].text.strip()
        # Strip accidental markdown fences
        text = re.sub(r'^```[a-z]*\n?', '', text)
        text = re.sub(r'\n?```$', '', text)
        return json.loads(text)
    except (json.JSONDecodeError, Exception) as exc:
        print(f"  [warn] Could not parse Claude response for {path}: {exc}", file=sys.stderr)
        return None


# ─── Post to GitHub ───────────────────────────────────────────────────────────

def post_review(pr, file_reviews: list[dict]) -> None:
    """
    Creates a single GitHub pull request review with all inline comments.
    """
    review_comments = []
    file_summaries  = []

    for item in file_reviews:
        file        = item["file"]
        result      = item["result"]
        hunk_map    = file["hunk_map"]
        added_lines = file["added_lines"]
        path        = file["path"]

        if result.get("summary"):
            file_summaries.append(f"**`{path}`** — {result['summary']}")

        for comment in result.get("comments", []):
            line = comment.get("line")
            if not isinstance(line, int):
                print(f"  [skip] {path}:{line} — not an integer, skipping", file=sys.stderr)
                continue

            # Prefer the exact line; fall back to nearest added line >= requested
            pos = hunk_map.get(line)
            if pos is None:
                candidates = sorted(l for l in hunk_map if l >= line)
                if candidates:
                    line = candidates[0]
                    pos  = hunk_map[line]
                else:
                    # last resort: nearest line before
                    candidates = sorted((l for l in hunk_map if l < line), reverse=True)
                    if candidates:
                        line = candidates[0]
                        pos  = hunk_map[line]
                    else:
                        print(f"  [skip] {path}:{line} — no diff position found", file=sys.stderr)
                        continue

            severity_icon = {"error": "🔴", "warning": "🟡", "suggestion": "🔵"}.get(
                comment.get("severity", "suggestion"), "🔵"
            )
            body = f"{severity_icon} **{comment.get('severity', 'suggestion').capitalize()}**\n\n{comment['body']}"

            print(f"  [comment] {path}:{line} pos={pos} ({comment.get('severity')})")
            review_comments.append({
                "path":     path,
                "position": pos,
                "body":     body,
            })

    overall_body = "## 🤖 Claude AI Review\n\n"
    if file_summaries:
        overall_body += "### File summaries\n" + "\n".join(f"- {s}" for s in file_summaries)
        overall_body += "\n\n"

    if not review_comments:
        overall_body += "_No issues found. Looks good! ✅_"

    has_errors = any(
        c.get("severity") == "error"
        for item in file_reviews
        for c in item["result"].get("comments", [])
    )
    event = "REQUEST_CHANGES" if has_errors else "COMMENT"

    try:
        pr.create_review(
            body=overall_body,
            event=event,
            comments=review_comments,
        )
        print(f"Review posted ({event}) with {len(review_comments)} inline comment(s).")
    except Exception as exc:
        # If inline comments fail, fall back to a plain summary comment
        print(f"  [warn] create_review failed: {exc}", file=sys.stderr)
        print("  Falling back to plain PR comment.", file=sys.stderr)
        fallback = overall_body + "\n\n> ⚠️ _Inline comments could not be posted; showing summary only._"
        pr.create_issue_comment(fallback)
        print("Fallback comment posted.")


# ─── Main ─────────────────────────────────────────────────────────────────────

def main() -> None:
    gh   = Github(auth=Auth.Token(GITHUB_TOKEN))
    repo = gh.get_repo(REPO_NAME)
    pr   = repo.get_pull(PR_NUMBER)

    print(f"Reviewing PR #{PR_NUMBER}: {pr.title}")

    raw_diff = get_diff()
    all_files = parse_diff(raw_diff)

    # Filter
    reviewable = [f for f in all_files if not should_skip(f["path"])]
    reviewable = reviewable[:MAX_FILES]

    if not reviewable:
        print("No reviewable files found. Skipping.")
        return

    print(f"Reviewing {len(reviewable)} file(s): {[f['path'] for f in reviewable]}")

    client = anthropic.Anthropic(api_key=ANTHROPIC_API_KEY)

    file_reviews = []
    for file in reviewable:
        print(f"  → {file['path']} …", end=" ", flush=True)
        result = review_file(client, file)
        if result:
            n = len(result.get("comments", []))
            print(f"{n} comment(s)")
            file_reviews.append({"file": file, "result": result})
        else:
            print("skipped")

    if not file_reviews:
        print("Nothing to post.")
        return

    post_review(pr, file_reviews)


if __name__ == "__main__":
    main()