# Blue/Green Deployment with Nginx Auto-Failover

A complete implementation of Blue/Green deployment strategy with automatic failover using Nginx upstreams. This project demonstrates zero-downtime deployments, health-based routing, and automatic failover when applications fail.

##  Features

- **Blue/Green Deployment** - Two identical environments running simultaneously
- **Automatic Failover** - Nginx automatically switches to healthy backend
- **Zero Failed Requests** - Client requests are retried on failure
- **Header Preservation** - Maintains X-App-Pool and X-Release-Id headers
- **Chaos Testing** - Built-in endpoints to simulate failures
- **Health Checks** - Regular health monitoring of backends

##  Project Structure

```
blue-green-nginx/
├── .env                    # Environment configuration
├── .env.example           # Environment template
├── docker-compose.yml     # Service orchestration
├── deploy.sh              # Deployment script
├── test-submission.sh     # Testing script
├── app.js                 # Node.js test application
├── Dockerfile.blue        # Blue environment Dockerfile
├── Dockerfile.green       # Green environment Dockerfile
└── nginx/
    ├── nginx.conf.template # Nginx configuration template
    └── docker-entrypoint.sh # Nginx initialization script
```

##  How It Works

### Architecture
```
Client → Nginx (Port 8080) → Backend Upstream
                         │
                         ├── Blue App (Port 8081) - Primary
                         └── Green App (Port 8082) - Backup
```

### Key Components

1. **Nginx Load Balancer**
   - Routes traffic to Blue (primary) by default
   - Automatically fails over to Green when Blue fails
   - Preserves application headers
   - Implements retry logic with tight timeouts

2. **Application Features**
   - `GET /version` - Returns deployment info with headers
   - `GET /healthz` - Health check endpoint
   - `POST /chaos/start` - Simulates failures (timeout/errors)
   - `POST /chaos/stop` - Stops failure simulation

3. **Auto-Failover Logic**
   - Detects failures in 2-3 seconds
   - Retries failed requests on backup server
   - No client-facing errors during failover

##  Quick Start

### Prerequisites
- Docker
- Docker Compose

### 1. Clone and Setup
```bash
git clone https://github.com/asingo-paul/blue-green-nginx.git
cd blue-green-nginx
cp .env.example .env
# Edit .env if needed
```

### 2. Deploy
```bash
# Build and start services
chmod +x deploy.sh
./deploy.sh
```

### 3. Access Points
- **Main Load Balancer**: http://localhost:8080
- **Blue Instance**: http://localhost:8081
- **Green Instance**: http://localhost:8082

##  Testing

### Basic Health Check
```bash
curl http://localhost:8080/version
# Response: {"pool":"blue","release":"blue-release-1","timestamp":"..."}
```

### Auto-Failover Test
```bash
# 1. Start with Blue active
curl http://localhost:8080/version

# 2. Simulate failure on Blue
curl -X POST "http://localhost:8081/chaos/start?mode=error"

# 3. Verify automatic switch to Green
curl http://localhost:8080/version

# 4. Stop chaos
curl -X POST "http://localhost:8081/chaos/stop"
```

### Headers Verification
```bash
curl -I http://localhost:8080/version
# Should see: X-App-Pool and X-Release-Id headers
```

##  Configuration

### Environment Variables (.env)/ you can get my .env form or lets say it is the same as .env.example
```bash
# Application Images
BLUE_IMAGE=blue-green-blue:local
GREEN_IMAGE=blue-green-green:local

# Deployment Control
ACTIVE_POOL=blue
RELEASE_ID_BLUE=blue-release-1
RELEASE_ID_GREEN=green-release-1
PORT=8080
```

### Nginx Configuration
Key settings in `nginx/nginx.conf.template`:
- **Timeouts**: 2s connect, 3s read/write
- **Retry Logic**: 2 attempts on errors/5xx/timeouts
- **Header Preservation**: X-App-Pool, X-Release-Id
- **Health Checks**: Regular backend monitoring

##  Docker Services

### Application Services
- **app_blue**: Blue environment (port 8081)
- **app_green**: Green environment (port 8082)
- **nginx**: Load balancer (port 8080)

### Health Checks
Each service includes health monitoring:
```yaml
healthcheck:
  test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8080/healthz"]
  interval: 5s
  timeout: 3s
  retries: 3
```

## 🔧 Customization

### Adding New Endpoints
Update `app.js` with new routes - they automatically benefit from failover protection.

### Modifying Failover Behavior
Edit `nginx.conf.template`:
- Adjust `max_fails` and `fail_timeout` for sensitivity
- Modify `proxy_next_upstream` for different error handling
- Change timeouts for different response requirements

### Deployment Strategies
- **Blue Active**: Set `ACTIVE_POOL=blue`
- **Green Active**: Set `ACTIVE_POOL=green`
- **Canary**: Modify upstream weights in nginx config

## Troubleshooting

### Common Issues

1. **Ports already in use**
   ```bash
   docker-compose down
   # Wait for cleanup, then restart
   docker-compose up -d
   ```

2. **Containers not starting**
   ```bash
   docker-compose logs
   # Check specific service
   docker-compose logs nginx
   ```

3. **Failover not working**
   - Verify nginx config with `docker exec nginx_gateway nginx -t`
   - Check application health endpoints
   - Review nginx error logs

### Logs and Monitoring
```bash
# View all logs
docker-compose logs -f

# Specific service logs
docker-compose logs nginx
docker-compose logs app_blue

# Real-time monitoring
docker-compose ps
docker stats
```

##  Performance

- **Failover Time**: 2-5 seconds
- **Request Retry**: Within same client request
- **Header Preservation**: 100% consistent
- **Zero Downtime**: During deployments

##  Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/improvement`)
3. Commit changes (`git commit -am 'Add new feature'`)
4. Push branch (`git push origin feature/improvement`)
5. Create Pull Request

##  License

This project is for educational purposes as part of the DevOps internship program.

##  Acknowledgments

- Nginx for robust load balancing capabilities
- Docker for containerization
- HNG DevOps program for the learning opportunity

---

**Note**: This is a demonstration project for Blue/Green deployment patterns. In production, consider additional security measures, monitoring, and database migration strategies.

regards : ASINGO PAUL