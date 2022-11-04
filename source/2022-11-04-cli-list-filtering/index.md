---
title: Introducing the new filtercondition flag to the Genesys Cloud CLI
tags: Genesys Cloud, Developer Engagement, CLI
date: 2022-11-04
author: charlie.conneely
category: 6
---

Greetings, everyone! In this blog, I'm going to introduce the new `filtercondition` flag, which has been added to our [CLI tool](https://developer.genesys.cloud/devapps/cli/) as of `v49.2.0`. With this flag, you can filter list output by applying a condition against a field in the response object. So, let's get into some examples of how you can use this new feature. 

## Usage

In this scenario, let's say you want to retrieve the ID of a wrap-up code and you know the name is "Default Wrap-up Code". Previously, you might have listed all wrap-up codes and used `CTRL-F` to search the name. Now, you can use a direct equals comparison in the `filtercondition` flag as follows:

```bash
gc routing wrapupcodes list --autopaginate --filtercondition="name==Default Wrap-up Code"
```

If a wrap-up code with this name exists, it will be returned inside a json array. If not, "null" is returned.

You can use a regular expression:

```bash
gc routing wrapupcodes list --autopaginate --filtercondition="name match ^Default(.*)Code$"
```

**Note:** The expression provided after the `match` keyword is passed directly to the Match function in the [regexp package](https://pkg.go.dev/regexp). 

You can use the `contains` keyword if you know the name contains the word "Default":

```bash
gc routing wrapupcodes list --autopaginate --filtercondition="name contains Default"
```

You can also use the `contains` keyword on arrays: 

```bash
gc authorization roles list --autopaginate --filtercondition="permissions contains role_manager"
```

Filtering based on numeric or boolean values:

```bash
gc users list --autopaginate --filtercondition="version<=55"
```

```bash
gc users list --autopaginate --filtercondition="version>55"
```

```bash
gc users list --autopaginate --filtercondition="acdAutoAnswer==true"
```

Filtering based on a nested value: 

```bash
gc users list --autopaginate --filtercondition="division.name==Home"
```

## Closing Thoughts 

Our Platform CLI tool already provides a means of performing quick and easy API operations. Hopefully, this new feature will save a few from the mild heachache of hacking together some code, or of searching through large response objects. At the time of writing this, the feature does not support multiple conditions i.e. no AND/OR capabilities. Until otherwise, you may find [jq](https://stedolan.github.io/jq/) to be a very useful tool for performing complex manipulations on returned json data.

Thanks for reading!

## Additional resources 
1. [regexp.Match documentation](https://pkg.go.dev/regexp#Match)
2. [Genesys Cloud CLI](/devapps/cli/)
4. [jq](https://stedolan.github.io/jq/)