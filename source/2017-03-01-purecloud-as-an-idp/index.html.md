---
title: PureCloud as an Identity Provider
tags: oauth, example, howwedoit
date: 2017-03-01
author: kevin.glinski@genesys.com
---


If you use the internet today, you have probably logged into a web site using your Facebook or Google accounts even if that web site is completely unrelated to Facebook or Google. In this scenario the web site is using Facebook and Google as an identity provider to get your basic info in their system while also letting them handle securing your password and authenticating who you are. Through the OAuth login flow, PureCloud can also be used as an identity provider for external applications, in fact, we use it ourselves in the developer forum.

The developer forum is an open source forum called [Discourse](http://www.discourse.org/) which has extension points to allow for creating your own authentication mechanism.

The first thing we do in our authentication plugin is to register with Discourse

```{"language":"ruby"}
  def register_middleware(omniauth)
    init_settings

    omniauth.provider :oauth2,
          name: @provider_name,
          setup: lambda {|env|
            opts = env['omniauth.strategy'].options
            opts[:client_id] = @client_id
            opts[:client_secret] = @client_secret

            opts[:client_options] = {
              site: "https://login.#{@region}/",
              authorize_url: '/oauth/authorize',
              token_url: '/oauth/token'
            }
          }
  end
```

While this code is very specific to Discourse, the important parts are that we are telling Discourse the PureCloud login urls and the OAuth client id and secret.  When users click the "Login with PureCloud" button, Discourse uses these settings to redirect to PureCloud for the user's authentication.  A similar strategy will be required for your application, but the concept is the same, when a user wishes to login, redirect them to PureCloud for them to provide their credentials. It should be noted that in the forum we support PureCloud logins from all global PureCloud regions, so in our code we will have a provider for each region, with its own client id, secret and login url. 

After the user logs in through PureCloud, they will be redirected back to your application. At this point you will need to get the basic information about that PureCloud user to associate them with your system.  In Discourse it looks like this.

```{"language":"ruby"}
def fetch_user_details(token)
    user_json_url = "https://api.#{@region}/api/v2/users/me?expand=organization"
    user_json = JSON.parse(open(user_json_url, 'Authorization' => "Bearer #{token}" ).read)
    puts user_json

    result = {
      :name     => user_json['name'],
      :email    => user_json['email'],
      :user_id => user_json["id"],
      :username => user_json["name"],
      :org_id => user_json["organization"]["id"]
    }

    result
  end
```

At this point, Discourse handled the authentication flow to get the bearer token.  Using that token, we will make a call to the _/api/v2/users/me?expand=organization_ route in PureCloud.  The _expand=organization_ will tell PureCloud to return details on the user's org with the response.  Org Id can be used to validate that specific PureCloud orgs do or do not have access to your app.  In our case with Discourse we use it to check if the org is our production Genesys org to know if the person logging in is a Genesys employee.

The last step in our login process is to map the PureCloud user to a user in Discourse.

```{"language":"ruby"}
def after_authenticate(auth)
    result = Auth::Result.new
    token = auth['credentials']['token']
    user_details = fetch_user_details(token)

    result.name = user_details[:name]
    result.username = user_details[:username]
    result.email = user_details[:email]

    #purecloud doesn't have a concept of a validated email
    result.email_valid = false

    current_info = ::PluginStore.get(@provider_name, "#{@provider_name}_user_#{user_details[:user_id]}")
    if current_info
      result.user = User.where(id: current_info[:user_id]).first
    end

    result.extra_data = {
        purecloud_user_id: user_details[:user_id],
        purecloud_org_id: user_details[:org_id]
    }

    result
  end
```

In this method the result.user object is going to contain the Discourse user that is logging in.  If that property is null then Discourse will create a new user based on the metadata that we are supplying on the result object.

There is one line here that is important to note and it is _result.email_valid = false_.  Here we are telling Discourse that it still needs to validate the user's email. At this time PureCloud does not validate email addresses, so it is possible for anyone to create a user with any email in their PureCloud org.  Therefore we don't trust the email that is returned back to us and require Discourse to validate the email to activate that user.

Now we can lookup users using their PureCloud user Id

```{"language":"ruby"}
current_info = ::PluginStore.get(@provider_name, "#{@provider_name}_user_#{user_details[:user_id]}")
if current_info
  result.user = User.where(id: current_info[:user_id]).first
end
```

If result.user is null then Discourse calls one last method

```{"language":"ruby"}
def after_create_account(user, auth)
  ::PluginStore.set(@provider_name, "#{@provider_name}_user_#{auth[:extra_data][:purecloud_user_id]}", {user_id: user.id })
end
```

and this code just sets up the mapping between the PureCloud and the Discourse user.  

There are the basics of how we use PureCloud as an identity provider in the Developer Center forum. When using PureCloud for an identity provider in your own solution there are a couple things to consider:

1. How will you map the PureCloud user to the user in your system?   
2. Do you need to validate the user's PureCloud org to see if they have purchased the product they are logging into?
3. How will you handle international support? There are multiple PureCloud regions that customers can be in, if your app is global then you will need to handle the login flows for each region. 
