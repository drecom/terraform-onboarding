#!/bin/bash

ASSET_DIR="lambda_asset"
TEMP_DIR="/tmp"
UPLOAD_REGION="ap-northeast-1"
UPLOAD_BUCKET="drecom-lambda"
UPLOAD_FILE_ALL="lambda.zip"
UPLOAD_FILE_MAIN="lambda_main.zip"
UPLOAD_FILE_LIB="lambda_lib.zip"

# check current aws profile name
CURRENT_PROFILE=`aws configure list | grep profile | awk '{print $2}'`
echo "Current aws profile is <- $CURRENT_PROFILE -> "
echo "Is that OK with you ? yes/no"
read INPUT
# get user confirm
if [ -z $INPUT ] ; then
  ConfirmExecution
elif [ $INPUT = 'y' ] || [ $INPUT = 'yes' ] ; then
  echo "Here we go..."
  # compression
  cd ${ASSET_DIR}
  zip -r ${TEMP_DIR}/${UPLOAD_FILE_ALL}  ./* > /dev/null
  zip -r ${TEMP_DIR}/${UPLOAD_FILE_LIB} ./python > /dev/null
  zip -r ${TEMP_DIR}/${UPLOAD_FILE_MAIN} ./* > /dev/null
  
  # transfer to s3 bucket
  aws s3 cp ${TEMP_DIR}/${UPLOAD_FILE_ALL}  s3://${UPLOAD_BUCKET}/${UPLOAD_FILE_ALL}  --region ${UPLOAD_REGION}
  aws s3 cp ${TEMP_DIR}/${UPLOAD_FILE_MAIN} s3://${UPLOAD_BUCKET}/${UPLOAD_FILE_MAIN} --region ${UPLOAD_REGION}
  aws s3 cp ${TEMP_DIR}/${UPLOAD_FILE_LIB}  s3://${UPLOAD_BUCKET}/${UPLOAD_FILE_LIB}  --region ${UPLOAD_REGION}

else
  echo "Oops !"
  echo "Upload cancelled."
  exit 1
fi
