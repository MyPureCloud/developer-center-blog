
# PureCloud Developer Center Blog
This is the repository that contains the content for blogs located at https://developer.mypurecloud.com/blog/.  New Blogs are accepted through pull requests.

# Contributing

1) Fork this repository to your own github account.
2) Create a new folder for your article following the pattern YYYY-MM-DD-title
3) Create a index.html.markdown file in your new folder and write your article in this file. See below for required properties at the start of the file.
4) Create an author bio (see below).
5) Run locally to make sure formatting looks correct (Optional but recommended)
6) Submit a pull request back to origin master

## Markdown tips

* Don't use h1 headers in your article, the title is inserted as a h1 and any section headers below that should start at h2 (markdown ##)
* Code blocks should be surrounded by ~~~ unlike the backticks used in Github Markdown
* Images can be included in your article folder and included in markdown using ~~~![alt text](image.png "Logo Title Text 1")~~~

## Required Properties
Each index.html.markdown file starts off with a couple required parameters which contain metadata about the article such as:

```
---
title: article
date: YYYY-MM-DD
tags: tag1, tag2
author: joe@example.com
---
```

Where

Parameter | Description
--------- | -----------
title     | Article title
date      | YYYY-MM-DD formatted date, this date should match the date specified in the containing folder
tags      | comma separated list of tags that apply to the article
author    | The email address of the author


## Author Bios

Author bios are injected to the bottom of the analytics page.  To add your author bio, edit data/authors.yml the valid properties that you can use are.


| Parameter | Description |
| --------- | -----------|
| email     | (required) Email address of the author |
| name      | (required) Author name |
| title     | (optional) Job title of the author |
| company   | (optional) Company of the author |
| twitter   | (optional) Author's twitter handle (exclude the @) |
| bio       | (required) Author bio describing who they are and what qualifications they have to be a SME. |


## Running locally

To run locally, you first need [Ruby installed](https://www.ruby-lang.org/en/documentation/installation/) as well as [Bundler](http://bundler.io/).  

1. Pull the repo locally, ```cd``` into the directory
2. Run ```bundle install``` to grab all the needed ruby gems.
3. Run ```startServer.sh``` or ```bundle exec middleman server```.  This will start a web app running on port 4567 using the same markdown engine that is used a build time. There will not be any css styling with this local site as we store all those assets in a different repository.
