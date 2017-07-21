---
title: Accessing the PureCloud data using SQL queries or MS Excel
date: 2017-07-21
tags: pcsd, sql, excel, data, analytics api
author: dariusz.socha@genesys.com
---

Our Platform API and SDKs are so smart. Personally I love to work with them as they allow to access PureCloud functions from my own application just by a few lines of code. The API is also platform independent and it can be accessed from PC, mobile app or even form an IoT device. It’s really useful and it allows to create valuable customisations for our customers. However, this is only an application developer point of view. Data analysts which aren’t familiarised with C# or JavaScript can have a different opinion on this. They do prefer SQL queries instead of LINQ expressions or CSV files in place of arrays and collections. The API acronym may sound strange for them.

The PureCloud shares the data through the API. Because we are a real cloud and multi-tenant solution we can’t give our customers access to a raw data in the database. Very often they ask about alternatives for accessing the data. The PureCloud Stats Dispatcher is an answer. PCSD is an open source tool created by PS team in the EMEA. It gives possibility to export the PureCloud data into external data sources. Today it supports two kinds of targets - SQL Server and CSV file, however thanks to its plugins architecture the tool can be easily extended to save the data to another source.

![diagram](diagram.png)

## Installation
In order to install the PCSD go to the [download page](https://bitbucket.org/eccemea/purecloud-stats-dispatcher/downloads/) and get the latest version of the application. Then execute the MSI installer and follow installation steps.

![installer](installer.png)

## oAuth configuration
PureCloud Stats Dispatcher connects to the system using oAuth integration. It means that in prior to first usage you have login to your PureCloud organisation and configure an oAuth app. To do this follow below steps:

* Login to PureCloud using administrative credentials.
* Navigate to: Admin -> Integrations -> OAuth.
* Click Add Client button.
* Enter following settings:
  * **App Name**: PCSD
  * **Description**: data exporting tool
  * **Grant Types**: Client Credentials
  * **Roles**: admin, Outbound Admin, Engage Supervisor
* Click Save button.
* Copy a new generated Client ID and Client Secret. You will need them to launch the PCSD.

![oauth](oauth.png)

## Export data to CSV

To export the data to CSV file you have to execute PCSD.exe application with following command prompt parameters:

* **clientid**: Client ID generated during configuration of oAuth integration.
* **clientsecret**: Client Secret generated during configuration of oAuth integration.
* **environment**: Environment's address based on your region, e.g. mypurecloud.ie for EMEA.
* **target-csv**: Full path of output file.

Sample command:

```
"C:\Program Files (x86)\Genesys\PureCloud Stats Dispatcher\PCSD.exe" /clientid=989898 /clientsecret=767676 /environment=mypurecloud.ie /target-csv="c:\temp\output.csv"
```

## Export data to SQL Server

To export the data to SQL Server you have to execute PCSD.exe application with following command prompt parameters:

* **clientid**: Client ID generated during configuration of oAuth integration.
* **clientsecret**: Client Secret generated during configuration of oAuth integration.
* **environment**: Environment's address based on your region, e.g. mypurecloud.ie for EMEA.
* **target-sql**: SQL Server connection string. As the tool automatically creates a database and tables you have to use an administrative account in the connection string.

Sample command:

```
"C:\Program Files (x86)\Genesys\PureCloud Stats Dispatcher\PCSD.exe" /clientid=989898 /clientsecret=767676 /environment=mypurecloud.ie /target-sql="Server=SQL0001; Database=PureCloudDb; User Id=sa; Password=p@ssw0rd”
```

## Periodically exports
We have designed the PCSD as a console application. You can use it on an ad hoc basis as well as schedule periodically exports, for instance by adopting the Windows Task Scheduler. PureCloud Stats Dispatcher remembers the finishing date and time of last export and use it as a default start time of the next process. So, consecutive PCSD launching gives you continuity of data in the database.

# Learn more
[PCSD project page](https://bitbucket.org/eccemea/purecloud-stats-dispatcher/overview)

[PCSD download page](https://bitbucket.org/eccemea/purecloud-stats-dispatcher/downloads/)