---
title: New fully generated CLI released
tags: Genesys Cloud, Developer Engagement, SDK, API, CLI
date: 2021-06-04
author: ronan.watkins
category: 6
---

We have been listening to feedback on our CLI and decided to change the CLI generation process. This new version is fully auto-generated and contains all API resources. With this new generation process, new APIs will be automatically added as they are deployed, just like with our SDKs.  

## Installing and Upgrading

The fully generated is available as of version `v13.0.0`. See the [CLI page](/api/rest/command-line-interface/) for information on how to download, or upgrade if you are an existing user.  

These changes mean that some existing CLI commands will change. For example, `gc queues` will become `gc routing queues`. The command structure is directly related to the API path, thus removing the guess-work from finding API methods.  

## Auto-completion

We have recently added auto-completion support for all major terminals in acknowledgement of the depth of some commands. Instructions for enabling auto-completion can be found on the [README](https://github.com/MyPureCloud/platform-client-sdk-cli#autocompletion).  

## Quick Hits

The [quick hits](https://github.com/MyPureCloud/quick-hits-cli) repo has been updated to have all examples match the new command structure.  

## Feedback

If you have any feedback or issues with the CLI, please reach out to us on the [developer forum](/forum).