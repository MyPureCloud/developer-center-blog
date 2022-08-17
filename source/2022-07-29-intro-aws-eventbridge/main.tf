terraform {
  required_providers {
    genesyscloud = {
     source = "mypurecloud/genesyscloud"
    }

    aws = {
      version = ">= 3.12"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
} 

variable "aws_account_id" {
  type        = string
  description = "The target AWS account id that Genesys Cloud will install the AWS EventBridge Partner Event Source"
}

variable "aws_region" {
  type        = string
  description = "Aws region where the resources to be provisioned."
}

variable "event_bus_name" {
  type        = string
  description = "Aws region where the resources to be provisioned."
}


module "AwsEventBridgeIntegration" {
   integration_name    = var.event_bus_name
   source              = "git::https://github.com/GenesysCloudDevOps/aws-event-bridge-module.git?ref=main"
   aws_account_id      = var.aws_account_id
   aws_account_region  = var.aws_region
   event_source_suffix = var.event_bus_name
   topic_filters       = ["v2.audits.entitytype.{id}.entityid.{id}"]
}

data "aws_cloudwatch_event_source" "genesys_event_bridge" {
  depends_on = [
    module.AwsEventBridgeIntegration
  ]
  name_prefix = "aws.partner/genesys.com"
}

resource "aws_cloudwatch_event_bus" "genesys_audit_event_bridge" {
  name              = data.aws_cloudwatch_event_source.genesys_event_bridge.name
  event_source_name = data.aws_cloudwatch_event_source.genesys_event_bridge.name
}

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

resource "aws_cloudwatch_log_group" "audit_log_events" {
  name = "/aws/events/audit_log_events"
}

resource "aws_cloudwatch_event_target" "audit_rule" {  
  rule      = aws_cloudwatch_event_rule.audit_events_rule.name
  target_id = "SendToCloudWatch"
  arn       = aws_cloudwatch_log_group.audit_log_events.arn
  event_bus_name = data.aws_cloudwatch_event_source.genesys_event_bridge.name
}
