# Genesys Cloud Developer Center Blog

This is the repository that contains the content for blogs located at https://developer.genesys.cloud/blog/.  New Blogs are accepted through pull requests.

# Contributing

1. Fork this repository to your own github account
2. Create a new folder for your article following the pattern YYYY-MM-DD-title
3. Create an `index.md` file in your new folder and write your article in this file. This file should reside in a location like `source/2021-01-31-my-first-post/index.md`. See below for required properties at the start of the file.
4. Submit a pull request back to origin/master
	1. If you are a first-time author, please include your bio and image in a comment in the PR. See below for details.

## Content Guidelines

* Blog posts must be related to Genesys Cloud in some way
* No private/sensitive/NDA-required information; All content will be visible publicly on the internet.
* The target audience for the blog is prospective and existing Genesys Cloud customers with an entry-level to expert technical background. All blog posts should be at least somewhat technical in nature.
* If appropriate, try to include 1-3 images to make the blog post more visually appealing.
* Keep it professional; lighthearted humor is fine, but no cursing, politics, or NSFW content.

## Authoring tips

* Don't use h1 headers in your article, the title is inserted as a h1 and any section headers below that should start at h2 (markdown ##)
* The first paragraph immediately following the frontmatter will be used as the summary
* Images can be included in your article folder and included in markdown using `![alt text](image.png "Logo Title Text 1")`
* Blog posts won't be published on the site until the date in the folder name has elapsed (on or after)

## Required Properties

Each index.md file starts off with a frontmatter section that contains metadata about the article. The following properties must be specified:

| Parameter | Description |
| --------- | ----------- |
| title     | Article title |
| date      | YYYY-MM-DD formatted date, this date should match the date specified in the containing folder and should reflect the intended publication date for the post. |
| tags      | comma separated list of tags that apply to the article |
| author    | The name key of the author. Recommended format is `first.last`, but can be anything as long as there are no spaces or special characters. |
| image     | The filename of the image to display as the header image in the blog listing. This path must be relative to the directory the index.md file is in and must not be an absolute path. |
| category  | The taxonomy category number. See below for mappings. |

Example:

```
---
title: article
date: YYYY-MM-DD
tags: tag1, tag2
author: first.last
image: yourimage.png
category: 6
---
```

## Taxonomy Categories

Choose from the following options to categorize your blog post:

| ID | Category Name |
| --- | --- |
| 0 | Introduction to Genesys Cloud Development |
| 1 | Identity and Access Management |
| 2 | Organizations and People |
| 3 | Telephony Configuration and Integration |
| 4 | Flows, Schedules and Routing |
| 5 | Contact Center Configuration |
| 6 | Infrastructure and Integration |
| 7 | Communications Channels |
| 8 | Account Settings |
| 9 | Notification and Communication |
| 10 | Documents |
| 11 | Data Reporting and Quality |
| 12 | Workforce Management |

## Author Bios

Author bios are displayed at the bottom of the blog post. First-time authors should provide the following information when submitting their first post:

| Property | Required | Description |
| --- | --- | --- |
| name      | yes |	Your name, to be read by humans |
| title     | yes | Your job title |
| company   | yes | Your place of employment |
| bio       | yes | Up to a few sentences about yourself and what qualifies you as a SME |
| social.twitter   | | A twitter handle you'd like to link in your bio (exclude the @) |
| social.github   | | A github user or org you'd like to link in your bio (just the user or org name) |
| social.youtube   | | A youtube channel ID you'd like to link in your bio |
| social.linkedin   | | A linkedin profile ID you'd like to link in your bio |

This information should be submitted in the following YAML format, but any format will do as long as the information is clear.

```yaml
yuri.yeti:
  name: Yuri the Yeti
  title: Chief Development Officer
  company: Genesys
  bio: YAAAAARRRRRRRRGGGGGGGHHHHHH!!!!
  social:
    twitter: GenesysCloudDev
    github: MyPureCloud
    youtube: UCa6aKdzqTSEW_DiWWPll7ag
    linkedin: yuriinahurry
```

Additionally, attach an image of yourself in the comment with your bio. The image should be:

* a headshot from the shoulders-ish up. This can be a fun picture, but please keep it workplace-appropriate.
* in PNG format
* a square image, suggested 400x400 pixels
