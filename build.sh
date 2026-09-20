#!/usr/bin/env bash
# Builds the image and pushes it to the branch-mapped Docker Hub repository.
#   dev          -> <DOCKER_USER>/dev   (public)
#   main/master  -> <DOCKER_USER>/prod  (private)
set -euo pipefail
cd "$(dirname "$0")"

: "${DOCKER_USER:?DOCKER_USER must be set}"
: "${DOCKER_PASS:?DOCKER_PASS must be set}"

BRANCH="${1:-${BRANCH_NAME:-${GIT_BRANCH:-$(git rev-parse --abbrev-ref HEAD)}}}"
BRANCH="${BRANCH#origin/}"
TAG="${BUILD_NUMBER:-$(git rev-parse --short HEAD)}"

case "$BRANCH" in
  dev)         REPO="dev"  ;;
  main|master) REPO="prod" ;;
  *) echo "ERROR: branch '${BRANCH}' is not mapped to a Docker Hub repository." >&2; exit 1 ;;
esac

IMAGE="${DOCKER_USER}/${REPO}"

echo ">> Building ${IMAGE}:${TAG} (branch: ${BRANCH})"
docker build -t "${IMAGE}:${TAG}" -t "${IMAGE}:latest" .

echo ">> Pushing ${IMAGE}:${TAG} and ${IMAGE}:latest"
echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin
docker push "${IMAGE}:${TAG}"
docker push "${IMAGE}:latest"
docker logout >/dev/null

echo "IMAGE=${IMAGE}:${TAG}" > image.env
echo ">> Build complete: ${IMAGE}:${TAG}"
