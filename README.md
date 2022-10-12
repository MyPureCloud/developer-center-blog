# Genesys Cloud Developer Center blog

The Genesys Cloud Developer Center Blog repository, https://developer.genesys.cloud/blog/, contains blog content; new blogs are accepted through pull requests.

# Contributing

1. Fork the Genesys Cloud Developer Center Blog repository to your GitHub account
2. Create a New folder for your article using the following format YYYY-MM-DD-title
3. In the New folder, create an `index.md` file and write your article in this file. 

:::primary
**Note**: The file should reside in a location (for example, `source/2021-01-31-my-first-post/index.md`). For more information, see the required properties at the start of the file below.
:::

4. Submit a pull request to merge the changes to the origin/master.
  
:::primary
**Note**: If a first-time author, include your bio and image in a comment in the Pull Request (PR). For more information, see the Content Guidelines section.
:::

## Content guidelines

* Blog posts must be related to Genesys Cloud
* No private/sensitive/NDA information; All content will be visible publicly on the internet.
* The target audience is prospective and existing Genesys Cloud customers with an entry-level to expert technical background. All blog posts should be relatively technical.
* If appropriate, include 1-3 images to make the blog post more visually appealing.
* Keep it professional; lighthearted humor is fine; no cursing, politics, or Not Safe for Work (NSFW) content.

## Authoring tips

* Do not use h1 headers; the title is inserted as an h1, and any section headers below that should start with h2 (markdown ##).
* Anything before the first page (frontmatter) will be used as the summary
* Images can be included in your article folder and markdown using `![alt text](image.png "Logo Title Text 1")`
* Blog posts will not be published until the date in the folder name has elapsed (on or after)

## Required properties

Each index.md file starts with a frontmatter section that contains metadata about the article. The following properties must be specified:

| Parameter | Description |
| --------- | ----------- |
| title     | Article title |
| date      | YYYY-MM-DD formatted date, this date should match the date specified in the containing folder and reflect the intended publication date for the post. |
| tags      | comma-separated list of tags that apply to the article |
| author    | The name key of the author. The recommended format is `first.last`, but it can be anything if there are no spaces or special characters. |
| image     | The image's filename displays as the header image in the blog listing. This path must be relative to the directory the index.md file is in and must not be an absolute path. |
| category  | The taxonomy category number. The following is an example for mappings. |

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

## Taxonomy categories

Choose from the following options to categorize your blog post:

| ID | Category Name |
| --- | --- |
| 0 | Introduction to Genesys Cloud Development |
| 1 | Identity and Access Management |
| 2 | Organizations and People |
| 3 | Telephony Configuration and Integration |
| 4 | Flows, Schedules, and Routing |
| 5 | Contact Center Configuration |
| 6 | Infrastructure and Integration |
| 7 | Communications Channels |
| 8 | Account Settings |
| 9 | Notification and Communication |
| 10 | Documents |
| 11 | Data Reporting and Quality |
| 12 | Workforce Management |

## Author bios

Author bios are displayed at the bottom of the blog post. First-time authors should provide the following information when submitting their initial post:

| Property | Required | Description |
| --- | --- | --- |
| name      | yes | Your name, to be read by humans |
| title     | yes | Your job title |
| company   | yes | Your place of employment |
| bio       | yes | A few sentences about yourself and what qualifies you as a Subject Matter Expert (SME) |
| social.twitter   | | A Twitter handle to link in your bio (exclude the @) |
| social.github   | | A GitHub user or org to link in your bio (just the user or org name) |
| social.youtube   | | A YouTube channel ID to link in your bio |
| social.linkedin  | | A LinkedIn profile ID to link in your bio |

The information should be submitted in the YAML format, but any format will do as long as the information is clear.

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

Attach an image of yourself in the comment with your bio. The image should be:

* A head and shoulders shot. This can be a fun picture, but keep it workplace-appropriate.
* PNG format
* Square image, suggested 400x400 pixels