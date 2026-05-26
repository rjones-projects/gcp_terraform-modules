#!/bin/bash -xe
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

restrict_su() {
  cat >/tmp/sudoers.sh <<"EOF"
#!/bin/bash
sudo chmod a+r /var/google-sudoers.d/*
sudo chmod a+r /etc/sudoers.d/google_sudoers
if grep -Fq "/bin/su" /etc/sudoers.d/google_sudoers
then
  :
else
  sudo awk 'FNR==1{print $0 ", !/bin/su";}' /etc/sudoers.d/google_sudoers > /tmp/google_sudoers
  sudo visudo -c -f /tmp/google_sudoers
  if [ "$?" -eq "0" ]; then
    sudo cp -f /tmp/google_sudoers /etc/sudoers.d/google_sudoers
  fi
fi
for file in /var/google-sudoers.d/*; do
  echo "Removing individual user access"
  echo "Removing individual user access for $file"
  filename=$(basename $file)
  if sudo grep -Fq "/bin/su" $file
  then
    echo "Su access already removed from $filename"
  else
    echo "Removing su access for $filename"
    sudo awk 'FNR==1{print $0 ", !/bin/su";}' $file > /tmp/$filename
    sudo visudo -c -f /tmp/$filename
    if [ "$?" -eq "0" ]; then
      sudo cp -f /tmp/$filename $file
    fi
  fi
done
/bin/bash
EOF

  chmod a+x /tmp/sudoers.sh
  chmod a+r /var/google-sudoers.d

  echo -e '\nForceCommand /tmp/sudoers.sh' >>/etc/ssh/sshd_config
  systemctl restart ssh.service
}


enable_google_cloud_ops_agent() {
  echo "[INFO] Installing google cloud ops agent (logs, metrics, and traces )"

  curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
  bash add-google-cloud-ops-agent-repo.sh --also-install

  cat >/etc/google-cloud-ops-agent/config.yaml <<"EOF"
logging:
  receivers:
    squid:
      type: files
      include_paths:
        - /var/log/squid/*.log
  service:
    pipelines:
      default_pipeline:
        receivers: [squid]
        processors: [squid_parser]
  processors:
    squid_parser:
      type: parse_json
      field: message
EOF
  systemctl restart google-cloud-ops-agent
}

enable_squid() {
  echo "[INFO] Installing Squid"
  apt-get update
  apt-get install squid-openssl -y

  gsutil cp ${whitelist_gcs} /etc/squid/whitelist.txt
  gsutil cp ${squid_config_gcs} /etc/squid/squid.conf
  gsutil cp ${tls_inspection_bypass_gcs} /etc/squid/tls_inspection_bypass.txt

  if [ ! -d /etc/squid/ssl ]; then
    echo "[INFO] Generating SSL cert"
    mkdir -p /etc/squid/ssl
    cd /etc/squid/ssl
    openssl genrsa -out squid.key 4096
    openssl req -new -key squid.key -out squid.csr -subj "/C=XX/ST=XX/L=squid/O=squid/CN=squid"
    openssl x509 -req -days 3650 -in squid.csr -signkey squid.key -out squid.crt
    cat squid.key squid.crt >>squid.pem
    /usr/lib/squid/security_file_certgen -c -s /var/spool/squid/ssl_db -M 4MB
  fi

  systemctl stop squid
  systemctl start squid
  systemctl enable squid

  sysctl -w net.ipv4.ip_forward=1
  echo "net.ipv4.ip_forward = 1" >>/etc/sysctl.d/ip_forward.conf

  my_ip=$(hostname -I | xargs)
  iptables -t nat -A PREROUTING -p tcp --dport 443 -j DNAT --to-destination $my_ip:443
  iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination $my_ip:80
    if [ ${allow_extra_connections} = true ]; then
      echo "start allowing extra connections"
      %{ for port, ips in extra_connections_map }
        iptables -t nat -A POSTROUTING -s ${extra_connections_source_range} -j MASQUERADE -d ${ips} -p tcp --dport ${port}
      %{ endfor ~}
    fi
  DEBIAN_FRONTEND=noninteractive apt-get install -y iptables-persistent
  sh -c "iptables-save > /etc/iptables/rules.v4"
  
}

enable_health_check_port() {
  apt-get install -y netcat-openbsd  
  nohup bash -c "while ! nc -z localhost 3128; do sleep 1; done" &
  nohup bash -c "while true; do { echo -e 'HTTP/1.1 200 OK\n\n$(date)'; } | nc -l -p 8080; done" &
}

watch_for_whitelist_changes() {
  cat >/tmp/reload_config.sh <<"EOF"
#!/bin/bash
while true; do
  sleep 10
  gsutil cp ${whitelist_gcs} /etc/squid/whitelist.txt
  gsutil cp ${squid_config_gcs} /etc/squid/squid.conf
  gsutil cp ${tls_inspection_bypass_gcs} /etc/squid/tls_inspection_bypass.txt
  squid -k parse && squid -k reconfigure
done
EOF
  chmod +x /tmp/reload_config.sh
  nohup bash -c "/tmp/reload_config.sh" &
}



###################################
# Main body of script starts here #
###################################
echo "[INFO] Start of script"


echo "Enable google cloud ops agent ?"${enable_google_cloud_ops_agent}
if [ ${enable_google_cloud_ops_agent} = true ]; then
  enable_google_cloud_ops_agent
fi

echo "Enable squid ?"${enable_squid}
if [ ${enable_squid} = true ]; then
  enable_squid
fi

echo "Restrict su ?"${restrict_su}
if [ ${restrict_su} = true ]; then
  restrict_su
fi

cd /usr/local/share/ca-certificates/
printf "%s" "${cert}" > voda.pem
openssl x509 -in voda.pem -inform PEM -out voda.crt
update-ca-certificates

systemctl restart squid
enable_health_check_port
watch_for_whitelist_changes

echo "[INFO] - Script completed"