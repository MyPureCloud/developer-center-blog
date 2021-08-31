---
title: New Experimental CLI Feature: Alternative Formats
date: 2021-08-26
tags: cli, developer engagement, experimental, alternative formats, YAML, JSON
author: michael.roddy
image: ./blog-img.png
category: 6
---

Hi everyone! I am excited to introduce a new experimental CLI feature: Alternative Formats. This new feature will allow you to send and receice data as an alternative format to JSON. Currently this feature supports YAML and in this blog post, I am going to demonstrate how you can use the new experimental feature in the CLI.


## List, Enable and Disable Experimental Features

To see a list of experimental features:  

`gc experimental list`

To enable an experimental feature:  

`gc experimental enable [feature_name]`

To disable an experimental feature:  

`gc experimental disable [feature_name]`

## Using Alternative Formats

To use the Alternative Formats feature we can pass a supported value (e.g YAML or JSON) to the `--inputformat` flag or to the `--outputformat` flag.

To display a request response as YAML simply include the `--outputformat=yaml` command.

Example Request:  

`gc users get f3dc94ca-acec-4ee4-a07e-ca7503ddbd62 --outputformat=yaml`

Example Output:

	acdAutoAnswer: false
	addresses: []
	chat:
	  jabberId: pq48dc149a7cb@genorg.orgspan.com
	division:
	  id: 79449497-d98a-4f8e-9abe-9893480f320c
	  name: ""
	  selfUri: /api/v2/authorization/divisions/79449497-d98a-4f8e-9abe-9893480f320c
	email: john.doe@genesys.com
	id: b061702d-7dc2-4743-997e-63be4a3267e1
	name: John Doe
	primaryContactInfo:
	- address: john.doe@genesys.com
	  mediaType: EMAIL
	  type: PRIMARY
	selfUri: /api/v2/users/b061702d-7dc2-4743-997e-63be4a3267e1
	state: active
	username: john.doe@genesys.com
	version: 2


If you want to input a YAML file when making a request, simply include the `--inputformat=yaml` command and pass the file to the `--file` flag.

Example Query:

query.yaml

	---
	interval: 2021-07-13T23:00:00.000Z/2021-07-19T23:00:00.000Z
	order: asc
	orderBy: conversationStart
	paging:
	  pageSize: 25
	  pageNumber: 1

Example Request:  

`gc analytics conversations details query create --file=./query.yaml --inputformat=yaml --outputformat=yaml`

Example Response:

	conversations:
	- conversationEnd: "2021-07-15T02:17:42.787Z"
	  conversationId: 2d3db0b9-c9c1-43f3-9d4f-0c2c20fb2bb4
	  conversationStart: "2021-07-14T16:17:13.638Z"
	  divisionIds:
	  - 12534f14-a63a-421f-a9de-25c8f8b614d5
	  originatingDirection: inbound
	  participants:
	  - participantId: 12534f14-a63a-421f-a9de-25c8f8b614d5
	    participantName: Customer
	    purpose: customer
	    sessions:
	    - direction: inbound
	      mediaType: chat
	      metrics:
	      - emitDate: "2021-07-14T16:17:13.638Z"
	        name: nConnected
	        value: 1
	      provider: PureCloud Webchat v2
	      requestedRoutings:
	      - Standard
	      segments:
	      - conference: false
	        disconnectType: timeout
	        queueId: 12534f14-a63a-421f-a9de-25c8f8b614d5
	        segmentEnd: "2021-07-15T02:17:42.785Z"
	        segmentStart: "2021-07-14T16:17:13.638Z"
	        segmentType: interact
	      sessionId: 12534f14-a63a-421f-a9de-25c8f8b614d5x
	      
	      response continues...

Note: If you do not pass a value to the `--inputformat` flag or to the `--outputformat` flag their value will default to JSON.

Note: As this is an experimental feature, the feature may be removed or changed at any time.