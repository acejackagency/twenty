# Railway Deployment Guide for Twenty CRM

## 📋 Overview

This guide will help you deploy Twenty CRM to Railway with proper environment configuration.

## 🚀 Setup Steps

### 1. Create Two Railway Services

You need **TWO separate services** in Railway:

#### Service 1: Backend (twenty-server)
- **Name**: `twenty-backend` (or your choice)
- **Root Directory**: `packages/twenty-server`
- **Build Command**: `npx nx build twenty-server`
- **Start Command**: `node dist/packages/twenty-server/main.js`

#### Service 2: Frontend (twenty-front)
- **Name**: `twenty-frontend` (or your choice)
- **Root Directory**: `packages/twenty-front`
- **Build Command**: `npx nx build twenty-front`
- **Start Command**: `npx serve -s dist/packages/twenty-front -l $PORT`

### 2. Add Required Railway Services

Add these services to your Railway project:
- **PostgreSQL** - Database
- **Redis** - Caching and queues

### 3. Configure Environment Variables

#### Frontend Service Variables

1. Go to your **Frontend service** in Railway
2. Click on **Variables** tab
3. Click **Raw Editor**
4. Copy the contents of `railway-frontend-env.json`
5. Replace `https://your-backend-service.up.railway.app` with your actual backend Railway URL
6. Save

**Example:**
```json
{
  "REACT_APP_SERVER_BASE_URL": "https://twenty-backend-production.up.railway.app"
}
```

#### Backend Service Variables

1. Go to your **Backend service** in Railway
2. Click on **Variables** tab
3. Click **Raw Editor**
4. Copy the contents of `railway-backend-env.json`
5. Fill in the following values:

**Required Changes:**

- `APP_SECRET`: Generate with `openssl rand -base64 32`
- `FRONTEND_URL`: Your frontend Railway URL (e.g., `https://twenty-frontend-production.up.railway.app`)
- `SERVER_URL`: Your backend Railway URL (e.g., `https://twenty-backend-production.up.railway.app`)
- `STORAGE_S3_ENDPOINT`: Your Cloudflare R2 endpoint (format: `https://ACCOUNT_ID.r2.cloudflarestorage.com`)
- `STORAGE_S3_NAME`: Your R2 bucket name
- `STORAGE_S3_ACCESS_KEY_ID`: Your R2 access key ID
- `STORAGE_S3_SECRET_ACCESS_KEY`: Your R2 secret access key

**Keep as-is (Railway auto-fills):**
- `PG_DATABASE_URL`: `${{Postgres.DATABASE_URL}}`
- `REDIS_URL`: `${{Redis.REDIS_URL}}`

### 4. Generate APP_SECRET

Run this command in your terminal:
```bash
openssl rand -base64 32
```

Copy the output and use it as your `APP_SECRET` value.

### 5. Get Cloudflare R2 Credentials

1. Log into Cloudflare Dashboard
2. Go to **R2** section
3. Find your bucket or create a new one
4. Click **Manage R2 API Tokens**
5. Create a new API token with read/write permissions
6. Copy:
   - Account ID (for the endpoint URL)
   - Access Key ID
   - Secret Access Key
7. Your endpoint format: `https://ACCOUNT_ID.r2.cloudflarestorage.com`

### 6. Deploy

1. Save all environment variables
2. Railway will automatically redeploy both services
3. Wait for deployments to complete
4. Visit your **frontend URL** (not backend!)

## 🔍 Troubleshooting

### Issue: Getting `{"statusCode":404,"message":"Cannot GET /","error":"Not Found"}`

**Solution**: You're accessing the backend URL instead of the frontend URL. Make sure you're visiting the frontend service URL.

### Issue: Frontend can't connect to backend

**Solution**: Check that `REACT_APP_SERVER_BASE_URL` in frontend matches your backend Railway URL exactly (no trailing slash).

### Issue: Database connection errors

**Solution**: Ensure PostgreSQL service is added to your Railway project and `PG_DATABASE_URL` uses the variable reference `${{Postgres.DATABASE_URL}}`.

### Issue: Storage/upload errors

**Solution**: Verify all Cloudflare R2 credentials are correct:
- Endpoint URL format is correct
- Access keys have proper permissions
- Bucket name matches exactly

## 📝 Important Notes

- **Frontend** only needs ONE variable: `REACT_APP_SERVER_BASE_URL`
- **Backend** needs all database, Redis, and storage credentials
- Never commit `APP_SECRET` or API keys to your repository
- Use different secrets for production vs development
- Railway's `${{ServiceName.VARIABLE}}` syntax auto-references other services

## ✅ Verification Checklist

- [ ] Two separate Railway services created (frontend + backend)
- [ ] PostgreSQL service added
- [ ] Redis service added
- [ ] Frontend has only `REACT_APP_SERVER_BASE_URL` variable
- [ ] Backend has all required variables filled in
- [ ] `APP_SECRET` generated and set
- [ ] Cloudflare R2 credentials configured
- [ ] Frontend URL points to backend URL
- [ ] Backend URL points to itself
- [ ] Both services deployed successfully
- [ ] Accessing frontend URL (not backend URL)

## 🎯 Quick Reference

**Frontend needs:**
- `REACT_APP_SERVER_BASE_URL` → Backend Railway URL

**Backend needs:**
- Database connection (auto from Railway)
- Redis connection (auto from Railway)
- APP_SECRET (you generate)
- Frontend URL (your frontend Railway URL)
- Server URL (your backend Railway URL)
- Cloudflare R2 credentials (from Cloudflare dashboard)

---

**Need help?** Check the Railway logs for each service to see specific error messages.
