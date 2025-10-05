# Docker Hub Deployment Guide for Twenty CRM

This guide shows you how to deploy your customized Twenty CRM to Railway using Docker Hub.

## Why This Approach?

Building Twenty CRM from source in Railway is complex due to:
- Monorepo build dependencies
- Yarn patches
- Vite configuration issues

**Solution**: Build Docker images locally (where it works) and push to Docker Hub for Railway to use.

## Prerequisites

1. **Docker Desktop** installed on your machine
2. **Docker Hub account** (free at https://hub.docker.com)
3. Your customized Twenty CRM code

## Setup Steps

### 1. Create Docker Hub Account

1. Go to https://hub.docker.com
2. Sign up for a free account
3. Remember your username (you'll need it)

### 2. Login to Docker Hub Locally

Open terminal and run:
```bash
docker login
```

Enter your Docker Hub username and password when prompted.

### 3. Configure Build Script

Edit `build-and-push.sh`:
```bash
DOCKER_USERNAME="your-actual-dockerhub-username"  # Change this!
```

Make the script executable:
```bash
chmod +x build-and-push.sh
```

### 4. Build and Push Your Images

Run the script:
```bash
./build-and-push.sh
```

This will:
- Build backend Docker image
- Build frontend Docker image
- Push both to Docker Hub

**Note**: First build takes 10-15 minutes. Subsequent builds are faster.

## Railway Configuration

### Backend Service (Twenty Worker)

1. Go to Railway → Backend Service → Settings
2. Under **Source**:
   - Click "Disconnect" (if connected to GitHub)
   - Click "Deploy Docker Image"
   - Enter: `your-dockerhub-username/twenty-server:latest`
3. Keep all existing environment variables
4. Set **Start Command**: `node dist/packages/twenty-server/src/main.js`

### Frontend Service (Twenty)

1. Go to Railway → Frontend Service → Settings
2. Under **Source**:
   - Click "Disconnect" (if connected to GitHub)
   - Click "Deploy Docker Image"
   - Enter: `your-dockerhub-username/twenty-frontend:latest`
3. Environment variables:
   - Keep: `REACT_APP_SERVER_BASE_URL` (pointing to backend)
   - Remove all backend-only variables (optional cleanup)

## Your Development Workflow

### Making Changes

1. **Edit code locally** (with AI, your IDE, etc.)
2. **Test locally** if needed
3. **Commit to GitHub** (for version control)
   ```bash
   git add .
   git commit -m "Your changes"
   git push
   ```
4. **Build new Docker images**
   ```bash
   ./build-and-push.sh
   ```
5. **Railway auto-deploys** the new images

### Updating Railway

Railway can auto-update when you push new images with the same tag (`latest`), or you can manually trigger a redeploy in Railway.

## Advanced: Versioning

Instead of using `latest`, you can version your images:

```bash
# In build-and-push.sh, change:
IMAGE_TAG="v1.0.1"  # Increment for each release

# Then in Railway, update to:
your-dockerhub-username/twenty-server:v1.0.1
```

This gives you more control over deployments.

## Troubleshooting

### Build Fails Locally

If Docker build fails on your machine:
```bash
# Clean Docker cache
docker system prune -a

# Try building again
./build-and-push.sh
```

### Railway Not Updating

1. Go to Railway service
2. Click "Deployments" tab
3. Click "Redeploy" on latest deployment

### Image Too Large

Docker images are large (2-3 GB). This is normal for Node.js applications. Docker Hub free tier allows this.

## Benefits of This Approach

✅ **Full control** - Edit anything you want locally
✅ **Version control** - Still use GitHub for code
✅ **Stable deployments** - Railway uses proven images
✅ **Fast Railway deploys** - No build step, just pull image
✅ **Easy rollbacks** - Keep old image versions
✅ **Professional workflow** - How real teams do it

## Summary

You get the best of both worlds:
- **Development**: Full flexibility with git and AI
- **Production**: Stable, fast deployments via Docker images

This is exactly how the Railway template works - it uses pre-built images. You're just building your own custom images instead of using the official ones!
