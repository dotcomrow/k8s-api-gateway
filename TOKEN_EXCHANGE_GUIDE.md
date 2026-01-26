# Token Exchange Guide

This guide documents the Gravitee -> Keycloak token exchange flow and how to add more services.

Overview
- Client sends a user access token to Gravitee.
- Gravitee validates the JWT (issuer + JWKS).
- Gravitee exchanges the user token at Keycloak for a target-audience token.
- Gravitee replaces the upstream Authorization header with the exchanged token.

Where the config lives
- Keycloak clients and exchange rules: `k8s-keycloak/manifests/keycloak.yaml`
  - `keycloak-client-config-external`: JSON definitions for external-realm clients
  - `keycloak-token-exchange-config`: rules for who can exchange to which targets
- Gravitee token exchange policy injection: `k8s-api-gateway/manifests/10-gravitee-annotation-sync.yaml`
- Gravitee gateway env + Vault wiring: `k8s-api-gateway/manifests/04-gravitee-deployments.yaml`
- Per-service enablement: add `gravitee.io/token-exchange-target` annotation on the Service
  (example: `k8s-ollama/manifests/ollama.yaml`)

Prereqs
1) Keycloak external realm is enabled and reachable.
2) Exchange client exists and secrets are stored in Vault:
   - `secret/data/keycloak-client-id-gravitee-introspection`
   - `secret/data/keycloak-client-secret-gravitee-introspection`
3) The service you want to protect is a Keycloak client in the external realm.

Add a new service (high level)
1) Create the Keycloak client
   - Add a JSON definition under `keycloak-client-config-external` in
     `k8s-keycloak/manifests/keycloak.yaml`.
   - Store client ID and secret in Vault:
     - `secret/data/keycloak-client-id-<client>`
     - `secret/data/keycloak-client-secret-<client>`
   - If you override client IDs via files, put `client-id-<client>` under `/vault/secrets/`.

2) Allow token exchange for the target
   - Update `keycloak-token-exchange-config` in `k8s-keycloak/manifests/keycloak.yaml`.
   - Format: `<realm>:<allowed-client>=<target1>,<target2>`
   - Example:
     - `external:gravitee-introspection=openwebui,ollama`
   - Client IDs in rules are resolved via `/vault/secrets/client-id-<name>` if present.

3) Enable token exchange on the Gravitee API
   - On the Kubernetes Service for the API, add:
     - `gravitee.io/token-exchange-target: "<client-id>"`
   - Example:
     - `gravitee.io/token-exchange-target: "openwebui"`

4) Ensure the upstream service validates the exchanged token
   - Configure the service to accept tokens issued for its client ID (audience).
   - For services that only accept their own tokens, this is required.

Rollout
- Apply changes in `k8s-keycloak`, `k8s-api-gateway`, and the service repo.
- Confirm Gravitee pods reload (configmap reload) and Keycloak configurator runs.

Validation
1) Call the API through Gravitee with a user token from the external realm.
2) Check Gravitee logs for token exchange failures.
3) Decode the exchanged token and verify:
   - `iss` = external realm
   - `aud` includes your target client

Troubleshooting
- 401 from upstream:
  - Ensure `gravitee.io/token-exchange-target` is set.
  - Ensure the target client exists in external realm.
  - Ensure token exchange permissions are present in Keycloak.
- Token exchange fails in Gravitee:
  - Confirm `TOKEN_EXCHANGE_CLIENT_ID`, `TOKEN_EXCHANGE_CLIENT_SECRET`, and
    `TOKEN_EXCHANGE_TOKEN_ENDPOINT` are set in the gateway pod.
  - Check Keycloak logs for token exchange errors.

Notes
- Token exchange is only injected for flows that include a JWT policy.
  If you override `definition-flows` without JWT, exchange will not run.
