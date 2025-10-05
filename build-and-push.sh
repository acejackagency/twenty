#!/bin/bash

# Twenty CRM Docker Build and Push Script
# This script builds Docker images locally and pushes them to Docker Hub

set -e  # Exit on error

# Configuration - UPDATE THESE VALUES
DOCKER_USERNAME="your-dockerhub-username"  # Change this to your Docker Hub username
IMAGE_TAG="latest"  # You can use version numbers like "v1.0.0" instead

# Image names
BACKEND_IMAGE="${DOCKER_USERNAME}/twenty-server:${IMAGE_TAG}"
FRONTEND_IMAGE="${DOCKER_USERNAME}/twenty-frontend:${IMAGE_TAG}"

echo "🚀 Building Twenty CRM Docker Images..."
echo ""

# Build backend image
echo "📦 Building backend image..."
docker build -t ${BACKEND_IMAGE} -f Dockerfile .
echo "✅ Backend image built: ${BACKEND_IMAGE}"
echo ""

# Build frontend image
echo "📦 Building frontend image..."
docker build -t ${FRONTEND_IMAGE} -f Dockerfile.frontend .
echo "✅ Frontend image built: ${FRONTEND_IMAGE}"
echo ""

# Push to Docker Hub
echo "🔄 Pushing images to Docker Hub..."
echo "⚠️  Make sure you're logged in: docker login"
echo ""

# Push backend
echo "📤 Pushing backend image..."
docker push ${BACKEND_IMAGE}
echo "✅ Backend image pushed"
echo ""

# Push frontend
echo "📤 Pushing frontend image..."
docker push ${FRONTEND_IMAGE}
echo "✅ Frontend image pushed"
echo ""

echo "🎉 Done! Your images are now on Docker Hub:"
echo "   Backend:  ${BACKEND_IMAGE}"
echo "   Frontend: ${FRONTEND_IMAGE}"
echo ""
echo "📋 Next steps:"
echo "1. Go to Railway"
echo "2. Update your services to use these images"
echo "3. Railway will automatically pull and deploy them"
