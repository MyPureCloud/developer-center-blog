---
title: Adding features to the Genesys Cloud SDKs
tags: Genesys Cloud, Developer Engagement, SDK, API
date: 2021-02-25
author: ronan.watkins
category: 6
---

Genesys offers Software Development Kits (SDKs) for all major programming languages. These SDKs wrap the REST calls to the Genesys Cloud API in a simple to use interface. The SDKs are generated against the public API Swagger definition. From time to time, bugs show up and people find use cases that the SDKs don't meet. 
We take feature requests and bug reports for the SDKs through the [GitHub issues](https://github.com/purecloudlabs/platform-client-sdk-common/issues) and the [Developer Forum](https://developer.mypurecloud.com/forum) but with lots of projects underway, it can take us a little time to getting around to implementing them so usually the quickest way to make changes is doing it yourself, this is one of the reasons that we open sourced our SDK generation.

## Repositories

There are two repositories involved in the generation of our SDKs. They include:

* [platform-client-sdk-common](https://github.com/MyPureCloud/platform-client-sdk-common)
* [swagger-codegen](https://github.com/MyPureCloud/swagger-codegen)

### swagger-codegen

swagger-codegen generates a JAR file with all the logic for generating Client SDKs using the API definition and mustache template files. We have forked this repo from [swagger-api/swagger-codegen](https://github.com/swagger-api/swagger-codegen). The reason for this is utilizing a fork of this project allows the language generators to be customized to meet the specific needs of the PureCloud Platform API SDKs. The [PureCloud SDK "languages"](https://github.com/MyPureCloud/swagger-codegen/tree/master/modules/swagger-codegen/src/main/java/io/swagger/codegen/languages) can be found in the _PureCloud*ClientCodegen.java_ language files.

### platform-client-sdk-common

The platform-client-sdk-common project is a consumer of this JAR and provides the templates, scripts and extensions for the SDKs. It also contains scripts for building and publishing the SDKs and diffing newly released swagger schemas to determine if new SDKs should be built and if so, what has changed and increment the version numbers appropriately.
For the vast majority of bug fixes and enhancements, this is where the changes are added.

## Contributing

To get started with contributing to the SDKs, firstly follow the instructions on [building the SDKs locally](https://github.com/MyPureCloud/platform-client-sdk-common/wiki/Building-Locally), simply clone swagger-codegen and platform-client-sdk-common, build swagger-codegen, edit/create appropriate [config files](https://github.com/MyPureCloud/platform-client-sdk-common/wiki/Config-Files), and run `sdkBuilder.js --sdk {language}` in the platform-client-sdk-common directory.

This [Developer Drop](https://youtu.be/NqaIykM7r30) on adding features to the SDKs has been created as a visual guide on how to contribute. In this video, I start off by cloning swagger-codegen and platform-sdk-client-common and setting them up with the necessary config. I then add a simple feature to the Go SDK and test it with a local SDK client. Finally, I push the changes to GitHub and create a pull request.