#!/bin/bash

apt-get update
apt-get install -y docker.io
apt-get install -y ansible
systemctl start docker
systemctl enable docker

docker pull keretdodor/yolo5
docker run -d --restart always -e ${SQS_QUEUE_URL} -e ${DYNAMODB_TABLE_NAME} -e ${S3_BUCKET} -e ${ALIAS_RECORD} -e ${AWS_REGION} keretdodor/yolo5

