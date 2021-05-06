---
title: Genesys Cloud SDK Configuration and Logging
tags: Genesys Cloud, Developer Engagement, SDK, API
date: 2021-05-06
author: ronan.watkins
category: 6
---

All of our client libraries except for Ruby and IOS have been updated to take a standardized approach to logging and configuration using a configuration file. This is the first step in an effort to add a standardized feature-set to our SDKs.  

# Configuration

**Note:** This behavior is not available in Javascript web applications.

A number of configuration parameters can be applied using a configuration file. There are two sources for this file:

* On Unix-based operating systems, the SDK will look for `$HOME/.genesyscloud[language]/config`. On Windows, the concept of a home directory varies by language implementation. Check the SDK README for the directory in a particular language.
* A configurable file path. The README for each SDK details the exact manner to set the file path.

The SDKs use an event-driven approach to monitoring for config file changes and will apply changes in near real-time, regardless of whether a config file was present at start-up. This behavior can be disabled by setting `live_reload_config` to false in the configuration file or through a boolean variable on the SDK.

INI and JSON formats are both supported. See below for examples of configuration values in both formats. Please note that not all SDKs have support for retry logic and re-authentication. Re-authentication only applies to Code Authorization Grants.  

Not all configuration parameters are necessary in a configuration file.

### INI:
```ini
[logging]
log_level = trace
log_format = text
log_to_console = false
log_file_path = /var/log/genesyscloudsdk.log
log_response_body = false
log_request_body = false
[retry]
retry_wait_min = 3
retry_wait_max = 10
retry_max = 5
[reauthentication]
refresh_access_token = true
refresh_token_wait_max = 10
[general]
live_reload_config = true
host = https://api.mypurecloud.com
```

### JSON:
```json
{
    "logging": {
        "log_level": "trace",
        "log_format": "text",
        "log_to_console": false,
        "log_file_path": "/var/log/genesyscloudsdk.log",
        "log_response_body": false,
        "log_request_body": false
    },
    "retry": {
        "retry_wait_min": 3,
        "retry_wait_max": 10,
        "retry_max": 5
    },
    "reauthentication": {
        "refresh_access_token": true,
        "refresh_token_wait_max": 10
    },
    "general": {
        "live_reload_config": true,
        "host": "https://api.mypurecloud.com"
    }
}
```

# Logging

## Logging configuration

In total, there are 6 parameters used to control logging:

### LogLevel

The default value is `None` meaning logging is disabled by default.

* `Trace` (HTTP Method, URL, Request Body, HTTP Status Code, Request Headers, Response Headers)
* `Debug` (HTTP Method, URL, Request Body, HTTP Status Code, Request Headers)
* `Error` (HTTP Method, URL, Request Body, Response Body, HTTP Status Code, Request Headers, Response Headers)
* `None`

### LogFormat

The default value is `Text`. The JSON output is flattened to a single line in order to optimize it for line-by-line parsing.

* `JSON`
* `Text`

### LogFilePath

**Note:** This behavior is not available in Javascript web applications.

This initially has no value. When set to a writable file path, the library will log to the file. SDK users are responsible for the rotation of the log file.

### LogToConsole

This is a boolean value set to `true` by default.

### LogRequestBody

This is a boolean value set to `false` by default. The request body can contain PII so developers should be mindful of this data if choosing to log it.

### LogResponseBody

This is a boolean value set to `false` by default. The response body can contain PII so developers should be mindful of this data if choosing to log it.

## Logging Output

### Text

The following is an example of the `Text` output for a trace log. Authorization values are redacted from each log message.

```
TRACE: 2021-03-25 13:38:55,586
=== REQUEST ===
URL: https://api.mypurecloud.com/api/v2/users
Method: GET
Headers: 
	Accept: application/json
	Content-Type: application/json
	User-Agent: PureCloud SDK/python
	purecloud-sdk: 113.0.1
	Authorization: [REDACTED]
=== RESPONSE ===
Status: 200
Headers: 
	Content-Type: application/json
	Transfer-Encoding: chunked
	Connection: keep-alive
	Date: Thu, 25 Mar 2021 13:38:55 GMT
	ININ-Correlation-Id: f3ac4404-283d-4d98-8b70-b75c4891d2ef
	inin-ratelimit-count: 1
	inin-ratelimit-allowed: 180
	inin-ratelimit-reset: 61
	Strict-Transport-Security: max-age=600; includeSubDomains
	Cache-Control: no-cache, no-store, must-revalidate
	Pragma: no-cache
	Expires: 0
	X-Cache: Miss from cloudfront
	Via: 1.1 cf141688d7284e2fa9f014f1f36987c9.cloudfront.net (CloudFront)
	X-Amz-Cf-Pop: DUB2-C1
	X-Amz-Cf-Id: 1df0c3d0-87da4ee9a2b6608e7f178a25==
CorrelationId: f3ac4404-283d-4d98-8b70-b75c4891d2ef
```

### JSON

The following is an example of expanded `JSON` output of a trace log.

``` {"language":"json"}
{
   "level":"trace",
   "date":"03-25-2021, 13:38:50",
   "method":"GET",
   "url":"https://api.mypurecloud.com/api/v2/users",
   "statusCode":200,
   "requestHeaders":{
      "Accept":"application/json",
      "Content-Type":"application/json",
      "User-Agent":"PureCloud SDK/python",
      "purecloud-sdk":"113.0.1",
      "Authorization":"[REDACTED]"
   },
   "responseHeaders":{
      "Content-Type":"application/json",
      "Transfer-Encoding":"chunked",
      "Connection":"keep-alive",
      "Date":"Thu, 25 Mar 2021 13:38:50 GMT",
      "inin-ratelimit-count":"1",
      "inin-ratelimit-allowed":"180",
      "inin-ratelimit-reset":"61",
      "ININ-Correlation-Id":"f3ac4404-283d-4d98-8b70-b75c4891d2ef",
      "Strict-Transport-Security":"max-age=600; includeSubDomains",
      "Cache-Control":"no-cache, no-store, must-revalidate",
      "Pragma":"no-cache",
      "Expires":"0",
      "X-Cache":"Miss from cloudfront",
      "Via":"1.1 1df0c3d087da4ee9a2b6608e7f178a25.cloudfront.net (CloudFront)",
      "X-Amz-Cf-Pop":"DUB2-C1",
      "X-Amz-Cf-Id":"a7e8c90b8847b1a2b74893794176df=="
   }
}
```