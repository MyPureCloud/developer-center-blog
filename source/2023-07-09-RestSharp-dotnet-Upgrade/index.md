---
title: RestSharp and Dotnet upgrade for .NET sdk
tags: Genesys Cloud, Developer Engagement, CLI
date: 2023-07-08
author: hemanth.dogiparthi
category: 6
---

Greetings, everyone! In this blog, I'm going to introduce some of the upgrades done for .NET sdk.
The .NET SDK is leveraging the third party RestSharp for making the API calls. This version has not been upgraded for a while in the SDK and  RestSharp.dll version 106.3.1 having a medium vulnerability.  

RestSharp got a major upgrade in v107 and greater, which contains quite a few breaking changes.

The most important  is that RestSharp stop using the legacy HttpWebRequest class, and uses well-known 'HttpClient' instead. This move solves lots of issues, like hanging connections due to improper HttpClient instance cache, updated protocols support, and many other problems. It also addressed the vulnerabilities in its previous versions.


Users planning to upgrade the .NET SDK to version 182.0.0 might encounter issues related to compatability of DLLs. Please be noted the below are the upgrades done for the SDK.

Some of the upgrades done as part of this release: 

1. .NET      v4.5    to   v4.7
2. RestSharp 106.3.1 to   110.2.0
3. Some dependencies of  System.Text.Json, System.Text.Encodings.Web, System.Threading.Tasks.Extensions added.

Some of the technical changes :

1. Configuration.Default.ApiClient.setBasePath(region);

  The BasePath will not return a RestClient instance. Since it is not necessary for the user to have a hold of RestClient instance.
  SDK will take care of the undelying REST calls.

2. IRestResponse is deprecated and RestResponse will be returned for this.Configuration.ApiClient.CallApi

  Although it doesnt impact any client who are using the repsective API classes to make the platform calls. The return of ApiResponse still holds good.
  But a call to generic CallApi will have an impact and users using the SDK need to make sure this is modified. 

Note: You need to update mono to the latest in your builds, if you want to build the SDK .NET repo in your environment.

Thanks for reading!
