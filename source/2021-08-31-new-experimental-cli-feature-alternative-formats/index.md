---
title: New Experimental CLI Feature: Alternative Formats
date: 2021-08-26
tags: cli, developer engagement, experimental, alternative formats, YAML, JSON
author: michael.roddy
image: ./blog-img.png
category: 6
---

Hi everyone! I am excited to introduce a new experimental CLI feature: Alternative Formats. But before we begin, what are experimental CLI features? Experimental CLI features are features that are still being tested or under development and are subject to breaking and non-breaking changes at any time. Also, as these are experimental features, they may be removed form the CLI or changed at any time. With that said, introducing Alternative Formats! The new experimental feature will allow you to send and receive data as an alternative format to JSON. Currently this feature supports YAML and in this blog post I am going to demonstrate how you can use Alternative Formats in the CLI.


## List, Enable and Disable Experimental Features

To see a list of experimental features:  

```
gc experimental list
```

To enable an experimental feature:  

```
gc experimental enable [feature_name]
```

To disable an experimental feature:  

```
gc experimental disable [feature_name]
```

## Using Alternative Formats

To use the Alternative Formats feature we can pass a supported value (e.g `YAML` or `JSON`) to the `--inputformat` flag or to the `--outputformat` flag.

To input `YAML` data:

```
--inputformat=yaml
```

To output `YAML` data:

```
--outputformat=yaml
```

**Note:** The `--inputformat` and `--outputformat` flags are not case sensitive. Writing `--inputformat=yaml` is the same as writing `--inputformat=YAML`.

**Note:** If you do not pass a value to the `--inputformat` flag or to the `--outputformat` flag their value will default to `JSON`.

## Input Format

If you want to input a `YAML` file when making a request, simply include the `--inputformat=yaml` command and pass the file to the `--file` flag.

**Example Query:**

`query.yaml`

```yaml
---
interval: 2021-07-13T23:00:00.000Z/2021-07-19T23:00:00.000Z
order: asc
orderBy: conversationStart
paging:
  pageSize: 25
  pageNumber: 1
```

**Example Request:**  

```
gc analytics conversations details query create --file=./query.yaml --inputformat=yaml
```

**Example Response:**

As we did not specify the output format, the response will be in `JSON` format.

```json
{
  "conversations": [
    {
      "conversationEnd": "2021-07-15T02:17:42.787Z",
      "conversationId": "b58e069b-ea04-4219-98ad-43de79e6dba3",
      "conversationStart": "2021-07-14T16:17:13.638Z",
      "divisionIds": ["cd28af1e-bfd8-4e24-aed1-075343054946"],
      "originatingDirection": "inbound",
      "participants": [
        {
          "participantId": "6c401d04-e997-40d3-9d81-4cb3308c2f93",
          "participantName": "Customer",
          "purpose": "customer",
          "sessions": [
            {
              "direction": "inbound",
              "mediaType": "chat",
              "provider": "PureCloud Webchat v2",
              "requestedRoutings": ["Standard"],
              "sessionId": "243fed6e-acbd-4bda-8c1e-a0a0177953aa",
              "metrics": [
                {
                  "emitDate": "2021-07-14T16:17:13.638Z",
                  "name": "nConnected",
                  "value": 1
                }
              ],
        
        response continues...
}
```
	      
## Output Format

If you want to format your response as `YAML`, simply include the `--outputformat=yaml` command.

**Example Request:**  

```
gc users get f3dc94ca-acec-4ee4-a07e-ca7503ddbd62 --outputformat=yaml
```

**Example Response:**

```yaml
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
```

## Thanks for Reading

If you have any feedback or issues, please feel free to reach out to us on the [developer forum](https://developer.genesys.cloud/forum/).