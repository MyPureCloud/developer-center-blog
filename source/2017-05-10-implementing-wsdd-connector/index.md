---
title: Implementing a Web Services Data Dip Connector
date: 2017-05-10
tags: bridge, wsdd, connector, integration
author: tim.smith
category: 6
---

The Web Services Data Dip (WSDD) connector integrates your interaction flows (voice IVRs, scripts, and future implementations) with a web service that you create that implements the web services data dip connector API. Your web service can call any third-party system that stores data, such as a customer relationship management (CRM) database. This blog post will cover implementing both standard and custom WSDD operations in a node.js web service.

## Resources

### Things you'll need

* Skillset to build and consume REST web services
* Basic knowledge of JavaScript, preferably node.js with express as well (only for the purposes of understanding the examples in this blog post)
* A PureCloud organization with the Web Services Data Dip connector enabled (if it's not enabled already, open a ticket with [PureCloud Support](https://elastictest.wpengine.com/articles/contact-purecloud-support/) and request that the  `webservices-datadip` bridge connector be enabled)
* A Windows server to host the Bridge Server - [hardware/VM specs](https://help.mypurecloud.com/articles/purecloud-bridge-server-specifications/)
* A server or cloud service to host your bridge integration web service - the requirements for this are entirely dependent on the integration you choose to build; the service is only required to conform to the REST contract for the bridge action. This service can be hosted on the same server as the Bridge Server service.

### Reading Materials

Take a look through these documentation pages to complete the necessary setup of your bridge server. This blog post is intended to supplement the existing product documentation.

* [How the WSDD connector works](https://help.mypurecloud.com/articles/how-web-services-data-dip-connector-works-web-service/)
* [Jargon you should understand](https://help.mypurecloud.com/articles/concepts-web-services-data-dip-connector/)
* [Requirements for the web services data dip connector](https://help.mypurecloud.com/articles/requirements-web-services-data-dip-connector/)
* Documentation for [setting up a web service data dip connector](https://help.mypurecloud.com/articles/set-up-web-services-data-dip-connector/):
    * [Install the Bridge Server](https://help.mypurecloud.com/articles/install-bridge-server/)
    * [Add a web services data dip connector](https://help.mypurecloud.com/articles/add-web-services-data-dip-connector/)
    * [Configure the web services data dip connector](https://help.mypurecloud.com/articles/configure-web-services-data-dip-connector/)
    * [Add bridge actions for the web services data dip connector](https://help.mypurecloud.com/articles/add-bridge-actions-web-services-data-dip-connector/)
    * [Use bridge actions in Architect for the web services data dip connector](https://help.mypurecloud.com/articles/use-bridge-actions-architect-web-services-data-dip-connector/)
* [Standard WSDD contracts](https://developer.mypurecloud.com/api/webservice-datadip/service-contracts.html)

## WSDD Implementation

I'm assuming that you have a bridge server up and running at this point with a server and connector up and running, but no actions configured. If not, go back to the reading materials above and do that now.

Let's get started building an integration!

### Architecture

First, let's make sure we're on the same page with _what_ we're building. 

When a customer is being processed through an interaction flow and hits a Bridge Action, PureCloud makes a request to your bridge server. Your bridge server's WSDD connector inspects its configuration for the requested action and executes a REST request to the action's configured endpoint. That request will be handled by the service we're about to build. The service will process the request and send a response back to the bridge server, which will return the response to the interaction flow to continue processing.

The service that implements the action is responsible for interpreting the request, interfacing with external systems (REST/SOAP web services, database queries, etc.), applying any necessary business logic, and returning a result consistent with the defined response contract for the action.

### Setting up the node app

In this example, we're building a web service using node.js and express. How you choose to implement your web service is entirely up to you; the only implementation requirements are that the service must be accessible from the bridge server and must conform to the configured request and response contracts.

#### Start the web service

The following lines of code create a service listening on port 8080 on the machine's IP address/hostname:

~~~
const app = require('express')();
const bodyParser = require('body-parser');
app.use(bodyParser.json());
var server = app.listen(8080, function () {
    // Do stuff when service is started
});
~~~

#### Implement a standard action

Once `app.listen(...)` has been executed, the web service is up and running. But with just that code, it doesn't do anything. Let's start by handling the [POST /GetContactByPhoneNumber](https://developer.mypurecloud.com/api/webservice-datadip/service-contracts.html#GetContactByPhoneNumber) request. 

This code example handles requests to the `/GetContactByPhoneNumber` path:

~~~
app.post('/GetContactByPhoneNumber', function (req, res) {
	try {
		// 1) Normalize input
		var targetPhone = normalizePhoneNumber(req.body.PhoneNumber);

		// 2) Find the requested data
		var contact = _.find(contacts, function(c) {
			if (!c) return false;

			var match = _.find(c.Contact.PhoneNumbers.PhoneNumber, function(phoneNumber) {
				var haystack = normalizePhoneNumber(phoneNumber.Number);
				return haystack === targetPhone;
			});
			return match !== undefined;
		});

		// 3) Return result
		if (contact) {
			res.status(200).send(contact);
		} else {
			res.status(404).end();
		}
	} catch (e) {
		res.status(500).send(e.message);
	}
});
~~~

First, this code retrieves the `PhoneNumber` property from the request body and removes any non-numeric characters. This normalization makes comparison of phone numbers easier so `(317) 555-1212` is equivalent to `3175551212`.

Second, logic is executed to iterate through the list of contacts to find the first contact with a matching phone number. The contact's phone number is also normailzed to the same format as the input phone number.

Finally, if a contact is found, the contact is returned with status code 200. If a contact is not found, a 404 response is returned. 

#### Implement a custom action

The code for handling a custom action is functionally equivalent to handling a standard action; both must accept the request, find data to return, and return the data in accordance with the defined response schema. Here's the function in the example that handles the `searchContactsByName` custom action. 

~~~
app.post('/searchContactsByName', function (req, res) {
	try {
		// 1) Normalize input
		var firstName = normalizeContactName(req.body.firstName);
		var lastName = normalizeContactName(req.body.lastName);
		var searchFullName = req.body.searchFullName === true;

		// 2) Find the requested data
		var contact = _.find(contacts, function(c) {
			if (!c) return false;

			var firstNameMatch = c.Contact.FirstName !== undefined && normalizeContactName(c.Contact.FirstName).includes(firstName);
			var lastNameMatch = c.Contact.LastName !== undefined && normalizeContactName(c.Contact.LastName).includes(lastName);
			var fullNameMatch = searchFullName === true && c.Contact.FirstName !== undefined && 
				(normalizeContactName(c.Contact.FullName).includes(firstName) || 
				normalizeContactName(c.Contact.FullName).includes(firstName));
			return firstNameMatch || lastNameMatch || fullNameMatch;
		});

		// 3) Return result
		if (contact) {
			res.status(200).send(contact);
		} else {
			res.status(404).end();
		}
	} catch (e) {
		res.status(500).send(e.message);
	}
});
~~~

First, this example retrieves and normalizes the first and last names from the request and a boolean value indicating whether or not the _contact_'s `FullName` property should be searched.

Next, it iterates through the contacts to find the first match based on the input criteria. The logic illustrated here is irrelevant to implementing a custom WSDD action and is only meant to serve as an example of something a custom action might do.

Finally, the contact is returned if one was found, or a 404 response is sent if no contact was found.

##### Custom action schemas

Custom actions require schemas to be defined for the request and response bodies so consumers of custom bridge actions know what to send and what to expect in the response. Here's the example request schema defining firstName, lastName, and searchFullName properties for the `searchContactsByName` custom action:

~~~
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "title": "SearchRequest",
  "description": "A search request body",
  "type": "object",
  "properties": {
    "firstName": {
      "type": "string",
      "description": "The first name for which to search"
    },
    "lastName": {
      "type": "string",
      "description": "The last name for which to search"
    },
    "searchFullName": {
      "type": "boolean",
      "description": "[true] to search in the contact's FullName field"
    }
  },
  "additionalProperties": true
}
~~~

A valid request to this service would look like this:

~~~
{
  "firstName": "Luke",
  "lastName": "Skywalker",
  "searchFullName": true
}
~~~

The `searchContactsByName` custom action utilizes the same response schema as the standard `GetContactByPhoneNumber` action. The schema definition was simply exported from the standard action and imported into the custom action.

## Final Thoughts

### A note about external data

The schema of a _contact_ in the example's data storage exactly matches the defined schema for a _contact_ returned by [POST /GetContactByPhoneNumber](https://developer.mypurecloud.com/api/webservice-datadip/service-contracts.html#GetContactByPhoneNumber), as well as the custom action. Outside of the "spherical cow in a vaccuum" example environment, this is unlikely. Most integration services will be required to transform the system of record's data model to the schema defined by the WSDD contract before sending the response. Depending on how disparate the schemas are, it may be advantageous to create a custom action that defines custom schemas that more closely match how the data is being stored.

### Schemas for standard actions

Standard request/response schemas are [documented on the dev center](https://developer.mypurecloud.com/api/webservice-datadip/service-contracts.html). To retrieve the schema defintions from standard and custom actions, look at the action details page for the action and click on the links for `Request` and `Response` schemas to download the JSON schema definitions. 

### Error handling

The integration service must determine how to handle errors as well as what response to send when data is not found. It is important to understand that error information sent in a response that's anything other than 200 will not be usable by the interaction flow consuming the action; non-200 responses will simply cause the failure condition to be taken and context for the failure will be lost.  However, there will be some infomration in the [Bridge Server logs](https://help.mypurecloud.com/articles/troubleshoot-web-services-data-dip-connector/) when the service sends non-200 responses that may be useful for troubleshooting failures. The examples take this approach of sending non-200 responses and failure is handled generically in the interaction flow.

An alternate approach is to define a custom contract with extra properties that can be evaluated to determine if the response was successful and if it contains data or not. This could be done by adding a boolean property for `hasError`, a string property for `errorMessage`, an integer property for `errorCode`, or any other failure data that you would find useful for the interaction flow consuming the action to know. An example of how to use this would be to process the successful response with a condition to check for `errorCode == 0` and take error handling actions for the caller if the condition is false.
