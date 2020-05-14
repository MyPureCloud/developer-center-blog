---
title: Managing custom query parameters in your Application URL with an OAuth Implicit Grant client
tags: custom client application, oauth implicit grant, redirecturi, query parameters
date: 2020-05-12
author: jerome.saint-marc@genesys.com
---

When you approach a platform or a topic you are not familiar with, it is sometimes difficult, at least for me, to start with a full sample which covers many topics at once.  
So I thought it could be useful to focus on certain parts and to share what I have understood of them.

Today, I will start with possible ways to manage custom query parameters in an Application URL, for [Custom Client Applications](https://help&#46;mypurecloud&#46;com/articles/about-custom-client-application-integrations/), and the Authorized Redirect URIs of an associated [OAuth client](https://help&#46;mypurecloud&#46;com/articles/create-an-oauth-client/).

**Here is the use case:**
1.	You want to expose a web based UI (i.e. web page) to your Genesys Cloud users (Contact Center Agents, Supervisors, Administrators, ...) and you want to expose that page directly in the Genesys Cloud client (a.k.a. PureCloud).
2.	We'll assume that the web page you want to expose needs to leverage the Platform API (to send request to the Genesys Cloud platform, or to subscribe to notifications coming from the platform).  
And therefore this requires to have an OAuth client defined in the configuration.
3.	Just to restrict the use case, we'll also consider that the application we want to expose is based on "static" html and javascript code and that it uses a [Token Implicit Grant approach](https://developer&#46;mypurecloud&#46;com/api/rest/authorization/use-implicit-grant.html).  
By this, I mean that Login and Platform API will be requested directly from the Genesys Cloud client (your web browser) - and that no "intermediate" server is involved (i.e. NOT an Authorization Code Grant approach).

**So what do we need to achieve this?**

1.	Add a Custom Client Application to your integrations (or Premium Application) in your Genesys Cloud organization  
=> *Application URL = $URL_1$*
2.	Add an OAuth client (Grant Type = Token Implicit Grant)  
If you are creating your own Custom Client Application, you will need to add this OAuth client in your organization.  
If you are a Premium App provider, this OAuth client will have to be created in the regional orgs we will create for you.  
=> *Authorized redirect URIs = $URL_2$*

_Note: $URL_1$ and $URL_2$ are not specific keywords/values. This is just to represent the urls, corresponding to your app, that you will need to configure. I'll come back to this later in this post._

Before continuing, I suggest you take a look at the page explaining the [Implicit Grant](https://developer&#46;mypurecloud&#46;com/api/rest/authorization/use-implicit-grant.html).

## What does that mean for my web client and the javascript code?

The Genesys Cloud client (or a web browser like Chrome when you are using the Genesys Cloud Web client) requests and loads the page that corresponds the Application URL of my Client Application ($URL_1$).  

When the javascript code is executed by the web client, and when it reaches the ***loginImplicitGrant*** method (from the Platform API Javascript SDK), one of the following will happen:
*	You already opened that page recently (authorization process was performed already), and the access token is still valid:  
The code execution will continue (what you write in the *then()* method of the ***loginImplicitGrant*** when called as a Promise)

*	It is the first time you open the page (for the day) or the access token is not valid anymore (token has expired):  
    The web client will be redirected to login&#46;mypurecloud&#46;com (or login&#46;mypurecloud&#46;ie, or ... - depending on your Genesys Cloud organization region). The code after ***loginImplicitGrant*** from your first page (corresponding to $URL_1$) will not be processed.
    1. 	If you provide the correct credentials, and if (only if) the redirectUri you provided in the ***loginImplicitGrant*** is configured under the OAuth client as Authorized Redirect URIs, then the web client will then be authorized and will be redirected to the redirect url you have provided.  
    The Redirect URI in the loginImplicitGrant MUST entirely match one of the urls you have configured under the OAuth client as Authorized Redirect URIs.  
    Here, this would mean $URL_2$
    2. 	The Genesys Cloud client (i.e. the web browser) then requests and loads the page that corresponds to the redirect uri ($URL_2$).

_Note on (2): if you are doing this via a Custom Client Application in widget or standalone mode (or with a Premium Application), the login/credentials part will be "transparent" to the user opening that page. The user will not be prompted to enter his credentials again._

It was probably clear for many of you, or all of you.  
But this is not what I wanted to explain here.

## Using custom query parameters in the Application URL

Now, let's say that when I open my Client Application, I want to pass a certain set of parameters to my html & javascript code.  
Custom Client Applications and Premium Applications support 2 built-in dynamic parameters: region (pcEnvironment) and language (pcLangTag)

Let's take a concrete example for $URL_1$.  
I can set it the following way as Application URL, in my Custom Client Application (or Premium Application):  
*https://my_web_server/index.html?environment=&#123;&#123;pcEnvironment&#125;&#125;&langTag=&#123;&#123;pcLangTag&#125;&#125;*  
&#123;&#123;pcEnvironment&#125;&#125; and &#123;&#123;pcLangTag&#125;&#125; are keywords.

When the Genesys Cloud client issues the HTTP GET to the configured url, it will replace &#123;&#123;pcEnvironment&#125;&#125; with the region of my Genesys Cloud organization, and &#123;&#123;pcLangTag&#125;&#125; with the language defined for my user.  
This is only applicable for Custom Client Applications and Premium Applications.

In other words, my Genesys Cloud sandbox being in Ireland and as I am using US English there and on my computer, my Genesys Cloud client will issue a request to:  
*https://my_web_server/index.html?environment=mypurecloud.ie&langTag=en-us*

Now, for the sake of this example, I'll also decide to pass another parameter - this one will be "static".  
Static in the sense that I will define the value I want in the Custom Client Application (in the Application URL) directly.  
Let's say I want to pass something that defines the userType (so my html & javascript code can display a different UI or different set of information in my page).  
I will define this the following way in my Custom Client Application.  
*Application URL = https://my_web_server/index.html?environment=&#123;&#123;pcEnvironment&#125;&#125;&langTag=&#123;&#123;pcLangTag&#125;&#125;&userType=agent*

_Important note: if you are not configuring and displaying this web app as a Custom Client Application (ex: opening the web app in a new tab via screen-pop, ...), you would have to provide the correct values for environment and langTag. The &#123;&#123;pcEnvironment&#125;&#125; and &#123;&#123;pcLangTag&#125;&#125; are only replaced dynamically by the PureCloud Web client when displaying as a Custom Client APplication (in widget or in stand-alone mode)._

Now, I finally come to the point of this post. At last 🙂

If my Custom Client Application (or Premium Application...) needs to leverage the Platform API, I need to create an OAuth client.  
So we'll create one, using Grant Type = Implicit Grant.

But what should I define in the Authorized redirect URIs?

You need to enter ***all possible urls*** that your client will set in the redirectUri of the ***loginImplicitGrant*** method. This includes query parameters, along with their possible values.

If your application is meant to be supported in multiple regions, or if your application is to leverage the languageTag, or if you have zillions possible values for the custom parameter I added (userType), it can become quite painful to configure all possible Redirect URIs.

## Possible approaches

### Approach 1 - Using javascript localStorage

My method is the following.

In the Custom Client Application, I am going to define the Application URL as:  
*https://my_web_server/index.html?environment=&#123;&#123;pcEnvironment&#125;&#125;&langTag=&#123;&#123;pcLangTag&#125;&#125;&userType=agent*  
*NB: That's what I referenced as $URL_1$ above.*

In the OAuth client, I am going to define a **single** Authorized redirect URI:  
*https://my_web_server/index.html*  
*NB: That's what I referenced as $URL_2$ above.*

It means that when I set a redirectUri for the ***loginImplicitGrant*** method, I will remove the query parameters.  
Otherwise, if I send the full $URL_1$ (*https://my_web_server/index.html?environment=mypurecloud.ie&langTag=en-US&userType=agent*), the OAuth Authorization process will fail as it doesn't correspond EXACTLY to the url I provisioned in my OAuth Client (*$URL_2$ = https://my_web_server/index.html*)

So what do I need to do to manage these parameters?

If you remember what I wrote few lines above on the Implicit Grant flow, you will notice that if I am not yet authenticated/authorized, the following happens:
1.	The Genesys Cloud client loads *https://my_web_server/index.html?environment=mypurecloud.ie&langTag=en-US&userType=agent*
2.	Then, upon a call to the ***loginImplicitGrant*** method, I am redirected to login&#46;mypurecloud&#46;ie
3.	And if this is successful, I am finally redirected to *https://my_web_server/index.html*

So how do I keep a track of my parameters?  
It is kind of easy - you can leverage the javascript's localStorage.

The first time your page is called (i.e. $URL_1$ = *https://my_web_server/index.html?environment=mypurecloud.ie&langTag=en-US&userType=agent*), you will extract the query parameters and store them in localStorage.

The second time your page is called (following redirect from authentication/authorization - i.e. $URL_2$ = *https://my_web_server/index.html*), the current url does not contain these parameters anymore.
You just need to extract the parameter values from your localStorage.

Let's create a method to ease management of the storage:

```
const _processQueryParameters = (value, token, defaultValue) => {
  let returnValue = null;

  if (value) {
    // new value received in query parameters - store value
    localStorage.setItem(token, value);
    returnValue = value;
  } else if (localStorage.getItem(token)) {
    // no value received - get value from storage (if it exists already)
    returnValue = localStorage.getItem(token);
  } else {
    // no value received and no value in storage (should not happen but...)
    // Use default value
    returnValue = defaultValue;
  }
  
  return returnValue;
};
```

The following is the code I execute at the beginning of my script/page.

```
const DEFAULT_ENVIRONMENT = "mypurecloud.com";
const DEFAULT_LANG_TAG = "fr";
const DEFAULT_USER_TYPE = "unknown";

const appName = "MyApp";
const clientId = "abcdefgh12345678"

// I can define the redirectUri with a static value in my code.
// Here, I have chosen to make it more dynamic, extracting origin and path only from the current URL
// This is because my $URL_1$ and my $URL_2$ have same origin and path (only difference is the query parameters)
const redirectUri = window.location.origin + window.location.pathname;

// Set purecloud objects
const platformClient = require('platformClient');
const apiClient = platformClient.ApiClient.instance;

var queryString = window.location.search.substring(1);
var pairs = queryString.split('&');

let tmpEnvironment = null;
let tmpLangTag = null;
let tmpUserType = null;

for (let i = 0; i < pairs.length; i++) {
  var currParam = pairs[i].split('=');

  if (currParam[0] === 'langTag') {
    let langParam = currParam[1];
    switch (langParam) {
      case 'en-us':
        tmpLangTag = 'en_US';
        break;
      case 'fr-fr':
        tmpLangTag = 'fr';
        break;
      default:
        tmpLangTag = DEFAULT_LANG_TAG;
        break;
    }
  } else if (currParam[0] === 'environment') {
    tmpEnvironment = currParam[1];
  } else if (currParam[0] === 'userType') {
    tmpUserType = currParam[1];
  }
}

// Store the query parameters into localstorage
// If query parameters are not provided, try to get values from localstorage
// Default values if it does not exist
let environment = _processQueryParameters(tmpEnvironment, appName + ":environment", DEFAULT_ENVIRONMENT);
let langTag = _processQueryParameters(tmpLangTag, appName + ":langTag", DEFAULT_LANG_TAG);
let userType = _processQueryParameters(tmpUserType, appName + ":userType", DEFAULT_USER_TYPE);

// Set PureCloud settings
// Calling setEnvironment to set the current organization region (mypurecloud.ie)
apiClient.setEnvironment(environment);
// Calling setPersistSettings to keep and to store authorization data locally (in my web browser)
// If I reopen my page and if the access token is still valid, authorization process is not triggered again.
apiClient.setPersistSettings(true, appName);

```

And when I do login:

```
// Accessing purecloud objects
$(document).ready(() => {

    // The next line will be executed in the 2 phases
    // first access using $URL_1$, and second access from the redirect URI - $URL_2$
    apiClient.loginImplicitGrant(clientId, redirectUri)
        .then((creds) => {
            // I will reach this part of the code only once I am authorized
            // i.e. $URL_1$ if I was authorized already (access token still valid), or $URL_2$ if I had to login and got redirected to my application on success
            console.log('Logged in with credentials: ', creds);
            console.log("Credentials also available here: ", apiClient.authData);
        })
        .catch((err) => console.error(err));
        
});

```

_Note: In the code above, I have decided to manage the case where no parameter is provided in the url and the value has not been stored in local storage, using a default value.  
You are not obliged to follow the same approach.  
You could consider that this is an error for your application/code, and display a warning/error message back to the user._


### Approach 2 - Using the state parameter

If you only have a single parameter value to pass, or let's say some data which is "not too long", you could also leverage the [state parameter](https://developer.mypurecloud.com/api/rest/authorization/additional-parameters.html#the_state_parameter) of the authorization flow.

This is not the real meaning and use of state parameter, as it is meant to allow the requesting application to associate the redirect for authorization with the response from the authorization server.  
But if you really can't or don't want to use localStorage (my preferred approach though), you could leverage this approach as well.

The data sent in the state parameter must not be too long (it is limited by the max URL length of any given component that handles the URL, including your web browser).  
If you have a ton of info that you need to track, consider using local storage or keeping the data server-side on your web server somewhere.

With state parameter approach, you would still follow the same type of configuration I explained previously in this post.

In the Custom Client Application, I am going to define the Application URL as:  
*https://my_web_server/index.html?userType=agent*  
*NB: That's what I referenced as $URL_1$ above.*

In the OAuth client, I am going to define a **single** Authorized redirect URI:  
*https://my_web_server/index.html*  
*NB: That's what I referenced as $URL_2$ above.*

In my code, I will need to manage things a bit differently than with localStorage.  
I still need to extract the query parameter, but:
1.	I will send the retrieved data through the state parameter of my ***loginImplicitGrant*** method.
2.	I will need to distinguish the case where I have a valid access token differently. Indeed, if I have a valid access token, the authorization process will not be triggered. It means that a state parameter will not be exchanged again with the Genesys Cloud organization. And it means that the state value which is available in my authorization data is still the value from the previous authorization flow.

With some code:

```
const appName = "MyApp";
const clientId = "abcdefgh12345678"

// I can define the redirectUri with a static value in my code.
// Here, I have chosen to make it more dynamic, extracting origin and path only from the current URL
// This is because my $URL_1$ and my $URL_2$ have same origin and path (only difference is the query parameters)
const redirectUri = window.location.origin + window.location.pathname;

// Set purecloud objects
const platformClient = require('platformClient');
const apiClient = platformClient.ApiClient.instance;

var queryString = window.location.search.substring(1);
var pairs = queryString.split('&');

let tmpUserType = null;

for (let i = 0; i < pairs.length; i++) {
  var currParam = pairs[i].split('=');
  if (currParam[0] === 'userType') {
    tmpUserType = currParam[1];
  }
}

// Set PureCloud settings
// Calling setEnvironment to set the current organization region (mypurecloud.ie)
apiClient.setEnvironment("mypurecloud.ie");
// Calling setPersistSettings to keep and to store authorization data locally (in my web browser)
// If I reopen my page and if the access token is still valid, authorization process is not triggered again.
apiClient.setPersistSettings(true, appName);


// Accessing purecloud objects
$(document).ready(() => {

    // The next lines will be executed in the 2 phases
    // first access using $URL_1$, and second access from the redirect URI - $URL_2$

    let stateValue;
    if (tmpUserType) {
      // first access using $URL_1$
      stateValue = tmpUserType;
    } else {
      // second access from the redirect URI - $URL_2$
      stateValue = "dummy";
    }

    apiClient.loginImplicitGrant(clientId, redirectUri, {state: stateValue})
        .then((creds) => {
            // I will reach this part of the code only once I am authorized
            // i.e. $URL_1$ if I was authorized already (access token still valid), or $URL_2$ if I had to login and got redirected to my application on success
            console.log('Logged in with credentials: ', creds);
            console.log("Credentials also available here: ", apiClient.authData);

            // Retrieve the parameter value
            // If https://my_web_server/index.html?userType=agent is the current url and I got here because my token was still valid, tmpUserType should be different from null
            // If https://my_web_server/index.html is the current url and I got here because the authorization flow was triggered, tmpUserType should be null but the value should be available in state data
            let myUserType;
            if (tmpUserType) {
              myUserType = tmpUserType;
            } else {
              myUserType = this.apiClient.authData.state;
            }

        })
        .catch((err) => console.error(err));
        
});

```

That's it for today!  
Hope this will help and will not add more confusion 🙂

