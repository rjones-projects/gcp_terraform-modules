locals {
  topic_specs = [
    for item in try(var.pubsub.spec, []) : merge(var.topic_default, item, {
      topic_name = try(item.topic_name, try(item.name, var.topic_default.topic_name))
    })
    if try(item.topic_name, try(item.name, "")) != ""
  ]

  topics = [
    for topic in local.topic_specs : merge(topic, {
      regions              = tolist(try(topic.regions, var.topic_default.regions))
      finops_resource_type = coalesce(try(topic.finops_resource_type, null), var.topic_default.finops_resource_type)
      labels               = { for k, v in try(topic.labels, var.topic_default.labels) : tostring(k) => tostring(v) }
      subscriptions = [
        for sub in try(topic.subscriptions, var.topic_default.subscriptions) : merge(var.subscription_default, sub, {
          finops_resource_type = coalesce(try(sub.finops_resource_type, null), var.subscription_default.finops_resource_type)
          labels = {
            for k, v in(
              try(sub.labels, null) != null
              ? sub.labels
              : try(topic.labels, var.subscription_default.labels)
            ) :
            tostring(k) => tostring(v)
          }
        })
      ]
    })
  ]

  topic_map = { for topic in local.topics : topic.topic_name => topic }

  schema_topics = {
    for topic in local.topics : topic.topic_name => topic
    if topic.schema != null
  }

  subscriptions = flatten([
    for topic in local.topics : [
      for sub in topic.subscriptions : merge(sub, {
        key                        = "${topic.topic_name}/${sub.name}"
        topic_name                 = topic.topic_name
        topic_finops_resource_type = topic.finops_resource_type
        subscription_name          = sub.name
      })
      if sub.name != null && sub.name != ""
    ]
  ])

  subscription_map = {
    for sub in local.subscriptions : sub.key => sub
  }

  topic_notification_map = {
    for notification in flatten([
      for topic in local.topics : [
        for idx, n in try(topic.notifications, []) : merge(n, {
          key            = "${topic.topic_name}/${idx}"
          topic_name     = topic.topic_name
          bucket         = tostring(n.bucket)
          payload_format = try(n.payload_format, "JSON_API_V1")
        })
        if try(n.bucket, "") != ""
      ]
    ]) : notification.key => notification
  }

  topic_notification_pubsub_publishers = {
    for topic_name in distinct(values(local.topic_notification_map)[*].topic_name) :
    topic_name => topic_name
  }

  finops_specs = concat(
    [
      for topic in local.topics : {
        resource_type = topic.finops_resource_type
        name          = "${topic.finops_resource_type}/${topic.topic_name}"
        resource_name = topic.topic_name
        input_labels  = topic.labels
      }
    ],
    [
      for sub in local.subscriptions : {
        resource_type = sub.finops_resource_type
        name          = "${sub.finops_resource_type}/${sub.topic_name}/${sub.subscription_name}"
        resource_name = sub.subscription_name
        input_labels  = sub.labels
      }
    ]
  )
}
