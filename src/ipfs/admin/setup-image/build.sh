#!/bin/bash
AWS_ACCESS_KEY_ID= # required unless IAM_ROLE is set
AWS_SECRET_ACCESS_KEY= # required unless IAM_ROLE is set
S3_ACL=private # default, optional
S3_BUCKET= # required
IAM_ROLE= # optional IAM role name, for usage on EC2.

docker build -t setup-docker-build .
read -p "Press any key to finish ..."
