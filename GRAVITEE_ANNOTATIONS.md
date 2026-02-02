# Gravitee Service Discovery Annotations

These annotations are whitelisted in the Gravitee management API config and
consumed by the `gravitee-annotation-sync` controller in `manifests/10-gravitee-annotation-sync.yaml`.
The controller creates `ApiV4Definition` resources for the Gravitee Kubernetes Operator (GKO).
GKO must be installed for these annotations to take effect.

## Discovery / access flags
- `gravitee.io/expose`: `"true"` to include the service in discovery
- `gravitee.io/context-path`: API context path
- `gravitee.io/auth-required`: auth type hint (ex: `jwt`, `apikey`)
- `gravitee.io/approval-required`: approval policy hint (ex: `admin`)
- `gravitee.io/token-exchange-target`: Keycloak client ID to exchange user tokens for (enables token exchange flow)

## Definition metadata (string)
- `gravitee.io/description`
- `gravitee.io/version`
- `gravitee.io/tags` (comma-separated; requires Gravitee license feature `apim-sharding-tags`)
- `gravitee.io/definition-name`
- `gravitee.io/definition-summary`
- `gravitee.io/definition-description`
- `gravitee.io/definition-version`
- `gravitee.io/definition-context-path`
- `gravitee.io/definition-type` (`PROXY`, `MESSAGE`, `NATIVE`, or `KAFKA`)
- `gravitee.io/definition-visibility` (ex: `PUBLIC`, `PRIVATE`)
- `gravitee.io/definition-state` (ex: `STARTED`, `STOPPED`)
- `gravitee.io/definition-lifecycle-state` (ex: `PUBLISHED`, `UNPUBLISHED`)

## Definition list fields (comma-separated)
- `gravitee.io/definition-groups`
- `gravitee.io/definition-tags` (requires Gravitee license feature `apim-sharding-tags`)
- `gravitee.io/definition-labels`
- `gravitee.io/definition-categories`
- `gravitee.io/definition-path-mappings`

## Definition assets (URLs)
- `gravitee.io/definition-picture-url`
- `gravitee.io/definition-background-url`

## Definition JSON fields (raw JSON strings)
- `gravitee.io/definition-metadata`
- `gravitee.io/definition-properties`
- `gravitee.io/definition-services`
- `gravitee.io/definition-resources`
- `gravitee.io/definition-plans` (JSON object map; arrays are converted to maps)
- `gravitee.io/definition-flows`
- `gravitee.io/definition-response-templates`
- `gravitee.io/definition-pages`
- `gravitee.io/definition-listeners`
- `gravitee.io/definition-entrypoints`
- `gravitee.io/definition-endpoint-groups`
- `gravitee.io/definition-endpoints`

## Listener and endpoint helpers
- `gravitee.io/definition-listener-host` (defaults to service DNS name)
- `gravitee.io/definition-listener-port` (defaults to service port)
- `gravitee.io/definition-endpoint-port` (service port name or number override for endpoint selection)
- `gravitee.io/definition-endpoint-scheme` (`http` or `https`)

## Definition execution options
- `gravitee.io/definition-execution-mode`
- `gravitee.io/definition-flow-mode`

## OpenAPI import (if supported by the discovery provider)
- `gravitee.io/definition-openapi-url`
- `gravitee.io/definition-openapi` (inline; keep within K8s annotation size limits)

Note: `definition-openapi-url` is used to generate a Swagger page in GKO; inline
OpenAPI content is not consumed by the current sync controller.

Tag handling: the sync controller defaults to `TAGS_MODE=ignore` to avoid
license-gated sharding tags in OSS. Set `TAGS_MODE=labels` to map tags to labels
or `TAGS_MODE=allow` if you have a license.

Plan handling: `definition-plans` should be a JSON object map. If you use an
array, the sync controller will convert it to a map keyed by a slug of the plan
name. If `security` is a string, it will be converted to `{ "type": "<value>" }`.

Group/category handling: the sync controller can auto-create groups and
categories in Gravitee when it sees `definition-groups` or
`definition-categories`. This requires `GRAVITEE_MANAGEMENT_API`,
`GRAVITEE_ADMIN_USERNAME`, and `GRAVITEE_ADMIN_PASSWORD`. Toggle with
`AUTO_CREATE_GROUPS` and `AUTO_CREATE_CATEGORIES`.
