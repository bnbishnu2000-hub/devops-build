#!/bin/bash

set -e

IMAGE_NAME="devops-build"
IMAGE_TAG="latest"

echo "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"

docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" .

echo "Docker image built successfully."
docker images "${IMAGE_NAME}"
