# 🐳 Gravitee.io Custom Docker Images

This directory contains optimized Dockerfiles for building custom Gravitee.io images with YugabyteDB support and Kubernetes integration.

## 📁 Structure

```
├── Dockerfile.management-api    # Management API with YugabyteDB drivers
├── Dockerfile.gateway          # Gateway with enhanced monitoring  
├── Dockerfile.portal           # Portal UI with custom configuration
├── src/gravitee-config/        # Configuration templates
└── .github/workflows/          # Automated builds
```

## 🚀 Automated Builds

Images are automatically built and pushed to GitHub Container Registry via GitHub Actions:

### 🎯 Triggers
- **Push to prod/main**: Builds and tags as `latest`
- **Pull Request**: Builds for testing (no push)
- **Manual Dispatch**: On-demand builds with custom suffix

### 🏷️ Image Tags
```bash
ghcr.io/dotcomrow/gravitee-management-api:latest
ghcr.io/dotcomrow/gravitee-management-api:prod-20241110-143022
ghcr.io/dotcomrow/gravitee-management-api:prod-sha-abc1234

ghcr.io/dotcomrow/gravitee-gateway:latest  
ghcr.io/dotcomrow/gravitee-gateway:prod-20241110-143022

ghcr.io/dotcomrow/gravitee-portal:latest
ghcr.io/dotcomrow/gravitee-portal:prod-20241110-143022
```

## 🔧 Key Features

### **Management API Image**
- ✅ **YugabyteDB Support**: Enhanced PostgreSQL JDBC driver (v42.7.4)
- ✅ **Database Tools**: PostgreSQL client for direct DB access
- ✅ **Debugging**: curl, wget, jq, netcat for troubleshooting
- ✅ **Health Checks**: Kubernetes-optimized readiness/liveness probes
- ✅ **Custom Config**: Pre-configured for YugabyteDB and Vault integration
- ✅ **Trace Context Policy**: Ships the `trace-context` policy plugin for API import validation

### **Gateway Image** 
- ✅ **Enhanced Monitoring**: Network debugging tools (tcpdump, netcat)
- ✅ **API Tools**: curl, jq for API testing and monitoring
- ✅ **Health Checks**: Custom endpoint monitoring for Kubernetes
- ✅ **Custom Config**: Pre-configured for APISIX integration
- ✅ **Trace Context Policy**: Ships the `trace-context` policy plugin for runtime execution

### **Portal Image**
- ✅ **Custom Branding**: Configurable UI elements and themes
- ✅ **OAuth Integration**: Pre-configured authentication templates  
- ✅ **Health Checks**: Nginx-optimized for Kubernetes deployments
- ✅ **Debugging Tools**: Basic tooling for frontend troubleshooting

## 🛠️ Manual Build (Development)

If you need to build locally for testing:

```bash
# Build individual services
docker build -f Dockerfile.management-api -t gravitee-management-api:test .
docker build -f Dockerfile.gateway -t gravitee-gateway:test .
docker build -f Dockerfile.portal -t gravitee-portal:test .

# Multi-architecture build
docker buildx build --platform linux/amd64,linux/arm64 \
  -f Dockerfile.management-api \
  -t ghcr.io/dotcomrow/gravitee-management-api:test .
```

## 🔐 Security Features

- ✅ **Vulnerability Scanning**: Automated Trivy security scans on every build
- ✅ **Non-Root Execution**: All services run as dedicated users (gravitee/nginx)
- ✅ **Minimal Surface**: Only essential packages installed
- ✅ **Multi-Architecture**: Built for AMD64 and ARM64 platforms
- ✅ **SARIF Reports**: Security findings uploaded to GitHub Security tab

## 🎛️ Configuration

All configuration templates are in `src/gravitee-config/`:

- **management-api/gravitee.yml**: Database, analytics, JWT settings
- **gateway/gravitee.yml**: Service discovery, caching, plugins  
- **portal/constants.json**: UI configuration, OAuth, documentation URLs

## 📊 Build Monitoring

Monitor builds in:
- **Actions Tab**: View build progress and logs
- **Packages**: See published container images
- **Security Tab**: Review vulnerability scan results

## 🚀 Deployment Integration

These images are referenced in:
- `manifests/04-gravitee-deployments.yaml`
- ArgoCD automatically pulls `latest` tags for deployments
- Vault Agent injects runtime secrets (no secrets in images)

## 🔄 Version Management

**Production Workflow:**
1. **Commit changes** to `src/` or `Dockerfile.*`
2. **GitHub Actions builds** and pushes new images automatically  
3. **ArgoCD detects** and deploys updated images to Kubernetes
4. **Vault injects** runtime configuration and secrets

No manual image building or shell scripts required! 🎉
