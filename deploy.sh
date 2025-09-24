#!/usr/bin/env bash
set -e
IMAGE="vimalathanga/ci-cd-demo:${1:-latest}"

echo "🚀 Deploying $IMAGE to staging..."
docker rm -f ci-cd-demo || true
docker run -d --name ci-cd-demo -p 5000:5000 "$IMAGE"
echo "✅ Deployed $IMAGE and running on port 5000"
