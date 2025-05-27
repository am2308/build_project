#!/bin/bash
set -e

echo "Building Docker image: $IMAGE_TAG"
docker build -t myapp:$IMAGE_TAG .

echo "Logging in to ECR: $TARGET_ECR"
aws ecr get-login-password --region $AWS_REGION | \
docker login --username AWS --password-stdin $TARGET_ECR

echo "Tagging image and pushing to"
docker tag myapp:$IMAGE_TAG $TARGET_ECR:$IMAGE_TAG
docker push $TARGET_ECR:$IMAGE_TAG
