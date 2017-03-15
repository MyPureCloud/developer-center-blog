#!/bin/bash
export PATH=$PATH:/home/jenkins/bin

export S3_STATIC_ASSETBUCKET=developercenter-blog

export CDN_URL=$CLOUD_FRONT_URL/$S3_STATIC_ASSETBUCKET/$BUILD_NUMBER
echo $CDN_URL

ruby -v


cd $WORKSPACE

echo -e "\n====Creating build.properties====\n"
echo "WEB_APP_NAME=developercenter-blog
SOURCE_BUILD_NAME=$JOB_NAME
SOURCE_BUILD_NUMBER=$BUILD_NUMBER
S3_BUCKET=$S3_STATIC_ASSETBUCKET
AMI_ID=None
ROLE=developer_center
git@bitbucket.org:inindca/developer-center.git
EMAIL_LIST=kevin.glinski@inin.com" > ${WORKSPACE}/build.properties

source $HOME/.nvm/nvm.sh
nvm install v4.5.0
nvm use v4.5.0

# Clone build scripts repo into directory
rm -rf build-deploy-web-app && git clone git@bitbucket.org:inindca/build-deploy-web-app.git

# Run the standard before-build script
source ./build-deploy-web-app/before-build.sh

export CLOUD_FRONT_URL=https://d3a63qt71m2kua.cloudfront.net
export CDN_URL=$CLOUD_FRONT_URL/$S3_STATIC_ASSETBUCKET/$BUILD_NUMBER
echo $CDN_URL

cd $WORKSPACE
rm -rf developer-center-common && git clone git@bitbucket.org:inindca/developer-center-common.git

cd $WORKSPACE/repo

gem install io-console
gem install ffi --platform=ruby

bundle install

cd $WORKSPACE
