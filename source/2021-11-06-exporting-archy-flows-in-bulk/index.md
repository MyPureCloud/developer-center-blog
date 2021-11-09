---
title: 'Exporting all of the Architect flows in your organization'
date: 2021-11-09
tags: cli Archy developer engagement experimental transform data go templates
author: john.carnell
image: ./blog-img.png
category: 6
---

Greetings everyone. 2021 is almost done and 2022 is quickly approaching. Back in September, Prince Merzula wrote a [blog post](/blog/2021-09-15-archy-export-feature/) introducing how to use [Archy](/devapps/archy/), the Genesys Cloud Command Line Interface (CLI) for exporting and importing Architect flows. The Archy CLI is a powerful tool for managing flows, but it only allows you to manage a single flow at a time. As I have begun working this last quarter on building out CI/CD pipelines using [CX as Code](/api/rest/CX-as-Code/) I have often run into situations where I need to export all of the Architect flows in an organization so I can put the flows under source control management. While Archy allows you to export individual flows, it does not allow me to easily do this in "bulk".

Fortunately, I can accomplish this using a combination of the Archy CLI and the new **transform** feature in the Genesys Cloud CLI. Michael Roddy first introduced this feature in a [blog post](/blog/2021-10-01-experimental-feature-transform-data/) in early October. The Genesys Cloud CLI **transform** feature allows us to write a [GO templating language](https://pkg.go.dev/text/template) file that can be used to transform the data from the JSON output returned by the Genesys Cloud CLI into any format you want. Since the **transform** feature leverages a full templating language we can leverage conditional and looping constructs along with a number of helper functions using the [Sprig](http://masterminds.github.io/sprig/) library.

Using this feature, I can write a small template that will take the output from a `gc flows list -a` command to generate a set of `archy export` commands that can then be used to execute a series of Archy exports.

## Writing the transform

When we use the Genesys Cloud CLI command, `gc flows list -a`, we return a list of all the flows currently under management within a Genesys Cloud organization. For the purposes of this blog post, the output from the `gc flows list -a` command against my demonstration organization looks like this:

```json
[
  {
    "id": "037f2416-0bfc-4172-afe1-18a8989cae7e",
    "name": "Default In-Queue Flow",
    "division": {
      "id": "e2220f18-f824-4ade-adf8-7375c04e5eb6",
      "name": "Home",
      "selfUri": "/api/v2/authorization/divisions/e2220f18-f824-4ade-adf8-7375c04e5eb6"
    },
    "description": "This flow provides handling for calls waiting in a queue.",
    "type": "INQUEUECALL",
    "active": false,
    "system": true,
    "deleted": false,
    "checkedInVersion": {
      "id": "1.0",
      "name": "1.0",
      "commitVersion": "1.0",
      "configurationVersion": "1.0",
      "secure": false,
      "configurationUri": "/api/v2/flows/037f2416-0bfc-4172-afe1-18a8989cae7e/versions/1.0/configuration",
      "selfUri": "/api/v2/flows/037f2416-0bfc-4172-afe1-18a8989cae7e/versions/1.0"
    },
    "currentOperation": {
      "id": "9fa478a0-9e34-4b40-9753-951a443daf60",
      "complete": true,
      "client": {
        "id": "3dfb45d2-acbd-4709-a652-4114f1d782b8",
        "name": "CX as Code",
        "selfUri": "/api/v2/oauth/clients/3dfb45d2-acbd-4709-a652-4114f1d782b8"
      },
      "errorDetails": [],
      "actionName": "VALIDATE",
      "actionStatus": "SUCCESS"
    },
    "selfUri": "/api/v2/flows/037f2416-0bfc-4172-afe1-18a8989cae7e"
  },
  ...  //Shortened for conciseness
]
```

While I am only showing one Architect flow in the above code snippet, there are 4 Architect flows in the actual payload returned for my organization. For the transform we are going to need to pull the `name` of the flow and the `type` of the flow out of the JSON being returned and inject it into an Archy command. When all is said and done, I should have 4 `archy export` commands being created. The transform is shown below:

```go
{{- range . -}}{{printf "archy export --flowName \"%s\" --flowType %s --exportType yaml --outputDir output --force\n" .name (lower .type)}}{{end}}
```

There are a fews things to note here. First, all of the data injected into this call is an array of records. Each record is a map of key/value pairs representing the JSON data being returned from the CLI. Embedded JSON objects in the payload are represented as a combination of arrays and maps. Second, to walk through each record we are going to use the `range` keyword. Then we are going to use the `printf` function to build a string containing each `archy export` command. Each value to be injected is going to be done via a `%s` placeholder.  The `flowName` and `flowType` command line parameters are injected by using the `.name` and `.type` values. The `.` allows us to access the current record being looped over by the `range` command. Since the `flowType` value is always lowercased, but stored in the backend as uppercase, I use the Sprig function `lower` to convert `.type` value to lowercase.

:::{"alert":"warning","title":"A word on flowType","autoCollapse":false}
One thing to be aware of is that it is possible to have different types of Architect flows with the exact same name. This is one of the reasons why the `flowType` variable is a required on an `archy export`. If you do have multiple flows with the same name, first consider renaming the flows. If that is not option, you might need to be build multiple transform files specific to each flow type and process each flow type independently going to their own `outputDir`. The reason for this is that the `archy export` currently does not allow you to specify the name of the outputted file being created. Multiple flow types with the same name would create a situation where the `archy export` commands would end up overwriting the previous file of a different type.  
:::

## Executing the transform

Let's put the transform shown above into a file called `archy_export_all.tmpl` and use it in our `gc flows list` command.

`gc flows list -a -transform archy_export_all_tmpl`

The output from this command, as run against my Genesys Cloud organization, looks like this:

```shell
archy export --flowName "Default In-Queue Flow" --flowType inqueuecall --exportType yaml --outputDir output --force
archy export --flowName "trsy" --flowType inboundcall --exportType yaml --outputDir output --force
archy export --flowName "SimpleFinancialIvr" --flowType inboundcall --exportType yaml --outputDir output --force
archy export --flowName "EmailAWSComprehendFlow" --flowType inboundemail --exportType yaml --outputDir output --force
```

You can redirect this output to a shell (or bat file for windows):

`gc flows list -a -transform archy_export_all_tmpl > export_architect_flows.sh`

Once the `archy export` commands are exported to a file you can execute the file to carry out the export of the Architect flows:

`./export_architect_flows.sh`

## Final Thoughts

Using the technique above you could easily write a nightly job to export all of your flows to the filesystem and then check them into source control. It is definitely not the most elegant code in the world, but system administration on any platform is a represents a constant tension between elegance and pragmatism. The **transform** feature is incredibly useful when you have to take the data from Genesys Cloud and "mash" into another format. Remember, the outputted format does not have to just be data, but also commands you could execute against other systems and platforms. 

## Additional Resources

1. [Introducing the Archy export feature](/blog/2021-09-15-archy-export-feature/)
2. [Archy](/devapps/archy/)
2. [CX as Code](/api/rest/CX-as-Code/)
3. [The Genesys Cloud CLI transform feature](/blog/2021-10-01-experimental-feature-transform-data/)
4. [Golang Templating Language](https://pkg.go.dev/text/template)
5. [Sprig Templating Library](http://masterminds.github.io/sprig/)
6. [DevDrop - Exporting Architect flows](https://youtu.be/QAmkM_agsrY)
7. [DevDrop - Using the CLI Transform function](https://youtu.be/XLn5lIV6POY) 
