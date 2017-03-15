#!/bin/bash
export PATH=$PATH:/home/jenkins/bin

#Copy to S3
#copy everything except svg
aws s3 cp $WORKSPACE/repo/localBuild/ s3://inin-static-assets/$S3_STATIC_ASSETBUCKET/$BUILD_NUMBER --recursive --exclude "*.svg" --acl "public-read"
#content type of svg needs to be explicitly set
aws s3 cp $WORKSPACE/repo/localBuild/ s3://inin-static-assets/$S3_STATIC_ASSETBUCKET/$BUILD_NUMBER --recursive --exclude "*" --include "*.svg" --acl "public-read" --content-type "image/svg+xml"
aws s3 sync s3://inin-static-assets/$S3_STATIC_ASSETBUCKET/$BUILD_NUMBER s3://inin-index-files-dev/developercenter --include "*" --acl "public-read" --cache-control "max-age=0, no-cache, no-store" --metadata-directive REPLACE --delete
