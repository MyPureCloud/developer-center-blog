---
title: Implicit Grant Login and the CLI
tags: Genesys Cloud, Developer Engagement, CLI
date: 2022-02-11
author: charlie.conneely
category: 6
---

Greetings, everyone! To configure our Genesys Cloud CLI tool, one needs to create a profile in their `config.toml` file using the command: `gc profiles new`. Previously, this operation only utilized the Client Credentials login method in which the user provides their client ID and secret in exchange for an access token. Although quick and easy, this method does not provide any user context. For this reason, in addition to the Client Credentials Grant, we have implemented the Implicit Grant (Browser) login method for the CLI. 

Below, I will outline how to use this new feature.  

## Configuring Genesys Cloud

To authenticate a client from the CLI using an Implicit Grant, you will first need said client to exist with the correct configurations in your Genesys Cloud org.

**Steps:**
- Navigate to **Admin -> Integrations -> OAuth**
- Click "Add Client"
  - Give your client a name.
  - Select "Token Implicit Grant (Browser)" under the "Grant Types" header.
  - Provide the necessary scopes. 
  - Enter your chosen redirect URI(s) (e.g. `http://localhost:8080`). The port number entered during the CLI profile  creation process will need to match one of these. If you want your local server instance to use a secure HTTP  connection, you will need to prepend the URI with "https". 

## CLI profile creation

For this part, you will need to have our CLI tool installed. Installation and setup instructions can be found [here](https://developer.genesys.cloud/api/rest/command-line-interface/ "Opens developer.genesys.cloud").

**Steps:**
- From your terminal, run: `gc profiles new`.
- Enter the necessary details, selecting "Implicit Grant" as your login method.
- Enter the port number of your redirect URI. 
- Choose if you would like to open a secure HTTP connection.

After this, you will be redirected to your org, where you will be asked to enter your login details. However, if you chose to use HTTPS, you will first need to select **Advanced -> Proceed to 127.0.0.1**. This is because the locally generated self-signed certificate is not recognized by an official Certificate Authority. 

If all goes well, you should see a success message in your browser. 

To demonstrate the usefulness of this new feature, run the command:

```console
$ gc users me get -p [profile name]
```

Previously, you would have received the error message "This request requires a user context. Client credentials cannot be used for requests to this resource." But now, after authenticating through an implicit login, you should receive a JSON object full of user details. 

**Note**: It is still safe to use a regular HTTP connection as the server instance is contained to your local machine. The secure connection serves as optional added security.

Thanks for reading!
 
## Additional Resources
- [CLI Setup & Configuration](https://developer.genesys.cloud/api/rest/command-line-interface/ "Opens developer.genesys.cloud")
- [Setting up and OAuth Client on Genesys Cloud](https://help.mypurecloud.com/articles/create-an-oauth-client/ "Opens help.mypurecloud.com")