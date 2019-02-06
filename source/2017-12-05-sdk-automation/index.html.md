---
title: Platform API SDK Automation
date: 2017-12-05
tags: platform, api, sdk, automation, build, process, how we do it
author: tim.j.smith@genesys.com
---


The PureCloud Platform API has official SDKs for JavaScript, Java/Android, .NET, Python, and Ruby. The SDKs are dynamically generated from the API's definition each time the Platform API is deployed. After each build, the SDKs are published to package managers appropriate per language. The entire process is automated from end-to-end and is also available as an open source project to enable manual and custom builds. 


## Resources

* [platform-client-sdk-common](https://github.com/MyPureCloud/platform-client-sdk-common) build scripts
* [swagger-codegen](https://github.com/MyPureCloud/swagger-codegen) fork with PureCloud "languages"
* [SDK documentation](https://developer.mypurecloud.com/api/rest/client-libraries/)


## Overview

The SDK build process begins with a Platform API deployment to production. After the API's automated tests pass for the production deployment, the SDK build job is initiated. The build process first retrieves the [API's swagger definition](https://api.mypurecloud.com/api/v2/docs/swagger). The swagger file is diffed with the swagger file that was last used to build the SDK. This diff generates the SDK's changelog by identifying major, minor, and point changes to the API's schema. After the diff has been completed, swagger-codegen is executed to generate the source code and documentation for the SDK. The source code is then compiled, checked in to its Github repo, then deployed to the package manager.


## Build Process

The build process is divided into three distinct stages: pre-build, build, and post-build. Each stage allows both pre-run and post-run scripts to be configured and run.


### Stage: pre-build

The pre-build stage executes setup tasks to ensure everything is in order to build the SDK. These tasks include:

* Executing pre-build pre-run scripts
* Cloning the SDK's source code repo (to get the current swagger and version info)
* Diffing the old and new swagger files
* Adding models for real-time notification messages
* Setting the SDK's version
* Generating release notes
* Executing pre-build post-run scripts


### Stage: build

After all pre-build tasks have completed, the build process will be initiated. This stage includes these tasks:

* Executing build pre-run scripts
* Generating SDK source code and documentation using swagger-codegen
* Executing build compile scripts
* Packaging documentation for deployment to the dev center
* Executing build post-run scripts


### Stage: post-build

The post-build stage executes the final tasks for the build process. These tasks include:

* Executing post-build pre-run scripts
* Commit new source code and documentation to repo
* Tag repo commit as new release
* Executing post-build post-run scripts


## Build Process Details

### Config Files

Each SDK's build process is controlled by a configuration file. Before any of the build stages begin (even before the pre-build pre-run scripts), the SDK builder script loads the requested configuration files. The local config file is intended to provide sensitive information (e.g. passwords for deploying to package managers) as well as any one-off build configuration changes. This allows the main config file to contain all of the standard configuration and the local file can tweak that config.

Once the config files have been loaded, the configuration is dereferenced to resolve any JSON pointers. The config file is then analyzed to ensure that required settings have been set. Next, the environment variables defined in the config file are loaded into memory, then the config file is processed again to resolve any references to environment variables. Once this process is complete, the config file is ready to be used by the build process.

For more information on config files, see the article on the wiki: [Config Files](https://github.com/MyPureCloud/platform-client-sdk-common/wiki/Config-Files).


### Swagger Diff and Versioning

The old and new swagger files are diffed using the [swaggerDiff.js](https://github.com/MyPureCloud/platform-client-sdk-common/blob/master/modules/swaggerDiff.js) module. This process crawls through every API operation and model to check for added, removed, and changed configurations. Each detected change is classified as:

| Change level | Description |
| :------------- | :------------- |
| major | breaking change |
| minor | forward-compatible addition |
| point | non-functional change, i.e. documentation |
{: class="table table-striped"}

Using the diff data, the SDK's version is incremented according to [semantic versioning](https://semver.org/) standards. 


### swagger-codegen

The [MyPureCloud/swagger-codegen](https://github.com/MyPureCloud/swagger-codegen) project was forked from [swagger-api/swagger-codegen](https://github.com/swagger-api/swagger-codegen). Utilizing a fork of this project allows the language generators to be customized to meet the specific needs of the PureCloud Platform API SDKs. The [SDK "languages"](https://github.com/MyPureCloud/swagger-codegen/tree/master/modules/swagger-codegen/src/main/java/io/swagger/codegen/languages) can be found in the _PureCloud*ClientCodegen.java_ language files. These files contain the fixes, changes, and overrides needed to correctly generate the source code from the Platform API's swagger definition.

The MyPureCloud/swagger-codegen fork is maintained solely for the purposes of maintaining the PureCloud SDKs. It was found that undesirable, low quality, and breaking changes were introduced on a regular basis, which had a negative impact on the stability of the SDKs. For this reason, the fork is intentionally not kept up to date with the parent repo; changes are pulled down only as needed for bugfixes and desirable new features.


### Templates

The SDK source code is generated by using the data in the swagger file to populate handlebars templates. The base templates can be found in [swagger-codegen's resources](https://github.com/MyPureCloud/swagger-codegen/tree/master/modules/swagger-codegen/src/main/resources), but are not modified there. All changes to templates are made in external template files that override the built-in ones. The template override files can be found [in the common repo](https://github.com/MyPureCloud/platform-client-sdk-common/tree/master/resources/sdk).


### Package Managers

Each SDK is deployed to a popular package manager appropriate for the language. The following packages are deployed when the SDKs are built:

| SDK Language | Package Manager | Package |
| :----------- | :-------------- | :------ |
| Java | Maven Central | [platform-client-v2](https://search.maven.org/#search%7Cgav%7C1%7Cg%3A%22com.mypurecloud%22%20AND%20a%3A%22platform-client-v2%22) |
| JavaScript | NPM | [purecloud-platform-client-v2](https://www.npmjs.com/package/purecloud-platform-client-v2) |
| JavaScript | Bower | purecloud-platform-client-v2 |
| .NET | nuget | [PureCloudPlatform.Client.V2](https://www.nuget.org/packages/PureCloudPlatform.Client.V2/) |
| Ruby | Ruby Gems | [purecloudplatformclientv2](https://rubygems.org/gems/purecloudplatformclientv2) |
| Python | Python Package Index | [PureCloudPlatformClientV2](https://pypi.python.org/pypi/PureCloudPlatformClientV2) |
{: class="table table-striped"}


### Building the SDKs Locally

To [build the SDKs locally](https://github.com/MyPureCloud/platform-client-sdk-common/wiki/Building-Locally), simply clone swagger-codegen and platform-client-sdk-common, build swagger-codegen, edit/create appropriate [config files](https://github.com/MyPureCloud/platform-client-sdk-common/wiki/Config-Files), and run `sdkBuilder.js --sdk {language}` in the platform-client-sdk-common directory. 


## SDK Maintenance

### Bugs and Issues

Issues found with the SDK may be reported via Github issues or preferably on the [Developer Forum](https://developer.mypurecloud.com/forum/). All issues will be recorded and tracked in Genesys' private Jira instance. When an issue is resolved, it will generally be included in the SDK's release notes on Github.


### Enhancements

Enhancements may be requested via the [Developer Forum](https://developer.mypurecloud.com/forum/). Enhancement requests will be considered and prioritized along with other work for the Platform API. Enhancements will generally be included in the SDK's release notes on Github.

### Pull Requests

Pull requests for changes to the SDKs are generally accepted if they meet the following criteria:

* Must be submitted to the [platform-client-sdk-common](https://github.com/MyPureCloud/platform-client-sdk-common) repo. The SDK source code repos contain only generated code and therefore do not accept PRs. Changes may only be made to the generator templates.
* Must not attempt to override contracts/models/request schemas for API resources; changes to API resources must be made upstream in the API itself and trickle down to the SDKs via swagger.
* Must add functionality that is generally useful to the SDK user community. Use case specific changes should be made in an unpublished local build.

To discuss a potential pull request submission, create a post on the [Developer Forum](https://developer.mypurecloud.com/forum/) to discuss it.
