---
title: New Account Switcher for Developer Tools
tags: Genesys Cloud, Developer Engagement, Developer Tools
date: 2021-08-17
author: ebenezer.osei
category: 6
---

Greetings everyone! The current developer tools doesn't support the ability to switch between accounts without having to logout and log back in. It can be annoying if you regularly use different accounts in the developer tools. The new account switcher solves this problem by saving your account information after you log in for the first time. It also gives you the ability to add other accounts once you are signed in, thereby, giving you the ability to switch between accounts without having to input your login details everytime.

## Using the Account Switcher

The new account switcher is already incorporated into the developer tools so you don't need any extra steps to utilize it.

Below was how the old side bar looked like:

![Old Account Switcher](old_account_switcher.png)

Here is the new look:

![New Account Switcher](new_account_switcher.png)

As shown above, there are 3 accounts currently signed in; the green one being the active account. You can easily switch to a different account by clicking on the account card. Once an account is selected, all operations will performed using the account's information.

## Confirm Changes

The confirm changes checkbox serves an important purpose. Due to the low effort in switching between accounts, some users may forget which account is currently active and perform crucial operations with the wrong account. To avoid such accidents, we included the confirm changes checkbox as a safeguard. It is totally optional for users. Once checked, you get a prompt in api-explorer whenever you try to make a non-GET request. To make this more effective, your confirm changes settings get saved even after you delete your account or your token gets expired. The settings then get reapplied once you log back in.

## Resources

This [Developer Drop](https://youtube.com) provide further details about the functionality of the account switcher.

## Feedback

If you have any feedback or issues with the new account switcher, please reach out to us on the [developer forum](/forum).
