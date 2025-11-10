# 🏗️ Gravitee API Management Architecture

## 📊 System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        k8s-api-gateway                          │
│                         Namespace                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │   Portal    │    │ Management  │    │   Gateway   │         │
│  │   :8080     │◄───┤    API      │────┤    :8082    │         │
│  │             │    │   :8083     │    │             │         │
│  └─────────────┘    └─────────────┘    └─────────────┘         │
│         │                   │                   │              │
│         └───────────────────┼───────────────────┘              │
│                             │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    APISIX Gateway                       │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │   │
│  │  │   Gateway   │  │    Admin    │  │     etcd    │    │   │
│  │  │ :9080/:9443 │  │    :9180    │  │    :2379    │    │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                             │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                  YugabyteDB                             │   │
│  │              (gravitee schema)                          │   │
│  │         PostgreSQL Compatible                           │   │
│  └─────────────────────────────────────────────────────────┘   │
│                             │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                HashiCorp Vault                          │   │
│  │         - Database credentials                          │   │
│  │         - JWT secrets                                   │   │
│  │         - APISIX admin keys                             │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 🔗 Component Interactions

### 1. **API Portal Flow**
```
Developer → APISIX (/portal/*) → Gravitee Portal → Management API → YugabyteDB
```

### 2. **API Management Flow**  
```
Admin → APISIX (/management/*) → Management API → YugabyteDB
                                       ↓
                               APISIX Admin API (sync)
```

### 3. **API Runtime Flow**
```
Client → APISIX (/gateway/*) → Gravitee Gateway → Target API
                    ↓
              (policies applied)
```

### 4. **Service Discovery Flow**
```
K8s Services (annotations) → Management API → API Catalog → Portal
```

## 🚦 Traffic Routing (APISIX)

| Path | Target | Purpose |
|------|--------|---------|
| `/portal/*` | Gravitee Portal :8080 | Developer portal UI |
| `/management/*` | Management API :8083 | Admin operations |
| `/gateway/*` | Gravitee Gateway :8082 | API runtime |

## 🗄️ Data Architecture

### YugabyteDB Schema: `gravitee`
```sql
-- Core Gravitee tables (auto-created)
├── apis                    -- API definitions
├── applications           -- Developer applications  
├── subscriptions         -- API access subscriptions
├── plans                 -- API access plans
├── users                 -- Portal users
├── organizations         -- Multi-tenant orgs
└── events               -- Audit trail
```

### Vault Secrets Structure
```
├── yugabyte-db/static-creds/gravitee-app
│   ├── username          -- Database user
│   └── password          -- Database password
├── secret/gravitee/jwt
│   └── secret           -- JWT signing key
└── secret/apisix/admin
    └── key             -- APISIX admin API key
```

## 🔐 Security Model

### RBAC Permissions

#### **gravitee** ServiceAccount
- `secrets`: Read Vault-injected secrets
- `services`: List/watch for service discovery
- `endpoints`: List/watch for service discovery  
- `configmaps`: Read configuration

#### **apisix** ServiceAccount  
- `secrets`: Read APISIX admin keys
- `configmaps`: Read APISIX configuration

### Vault Integration
- **Agent injection**: Automatic secret mounting
- **Role-based access**: Each service account has specific Vault role
- **Secret rotation**: Vault manages credential lifecycle

## 📊 Resource Allocation

| Component | CPU Request | Memory Request | CPU Limit | Memory Limit |
|-----------|-------------|---------------|-----------|--------------|
| Management API | 200m | 512Mi | 2000m | 2Gi |
| Gateway | 100m | 256Mi | 1000m | 1Gi |
| Portal | 50m | 64Mi | 200m | 128Mi |
| APISIX | 200m | 256Mi | 1000m | 1Gi |
| APISIX etcd | 100m | 128Mi | 500m | 512Mi |

## 🔄 Startup Sequence

### 1. **Infrastructure** (Parallel)
- YugabyteDB cluster
- HashiCorp Vault
- Vault token distribution

### 2. **Database Setup** (Sequential)
```
vault-token-copy → setup-yugabyte-gravitee-db → setup-apisix-db
```

### 3. **Core Services** (Parallel after DB ready)
- APISIX etcd
- APISIX gateway  
- Gravitee Management API

### 4. **Frontend Services** (After core ready)
- Gravitee Gateway
- Gravitee Portal

### 5. **Configuration** (Final)
- APISIX route configuration
- Service discovery initialization

## 🔍 Health Checks & Monitoring

### Health Endpoints
- **Management API**: `/management/platform`
- **Gateway**: `/_node/health`
- **Portal**: `/` (HTTP 200)
- **APISIX**: TCP check on port 9080

### Key Metrics
- API request rates and latency
- Database connection pools
- Memory and CPU utilization
- Error rates and response codes

## 🌐 Network Policies

### Internal Communication
- All services communicate within cluster
- No external database or vault access needed
- APISIX serves as single entry point

### External Access
- APISIX gateway ports (9080/9443)
- Portal access via APISIX routes
- Management API via APISIX routes (authenticated)

## 🔄 Scaling Strategy

### Horizontal Scaling
- **Gravitee Gateway**: 2+ replicas (stateless)
- **APISIX**: 2+ replicas (stateless)
- **Management API**: 1 replica (can scale with session affinity)

### Vertical Scaling
- Gateway: Scale CPU for high throughput APIs
- Management API: Scale memory for large API catalogs
- APISIX: Scale both CPU/memory for high concurrent connections

This architecture provides a robust, scalable API management platform while maintaining all your infrastructure investments and security requirements.