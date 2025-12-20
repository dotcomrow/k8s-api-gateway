# 🚀 Gravitee API Management Platform

[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Gravitee](https://img.shields.io/badge/Gravitee-FF6900?style=flat&logo=gravitee&logoColor=white)](https://gravitee.io/)
[![YugabyteDB](https://img.shields.io/badge/YugabyteDB-FF6900?style=flat&logo=yugabyte&logoColor=white)](https://yugabyte.com/)
[![Vault](https://img.shields.io/badge/Vault-000000?style=flat&logo=vault&logoColor=white)](https://vaultproject.io/)
[![APISIX](https://img.shields.io/badge/APISIX-FF6900?style=flat&logo=apache&logoColor=white)](https://apisix.apache.org/)

> **Complete API Management Platform** with developer portal, access workflows, and integrated gateway - replacing Backstage while preserving infrastructure investments.

## 🎯 What This Provides

- **🌐 Developer Portal**: Self-service API discovery and access requests
- **⚡ High-Performance Gateway**: APISIX-powered API runtime with policies
- **🔐 Enterprise Security**: Vault-managed secrets with Kubernetes RBAC
- **📊 Service Discovery**: Automatic API catalog from Kubernetes annotations
- **🗄️ Distributed Database**: YugabyteDB for high availability and scalability

## 🏗️ Architecture

```
External Traffic → APISIX Gateway → Gravitee Services → YugabyteDB
                      ↓
                  Portal Routes:
                  /portal/*     → Developer Portal UI
                  /management/* → Admin API
                  /gateway/*    → Runtime API Gateway
```

## 📁 Project Structure

```
k8s-api-gateway/
├── 📋 Deployment
│   ├── manifests/
│   │   ├── api-gateway-gravitee.yaml    # 🆕 Complete Gravitee platform (1,429 lines)
│   │   └── api-gateway.yaml             # Original mixed Backstage/Gravitee
│   └── gravitee-deployments.yaml       # Standalone Gravitee components
│
├── 🔨 Build System  
│   ├── build-gravitee-images.sh         # 🆕 Docker build automation
│   └── src/
│       ├── Dockerfile.gravitee          # 🆕 Multi-stage Gravitee builds
│       ├── Dockerfile.backstage         # Original Backstage build
│       └── gravitee-config/             # 🆕 Configuration templates
│           ├── management-api/gravitee.yml
│           ├── gateway/gravitee.yml
│           └── portal/constants.json
│
├── 📚 Documentation
│   ├── README.md                        # This file
│   ├── ARCHITECTURE.md                  # 🆕 System architecture details  
│   ├── GRAVITEE_SETUP.md               # 🆕 Technical setup guide
│   ├── GRAVITEE_DEPLOYMENT_GUIDE.md    # 🆕 Step-by-step deployment
│   └── MIGRATION_COMPLETE.md           # 🆕 Migration summary
│
└── 🔧 Utilities
    └── verify-migration.sh              # 🆕 Deployment verification script
```

## 🚀 Quick Start

### 1. **Verify Setup**
```bash
./verify-migration.sh
```

### 2. **Build Images** 
```bash
./build-gravitee-images.sh
```

### 3. **Deploy Platform**
```bash
kubectl apply -f manifests/api-gateway-gravitee.yaml
```

### 4. **Monitor Deployment**
```bash
kubectl get pods -n k8s-api-gateway -w
```

### 5. **Access Portal**
```bash
# Get APISIX endpoint
kubectl get svc -n k8s-api-gateway apisix

# Access Gravitee Portal
open http://<apisix-host>/portal/
```

## ⚙️ Core Components

| Component | Port | Purpose | Replicas |
|-----------|------|---------|----------|
| **Gravitee Portal** | 8080 | Developer portal UI | 1 |
| **Management API** | 8083 | Admin backend | 1 |
| **Gravitee Gateway** | 8082 | API runtime engine | 2 |
| **APISIX Gateway** | 9080/9443 | Traffic routing | 2 |
| **APISIX Admin** | 9180 | Gateway config | - |
| **etcd** | 2379 | APISIX storage | 1 |

## 🔐 Security Features

- **🔒 Vault Integration**: All secrets managed by HashiCorp Vault
- **👤 RBAC**: Kubernetes role-based access control
- **🛡️ Service Accounts**: Dedicated permissions per component
- **🔑 JWT Authentication**: Token-based portal access
- **🌐 CORS Support**: Cross-origin resource sharing
- **📋 Audit Trail**: Complete API access logging

## 🔍 Service Discovery

Add annotations to your Kubernetes services for automatic API catalog population:

```yaml
metadata:
  annotations:
    gravitee.io/expose: "true"
    gravitee.io/definition-context-path: "/api/v1/my-service"
    gravitee.io/definition-summary: "My Service API" 
    gravitee.io/definition-description: "Detailed service description"
    gravitee.io/definition-version: "1.0.0"
    gravitee.io/definition-groups: "internal,public"
    gravitee.io/definition-tags: "internal,public"
    gravitee.io/definition-openapi-url: "https://example.com/openapi.yaml"
```

Full annotation list and formats: `GRAVITEE_ANNOTATIONS.md`.

Discovery watches all namespaces by default; set `K8S_NAMESPACE` to restrict scope.

Install the Gravitee Kubernetes Operator and annotation sync controller:

```bash
kubectl apply -f manifests/09-gravitee-operator.yaml
kubectl apply -f manifests/10-gravitee-annotation-sync.yaml
```

## 📊 Key Benefits

### ✅ **Vs Backstage**
- **Simpler**: No complex plugin ecosystem
- **Faster**: Purpose-built for API management  
- **Reliable**: No pg-native compatibility issues
- **Feature-Rich**: Native API portal capabilities

### ✅ **Preserved Infrastructure**
- **YugabyteDB**: Same distributed database (new schema)
- **HashiCorp Vault**: Identical secrets management
- **Kubernetes RBAC**: Same security model
- **Docker**: Same build patterns and registry

## 🛠️ Operations

### **Health Checks**
```bash
# Check all services
kubectl get pods -n k8s-api-gateway

# Verify setup jobs completed  
kubectl get jobs -n k8s-api-gateway

# Test portal access
curl http://<apisix-host>/portal/
```

### **Logs & Troubleshooting**
```bash
# Gravitee services
kubectl logs -n k8s-api-gateway deployment/gravitee-management-api
kubectl logs -n k8s-api-gateway deployment/gravitee-gateway  
kubectl logs -n k8s-api-gateway deployment/gravitee-portal

# APISIX gateway
kubectl logs -n k8s-api-gateway deployment/apisix

# Database setup
kubectl logs -n k8s-api-gateway job/setup-yugabyte-gravitee-db
```

### **Scaling**
```bash
# Scale Gravitee Gateway for higher throughput
kubectl scale -n k8s-api-gateway deployment/gravitee-gateway --replicas=3

# Scale APISIX for more concurrent connections
kubectl scale -n k8s-api-gateway deployment/apisix --replicas=3
```

## 📈 What's Next

1. **🎨 Customize Portal**: Brand the developer portal for your organization
2. **📋 Configure Workflows**: Set up API access approval processes  
3. **🔍 Add APIs**: Annotate services for automatic discovery
4. **📊 Enable Monitoring**: Add observability and metrics collection
5. **🔒 Enhance Security**: Implement additional authentication providers

## 📚 Documentation

- **[📖 ARCHITECTURE.md](./ARCHITECTURE.md)** - Detailed system architecture
- **[🚀 GRAVITEE_DEPLOYMENT_GUIDE.md](./GRAVITEE_DEPLOYMENT_GUIDE.md)** - Complete deployment guide  
- **[🔧 GRAVITEE_SETUP.md](./GRAVITEE_SETUP.md)** - Technical configuration details
- **[✅ MIGRATION_COMPLETE.md](./MIGRATION_COMPLETE.md)** - Migration summary and status

## 🎉 Migration Complete

**Successfully migrated from Backstage to Gravitee.io** while preserving all infrastructure investments and enhancing API management capabilities. The platform is ready for production deployment with comprehensive documentation and automation.

> **Ready to deploy?** See [GRAVITEE_DEPLOYMENT_GUIDE.md](./GRAVITEE_DEPLOYMENT_GUIDE.md) for step-by-step instructions.
