# Gravitee Service Discovery Annotations

This repo whitelists the annotations below in the Gravitee management API config
under `services.discovery.kubernetes.annotations`.

## Discovery / access flags
- `gravitee.io/expose`: `"true"` to include the service in discovery
- `gravitee.io/context-path`: API context path
- `gravitee.io/auth-required`: auth type hint (ex: `jwt`, `apikey`)
- `gravitee.io/approval-required`: approval policy hint (ex: `admin`)

## Definition metadata (string)
- `gravitee.io/description`
- `gravitee.io/version`
- `gravitee.io/tags` (comma-separated)
- `gravitee.io/definition-name`
- `gravitee.io/definition-summary`
- `gravitee.io/definition-description`
- `gravitee.io/definition-version`
- `gravitee.io/definition-context-path`
- `gravitee.io/definition-visibility` (ex: `PUBLIC`, `PRIVATE`)
- `gravitee.io/definition-state` (ex: `STARTED`, `STOPPED`)
- `gravitee.io/definition-lifecycle-state` (ex: `CREATED`, `PUBLISHED`)

## Definition list fields (comma-separated)
- `gravitee.io/definition-groups`
- `gravitee.io/definition-tags`
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
- `gravitee.io/definition-plans`
- `gravitee.io/definition-flows`
- `gravitee.io/definition-response-templates`
- `gravitee.io/definition-entrypoints`
- `gravitee.io/definition-endpoints`

## Definition execution options
- `gravitee.io/definition-execution-mode`
- `gravitee.io/definition-flow-mode`

## OpenAPI import (if supported by the discovery provider)
- `gravitee.io/definition-openapi-url`
- `gravitee.io/definition-openapi` (inline; keep within K8s annotation size limits)
