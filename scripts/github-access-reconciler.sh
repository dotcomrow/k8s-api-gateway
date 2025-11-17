#!/bin/sh
set -euo pipefail

REQUIRED_ENV="MGMT_API_URL ADMIN_USERNAME ADMIN_PASSWORD GITHUB_ORG GITHUB_ALLOWED_TEAMS GITHUB_TOKEN"
for var in $REQUIRED_ENV; do
  if [ -z "${!var:-}" ]; then
    echo "❌ Missing required env var: $var" >&2
    exit 1
  fi
done

PAGE_SIZE="${PAGE_SIZE:-100}"
ALLOWED_TEAMS="$(printf '%s' "$GITHUB_ALLOWED_TEAMS" | tr ',' ' ')"

github_has_team() {
  username="$1"
  for team in $ALLOWED_TEAMS; do
    api="https://api.github.com/orgs/${GITHUB_ORG}/teams/${team}/memberships/${username}"
    status=$(curl -s -H "Authorization: Bearer ${GITHUB_TOKEN}" \
      -H "Accept: application/vnd.github+json" \
      -w "%{http_code}" -o /tmp/github-membership "$api" || echo "000")
    if [ "$status" = "200" ]; then
      state=$(jq -r '.state' /tmp/github-membership 2>/dev/null || echo "inactive")
      if [ "$state" = "active" ]; then
        return 0
      fi
    fi
  done
  return 1
}

page=1
total_checked=0
total_deactivated=0

while true; do
  resp=$(curl -s -u "${ADMIN_USERNAME}:${ADMIN_PASSWORD}" \
    "$MGMT_API_URL/management/organizations/DEFAULT/environments/DEFAULT/users?page=${page}&size=${PAGE_SIZE}" )

  count=$(printf '%s\n' "$resp" | jq '.data | length' 2>/dev/null || echo 0)
  [ "$count" -eq 0 ] && break

  users_json=$(printf '%s\n' "$resp" | jq -c '.data[]')
  while IFS= read -r user; do
    [ -z "$user" ] && continue
    source=$(printf '%s' "$user" | jq -r '.source')
    [ "$source" = "github" ] || continue

    user_id=$(printf '%s' "$user" | jq -r '.id')
    source_id=$(printf '%s' "$user" | jq -r '.sourceId // empty')
    username=$(printf '%s' "$user" | jq -r '.username // empty')
    status=$(printf '%s' "$user" | jq -r '.status')

    gh_user="${source_id:-$username}"
    if [ -z "$gh_user" ]; then
      continue
    fi

    total_checked=$((total_checked + 1))

    if github_has_team "$gh_user"; then
      continue
    fi

    if [ "$status" = "INACTIVE" ]; then
      continue
    fi

    deactivate_status=$(curl -s -u "${ADMIN_USERNAME}:${ADMIN_PASSWORD}" \
      -o /tmp/deactivate-response -w "%{http_code}" \
      -X PUT "$MGMT_API_URL/management/organizations/DEFAULT/environments/DEFAULT/users/${user_id}/status?status=DEACTIVATED" || echo "000")

    if [ "$deactivate_status" = "200" ]; then
      total_deactivated=$((total_deactivated + 1))
      echo "🔒 Deactivated GitHub user ${gh_user} (${user_id})"
    else
      echo "⚠️ Failed to deactivate user ${gh_user} (${user_id}), status ${deactivate_status}" >&2
      cat /tmp/deactivate-response >&2 || true
    fi
  done <<EOF
$users_json
EOF

  page=$((page + 1))
done

echo "✅ Reconciliation complete. Checked ${total_checked} GitHub users, deactivated ${total_deactivated}."
