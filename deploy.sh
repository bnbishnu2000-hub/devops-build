#!/usr/bin/env bash
# Deploys the image recorded by build.sh on port 80 and verifies it responds.
set -euo pipefail
cd "$(dirname "$0")"

if [[ -z "${IMAGE:-}" && -f image.env ]]; then
  source image.env
fi
: "${IMAGE:?IMAGE is not set. Run build.sh first or export IMAGE=<repo>:<tag>}"
export IMAGE

if ! docker image inspect "${IMAGE}" >/dev/null 2>&1; then
  if [[ -n "${DOCKER_USER:-}" && -n "${DOCKER_PASS:-}" ]]; then
    echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin
  fi
  docker pull "${IMAGE}"
fi

echo ">> Deploying ${IMAGE} on port 80"
docker compose up -d --no-build --remove-orphans

for _ in $(seq 1 15); do
  if curl -fs -o /dev/null http://127.0.0.1:80/; then
    echo ">> Deployment healthy: ${IMAGE}"
    docker image prune -f >/dev/null
    exit 0
  fi
  sleep 2
done

echo "ERROR: application did not respond on port 80." >&2
docker compose logs --tail=50
exit 1
