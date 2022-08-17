---
title: Introduction to the Genesys Cloud and AWS EventBridge Integration
tags: Genesys Cloud, Developer Engagement, EventBridge, Event Bus
date: 2022-07-29
author: john.carnell
category: 6
---

Greetings everyone! This month, I want to introduce the Genesys Cloud/AWS EventBridge integration. Genesys Cloud is an event-driven platform.  As various contact-center related activities are occurring (e.g. a new phase of a conversation has begun, an Agent goes on queue, off queue, etc...), a message is generated indicating that the activity has happened. 

The Genesys Cloud/AWS EventBridge integration allows you as a developer to tap into the massive stream of events being emitted from Genesys Cloud and send them to your Amazon Web Services (AWS) account for processing. Tapping into the Genesys Cloud event stream allows you to build scalable, near-time, back-end integrations. Unlike platform API calls, where an API endpoint is polled repeatedly to retrieve data (even when there is no data to be retrieved), event-based integrations are "push" models where events are pushed to interested parties and consumed as the event occurs. Using an event-based approach is often more scalable and resilient than using a platform API approach because unlike platform APIs, consumption of messages does not come with the same [rate-limits](/platform/api/rate-limits) often associated with Genesys Cloud platform APIs.

Let's get started by first defining what is an event bus, the integration pattern that AWS EventBridge is built around.

## What is an event bus?
An event bus (also known as a message bus) is an integration pattern that allows systems to share state and data changes through the passing of messages back and forth between these systems.  With an event bus, the producer of the message and the consumers of the message never directly exchange messages. Instead, the event producer publishes a message to what is conceptually a pipe. As that message enters the pipe, other systems can read the message from the pipe and do what they like with it. New event producers and consumers can be easily added to and removed from the pipe. The diagram below illustrates the concept of an event bus:

![Event Bus](eventbus_conceptual.png "A conceptual view of an event bus")

:::{"alert":"primary","title":"What is the difference between message queues, an event bus, and enterprise service buses?","autoCollapse":false}
If you are new to integration patterns, you might be asking what the difference between event buses and other integration patterns and technologies are. An event bus focuses on providing a transport and routing layer for messages generated from events occurring within systems. It is meant to be a lightweight integration pattern. An event bus does not have the comprehensive queuing capabilities of a specialized message queue platform like IBM's MQ or the open source equivalent, Apache MQ. An event bus has minimal support for the transformation of messages, and does not provide the ability to apply comprehensive business rules to a message traveling inside the pipe. There are much heavier technologies, like the enterprise service bus, that provide these capabilities.

An event bus follows the maxim: "Dumb pipes, smart endpoints."
:::

## What is AWS EventBridge?
AWS EventBridge is a managed event bus that allows AWS partners to publish messages from their platforms to resources residing in AWS. With AWS EventBridge a message originating from a partner platform (e.g. Genesys Cloud) can be persisted to an AWS S3 bucket, sent to a Kinesis stream or processed directly by a Lambda running within your own AWS account. AWS EventBridge provides a lightweight, filtering language to help filter out events that are not of interest to you.

## Why use AWS EventBridge with Genesys Cloud
The Genesys Cloud/AWS EventBridge integration is an extremely attractive option for building event-based integrations with Genesys Cloud because:

- **Completely managed by AWS**. AWS EventBridge is completely managed by AWS. There are no servers to manage and you only pay for what you use. There is no code required to set up AWS EventBridge.
- **Resiliency**.  AWS provides a [99.99%](https://aws.amazon.com/eventbridge/sla/) Service Level Agreement (SLA_ for AWS EventBridge. If Genesys Cloud is unable to connect to your AWS EventBridge account due to an AWS outage, Genesys Cloud will queue messages and retry sending them for up to 4 days. This is quite a bit different from the Genesys Cloud notification service.  With the Genesys Cloud notification service, if the WebSocket that messages were being passed across is closed, any sent messages are lost. In addition, AWS EventBridge does allow for retry logic and the use of Dead Letter Queues (DLQ) if an event bus is unable to deliver a message to a target in Amazon.
- **Scalability**. AWS automatically handles scaling for bursts of messages coming into the AWS infrastructure. By leveraging AWS EventBridge and other AWS technologies like Kinesis and AWS Lambdas you can automatically scale up and down to meet almost any volume requirements without the direct need for human intervention.
- **Multiple integration partners**.  AWS EventBridge integrates with a large number of partner systems. This makes integrating third-party SaaS platforms like Genesys Cloud a configuration exercise rather than a custom-coding one. For a full list of AWS EventBridge integration partners,see [here](https://aws.amazon.com/eventbridge/integrations/).
- **Multiple AWS targeting options**. Once a message hits the AWS EventBridge, you are able to process the message with a large number of AWS technologies. A full list can be found [here](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-targets.html). AWS EventBridge does not just limit you to AWS-based targets. AWS EventBridge can pass along messages to any HTTP-based API.

## Setting up the Genesys Cloud and AWS EventBridge
In order to set up Genesys Cloud and AWS EventBridge, there are a number of components in both Genesys Cloud and AWS that need to be configured.  The diagram below illustrates these components:

![EventBridge Configuration](eventbridge_configuration.png "EventBridge Config Components")

1. **Genesys Cloud EventBridge Integration**.  Genesys Cloud's EventBridge capabilities are exposed as a Genesys Cloud integration. For instructions on how to set up the AWS EventBridge integration in Genesys Cloud, see [here](https://help.mypurecloud.com/articles/about-the-amazon-eventbridge-integration/).
2. **AWS EventBridge Partner Event Source**. The AWS partner event source represents the partner configuration needed to be done in your Amazon account in order for the partner to communicate with AWS. The Genesys Cloud EventBridge integration will automatically create a partner event source for you in your Amazon account.  However, before you can begin receiving messages from Genesys Cloud, you will need to associate the Genesys Cloud-created partner event source with an AWS Event bus. 
3. **AWS EventBridge Event Bus**. This is the event bus that information will flow across. There is always at least one AWS EventBridge event bus associated with your AWS account. The name of this pre-created event bus is called *default*. You can create additional event buses to segregate message traffic coming in the event bus.
4. **AWS EventBridge Rules**.  AWS provides a filtering language that enables you to match on patterns on incoming events and only allows those events that match the pattern to be allowed into the event bus. Once a message has been matched to a pattern, it will be passed to one or more AWS EventBridge targets.
5. **AWS EventBridge Targets**. An AWS EventBridge rule can have one or more EventBridge targets. A target represents a destination where a message will be stored or processed. A full list can be found [here](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-targets.html).

:::{"alert":"primary","title":"Video tutorials for setting up AWS EventBridge","autoCollapse":false}
I will not be walking through step-by-step in this blog post on how to manually set up the Genesys Cloud AWS EventBridge integration or the AWS EventBridge integration. These topics are covered in the following videos:

1. [Configuring a simple AWS EventBridge with Genesys Cloud](https://www.youtube.com/watch?v=1uqEUpFtk8Q). This is a short video that walks through how to hook up Genesys Cloud and AWS EventBridge to send Genesys Cloud events to an AWS Lambda.
2. [AWS EventBridge Overview](https://www.youtube.com/watch?v=ea9SCYDJIm4). An AWS-produced video that provides an excellent overview of AWS EventBridge and how to configure it.
:::

## Using CX as Code and Terraform to completely set up an AWS EventBridge
Let's build an AWS EventBridge integration that will take all available Genesys Cloud audit events and pass them to an AWS CloudWatch log group. In order to do this we will are going to need to create/configure:

1. A Genesys Cloud/AWS EventBridge Integration.
2. A partner event source.  (This is done for you by Genesys Cloud)
2. Associate the Genesys Cloud partner event source to an event bus.
3. Create a rule to be triggered on incoming messages.
4. Create a rule target(s) that will be sent the message if the message matches.

This is illustrated in the diagram below:

![EventBridge Implementation](eventbridge_implementation.png "A message bus implementation using AWS EventBridge")

To set up this example, we are going to use **CX as Code** and the Hashicorp AWS Provider to install all of the configurations needed for this example. We are going to walk through each of the major **CX as Code** and Hashicorp AWS provider components of this integration. For conciseness, I am not going to show the entire [main.tf](main.tf) file or the example [dev.auto.tfvars](dev.auto.tfvars) file that sets the environment variables for the Terraform script. 

### Setting up the Genesys Cloud AWS EventBridge integration
The first thing that needs to be done is to create the Genesys Cloud AWS EventBridge integration. You can use the **CX as Code** [genesyscloud_integration](https://registry.terraform.io/providers/MyPureCloud/genesyscloud/latest/docs/resources/integration) resource to set up the integration. However, the `genesyscloud_integration` is a general purpose resource for setting up any kind of Genesys Cloud integration. Each integration requires specialized meta-data that is not always clearly documented. To simplify this for the creation of an AWS EventBridge integration, we have wrapped this set up using a Terraform remote module that is stored [here](git::https://github.com/GenesysCloudDevOps/aws-event-bridge-module.git?ref=main). The configuration for Genesys Cloud EventBridge remote module is shown below:

```
module "AwsEventBridgeIntegration" {
   integration_name    = var.event_bus_name
   source              = "git::https://github.com/GenesysCloudDevOps/aws-event-bridge-module.git?ref=main"
   aws_account_id      = var.aws_account_id
   aws_account_region  = var.aws_region
   event_source_suffix = var.event_bus_name
   topic_filters       = ["v2.audits.entitytype.{id}.entityid.{id}"]
}
```

### Create the Cloudwatch Log Group
Next, we need to create the Cloudwatch log watch group that will hold the Genesys Cloud audit events passed to the AWS EventBridge. To create this log group, we will use the [Hashicorp AWS provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).

```
resource "aws_cloudwatch_log_group" "audit_log_events" {
  name = "/aws/events/genesyscloud_audit_log_events"
}
```

### Create the Event Bus
The creation of a Genesys Cloud EventBridge integration will create an AWS partner event source in your AWS account. Remember though, we need to associate a partner event source with an event bus. We will do by first looking up the event source that was created by Genesys Cloud.

```
data "aws_cloudwatch_event_source" "genesys_event_bridge" {
  depends_on = [
    module.AwsEventBridgeIntegration
  ]
  name_prefix = "aws.partner/genesys.com"
}
```

:::{"alert":"warning","title":"Beware the single bus","autoCollapse":false}
The above Terraform data lookup uses a `name_prefix` to look up the event source. The above example looks for an event source that begins with `aws.partner/genesys.com`. If you have more than one Genesys Cloud EventBridge integration defined the above code will pull back more than one definition and fail. Multiple Genesys Cloud EventBridge integrations will have to use the fully qualified name in the `event_source` field. (e.g. aws.partner/genesys.com/cloud/<<Genesys Cloud Organization Id>>/<<Event Source Suffix>>)
:::

Once the partner event source is looked up, it can be used to create the event bus. The Terraform snippet below demonstrates this.

```
resource "aws_cloudwatch_event_bus" "genesys_audit_event_bridge" {
  name              = data.aws_cloudwatch_event_source.genesys_event_bridge.name
  event_source_name = data.aws_cloudwatch_event_source.genesys_event_bridge.name
}
```

### Creating the event bus rules and targets
Once the event bus is created, we can create a rule to process audit events. This is where AWS EventBridge's filtering rules can be applied to match or exclude messages being passed from Genesys Cloud to AWS. Shown below is the Terraform resource definition that creates the EventBridge rule.

```
resource "aws_cloudwatch_event_rule" "audit_events_rule" {
  depends_on = [
    aws_cloudwatch_event_bus.genesys_audit_event_bridge
  ]
  name        = "capture-audit-events"
  description = "Capture audit events coming in from AWS"
  event_bus_name = data.aws_cloudwatch_event_source.genesys_event_bridge.name

  event_pattern = <<EOF
    {
      "source": [{
        "prefix": "aws.partner/genesys.com"
      }]
 
    }
EOF
}
```

Once the rule has been created, you can associate one or more targets that will process the message passed into the event bus. For our purposes, the resource below will create an event target that will pass the message to an AWS Cloudwatch log group.

```
resource "aws_cloudwatch_event_target" "audit_rule" {  
  rule      = aws_cloudwatch_event_rule.audit_events_rule.name
  target_id = "SendToCloudWatch"
  arn       = aws_cloudwatch_log_group.audit_log_events.arn
  event_bus_name = data.aws_cloudwatch_event_source.genesys_event_bridge.name
}
```

## Final Thoughts
The Genesys Cloud/AWS EventBridge integration offers a new and powerful tool for integrating Genesys Cloud with other internal applications and SaaS platforms.  It allows you to build resilient and scalable backend integrations without having to deal with many of the low-level complexities involved with building integrations using the Genesys Cloud notification service and a web socket. Furthermore, when you leverage **CX as Code** and Terraform, you easily automate the configuration and configuration of Genesys Cloud and AWS EventBridge into a simple, declarative format that can be easily processed with a CI/CD pipeline.


## Additional Resources
1. [AWS EventBridge documentation](https://docs.aws.amazon.com/eventbridge/?id=docs_gateway)
2. [Genesys Cloud/AWS EventBridge documentation](https://help.mypurecloud.com/articles/about-the-amazon-eventbridge-integration/)
3. [Genesys Cloud/AWS EventBridge Technical Notes](/notificationsalerts/notifications/event-bridge)
4. [Genesys Cloud EventBridge topics](/notificationsalerts/notifications/available-topics)
5. [Genesys Cloud CX as Code](devapps/cx-as-code/)
6. [Genesys Cloud Remote Modules](https://github.com/GenesysCloudDevOps)
7. [Genesys Cloud EventBridge remote module](https://github.com/GenesysCloudDevOps/aws-event-bridge-module)
8. [DevDrop - Configuring a simple AWS EventBridge with Genesys Cloud](https://www.youtube.com/watch?v=1uqEUpFtk8Q).
9. [Video - AWS EventBridge Overview](https://www.youtube.com/watch?v=ea9SCYDJIm4).
10. [Blueprint - AWS EventBridge. Create a PagerDuty incident in response to an oAuth Client delete](/blueprints/aws-eventbridge-oauth-client-delete-blueprint/)
11. [Blueprint - AWS EventBridge. Write user presence updates to a DynamoDB table](/blueprints/aws-eventbridge-user-presence-update-blueprint/)