#!/bin/bash

apt-get update
apt-get install -y docker.io
apt-get install -y ansible
systemctl start docker
systemctl enable docker

docker pull keretdodor/yolo5
docker run -d --restart always keretdodor/yolo5

