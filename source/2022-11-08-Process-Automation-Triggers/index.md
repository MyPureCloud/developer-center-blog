---
Title: Process Automation Triggers
tags: Genesys Cloud, Developer Engagement, Triggers
date: 2022-11-08
author: tyler.bath
category: 6
---

Many customers ask us to do things regarding system events. For example, ensuring that attributes on a call always make it to an external system even if the customer abandons the conversation at an unanticipated time. Process automation allows customers to replace logic throughout the IVR with a single process automation trigger. 

## What is a trigger?

Process automation is a service that allows you to invoke workflows based on Genesys Cloud events. This post introduces services and how to configure triggers using the associated API endpoints [APIExplorer](https://developer.genesys.cloud/devapps/api-explorer#get-api-v2-processautomation-triggers "API Explorer page") in the Genesys Cloud Developer Center.


Triggers allow you to define what circumstances you can invoke workflows.

For the latest overview on Triggers, see [Triggers overview](https://developer.genesys.cloud/platform/process-automation/ "Goes to the Triggers overview page") in the Genesys Cloud Developer Center.

Triggers consist of three parts: 

1. Event type (topicName)
2. Invoke workflow (target)
3. Using conditions to filter events with (matchCriteria).

## Create a trigger

To create a trigger - run a POST request against /api/v2/processautomation/triggers that supply a body (for example,
the UI [APIExplorer]( https://developer.genesys.cloud/devapps/api-explorer#post-api-v2-processautomation-triggers "API Explorer page") in the Genesys Cloud Developer Center.

```json
{
    "topicName":"v2.detail.events.conversation.{id}.customer.end",
    "name": "Send SMS message after chats with odd disconnects",
    "description": "When a chat conversation with a customer has ended in error or a transfer, invoke 'send SMS for chat disconnect' workflow",
    "target":{
        "id": "b008976c-e085-43b7-b27d-9c0efd5fbfb5",
        "type": "Workflow"
    },
    "matchCriteria": [
        {
            "jsonPath": "mediaType",
            "operator": "Equal",
            "value": "CHAT"
        },
        {
            "jsonPath": "disconnectType",
            "operator": "In",
            "values": ["ERROR","TRANSFER"]
        }
    ],
    "eventTTLSeconds": "120",
    "enabled": true
}
```
## Json fields

* topicName: The topic the trigger should listen to from the list of available topics for process automation, which is found [here]( https://developer.genesys.cloud/notificationsalerts/notifications/available-topics "Available topics page") in the Genesys Cloud Developer Center.

:::primary
**Note**: Make sure you apply the process automation filter check box. Topic names must include the wildcard {id} and cannot be replaced with an actual id.
:::

* name: Trigger name.

* description (optional): The trigger description

* target id: This workflow id invokes when the criteria successfully match. The workflow id can be retrieved from the URL in the workflow UI.

The diagram illustrates the UI with the highlighted workflow ID from the URL.

![Example of Workflow ID](Example_workflow_ID.png "Example of Workflow ID")

* type: The target type to invoke. Currently, workflow is the only possibility.

* matchCriteria (optional): These filter the events to those that interest you. These criteria run against the event body. The event bodies schema for each topic can be found [here](https://developer.genesys.cloud/notificationsalerts/notifications/available-topics "Available topics page") in the Genesys Cloud Developer Center.

* jsonPath: Defines how to parse the JSON documents, that is the event payload as defined by the topic, and find the specific elements. Express the condition using JsonPath, the language used to traverse and parse JSON documents, to find specific elements. You can also use the Jayway JsonPath Evaluator, the JSONPath test utility tool, to check the response for your JSON payload and JSONPath statements.

* operator: Defines the comparison type that is used to filter the jsonPath output with the user-defined value. Refer the table for supported operators for filter.

* value or values: Value for comparison. As shown above, a "value" or "values" field should be set in the two-match criteria based on the operator type. For example, 'Equal' would expect a 'value' while 'In' would expect a list in the 'values' field.

* eventTTLSeconds (optional): Triggers are typically processed in a few seconds. Event processing can be delayed due to rate limiting or infrastructure issues, and this field allows you to discard events if they are no longer useful. For example, you only want to send an SMS to a customer within two minutes of disconnecting.

*  enabled: Controls whether the trigger is evaluated for real events. You can test your trigger while it is disabled or disable a false trigger.

## Testing triggers

When you create a trigger, you may want to check different event bodies to see that your trigger invokes your expected target for the correct cases. You can accomplish this by running any created trigger against the testing endpoint.

To test a trigger, run a POST request against /api/v2/processautomation/triggers/{id}/test where the {id} is replaced with the id of the trigger you would like to test.

The POST has to include a body that matches the schema of the configured topicName.

A third-party tool that might help create sample bodies from the schema is: 
[JSON Schema Faker]( https://json-schema-faker.js.org/ 
"JSON Schema Faker page") on the JSON Schema Faker website.

The following example is for a "v2.detail.events.conversation.{id}.customer.end" topic.

```json
{
  "eventTime": 10000,
  "conversationId": "conversationId",
  "participantId": "participantId",
  "sessionId": "sessionId",
  "disconnectType": "ERROR",
  "mediaType": "CHAT",
  "externalOrganizationId": "externalOrganizationId",
  "externalContactId": "externalContactId",
  "provider": "provider",
  "direction": "INBOUND",
  "ani": "ani",
  "dnis": "dnis",
  "addressTo": "addressTo",
  "addressFrom": "addressFrom",
  "callbackUserName": "callbackUserName",
  "callbackNumbers": [
    "8675309",
    "5882300"
  ],
  "callbackScheduledTime": 20000,
  "subject": "subject",
  "messageType": "SMS",
  "interactingDurationMs": 500
}

Example of the response from the test endpoint:

{
    "schemaValidation": {
        "name": "Validate test event body against topic schema",
        "step": 1,
        "matches": true
    },
    "targetValidation": {
        "name": "Verify that trigger target is configured correctly",
        "step": 2,
        "matches": true
    },
    "jsonPathValidation": {
        "name": "Check jsonPath match criteria",
        "step": 3,
        "matches": true,
        "details": [
            {
                "jsonPath": "mediaType",
                "operator": "Equal",
                "value": "CHAT",
                "generatedJsonPathCondition": "mediaType",
                "match": true,
                "jsonPathExtraction": [
                    {
                        "value": "CHAT",
                        "path": "$['mediaType']"
                    }
                ]
            },
            {
                "jsonPath": "disconnectType",
                "operator": "In",
                "values": ["ERROR", "TRANSFER"],
                "generatedJsonPathCondition": "disconnectType",
                "match": true,
                "jsonPathExtraction": [
                    {
                        "value": "ERROR",
                        "path": "$['disconnectType']"
                    }
                ]
            }
        ]
    },
    "triggerMatches": true
}
```
## Response fields

* SchemaValidation: This shows if the body provided in the request was valid for the topic and, if not, will show an error message for what is incorrectly configured.

* targetValidation: This shows whether the provided targetId is valid. This verifies that the workflow exists and is active.

* jsonPathValidation: This shows the results of evaluating each match criteria.

* triggerMatches: This indicates whether the event would have caused the trigger to fire.

Using the information in this response should help ensure that your trigger fires for your scheduled events. 

## Additional factors

When a workflow is executed, only the top-level non-complex attributes on the event are available as input variables to the workflow. So, for the test mode example above, the "callbackNumbers" field would not be provided to the workflow as input as it is a complex array object.
Triggers are updated by running a PUT against the /api/v2/processautomation/triggers/{id} route using the same body as a create request.
The topicName cannot be updated; instead, a new trigger is created, and the old trigger deleted.

## Use trigger examples

 * [Use triggers to process participant attributes](https://github.com/GenesysCloudBlueprints/process-participant-attributes-event-triggers-blueprint "Goes to the Use triggers to process participant attributes repository") in GitHub.

* [Implement an automated SMS message when a callback is not answered](https://github.com/GenesysCloudBlueprints/sms-followup-on-missed-callback-blueprint "Goes to the Implement an automated SMS message when a callback is not answered repository") in GitHub.

## Additional Resources

* [Triggers overview](https://developer.genesys.cloud/platform/process-automation/)
* [Example of a Trigger](https://developer.genesys.cloud/platform/process-automation/example-trigger)