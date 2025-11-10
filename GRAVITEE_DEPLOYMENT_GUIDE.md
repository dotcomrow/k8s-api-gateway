# Gravitee API Management Platform - Deployment Guide

## 🎯 Overview

This deployment replaces Backstage with **Gravitee.io API Management Platform** while maintaining the same architectural principles:
- **YugabyteDB**: Distributed SQL database backend
- **HashiCorp Vault**: Centralized secrets management
- **Kubernetes RBAC**: Role-based access control
- **APISIX**: High-performance API gateway integration
- **Service Discovery**: Automatic API catalog from K8s annotations

## 📋 Components Deployed

### Core Gravitee Stack
- **Gravitee Management API** (Port 8083): Admin API and backend services
- **Gravitee Gateway** (Port 8082): API runtime execution engine  
- **Gravitee Portal** (Port 8080): Developer portal UI for API access requests

### Supporting Infrastructure
- **APISIX API Gateway** (Ports 9080/9443): High-performance API gateway with etcd
- **YugabyteDB**: PostgreSQL-compatible distributed database
- **HashiCorp Vault**: Secrets management and PKI
- **Kubernetes RBAC**: Fine-grained access control

## 🚀 Quick Start

### 1. Prerequisites
```bash
# Ensure you have the necessary tools
kubectl version --client
helm version

# Clone the repository
git clone <your-repo>
cd k8s-api-gateway
```

### 2. Build Custom Images
```bash
# Build Gravitee images with YugabyteDB support
./build-gravitee-images.sh

# Images will be tagged and pushed to GHCR:
# - ghcr.io/dotcomrow/gravitee-management-api:latest
# - ghcr.io/dotcomrow/gravitee-gateway:latest  
# - ghcr.io/dotcomrow/gravitee-portal:latest
```

### 3. Deploy the Platform
```bash
# Deploy the complete Gravitee platform
kubectl apply -f manifests/api-gateway-gravitee.yaml

# Monitor deployment progress
kubectl get pods -n k8s-api-gateway -w
```

### 4. Verify Installation
```bash
# Check all services are running
kubectl get all -n k8s-api-gateway

# Check database setup completion
kubectl logs -n k8s-api-gateway job/setup-yugabyte-gravitee-db

# Check Gravitee services health
kubectl logs -n k8s-api-gateway deployment/gravitee-management-api
kubectl logs -n k8s-api-gateway deployment/gravitee-gateway
kubectl logs -n k8s-api-gateway deployment/gravitee-portal

# Check APISIX route configuration
kubectl logs -n k8s-api-gateway job/configure-apisix-routes
```

## 🌐 Access URLs

After deployment, access the portal through APISIX routes:

```bash
# Get APISIX service endpoint
kubectl get svc -n k8s-api-gateway apisix

# Access URLs (replace <apisix-host> with actual host/IP):
# - Gravitee Portal: http://<apisix-host>/portal/
# - Management API: http://<apisix-host>/management/  
# - Gateway Runtime: http://<apisix-host>/gateway/
```

## 🔧 Configuration Details

### Database Schema
- **Database**: `gravitee` (replaces `backstage`)
- **Schema**: `gravitee` 
- **Connection**: YugabyteDB via PostgreSQL protocol
- **Credentials**: Managed via Vault (`yugabyte-db/static-creds/gravitee-app`)

### Vault Integration
All sensitive data is stored in HashiCorp Vault:
- `yugabyte-db/static-creds/gravitee-app`: Database credentials
- `secret/gravitee/jwt`: JWT signing secret
- `secret/apisix/admin`: APISIX admin API key

### RBAC Configuration
Service accounts with specific permissions:
- **gravitee**: Access to secrets and service discovery
- **apisix**: APISIX admin operations and route management

### APISIX Routes
Automatically configured routes for portal access:
- `/portal/*` → Gravitee Portal (public access)
- `/management/*` → Management API (authenticated)
- `/gateway/*` → Gateway runtime (API execution)

## 🔍 Service Discovery

Gravitee automatically discovers APIs from Kubernetes services using annotations:

```yaml
# Add to your service manifests for automatic discovery:
metadata:
  annotations:
    gravitee.io/definition-context-path: "/api/v1/myservice"
    gravitee.io/definition-summary: "My Service API"
    gravitee.io/definition-description: "Detailed description of the service"
    gravitee.io/definition-version: "1.0.0"
    gravitee.io/definition-groups: "internal,public"
```

## 🛠️ Troubleshooting

### Common Issues

1. **Database Connection Issues**
   ```bash
   # Check YugabyteDB status
   kubectl get pods -n yugabyte
   kubectl logs -n yugabyte deployment/yb-tserver
   
   # Check database setup job
   kubectl logs -n k8s-api-gateway job/setup-yugabyte-gravitee-db
   ```

2. **Vault Authentication Issues**
   ```bash
   # Check Vault status
   kubectl get pods -n vault
   kubectl logs -n vault deployment/vault
   
   # Check token copy job
   kubectl logs -n k8s-api-gateway job/vault-token-copy
   ```

3. **Gravitee Service Issues**
   ```bash
   # Check Gravitee pod logs
   kubectl logs -n k8s-api-gateway deployment/gravitee-management-api
   kubectl logs -n k8s-api-gateway deployment/gravitee-gateway
   kubectl logs -n k8s-api-gateway deployment/gravitee-portal
   ```

4. **APISIX Route Issues**
   ```bash
   # Check APISIX status
   kubectl logs -n k8s-api-gateway deployment/apisix
   
   # Check route configuration job
   kubectl logs -n k8s-api-gateway job/configure-apisix-routes
   
   # Manually check APISIX routes
   kubectl exec -n k8s-api-gateway deployment/apisix -- curl -H "X-API-KEY: <admin-key>" http://localhost:9180/apisix/admin/routes
   ```

### Health Check Commands
```bash
# Comprehensive health check
kubectl get pods -n k8s-api-gateway
kubectl get jobs -n k8s-api-gateway  
kubectl get services -n k8s-api-gateway

# Check all setup jobs completed
kubectl get jobs -n k8s-api-gateway | grep -E "(setup|configure|copy)" | awk '{print $1, $2}'
```

## 🔄 Migration Notes

### Differences from Backstage
- **Simpler Configuration**: No complex plugin system
- **Better API Management**: Native API portal and access workflows
- **Enhanced Performance**: Optimized for API management workloads
- **Integrated Gateway**: Native APISIX integration vs external setup

### Preserved Architecture
- Same YugabyteDB backend (different schema)
- Same Vault secrets management approach
- Same RBAC and security model
- Same Docker build and deployment patterns

## 📚 Additional Resources

- [Gravitee.io Documentation](https://docs.gravitee.io/)
- [APISIX Documentation](https://apisix.apache.org/docs/)
- [YugabyteDB Documentation](https://docs.yugabyte.com/)
- [HashiCorp Vault Documentation](https://www.vaultproject.io/docs/)

## 🎉 Next Steps

1. **Configure API Access Workflows**: Set up approval processes in Gravitee portal
2. **Add Service Discovery**: Annotate your services for automatic API catalog population
3. **Set up Monitoring**: Configure observability for the API platform
4. **Security Hardening**: Review and enhance security policies and access controls