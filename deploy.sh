#!/bin/bash
set -e

echo "Logging into ECR: $ECR_REPO"
aws ecr get-login-password --region $AWS_REGION | \
docker login --username AWS --password-stdin $ECR_REPO

echo "Pulling Docker image: $ECR_REPO:$IMAGE_TAG"
cd $APP_DIR
docker-compose down
docker-compose pull
docker-compose up -d
