---
title: Integrating Vault into a CX as Code flow 
tags: Genesys Cloud, Developer Engagement, CX as Code, Vault
date: 2021-11-25
author: charlie.conneely
category: 6
---

Hi everyone! In this blog, I am going to demonstrate how to incorporate Hashicorp's Vault into your CX as Code flow to store and retrieve your Genesys Cloud credentials. Assuming you have already installed the [Vault](https://www.vaultproject.io/docs/install) and [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) CLI tools, let's get started!

## Configuring Vault

For this example, I am going to run a local Vault *dev server* by executing the following command from the CLI:

```
$ vault server -dev
```

After running this command, the *Address* of our *dev server* should be displayed as `http://127.0.0.1:8200` in the terminal, along with our *Unseal Key* and *Root Token*. The *Root Token* will serve to authenticate us against our Vault server.

Next, we will save the *Address* and *Root Token* as environment variables by running the following commands in a separate terminal: 
```
$ export VAULT_ADDR="http://127.0.0.1:8200"
$ export VAULT_TOKEN="<Root Token>" 
```

Now that our server is running, we can create our secrets by doing the following:
- Visit `localhost:8200` in the browser.  
- Select "Token" as our sign in method.
- Paste our *Root Token* into the input field and click "Sign In".
- Navigate to the secrets engine inside `/secret` and click "Create Secret"
- Provide a path for the secrets (I'm using `genesyscloud_creds`)
- Add the following three key/value pairs:
  - `client_id`: The Genesys Cloud client credential grant Id that CX as Code executes against.
  - `client_secret`: This is the Genesys Cloud client credential secret that CX as Code executes against. 
  - `region`: This is the Genesys Cloud region in which your organization is located.
- Click "Save".

You can also perform these steps by running the following command from your CLI (provided your environment variables are set as described above):
```
$ vault kv put secret/genesyscloud_creds client_id="<CLIENT_ID>" client_secret="<CLIENT_SECRET>" region="<REGION>"
```
**Note:** You should be careful when using this approach as your sensitive data will be stored in your shell history. A list of workarounds to this problem can be found [here](https://learn.hashicorp.com/tutorials/vault/static-secrets#q-how-do-i-enter-my-secrets-without-exposing-the-secret-in-my-shell-s-history).

## Terraform and CX as Code

Now that we have our Vault server running and storing our credentials, let's look at how we can pull this data, incorporate it into our Terraform code, and provision some Genesys Cloud infrastructure. 

First, I created a Terraform file called `main.tf`, defined two providers: `genesyscloud` and `vault`
```hcl
terraform {
    required_version = ">= 0.12"
    required_providers {
        genesyscloud = {
            source  = "mypurecloud/genesyscloud"
            version = "0.14.0"
        }
    }
}

provider "vault" {
    # address defaults to $VAULT_ADDR
    # token defaults to $VAULT_TOKEN
}

provider "genesyscloud" {

}
```

...and then ran:
```
$ terraform init
```

To manipulate objects in our Genesys Cloud org, we need to configure our `genesyscloud` provider with three attributes: `oauthclient_id`, `oauthclient_secret`, and `aws_region`. Since this is sensitive data, it would be bad practice to hardcode these values. Luckily, we have them stored securely in our Vault. To fetch this data, we need to define the data source exposed by `vault` called `vault_generic_secret` and provide the path `secret/genesyscloud_creds`
```hcl
data "vault_generic_secret" "genesys_client_credentials" {
    path = "secret/genesyscloud_creds"
}
```

...and update our provider as follows:
```hcl
provider "genesyscloud" {
    oauthclient_id     = data.vault_generic_secret.genesys_client_credentials.data["client_id"]
    oauthclient_secret = data.vault_generic_secret.genesys_client_credentials.data["client_secret"]
    aws_region         = data.vault_generic_secret.genesys_client_credentials.data["region"]
}
```

Finally, we can begin provisioning our Genesys Cloud infrastructure! In the example below, I created a new Wrap-Up Code using the `genesyscloud_routing_wrapupcode` resource and named it "Test WUC".
```hcl
resource "genesyscloud_routing_wrapupcode" "example" {
    name = "Test WUC"
}
```

Now if you run `terraform apply` and navigate to **Admin > Contact Centre > Wrap-Up Codes** in your org, you should see this Wrap-Up Code created there. 

## Final Thoughts
- The Vault *dev server* created in this environment is, of course, not suitable for production code. A persistent back-end service would be required in a team/production environment not just to manage secrets, but also to create a secure single point of access to our Terraform state files. If you're interested in deploying a production Vault server, documentation on using the AWS secrets engine with Vault can be found [here](https://www.vaultproject.io/docs/secrets/aws), and an open source Terraform Module for running Vault on AWS can be found [here](https://registry.terraform.io/modules/hashicorp/vault/aws/latest).
- If you have any questions or issues pertaining to CX as Code or the Genesys Cloud platform, please reach out to us on our [Developer Forum](https://developer.genesys.cloud/forum/).

Thanks for reading!

## Additional Resources
- [Terraform source code](https://github.com/MyPureCloud/developer-center-blog/blob/master/source/2021-11-25-vault-with-cx-as-code/main.tf)
- [Blog post by John Carnell - Intro to CX as Code](https://developer.genesys.cloud/blog/2021-04-16-cx-as-code/) - What it is, installation, etc. 
- [Blog post by John Carnell - How to begin your CX as Code journey](https://developer.genesys.cloud/blog/2021-10-10-treating-contact-center-infrastructure-as-code/) - The principles of CX as Code, its use cases, etc.
- ["Terraform: Up & Running: Writing Infrastructure as Code" by Yevgeniy Brikman](https://www.amazon.co.uk/Terraform-Running-Writing-Infrastructure-Code/dp/1492046906/ref=sr_1_1?adgrpid=59614341558&hvadid=291375250979&hvdev=c&hvlocphy=20487&hvnetw=g&hvqmt=e&hvrand=14794081332576673109&hvtargid=kwd-296233851066&hydadcr=1425_1794083&keywords=terraform+up+and+running&qid=1637929021&qsid=257-7362453-3738318&s=books&sr=1-1&sres=1492046906%2C1491977086%2C8328366495%2C1800565976%2C1492046531%2C1800207557%2C1617296899%2C1492083658%2C1492056472%2C1684542669%2CB01DCPXKZ6%2CB08BDWYDP7%2C1688449515%2C1643701401%2C1788623533%2C1484273273&srpt=ABIS_BOOK) - A comprehensive guide to Terraform and IAC. 
- Documentation for all Terraform providers can be found at [https://registry.terraform.io/](https://registry.terraform.io/)


