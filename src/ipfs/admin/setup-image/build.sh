#!/bin/bash
AWS_ACCESS_KEY_ID=AKIAWUFYU45RSPJGHIZK # required unless IAM_ROLE is set
AWS_SECRET_ACCESS_KEY=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 # required unless IAM_ROLE is set
S3_ACL=private # default, optional
S3_BUCKET=heroku-polls-user # required
IAM_ROLE= # optional IAM role name, for usage on EC2.

docker build -t setup-docker-build .
read -p "Press any key to finish ..."
