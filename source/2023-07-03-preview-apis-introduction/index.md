---
title: Introducing the Preview APIs to the Genesys Cloud SDK and CLI
tags: Genesys Cloud, Developer Engagement, CLI
date: 2023-07-03
author: declan.ginty
category: 6
---

Greetings everyone! In this blog, I'm going to introduce the preview APIs, which have been added to our [GO SDK (v103.0.0 & greater)](https://developer.genesys.cloud/devapps/sdk/go), [Java SDK (v179.0.0 & greater)](https://developer.genesys.cloud/devapps/sdk/java), [Javascript SDK (v170.0.0 & greater)](https://developer.genesys.cloud/devapps/sdk/javascript), [Python SDK (v174.0.0 & greater)](https://developer.genesys.cloud/devapps/sdk/python), [.NET SDK (v177.0.0 & greater)](https://developer.genesys.cloud/devapps/sdk/dotnet) and [CLI tool (v70.0.0 & greater)](https://developer.genesys.cloud/devapps/cli/).

With the preview APIs, the SDKs and CLI will have access to a wider range of classes, methods and functionality. The full list of endpoints now available can be seen [here](https://developer.genesys.cloud/platform/preview-apis). The addition of these preview APIs will not affect the current behaviour of any of the SDKs and will only enhance them to provide more functionality.

For questions, comments, concerns, or help with these APIs, SDKs or CLI, please post on the [Genesys Cloud Developer Forum](https://developer.genesys.cloud/forum/).

## Usage
Usage of a preview method is no different to the usage of a regular method in the SDKs and CLI. Below is an example usage of a preview API using the Javascript SDK.

[POST /api/v2/taskmanagement/workitems](https://developer.genesys.cloud/platform/preview-apis#post-api-v2-taskmanagement-workitems)

```
const platformClient = require("purecloud-platform-client-v2");

const client = platformClient.ApiClient.instance;
client.setEnvironment(platformClient.PureCloudRegionHosts.us_east_1); // Genesys Cloud region

// Manually set auth token or use loginImplicitGrant(...) or loginClientCredentialsGrant(...)
client.setAccessToken("your_access_token");

let apiInstance = new platformClient.TaskManagementApi();

let body = {}; // Object | Workitem

// Create a workitem
apiInstance.postTaskmanagementWorkitems(body)
  .then((data) => {
    console.log(`postTaskmanagementWorkitems success! data: ${JSON.stringify(data, null, 2)}`);
  })
  .catch((err) => {
    console.log("There was a failure calling postTaskmanagementWorkitems");
    console.error(err);
  });
```

## Limited Access and Breaking Changes
**Warning** The Preview API resources are available in a limited capacity as a preview of resources that are intended to be released publicly at some point in the future. Access to these resources is often restricted by feature toggles enabled on a per-org basis. Preview APIs are subject to both breaking and non-breaking changes at any time without notice. This includes, but is not limited to, changing resource names, paths, contracts, documentation, and removing resources entirely.

All preview methods will be marked in the documentation and source code as preview. Ensure you are aware of any preview methods you are using to be ready in the event of changes to the method. 

## Closing thoughts
While a helpful addition to the Genesys Cloud SDK and CLI, the preview APIs can cause problems if not used correctly so ensure to use them wisely.

Thanks for reading!

## Additional resources 
1. [Genesys Cloud CLI](/devapps/cli/)
2. [Genesys Cloud SDK](https://developer.genesys.cloud/devapps/sdk/)