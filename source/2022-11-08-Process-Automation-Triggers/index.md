We have had many customers ask us to be able to do things in response to events in the system. For example, ensuring that attributes on a call always make it to an external system even if the customer abandons the conversation at an unanticipated time. Process automation allows customers to replace logic throughout the IVR with a single process automation Trigger. 


Related Developer Center overview of triggers: https://developer.genesys.cloud/platform/process-automation/


Process automation is a service that will allow you to invoke workflows based on events happening in Genesys Cloud. This post is to give an introduction to the service and how to configure triggers using the associated API endpoints: https://developer.genesys.cloud/devapps/api-explorer#get-api-v2-processautomation-triggers

Triggers allow you to define under what circumstances you would like to invoke workflows.

Triggers consist of 3 main parts: the type of event (topicName), the workflow to invoke (target), and conditions to filter the events with (matchCriteria).


Creating triggers:
To create a trigger - run a POST request against /api/v2/processautomation/triggers supplying a body like an example below. UI example: https://developer.genesys.cloud/devapps/api-explorer#post-api-v2-processautomation-triggers

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



topicName - The topic the trigger should listen to from the list of available topics for processes automation, which can be found here: https://developer.genesys.cloud/notificationsalerts/notifications/available-topics (make sure to apply the process automation filter check box). The topic names must include the wildcard {id} and can not be replaced with an actual id.

name - Name of the trigger

description (optional) - A description of the trigger

target

id - The id of the workflow to invoke when the match criteria match successfully. The id of a workflow can be retrieved from the URL in the workflow UI.

Example from UI with workflow ID highlighted in URL:


type - The type of target to invoke. Currently, the only possibility is Workflow

matchCriteria (optional) - These filter events to only those you are interested in. These criteria are run against the event body. The schema for the event bodies can be found for each topic here: https://developer.genesys.cloud/notificationsalerts/notifications/available-topics

jsonPath - The json path to the field to use in the match comparison

operator - The operator used when comparing the jsonPath result to the value or values

value or values - Value for comparison. As shown in the 2 match criteria above, a "value" or "values" field should be set based on the type of operator. For example, 'Equal' would expect a 'value' while 'In' would expect a list in the 'values' field

eventTTLSeconds (optional) - Triggers are typically processed in a few seconds. Event processing can be delayed due to rate limiting or infrastructure issues, and this field allows you to discard events if they are no longer useful. For example, you only want to send an SMS to a customer within 2 minutes of a disconnect.

enabled - Controls whether the trigger is evaluated for real events. You can test your trigger while it is disabled or disable a misbehaving trigger

Testing triggers:

When creating a trigger, you may want to check different event bodies to see that your trigger will invoke your expected target for the correct cases. You can accomplish this by running any created trigger against the testing endpoint


To test a trigger, run a POST request against /api/v2/processautomation/triggers/{id}/test where the {id} is replaced with the id of the trigger you would like to test.

The POST will also have to include a body that matches the schema of the configured topicName.

An online 3rd party tool that might help create sample bodies from the schema is https://json-schema-faker.js.org/. 

The example below is for a "v2.detail.events.conversation.{id}.customer.end" topic:

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

Example response from the test endpoint:

{
    "schemaValidation": {
        "name": "Validate test event body against topic schema",
        "step": 1,
        "matches": true
    },
    "targetValidation": {
        "name": "Verify trigger target is configured correctly",
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

schemaValidation - This shows if the body provided in the request was valid for the topic and if not will show an error message for what is incorrectly configured.

targetValidation - Shows whether or not the provided targetId is valid. It will verify the workflow exists and is active.

jsonPathValidation - This shows the results of evaluating each match criteria.

triggerMatches - Indicates whether or not the event would have caused the trigger to fire.


Using the information in this response should help ensure that your trigger will fire for your scheduled events. 


Other considerations:
Currently, when we execute a workflow, only the top-level non-complex attributes on the event are available for use as input variables to the workflow. So in the above example for test mode, the "callbackNumbers" field would not be provided to the workflow as input as it is a complex array object.
Triggers are updated by running a PUT against the /api/v2/processautomation/triggers/{id} route using the same body as a create request.
TopicName cannot be updated; instead, a new trigger should be created, and the old trigger deleted.

Example uses:
Use triggers to process participant attributes - https://github.com/GenesysCloudBlueprints/process-participant-attributes-event-triggers-blueprint

Implement an automated SMS message when a callback is not answered - https://github.com/GenesysCloudBlueprints/sms-followup-on-missed-callback-blueprint