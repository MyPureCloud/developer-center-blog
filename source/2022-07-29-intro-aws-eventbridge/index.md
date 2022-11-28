---
title: Introduction to the Genesys Cloud and AWS EventBridge integration
tags: Genesys Cloud, Developer Engagement, EventBridge, Event Bus
date: 2022-07-29
author: john.carnell
category: 6
---

Greetings everyone! I want to introduce the Genesys Cloud/AWS EventBridge integration. Genesys Cloud is an event-driven platform.  As various contact-center-related activities occur (e.g., a new conversation phase has begun, an Agent goes on queue, off the queue, etc.), a generated message indicates that the activity has happened. 

The Genesys Cloud/AWS EventBridge integration allows you to tap into the massive stream of events emitted from Genesys Cloud and send them to your Amazon Web Services (AWS) account for processing. Tapping into the Genesys Cloud event stream allows you to build scalable, near-time backend integrations. Unlike platform API calls, event-based integrations are "push" models where events are pushed to interested parties and consumed as the event occurs. Using an event-based approach is often more scalable and resilient than a platform API, unlike platform APIs, the consumption of messages does not come with the same [rate-limits](/platform/api/rate-limits) often associated with Genesys Cloud platform APIs.

Let's start by defining an event bus and the integration pattern that AWS EventBridge is built around.

## What is an Event bus?
An event bus (also known as a message bus) is an integration pattern that allows systems to share state and data changes by passing messages back and forth between these systems.  With an event bus, the producer of the message and the consumers of the message never directly exchange messages. Instead, the event producer publishes a message about what is conceptually a pipe. As that message enters the pipe, other systems can read the message from the pipe and do what they like with it. New event producers and consumers can be easily added to and removed from the pipe. The diagram illustrates the concept of an event bus:

![ A conceptual view of an event bus](eventbus_conceptual.png "A conceptual view of an event bus")

:::{"alert":"primary","title":"What is the difference between message queues, an event bus, and enterprise service buses?","autoCollapse":false}
If you are new to integration patterns, you might ask what the difference between event buses and other integration patterns and technologies is. An event bus focuses on providing a transport and routing layer for messages generated from events occurring within systems. It is meant to be a lightweight integration pattern. An event bus does not have the comprehensive queuing capabilities of a specialized message queue platform like IBM's MQ or the open-source equivalent, Apache MQ. An event bus has minimal support for transforming messages and does not provide the ability to apply comprehensive business rules to a message traveling inside the pipe. Much heavier technologies, like the enterprise service bus, provide these capabilities.

An event bus follows the maxim: "Dumb pipes, smart endpoints."
:::

## What is AWS EventBridge?
AWS EventBridge provides a lightweight filtering language to help filter events that are not of interest to you. AWS EventBridge is a managed event bus that allows AWS partners to publish messages from their platforms to resources residing in AWS. With AWS EventBridge a message originating from a partner platform (e.g., Genesys Cloud) can be persisted to an AWS S3 bucket, sent to a Kinesis stream or processed directly by a Lambda running within your own AWS account.

## Why use AWS EventBridge with Genesys Cloud
The Genesys Cloud/AWS EventBridge integration is a desirable option for building event-based integrations with Genesys Cloud because:

* **Managed by AWS**. AWS completely manages AWS EventBridge. There is no code required to set up AWS EventBridge. There are no servers to manage, and you only pay for what you use.
* **Resiliency**.  AWS provides an [Amazon EventBridge Service Level Agreement](https://aws.amazon.com/eventbridge/sla/ "Goes to the Amazon EventBridge Service Level Agreement page"). If Genesys Cloud cannot connect to your AWS EventBridge account due to an AWS outage, Genesys Cloud queues messages and retry sending them for up to four days. This is quite a bit different from the Genesys Cloud Notification service.  With the Genesys Cloud Notification service, if the WebSocket that messages were being passed across is closed, any sent messages are lost. In addition, AWS EventBridge allows for retry logic and the use of Dead Letter Queues (DLQ) if an event bus cannot deliver a message to a target in Amazon.
* **Scalability**. AWS automatically handles scaling for bursts of messages coming into the AWS infrastructure. By using AWS EventBridge and other AWS technologies like Kinesis and AWS Lambdas, you can automatically scale up and down to meet almost any volume requirements without the direct need for human intervention.
* **Multiple integration partners**.  AWS EventBridge integrates with many partner systems. This makes integrating third-party SaaS platforms like Genesys Cloud a configuration exercise rather than a custom-coding one. For a full list of AWS EventBridge integration partners. For information, see [Amazon EventBridge integrations](https://aws.amazon.com/eventbridge/integrations/ "Goes to the Amazon EventBridge integrations page").
* **Multiple AWS targeting options**. Once a message hits the AWS EventBridge, you can process the message with many AWS technologies. For a full list, see [Amazon EventBridge targets](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-targets.html "Goes to the Amazon EventBridge targets page"). AWS EventBridge does not  limit you to AWS-based targets. AWS EventBridge can pass along messages to any HTTP-based API.

## Why use the Genesys Cloud Notification Service and WebSockets?
Before the Genesys Cloud/AWS EventBridge integration addition, Genesys Cloud only offered the consumption of messages by using the Notification service and a WebSocket. This messaging integration model was initially built for doing near-time UI-based messaging integrations. The most common use case is building out of near-time contact center dashboards.

This model can be used in backend services to build near-time data integrations, mainly if using AWS in your organization is impossible. However, as a developer, you need to be aware of the following when using this model:

1. **No message durability**. Genesys Cloud only sends events over an open WebSocket. If a WebSocket is closed for any reason, any events generated while the WebSocket is not open will not be queued or retried when a new WebSocket is created. In the event of any network interruption, once a WebSocket is re-established, the developer must use the Genesys Cloud API to "fill in" the data that was missing when the socket was down.
2. **WebSockets are a lower-level primitive**. With a WebSocket, you, as the developer, are responsible for establishing the network connection, handling network connectivity issues, scaling based on the volume of messages, and processing messages. While these individual activities are not complicated, they can make building message-based integrations more complex.
3. **Limited generalization for subscribing topics**. When subscribing to topics, you must know the id of the Genesys Cloud object that you are listening to the events. This can be painful, and there is no mechanism to subscribe to events from numerous queues using a single topic. For example, to subscribe to events associated with multiple queues, you must subscribe to each queue.

In addition to the limitations above, you need to manage and respect the following Genesys Cloud rate-limits associated with the Notification service WebSockets implementation:

1. **Channels remain active for 24 hours**. Resubscribe to topics to maintain a channel longer than 24 hours.
2. **You can create up to 20 channels per user and application**. When the channel limit is reached, the new channel replaces the oldest channel with no active connection.
3. **Each WebSocket connection is limited to 1,000 topics**. If you subscribe to more than 1,000 topics, then the Notification service returns a 400-error code.
4. **Each channel can only be used by one WebSocket at a time**. The first WebSocket disconnects if you connect a second WebSocket with the same channel ID.

We will not walk through how to set up a web socket using the Notification service but recommend reviewing the following resources:

1. [Genesys Cloud Notification Service Overview](https://developer.genesys.cloud/notificationsalerts/notifications/ "Goes to the Genesys Cloud Notification Service Overview page") in the Genesys CLoud Developer Center
2. [Using the Genesys Cloud CLI to listen to Notification Service Events](https://www.youtube.com/watch?v=r4Jc-Mn0ONA "Goes to the DevDrop 11: Using the Genesys Cloud CLI to listen to Notification Service Events video") in YouTube
3. [Using the Genesys Cloud Python SDK with the Notification Service](https://www.youtube.com/watch?v=z6JS12DX_pI "Goes to the DevDrop 10: Using the Genesys Cloud Python SDK with the Notification Service video") in YouTube
4. [Build a chat translation assistant with the AWS Translate service]( https://developer.genesys.cloud/blueprints/chat-translator-blueprint/ "Goes to Build a chat translation assistant with the AWS Translate service page") in the Genesys Cloud Developer Center.    

## Setting up the Genesys Cloud and AWS EventBridge
Several components are required to be configured in Genesys Cloud and AWS to set up Genesys Cloud and AWS EventBridge. The diagram illustrates these components:

![EventBridge Configuration](eventbridge_configuration.png "EventBridge Configuration")

1. **Genesys Cloud EventBridge integration**.  Genesys Cloud's EventBridge capabilities are exposed as a Genesys Cloud integration. For instructions on how to set up the AWS EventBridge integration in Genesys Cloud. For more information, see [About the Amazon EventBridge integration](https://help.mypurecloud.com/articles/about-the-amazon-eventbridge-integration/ "Goes to About the Amazon EventBridge integration page") in the Genesys Cloud Resource Center.
2. **AWS EventBridge Partner Event Source**. The AWS partner event source represents the partner configuration needed in your Amazon account to communicate with AWS. The Genesys Cloud EventBridge integration will automatically create a partner event source in your Amazon account. However, before receiving messages from Genesys Cloud, you must associate the Genesys Cloud-created partner event source with an AWS Event bus. 
3. **AWS EventBridge Event bus**. This is the event bus that information flows across. There is always at least one AWS EventBridge event bus associated with your account. The name of this pre-created event bus is *default*. You can create more event buses to segregate message traffic coming in the event bus.
4. **AWS EventBridge rules**.  AWS provides a filtering language that enables you to match patterns on incoming events and only allows those events that match the pattern in the event bus. Once a message has been matched to a pattern, it will be passed to one or more AWS EventBridge targets.
5. **AWS EventBridge targets**. An AWS EventBridge rule can have one or more EventBridge targets. A target represents a destination where a message is stored or processed. For a complete list, see [Amazon EventBridge targets](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-targets.html "Goes to the Amazon EventBridge targets page") on the Amazon website.

:::{"alert":"primary","title":"Video tutorials for setting up AWS EventBridge","autoCollapse":false}
I will not provide a step-by-step process for manually setting up the Genesys Cloud AWS EventBridge integration or the AWS EventBridge integration. These topics are covered in the following videos:

1. [Introducing the Genesys Cloud AWS EventBridge Integration](https://www.youtube.com/watch?v=1uqEUpFtk8Q "Goes to DevDrop 15: Introducing the Genesys Cloud AWS EventBridge Integration video") in YouTube. This short video walks through how to hook up Genesys Cloud and AWS EventBridge to send Genesys Cloud events to an AWS Lambda.
2. [How To Get Started With Amazon EventBridge](https://www.youtube.com/watch?v=ea9SCYDJIm4 "Goes to the How To Get Started With Amazon EventBridge video") in YouTube, that provides an excellent overview of AWS EventBridge and how to configure it.
:::

## Using CX as Code and Terraform to set up an AWS EventBridge
Let's build an AWS EventBridge integration that takes all available Genesys Cloud audit events and pass them to an AWS CloudWatch log group. To perform this action, we need to create/configure the following:

1. A Genesys Cloud/AWS EventBridge Integration.
2. A partner event source.  (This is done for you by Genesys Cloud)
2. Associate the Genesys Cloud partner event source with an event bus.
3. Create a rule to be triggered on incoming messages.
4. Create a rule target(s) that will be sent the message if the message matches.

This is illustrated in the diagram below:

![EventBridge Implementation](eventbridge_implementation.png " EventBridge Implementation")

To set up this example, we use **CX as Code** and the Hashicorp AWS Provider to install all of the configurations for this example. We walk through each of the major **CX as Code** and Hashicorp AWS provider components of this integration. For conciseness, I am not going to show the entire [main.tf](main.tf) file or the example [dev.auto.tfvars](dev.auto.tfvars) file that sets the environment variables for the Terraform script. 

### Setting up the Genesys Cloud AWS EventBridge integration
The first thing that needs to be done is to create the Genesys Cloud AWS EventBridge integration. You can use the **CX as Code** [genesyscloud_integration (Resource)](https://registry.terraform.io/providers/MyPureCloud/genesyscloud/latest/docs/resources/integration "Goes to the genesyscloud_integration (Resource) page") on the Terraform website. However, the `genesyscloud_integration` is a general-purpose resource for setting up any Genesys Cloud integration. Each integration requires specialized meta-data that is not always clearly documented. To simplify this for creating an AWS EventBridge integration, we have wrapped this setup using a Terraform remote module stored in the [Genesys Cloud DevOps repository](git::https://github.com/GenesysCloudDevOps/aws-event-bridge-module.git?ref=main "Goes to Genesys Cloud DevOps repository") in GitHub. The configuration for Genesys Cloud EventBridge remote module is shown below:

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

### Create the Cloudwatch Log group
Next, we must create the Cloudwatch log watch group to hold the Genesys Cloud audit events passed to the AWS EventBridge. To create this log group, we use the [AWS provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs "Goes to the AWS Provider page") on the Terraform website.

```
resource "aws_cloudwatch_log_group" "audit_log_events" {
  name = "/aws/events/genesyscloud_audit_log_events"
}
```

### Create the Event bus
The creation of a Genesys Cloud EventBridge integration creates an AWS partner event source in your AWS account. Remember, though; we need to associate a partner event source with an event bus. We will first look up the event source that Genesys Cloud created.

```
data "aws_cloudwatch_event_source" "genesys_event_bridge" {
  depends_on = [
    module.AwsEventBridgeIntegration
  ]
  name_prefix = "aws.partner/genesys.com"
}
```

:::{"alert":"warning","title":"Beware the single bus","autoCollapse":false}
The above Terraform data lookup uses a `name_prefix` to look up the event source. The above example looks for an event source that begins with `aws.partner/genesys.com`. If you have more than one Genesys Cloud EventBridge integration defined, the above code pulls back more than one definition and fail. Multiple Genesys Cloud EventBridge integrations must use the fully qualified name in the `event_source` field. (e.g. aws.partner/genesys.com/cloud/<<Genesys Cloud Organization Id>>/<<Event Source Suffix>>)
:::

Once the partner event source is located, it can be used to create the event bus. The Terraform snippet demonstrates this below.

```
resource "aws_cloudwatch_event_bus" "genesys_audit_event_bridge" {
  name              = data.aws_cloudwatch_event_source.genesys_event_bridge.name
  event_source_name = data.aws_cloudwatch_event_source.genesys_event_bridge.name
}
```

### Creating the Event bus rules and targets
Once the event bus is created, we can create a rule to process audit events. This is where AWS EventBridge's filtering rules is applied to match or exclude messages passed from Genesys Cloud to AWS. Below is the Terraform resource definition that creates the EventBridge rule.

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

Once created, you can associate one or more targets that process the message passed into the event bus. The resource below creates an event target that passes the message to an AWS Cloudwatch log group.

```
resource "aws_cloudwatch_event_target" "audit_rule" {  
  rule      = aws_cloudwatch_event_rule.audit_events_rule.name
  target_id = "SendToCloudWatch"
  arn       = aws_cloudwatch_log_group.audit_log_events.arn
  event_bus_name = data.aws_cloudwatch_event_source.genesys_event_bridge.name
}
```

## Final thoughts
The Genesys Cloud/AWS EventBridge integration offers a new and powerful tool for integrating Genesys Cloud with other internal applications and SaaS platforms. The tool allows you to build resilient and scalable backend integrations without dealing with many low-level complexities using the Genesys Cloud Notification service and a WebSocket. Furthermore, when you use **CX as Code** and Terraform, you easily automate the configuration and configuration of Genesys Cloud and AWS EventBridge into a simple, declarative format that can be quickly processed with a CI/CD pipeline.

## Additional resources
1. [Amazon EventBridge Documentation](https://docs.aws.amazon.com/eventbridge/?id=docs_gateway "Goes to Amazon EventBridge Documentation page") on the AWS website
2. [About the Amazon EventBridge integration](https://help.mypurecloud.com/articles/about-the-amazon-eventbridge-integration/ "Goes to the About the Amazon EventBridge integration page") in the Genesys Cloud Resource Center
3. [Genesys Cloud/AWS EventBridge Technical Notes](/notificationsalerts/notifications/event-bridge)
4. [Genesys Cloud EventBridge topics](/notificationsalerts/notifications/available-topics)
5. [Genesys Cloud CX as Code](https://developer.genesys.cloud/devapps/cx-as-code/ "Goes to the Genesys Cloud CX as Code page") in the Genesys Cloud Developer Center
6. [Genesys Cloud Remote Modules](https://github.com/GenesysCloudDevOps)
7. [Genesys Cloud EventBridge remote module](https://github.com/GenesysCloudDevOps/aws-event-bridge-module)
8. [Introducing the Genesys Cloud AWS EventBridge Integration](https://www.youtube.com/watch?v=1uqEUpFtk8Q "Goes to the DevDrop 15: Introducing the Genesys Cloud AWS EventBridge Integration video") in YouTube.
9. [Video - How To Get Started With Amazon EventBridge](https://www.youtube.com/watch?v=ea9SCYDJIm4 "Goes to How To Get Started With Amazon EventBridge video") in YouTube.
10. [Blueprint - AWS EventBridge - Create a PagerDuty incident in response to OAuth client deletes](https://developer.genesys.cloud/blueprints/aws-eventbridge-oauth-client-delete-blueprint/ "Goes to the AWS EventBridge - Create a PagerDuty incident in response to OAuth client deletes page") in the Genesys Cloud Developer Center
11. [Blueprint - AWS EventBridge - Write user presence updates to DynamoDB](https://developer.genesys.cloud/blueprints/aws-eventbridge-user-presence-update-blueprint/ "Goes to the AWS EventBridge - Write user presence updates to DynamoDB page") in the Genesys Cloud Developer Center