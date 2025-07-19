# Deploying Gorush to Fly.io

This guide explains how to deploy gorush (push notification server) to Fly.io with FCM support.

## Prerequisites

1. [Fly.io account](https://fly.io/signup)
2. [Fly CLI installed](https://fly.io/docs/hands-on/install-flyctl/)
3. FCM service account JSON credentials

## Setup Instructions

### 1. Install Fly CLI

```bash
# macOS
brew install flyctl

# or via script
curl -L https://fly.io/install.sh | sh
```

### 2. Login to Fly.io

```bash
fly auth login
```

### 3. Launch the App

From the gorush directory:

```bash
fly launch
```

When prompted:
- Choose an app name (or accept the default)
- Select a region close to your users
- Don't create a PostgreSQL database
- Don't create a Redis database
- Don't deploy yet

### 4. Set FCM Credentials

Set your FCM credentials as a secret:

```bash
fly secrets set GOOGLE_APPLICATION_CREDENTIALS='paste-your-entire-json-here'
```

Or if you have the credentials in a file:

```bash
fly secrets set GOOGLE_APPLICATION_CREDENTIALS="$(cat path/to/your-service-account.json)"
```

### 5. Deploy

```bash
fly deploy
```

### 6. Verify Deployment

Check the app status:

```bash
fly status
```

View logs:

```bash
fly logs
```

Test the health endpoint:

```bash
curl https://your-app-name.fly.dev/healthz
```

## Testing Push Notifications

Send a test notification:

```bash
curl -X POST https://your-app-name.fly.dev/api/push \
  -H "Content-Type: application/json" \
  -d '{
    "notifications": [{
      "tokens": ["your-device-token"],
      "platform": 2,
      "message": "Hello from Fly.io!"
    }]
  }'
```

## Configuration

The app is configured via environment variables in `fly.toml`:

- `GORUSH_CORE_PORT`: Set to 8080 (Fly.io default)
- `GORUSH_ANDROID_ENABLED`: true
- `GORUSH_IOS_ENABLED`: false (set to true and add certs if needed)

To add more configuration:

```bash
fly secrets set GORUSH_LOG_LEVEL=debug
```

## Scaling

Fly.io automatically scales based on traffic. To manually scale:

```bash
# Scale to 2 instances
fly scale count 2

# Scale memory/CPU
fly scale vm shared-cpu-1x --memory 512
```

## Monitoring

View metrics:

```bash
fly dashboard
```

## Updating

To deploy updates:

```bash
git pull
fly deploy
```

## Troubleshooting

1. **Check logs**: `fly logs`
2. **SSH into container**: `fly ssh console`
3. **Check secrets**: `fly secrets list`
4. **Restart app**: `fly apps restart`

## Cost

Fly.io's free tier includes:
- 3 shared-cpu-1x VMs (256MB RAM)
- 160GB outbound data transfer
- Perfect for small to medium push notification workloads

## Advantages over Netlify Functions

- No environment variable size limits
- Persistent containers (better for push services)
- WebSocket support
- Built-in SSL/TLS
- Global edge network
- Better suited for long-running services