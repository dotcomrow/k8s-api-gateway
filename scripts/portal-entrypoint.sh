#!/bin/sh
set -euo pipefail

TEMPLATE_DIR=/usr/share/nginx/html

# Load every Vault-injected secret so env vars are available.
if [ -d /vault/secrets ]; then
  for secret in /vault/secrets/*; do
    if [ -f "$secret" ]; then
      # shellcheck disable=SC1090
      . "$secret"
    fi
  done
fi

render_template() {
  tpl="$1"
  target="${tpl%.tpl}"

  vars=$(grep -o '\${[A-Za-z_][A-Za-z0-9_]*}' "$tpl" | sort -u | tr -d '${}')

  if [ -n "$vars" ]; then
    for var in $vars; do
      eval "value=\${$var:-}"
      if [ -z "$value" ]; then
        echo "❌ Missing required environment variable '$var' for template $tpl" >&2
        exit 1
      fi
    done
    repl=$(printf ' ${%s}' $vars)
    envsubst "$repl" < "$tpl" > "$target"
  else
    cp "$tpl" "$target"
  fi
}

if [ -d "$TEMPLATE_DIR" ]; then
  find "$TEMPLATE_DIR" -name '*.tpl' -print0 | while IFS= read -r -d '' tpl; do
    render_template "$tpl"
  done
fi

exec nginx -g 'daemon off;'
