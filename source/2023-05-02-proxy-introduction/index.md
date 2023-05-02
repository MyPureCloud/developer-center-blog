---
title: Introducing the proxy setup to the Genesys Cloud CLI, SDK, CX-as-code
tags: Genesys Cloud, Developer Engagement, CLI
date: 2023-05-02
author: hemanth.dogiparthi
category: 6
---

Greetings, everyone! In this blog, I'm going to introduce the new proxy configuration, which has been added to our [GO SDK] - (v96.0.0 & greater  https://developer.genesys.cloud/devapps/sdk/go), 
[CLI tool] (66.0.0 & greater  https://developer.genesys.cloud/devapps/cli/) and [CX as code] (v1.15.0 & greater https://developer.genesys.cloud/devapps/cx-as-code/). With this configuration applied, you can make SDK platform calls ,use CLI and CX-as-code  via a proxy server.

## Usage

## 1. SDK:

In this scenario, let's say you want to access the platform API calls in SDK via a proxy server, it can be accomplished by setting the proxy settings on the configuration object.

The `ProxyConfiguration` object has 3 properties that determine the URL for proxying.
Port - Port of the Proxy server
Host - Host Ip or DNS of the proxy server
Protocol - Protocol required to connect to the Proxy (http or https)

The 'ProxyConfiguration' has another section which is an optional section. If the proxy requires authentication to connect to
'Auth' needs to be mentioned under the 'ProxyConfiguration'.

Example logging configuration for GO:
```go
proxyconf := ProxyConfiguration{}
config.ProxyConfiguration := &proxyconf
config.ProxyConfiguration.Host = hostname
config.ProxyConfiguration.Port = port
config.ProxyConfiguration.Protocol = protocol

auth := Auth{}
config.ProxyConfiguration.Auth = &auth
config.ProxyConfiguration.Auth.UserName = userName
config.ProxyConfiguration.Auth.Password = password
```

Similar configuration can be applied for othe SDKs like Java , Javascript, Python which you can find in the respective github sdk pages and developer center for the sdks.

## 2. CX-as-code:

If you want to access your CX as Code via a proxy server, while setting up the terraform provider you can provide this configuration so that underlying GO SDK use this setting for making the platform API calls for creating the Genesys Cloud configuration objects 

```bash
provider "genesyscloud" {
  oauthclient_id = "<client-id>"
  oauthclient_secret = "<client-secret>"
  aws_region = "<aws-region>"

  proxy {
    host     = "example.com"
    port     = "8443"
    protocol = "https"

    auth {
      username = "john"
      password = "doe"
    }
  }
}
```

The following environment variables may be set to avoid hardcoding Proxy and Auth Client information into your Terraform files:

```bash
GENESYSCLOUD_PROXY_PORT
GENESYSCLOUD_PROXY_HOST
GENESYSCLOUD_PROXY_PROTOCOL
GENESYSCLOUD_PROXY_AUTH_USERNAME
GENESYSCLOUD_PROXY_AUTH_PASSWORD
```

## 3. CLI:

If you want to access your the CLI via a proxy server, you can setup this during 'gc profiles new' command and answer the questions. These questions will also include setting up the proxy configuration. If everything works correctly you should have a file created in your home directory called .gc/config.toml and it contains the proxy config information along with all the other configuration information.

sample proxy info from .gc/config.toml
```bash
proxy_host = 'hostname'
proxy_port = 'port'
proxy_protocol = 'http'
proxy_username = 'john_doe1'
proxy_password = 'password'
```
**Note:** The poxy username and password are optional params.

The new feature also allows you to setup the proxy using a gc cli command.

To add a proxy configuration for the CLI , you can a pass file parameter with proxy configuration in it.

JSON configuration file (proxy.json):

```bash
{ 
    "host": "hostname", 
    "protocol": "http", 
    "port": "8888", 
    "userName": "username", 
    "password": "password"
}
```

Command to Enable Proxy: gc proxy --file=proxy.json

To disable this Proxy Configuration, you can run the following command. gc proxy disable

## Closing Thoughts 

Hopefully, this new feature will help clients to leverage using a proxy server setup if required in their use cases.

Thanks for reading!

## Additional resources 
1. [Genesys Cloud CLI](/devapps/cli/)
2. [Blog post by John Carnell - Intro to CX as Code](https://developer.genesys.cloud/blog/2021-04-16-cx-as-code/)