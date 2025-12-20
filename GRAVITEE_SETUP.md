# Gravitee.io API Management Platform with YugabyteDB, Vault, and APISIX Integration

This replaces Backstage with Gravitee.io for API management, developer portal, and service governance.

## Architecture

```
┌─────────────────┐    ┌──────────────┐    ┌─────────────────┐
│ Developer       │───▶│ Gravitee     │───▶│ APISIX Gateway  │
│ Portal          │    │ Management   │    │                 │
│ (API Requests)  │    │ API          │    │                 │
└─────────────────┘    └──────────────┘    └─────────────────┘
         │                       │                     │
         ▼                       ▼                     ▼
┌─────────────────┐    ┌──────────────┐    ┌─────────────────┐
│ Gravitee        │    │ YugabyteDB   │    │ Backend APIs    │
│ Gateway         │───▶│ (Database)   │    │                 │
│ (API Runtime)   │    │              │    │                 │
└─────────────────┘    └──────────────┘    └─────────────────┘
```

## Key Features

### 🔐 **Security & Access Management**
- **API Access Requests**: Developers request access through portal
- **Approval Workflows**: Admin approval for sensitive APIs
- **API Key Management**: Generate, rotate, revoke API keys
- **JWT Authentication**: Token-based auth for all APIs
- **Vault Integration**: All secrets managed via HashiCorp Vault

### 🔍 **Service Discovery**
- **Kubernetes Annotations**: Auto-discover services like Teleport
- **APISIX Sync**: Automatically configure routes in APISIX
- **Service Catalog**: Browse available internal APIs
- **Health Monitoring**: Track API health and metrics

### 📊 **Developer Experience**  
- **Self-Service Portal**: Request access to APIs
- **API Documentation**: Auto-generated from OpenAPI specs
- **Usage Analytics**: Track API consumption and performance
- **Rate Limiting**: Per-user/per-app rate limits

### 🏗️ **Infrastructure**
- **YugabyteDB**: Distributed SQL database for all data
- **Vault**: Centralized secrets management
- **RBAC**: Kubernetes role-based access control
- **ArgoCD**: GitOps deployment pipeline

## Service Annotations for Auto-Discovery

Services can be automatically discovered and added to the API catalog using annotations:

```yaml
apiVersion: v1
kind: Service
metadata:
  annotations:
    gravitee.io/expose: "true"
    gravitee.io/context-path: "/api/users"
    gravitee.io/auth-required: "jwt"
    gravitee.io/approval-required: "admin"
    gravitee.io/definition-summary: "User management API"
    gravitee.io/definition-description: "User management API"
    gravitee.io/definition-version: "v1"
    gravitee.io/definition-tags: "users,auth"
    gravitee.io/definition-openapi-url: "https://example.com/openapi.yaml"
spec:
  # your service configuration
```

Discovery watches all namespaces by default; set `K8S_NAMESPACE` to restrict scope.

See `GRAVITEE_ANNOTATIONS.md` for the full supported annotation list and formats.

## Operator-Based Discovery

Annotation discovery is handled by the Gravitee Kubernetes Operator (GKO) plus a small
sync controller that converts service annotations into `ApiV4Definition` resources.

Apply the operator and sync manifests:

```bash
kubectl apply -f manifests/09-gravitee-operator.yaml
kubectl apply -f manifests/10-gravitee-annotation-sync.yaml
```

## Deployment

1. **Build Images**: `./build-gravitee-images.sh`
2. **Apply Manifests**: ArgoCD automatically deploys from Git
3. **Access Portal**: `https://your-domain.com/gravitee/`

## Configuration

- **Management API**: `gravitee-management-api.k8s-api-gateway.svc.cluster.local:8083`
- **Gateway**: `gravitee-gateway.k8s-api-gateway.svc.cluster.local:8082`  
- **Portal**: `gravitee-portal.k8s-api-gateway.svc.cluster.local:8080`
- **Database**: YugabyteDB with `gravitee` schema
- **Secrets**: All stored in Vault under `secret/gravitee/`
