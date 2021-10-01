---
title: New Experimental CLI Feature: Transform Data
date: 2021-10-01
tags: cli, developer engagement, experimental, transform data, go templates
author: michael.roddy
image: ./blog-img.png
category: 6
---

Hi everyone, I am excited to introduce another new experimental CLI feature: Transform Data. Experimental CLI features were released in version 18.0.0 of the Genesys Cloud CLI. Experimental features allow us to release ideas around the CLI early and give customers an opportunity to give feedback on the feature before the work on them is finalized. We do not guarantee a feature will be made available for public release, but it's our intent to promote experimental features after a suitable beta period. Experimental features are tied to the CLI binary, so when we release an experimental feature or promote an experimental feature, you will need to download the CLI binary that matches the release or promotion of that feature. To work with the experimental features in your binary, you can: list, enable and disable experimental features. The new experimental feature will allow you to transform output data from the CLI by using a Go template and in this blog post, I am going to demonstrate how you can use the Transform Data feature in the Genesys Cloud CLI.

**Note:** Experimental `CLI` features are subject to breaking and non-breaking changes at any time.


## List, Enable and Disable Experimental Features

To see the list of experimental features:  

```
gc experimental list
```

To enable an experimental feature:  

```
gc experimental enable [feature_name]
```

To disable an experimental feature:  

```
gc experimental disable [feature_name]
```

**Note:** By default, experimental features are turned off. To use and experimental feature, you must explicitly enable the feature.

**Note:** Experimental features are tied to the `CLI` binary, so when we release an experimental feature or promote an experimental feature, you will need to download the `CLI` binary that matches the release or promotion of that feature.

## The Transform Data Feature

The Transform Data feature uses `Go` templates for transforming output data. `Go` templates are a powerful way to "transform" or customize output however you want, for example, transforming output data from the `CLI` to `CSV` format, transforming output data to `HCL` format or just extracting certain attributes or fields from an object. Templates are provided to the Genesys Cloud `CLI` as either a file containing the template string and passed to the `--transform` flag or as a "raw" template string and input directly in the terminal and passed to the `--transformstr` flag. We will explore `Go` templates and using the `--transform` flag and the `--transformstr` flag in the sections below. If you would like to read more about `Go` templates, see Go's template package [text/template](https://pkg.go.dev/text/template) for more info.

## A Brief Overview Of The Go Template Syntax

`Go` templates are essentially made up of `actions` and are deliminated by double curly braces enclosing your `action`. 

You can see the list of actions here: [Go template action list](https://pkg.go.dev/text/template#hdr-Actions). 

These `actions` may represent loops, conditionals or data evaluations (arguments and pipelines). 

`Arguments` are simple values. 

You can see the list of `arguments` here: [Go template argument list](https://pkg.go.dev/text/template#hdr-Arguments). 

A `pipeline` is a possibly chained sequence of "commands". A command is a simple value (`argument`) or a function or method call, possibly with multiple arguments. 

You can see `pipeline` examples here: [Go template pipelines](https://pkg.go.dev/text/template#hdr-Pipelines).

`Go` templates output all text between `actions`, even white space. It may be useful for you to trim the white space in your `Go` templates. 

You can see how text and spaces work here: [Go template text and spaces](https://pkg.go.dev/text/template#hdr-Text_and_spaces)

## Using The Transform Data Feature In The CLI

### Template Files

If you would like to use a `Go` template file in the `CLI` to transform output data, you can pass the template file path to the `--transform` flag when making a request.

***Example Request:***

```
gc users get f3dc94ca-acec-4ee4-a07e-ca7503ddbd62 --transform=./tmpl.gotmpl
```

### Template Strings

If you would like to use a `Go` template string in the `CLI` to transform output data, you can pass the "raw" template string to the `--transformstr` flag surrounded by single quotes when making a request.

***Example Request:***

```
gc users get f3dc94ca-acec-4ee4-a07e-ca7503ddbd62 --transformstr='your_go_template_string'
```

## Transforming Output Data To CSV Format

**Note:** To write a `Go` template, you must know the structure of the data in advance.

In this example we will be transforming output data from a `gc users list -a` command to `CSV` format.

To begin, lets run the `gc users list -a` command to see the structure of the data before we write the `Go` template.

To get a list of all users, run the following command:

```
gc users list -a
```

The request above will return the following response:

***Note:*** Here I am showing just one object from the list of objects returned from a `gc users list -a` command.

```
[
  {
    "id": "a231695b-e835-4cc5-afc2-c74c1e33cea2",
    "name": "John Doe",
    "division": {
      "id": "a231695b-e835-4cc5-afc2-c74c1e33cea2",
      "name": "",
      "selfUri": "/api/v2/authorization/divisions/b5f58b9d-0582-4baf-990c-9cc07a6c5828"
    },
    "chat": {
      "jabberId": "4e3f11b1-b1b2-4e8f-ae24-2ade95b7fcd2@genesys.com"
    },
    "email": "john.doe@genesys.com",
    "primaryContactInfo": [
      {
        "address": "john.doe@genesys.com",
        "mediaType": "EMAIL",
        "type": "PRIMARY"
      }
    ],
    "addresses": [],
    "state": "active",
    "username": "john.doe@genesys.com",
    "version": 6,
    "acdAutoAnswer": false,
    "selfUri": "/api/v2/users/275cdf93-db48-420e-b300-d056deb4ab0c"
  },
  
  response continues...
  
]
```

Now that we can see the structure of the data, we can write the `Go` template.

***Note:*** This is an example `Go` template file for transforming output data to `CSV` format. 

`tmpl.gotmpl`

```
{{- range . -}}
id: {{.id}},name: {{.name}},division: 
    {{- range $key, $val := .division -}}
        {{$key}}: {{$val}},
    {{- end -}}
    chat:
    {{- range $key, $val := .chat -}}
        {{$key}}: {{$val}},
    {{- end -}}
    email: {{.email}},primaryContactInfo:
    {{- range .primaryContactInfo -}}
        {{- range $key, $val := . -}}
            {{$key}}: {{$val}},
        {{- end -}}
    {{- end -}}
    addresses:
    {{- range .addresses -}}
        {{- range $key, $val := . -}}
            {{$key}}: {{$val}},
        {{- end -}}
    {{- end -}}
    state: {{.state}},username: {{.username}},version: {{.version}},acdAutoAnswer: {{.acdAutoAnswer}},selfUri: {{.selfUri}},
{{- end -}}
```

So to get a list of users and transform the output to `CSV` format, run the following command:

```
gc users list -a --transform=./tmpl.gotmpl
```

The output from running the above command is as follows:

***Note:*** Here I am showing just one user object transformed to `CSV` format. In the case of transforming output from a `gc users list -a` command, you would have multiple objects transformed to `CSV` format.

```
id: 3b62fe12-755a-4533-a4c0-e7815f28b848,name: John Doe,division:id: 3b62fe12-755a-4533-a4c0-e7815f28b848,name: ,selfUri: /api/v2/authorization/divisions/360e4e37-fea7-4bb1-a346-11a74dbb38ff,chat:jabberId: 360e4e37-fea7-4bb1-a346-11a74dbb38ff@genesys.com,email: john.doe@genesys.com,primaryContactInfo:address: john.doe@genesys.com,mediaType: EMAIL,type: PRIMARY,addresses:state: active,username: john.doe@genesys.com,version: 6,acdAutoAnswer: false,selfUri: /api/v2/users/9096aac0-936a-4fa5-b331-57e09f2ce09b
```

As you can see from the example above, the output data is now in `CSV` format.

## Transforming Output Data to HCL Format

**Note:** To write a `Go` template, you must know the structure of the data in advance.

In this example we will be transforming output data from a `gc users get [user_id]` command to `HCL` format.

To begin, lets run the `gc users get [user_id]` to see the structure of the data before we write the `Go` template.

To get a user by ID, run the following command:

```
gc users get [user_id]
```

The response from running the above command is as follows:

```
{
  "id": "f0eeb2e7-6307-46e8-bb29-f8a223d46acf",
  "name": "John Doe",
  "division": {
    "id": "f0eeb2e7-6307-46e8-bb29-f8a223d46acf",
    "name": "",
    "selfUri": "/api/v2/authorization/divisions/f0eeb2e7-6307-46e8-bb29-f8a223d46acf"
  },
  "chat": {
    "jabberId": "f0eeb2e7-6307-46e8-bb29-f8a223d46acf@genesys.com"
  },
  "email": "john.doe@genesys.com",
  "primaryContactInfo": [
    {
      "address": "john.doe@genesys.com",
      "mediaType": "EMAIL",
      "type": "PRIMARY"
    }
  ],
  "addresses": [],
  "state": "active",
  "username": "john.doe@genesys.com",
  "version": 1,
  "acdAutoAnswer": false,
  "selfUri": "/api/v2/users/f0eeb2e7-6307-46e8-bb29-f8a223d46acf"
}
```

Now that we can see the structure of the data, we can write the Go template.

***Note:*** This is an example `Go` template file for transforming output data to `HCL` format. 

***Note:*** This template follows the styling conventions from Terraform. You can see Terraforms styling  conventions here: [Style conventions in Terraform](https://www.terraform.io/docs/language/syntax/style.html)

`tmpl.gotmpl`

```
id            = "{{.id}}"
name          = "{{.name}}"
email         = "{{.email}}"
state         = "{{.state}}"
username      = "{{.username}}"
version       = "{{.version}}"
acdAutoAnswer = "{{.acdAutoAnswer}}"
selfUri       = "{{.selfUri}}"

division {
  id      = "{{.division.id}}"
  name    = "{{.division.name}}"
  selfUri = "{{.division.selfUri}}"
}

chat {
  jabberId = "{{.chat.jabberId}}"
}

primaryContactInfo = [
  {
    {{- range .primaryContactInfo}} 
    address   = "{{.address}}"
    mediaType = "{{.mediaType}}"
    type      = "{{.type}}" 
    {{- end}}
  }
]
```

So to get a user by ID and transform the output to `HCL` format, run the following command:

```
gc users get [user_id] --transform=./tmpl.gotmpl
```

The output from running the above command is as follows:

```
id            = "f0eeb2e7-6307-46e8-bb29-f8a223d46acf"
name          = "John Doe"
email         = "john.doe@genesys.com"
state         = "active"
username      = "john.doe@genesys.com"
version       = "1"
acdAutoAnswer = "false"
selfUri       = "/api/v2/users/f0eeb2e7-6307-46e8-bb29-f8a223d46acf"

division {
  id      = "f0eeb2e7-6307-46e8-bb29-f8a223d46acf"
  name    = ""
  selfUri = "/api/v2/authorization/divisions/f0eeb2e7-6307-46e8-bb29-f8a223d46acf"
}

chat {
  jabberId = "23cfa207-7b56-424f-8799-60b6315b1971@genesys.com"
}

primaryContactInfo = [
  { 
    address   = "john.doe@genesys.com"
    mediaType = "EMAIL"
    type      = "PRIMARY"
  }
]
```

As you can see from the example above, the output data is now in `HCL` format.

## Final Thoughts

`Go` templates are a powerful way to transform data and with the new experimental `CLI` feature, you can customize output from the `CLI` however you want. To provide a `Go` template to the `CLI`, you can pass a template file path to the `--transform` flag or you can pass a "raw" template string to the `--transformstr` flag surrounded by single quotes. Thats all for this blog post, I hope you found it informative. If you have any feedback or issues, please feel free to reach out to us on the [developer forum](https://developer.genesys.cloud/forum/). Thanks for reading.

## Additional Resources

1. The new experimental feature Alternative Formats: [Introducing Alternative Formats in the CLI - blog post](https://developer.genesys.cloud/blog/2021-08-31-new-experimental-cli-feature-alternative-formats/).
2. Go's template package documentation: [text/template](https://pkg.go.dev/text/template).
3. Terraforms styling  conventions: [Style conventions in Terraform](https://www.terraform.io/docs/language/syntax/style.html)
3. CLI install page: [Instructions on how to install the CLI.](https://developer.genesys.cloud/api/rest/command-line-interface/)
2. 20 minute video providing an introduction and preview to the CLI: [Introducing the CLI - DevDrop. ](https://www.youtube.com/watch?v=OnYDs5NsLpU)
3. 45 minute webinar on how to use the CLI: [Introducing the CLI - DevCast. ](https://www.youtube.com/watch?v=rb2xqZU5vNc)
4. 20 minute video on how to use Python and the CLI to bulk users between queues: [Using the CLI to move users between queues. ](https://www.youtube.com/watch?v=VmrBhVc6n1U)
5. Repository of various examples of how to use the CLI: [CLI Quick Hits Repository. ](https://github.com/MyPureCloud/quick-hits-cli)
6. Reach out to us on the [developer forum](https://developer.genesys.cloud/forum/).