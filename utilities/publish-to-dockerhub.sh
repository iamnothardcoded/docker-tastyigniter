#!/bin/bash

# Script to publish TastyIgniter Docker image to Docker Hub
# Configuration for iamnothardcoded/tastyigniter

set -e

DOCKERHUB_USERNAME="iamnothardcoded"
IMAGE_NAME="tastyigniter"
VERSION="4.0.4"

# Wrapper for docker command (handles flatpak environment)
docker_cmd() {
    if command -v flatpak-spawn &> /dev/null; then
        flatpak-spawn --host docker "$@"
    else
        docker "$@"
    fi
}

echo "==> Building Docker image..."
cd "$(dirname "$0")/.."
docker_cmd build -f Dockerfile.dev -t ${IMAGE_NAME}:${VERSION} -t ${IMAGE_NAME}:latest .

echo ""
echo "==> Tagging image for Docker Hub..."
docker_cmd tag ${IMAGE_NAME}:${VERSION} ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${VERSION}
docker_cmd tag ${IMAGE_NAME}:latest ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest

echo ""
echo "==> Logging in to Docker Hub..."
echo "Please enter your Docker Hub password when prompted:"
docker_cmd login -u ${DOCKERHUB_USERNAME}

echo ""
echo "==> Pushing image to Docker Hub..."
docker_cmd push ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${VERSION}
docker_cmd push ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest

echo ""
echo "✅ Success! Your image is now available at:"
echo "   https://hub.docker.com/r/${DOCKERHUB_USERNAME}/${IMAGE_NAME}"
echo ""
echo "Others can pull it with:"
echo "   docker pull ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest"
echo "   docker pull ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${VERSION}"
