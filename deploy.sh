#!/bin/bash

set -e

echo "Stopping existing application..."

docker compose down

echo "Building and deploying application..."

docker compose up -d --build

echo "Deployment completed successfully."

docker compose ps
