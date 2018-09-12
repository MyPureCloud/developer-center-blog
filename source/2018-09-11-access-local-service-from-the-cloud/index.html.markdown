---
title: How To Securely Access A Local Service From The Cloud
tags: https, secure, data dip, localhost, bridge, connectors, action, service, ngrok
date: 2018-09-11
author: patrick.barry@genesys.com
---

In the past, our customers have needed to rely on our [Bridge Server](https://help.mypurecloud.com/articles/bridge-platform-overview/) 
if they wanted to call a service that was behind their firewall and they did not want to expose it externally (to the internet). 
The Bridge Server was nice because it prevented companies from having to figure out how to safely expose internal-only services.  
Once a Bridge Server was installed, you could then install any number of "Connectors" that would add the functionality you need.  
One Connector, the Web Services Data Dip, would allow our customers to hit REST endpoints behind their firewall, and send the information 
back to their IVR.  This Connector leveraged PureCloud Admin to define the information needed to perform the data 
retrieval (URL, request schema, response schema, etc). This configuration is known as an "Action" in the PureCloud ecosystem. 

<img src="/2018-09-11-access-local-service-from-the-cloud/purecloudflow.png" border="50" alt="PureCloud Workflow" style="display:block;margin-left: auto;margin-right: auto;width: 50%;border-width: 3px;   border-color: C9D5F0;   border-style: solid;">


This setup has worked well, however, it requires our customers to keep up on the maintenance of these components.  
For example, the Bridge and Connectors have to be updated regularly. The Bridge Server lives on a Windows server that has 
to be kept up with security patches, etc. Basically, it just required another "thing" that required oversight.

## A Simpler Alternative
Developers at Genesys set out to finder a better approach to solving the problem of exposing local services securely, 
without the need of a Bridge Server. In our efforts, we discovered ngrok.  Ngrok is a program that you can download and 
run locally that will instantly create a public HTTPS URL for a web service running locally.  Unlike the Bridge Server, 
it can run on Linux, Windows or OSX.  It does not require any "Connectors" or robust hardware. Ngrock connects to the 
"ngrok cloud service" which accepts traffic on a public address and relays that traffic through to the ngrok process 
running on your machine and then on to the local address you specified.  No SSL certificate, proxy or fancy networking 
needed. All of that is taken care of for you by ngrok.

<img src="/2018-09-11-access-local-service-from-the-cloud/ngrok.png" alt="ngrok" style="display:block;margin-left: auto;margin-right: auto;width: 60%;">

Pairing ngrok with PureCloud's Data Actions will give you the best of both worlds. It allows you to integrate local services 
with PureCloud, without having to write any additional code or setup complex networking rules. We've proven it out and 
this is what we did...

### Quick Start

#### Setup A Local Test Service
1. You can use one of your existing services or use the one we did.  If you use an existing service, just make sure the 
service accepts http traffic.
    *  We used: https://github.com/MyPureCloud/webservice-data-dip-connector-example-node
    *  Just follow the directions under "Running the web service"
    *  Once the service is running, it automatically adds one user available for testing. You can test using this command:
    
   ~~~bash
   curl -X POST http://localhost:8080/searchContactsByName -H 'Content-Type: application/json' -d '{"firstName": "Test"}'
   ~~~
 
#### Setup ngrok
 1. Install ngrock https://dashboard.ngrok.com/get-started
    * Make sure to ngrok is added your PATH
    * You will need a token. Explained in (step 3 on page above)
    
    **Production Tip:** _When running ngrok in a non-dev environment, you will need to upgrade your ngrok license to either the Pro or 
    Business plan. This will allow you to use TLS as well as use reserved domain names. When using the Free ngrok 
    version, the URL used will change every time you restart the ngrok the process. More information can be found here: 
    [https://ngrok.com/pricing](https://ngrok.com/pricing)_
    
2. When you start ngrok, you can configure using only command line params OR you create a config file.
   * You can configure ngrok to use proxies, basic auth, logging, etc. https://ngrok.com/docs#config-options
3. For the sake of this example, run this command to point to the service you started above, that is listening on port **8080**

   ~~~bash
   ngrok http 8080 -bind-tls=true
   ~~~
    
<img src="/2018-09-11-access-local-service-from-the-cloud/screenshot1.png" alt="ngrok console"  width="60%" style="display:block;margin-left: auto;margin-right: auto;width: 60%;padding:10px;">
4. Test ngrok's URL works with your test service

~~~bash
curl -X POST https://478b91ce.ngrok.io/searchContactsByName -H 'Content-Type: application/json' -d '{"firstName": "Test"}'
~~~
    
####Create a PureCloud Custom Action
1. Log into PureCloud Admin
<img src="/2018-09-11-access-local-service-from-the-cloud/screenshot2.png" alt="PureCloud Admin"  style="display:block;width: 60%;padding:10px;">
2. The custom Action we are going to setup needs to belong to a PureCloud Integration. Lets create a test Integration..
    * **Go to Integrations > Integrations**
    <img src="/2018-09-11-access-local-service-from-the-cloud/screenshot3.png" alt="Integrations Admin Page"  style="display:block;width: 60%;padding:10px;">
    * **Add a new Integration**
        1. Install **Web Services Data Actions**
        <img src="/2018-09-11-access-local-service-from-the-cloud/screenshot4.png" alt="Install Web Service Data Actions"  style="display:block;width: 20%;padding:10px;">
        2. Give your Integration the name **"Test Local Service Integration"**
        3. Hit Save
        4. Make the Integration Active  
        ![Active](active.png)
    * **Create Custom Action**
        1. In PureCloud Admin, go to Integrations > Actions
        <img src="/2018-09-11-access-local-service-from-the-cloud/screenshot5.png" alt="PureCloud Actions"  style="display:block;width: 70%;padding:10px;">
        2. Click Import
        3. Import [importExample.json](importExample.json)
        4. Select the Integration you created above. _(Test Local Service Integration)_
        5. Name your Action: "Action Test With ngrok"
        6. Once your new Action opens, go to the Setup tab
            * Contracts is setup for you. No change is needed here. This defines the request going to your service and response that will be coming back.
            * Go to Configuration section.  Find requestURLTemplate and change the value to use the ngrok url generated above. So the entry will look like:

           ~~~
                 "requestUrlTemplate": "https://478b91ce.ngrok.io/searchContactsByName",
           ~~~
            * Go to Test section and type in "Test" for the first name and "Account" for last name.
            <img src="/2018-09-11-access-local-service-from-the-cloud/screenshot6.png" alt="PureCloud Actions"  style="display:block;width: 80%;padding:10px;">
            * Uncheck Flatten output and hit Run Action
            * In the results, you can expand JSON and see the response sent back from your webservice.
## Summary
This demonstrates how you can expose any service that is running locally to PureCloud, so it can be used by any of our tools, 
including Architect and Scripter.  This is a great solution for services that are behind a companies firewall and eliminates 
the need for a Bridge Server to get to them. 

_**Architecture Note:** Would you use this approach to hit services that are publicly facing? No. In that scenario, you would still use a 
[Custom Action in PureCloud](https://help.mypurecloud.com/articles/create-custom-action-integrations/), but instead of fronting it with ngrok, you would just use the service's publicly facing URL._

------------

## ngrok Tips
* When you start ngrok using command line arguments, the command will begin with:

~~~bash
ngrok [protocol] [options] [address]
~~~
* When you start ngrok using file-based configurations, then you just specify the tunnel name.

~~~bash
ngrok start [tunnel-name]
~~~
* By default, ngrok will forward any http or https traffic to the port specified in your ngrok configuration. If you only 
want listen for https traffic, set **bind_tls**: true in your configuration file, or if you are using command line, it 
will be **bind-tls=true**. (_notice the dash instead of underscore_)
* You can secure the ngrok address, by adding Basic Auth to it. 
  [https://ngrok.com/docs#expose](https://ngrok.com/docs#expose)
  
~~~bash
  #Example ~/.ngrok2/ngrok.yml
  authtoken: xxx
  tunnels:
    actions:
      proto: http
      addr: 8080
      bind_tls: true
      subdomain: actions
      auth: "demo:secret"
~~~
*  ngrok does not have to run on the same machine as the service you are exposing. To forward to another service, you 
will need to set the host header to "rewrite" or have it match the address you are going to "myservice.genesys.com". 
[https://ngrok.com/docs#host-header](https://ngrok.com/docs#host-header)

~~~bash
  #Example ~/.ngrok2/ngrok.yml
  authtoken: xxx
  tunnels:
    myservice:
      proto: http
      bind_tls: true
      subdomain: actions
      host_header: rewrite
      addr: myservice.genesys.com
~~~    
*  ngrok will default to using their US region cloud. If you are not in the US, you should specify the region in your config. 
  [https://ngrok.com/docs#global-locations](https://ngrok.com/docs#global-locations)
*  TLS/HTTPS tunnels will terminate on the ngrok servers. Because of this, there is extra work you will have to do if you want to use HTTPS between ngrok and your locally running service.  

#### Secure Connection With Certificate Warnings
This configuration will create a HTTPS address, that forwards traffic to your service, via HTTPS as well.  Because the 
TLS connection is terminated on ngrok, a new secure connection is made between ngrok and your service.  This results in 
an "insecure certificate warning" because your local service does not know how to resolve a certificate coming from the 
ngrok domain (ngrok.io).  If you are using something like curl, you can use the _**--insecure**_ flag to ignore this warning. 

~~~bash
  #Example ~/.ngrok2/ngrok.yml
  authtoken: xxx
  tunnels:
    mySecureService:
      proto: tls
      addr: localhost:443
      subdomain: actions
~~~ 

#### Secure Connection Without Certificate Warnings
This setup will require $$$ and more setup time. 
 
1. Buy a SSL (TLS) certificate for a domain name that you own 
2. Configure your local web server to use that certificate and its private key to terminate TLS connections
3. Create a custom domain in ngrok, that matches the domain on your certificate.  [https://ngrok.com/docs#custom-domains](https://ngrok.com/docs#custom-domains)
4. Make sure ngrok tunnel configurations include the region you are in, and hostname 

~~~bash
  #Example ~/.ngrok2/ngrok.yml
  authtoken: xxx
  tunnels:
    mySecureServiceWithoutWarnings:
      proto: tls
      region: us
      hostname: secureService.genesys.com
~~~ 

#### Best Practice
If a company is going the distance to buy a certificate, manage a web server, etc, then their service is most likely exposed to the 
internet. If this is the case, then you do not need ngrok and can configure your custom action(s) to use your publicly accessible endpoint.

---   