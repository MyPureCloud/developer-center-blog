---
title: Adding a new field to an existing CX as Code resource
tags: Genesys Cloud, Developer Engagement, CX as Code
date: 2024-09-21
author: charlie.conneely
category: 0
---

Greetings, all! Welcome back to another Genesys Cloud developer blog. Today I'm going to describe how you can add a field to one of our Terraform resources. Often new fields are added to the request bodies of endpoints in our public API, and we are asked when this field will be visible in the relevant Terraform resource. Unlike our SDKs, the code for our Terraform provider is not generated, so we have to make all updates manually. This means that we can only add a new field as soon as we have the time and resources to do so. Luckily all is not lost—CX as Code is open source, which means you can make these changes yourself and see the resource updated in no time. 

In this blog, I'll break down all the steps you need to complete. The first thing you'll need to do is make a fork of [our repository](https://github.com/MyPureCloud/terraform-provider-genesyscloud). Now we can start coding!

For the purpose of this blog, we'll pretend that we are adding a new field `bar` to the imaginary resource `genesyscloud_foo`. Here are the main components:

1. [Getting set up](#dependencies)
1. [Adding the field to the resource schema](#schema)
1. [Including the field in POST & PUT requests](#build)
1. [Reading the field back into our Terraform state](#read)
1. [Updating the docs](#docs)
1. [Testing](#testing)
1. [Create a pull request](#pr)
1. [Conclusion](#conclusion)

<h2 id="dependencies"> Getting set up </h2>

There are two ways you can set up your dev environment to contribute:

<h4> Option A: Cloning the project and installing the dependencies </h4>

1. Install [Go 1.20](https://go.dev/dl/) and [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) on your machine. 
1. Fork [our repository](https://github.com/MyPureCloud/terraform-provider-genesyscloud) (Unselect "Copy the main branch only"). 
1. Clone your forked repo locally.
1. Checkout the `dev` branch.

<h4> Option B: Using GitHub Codespaces </h4>

By using codespaces, you won't have to worry about installing any dependencies—you can just spin up a VM on your browser and get coding.

1. Fork [our repository](https://github.com/MyPureCloud/terraform-provider-genesyscloud) (Unselect "Copy the main branch only"). 
1. Open the "dev" branch.
1. Select the "Code" dropdown.
1. Click "Create codespace on dev" 

**Note:** At the time of writing this article, we are working off a dev branch branch before merging to main and releasing. This may have changed. If you don't see a branch called `dev` on [terraform-provider-genesyscloud](https://github.com/MyPureCloud/terraform-provider-genesyscloud), you can go ahead and work off of main, and select main as the target branch for your pull request.

<h2 id="schema"> Adding the field to the resource schema </h2>

Since we're adding a field to the genesyscloud_foo resource, we should look for the package `genesyscloud/foo`. Inside, we will find the file `resource_genesyscloud_foo_schema.go`. The schema is a map where the key is a string (the name of the field), and the value is a Schema object that describes the field; its type, whether is required, etc. Have a look at the docs for the struct and see what attributes apply to the field you're adding - [https://pkg.go.dev/github.com/hashicorp/terraform/helper/schema#Schema](https://pkg.go.dev/github.com/hashicorp/terraform/helper/schema#Schema). 

In this example, `bar` is just a simple, optional string. Here is how the schema definition will look after we have added the new field `bar`:

```golang
func ResourceFoo() *schema.Resource {
	return &schema.Resource{
		Description: "Genesys Cloud Foo",

		CreateContext: provider.CreateWithPooledClient(createFoo),
		ReadContext:   provider.ReadWithPooledClient(readFoo),
		UpdateContext: provider.UpdateWithPooledClient(updateFoo),
		DeleteContext: provider.DeleteWithPooledClient(deleteFoo),
		Importer: &schema.ResourceImporter{
			StateContext: schema.ImportStatePassthroughContext,
		},
		SchemaVersion: 1,
		Schema: map[string]*schema.Schema{
			"name": {
				Description: "The name of the foo.",
				Type:        schema.TypeString,
				Required:    true,
			},
			"bar": {
				Description: "The bar.",
				Type:        schema.TypeString,
				Optional:    true,
			},
		},
	}
}
```

<h2 id="build"> Including the field in POST & PUT requests </h2>

Hello

<h2 id="read"> Reading the field back into our Terraform state </h2>

Dia dhuit

<h2 id="docs"> Updating the docs </h2>

Hallo

<h2 id="testing"> Testing </h2>

Ya sas

<h2 id="pr">Open a pull request</h2>

Hei

<h2 id="conclusion">Conclusion</h2>

Ciao