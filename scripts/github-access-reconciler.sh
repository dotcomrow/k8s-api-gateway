#!/bin/sh
set -eu

# Required environment variables
REQUIRED_ENV="MGMT_API_URL ADMIN_USERNAME ADMIN_PASSWORD GITHUB_ORG GITHUB_ALLOWED_TEAMS GITHUB_TOKEN"

# Validate required env vars using env + awk (POSIX-safe, no bash-isms)
for var in $REQUIRED_ENV; do
  value=$(env | awk -F= -v key="$var" '$1==key {print substr($0, index($0,"=")+1)}')
  if [ -z "$value" ]; then
    echo "❌ Missing required env var: $var" >&2
    exit 1
  fi
done

# Default page size if not set; avoid := to keep busy shells happy
if [ -z "${PAGE_SIZE-}" ]; then
  PAGE_SIZE=100
fi

# GITHUB_ALLOWED_TEAMS is a comma-separated list, normalize to space-separated
ALLOWED_TEAMS=$(printf '%s' "$GITHUB_ALLOWED_TEAMS" | tr ',' ' ')

github_has_team() {
  username="$1"

  # If no allowed teams configured, deny everything
  if [ -z "$ALLOWED_TEAMS" ]; then
    return 1
  fi

  for team in $ALLOWED_TEAMS; do
    api="https://api.github.com/orgs/${GITHUB_ORG}/teams/${team}/memberships/${username}"

    # Request membership info; write body to temp file, capture HTTP status
    status=$(curl -s \
      -H "Authorization: Bearer ${GITHUB_TOKEN}" \
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

while :; do
  resp=$(curl -s -u "${ADMIN_USERNAME}:${ADMIN_PASSWORD}" \
    "$MGMT_API_URL/management/organizations/DEFAULT/environments/DEFAULT/users?page=${page}&size=${PAGE_SIZE}")

  # Number of users in this page
  count=$(printf '%s\n' "$resp" | jq '.data | length' 2>/dev/null || echo 0)

  # No more users; stop paging
  if [ "$count" -eq 0 ]; then
    break
  fi

  # Iterate each user object
  users_json=$(printf '%s\n' "$resp" | jq -c '.data[]')

  # Use a here-document to avoid subshell issues
  while IFS= read -r user; do
    [ -z "$user" ] && continue

    source=$(printf '%s' "$user" | jq -r '.source')
    [ "$source" = "github" ] || continue

    user_id=$(printf '%s' "$user" | jq -r '.id')
    source_id=$(printf '%s' "$user" | jq -r '.sourceId // empty')
    username=$(printf '%s' "$user" | jq -r '.username // empty')
    status=$(printf '%s' "$user" | jq -r '.status')

    # Prefer sourceId, fall back to username
    if [ -n "$source_id" ]; then
      gh_user="$source_id"
    else
      gh_user="$username"
    fi

    # If we still don't have a GitHub username, skip
    if [ -z "$gh_user" ]; then
      continue
    fi

    total_checked=$((total_checked + 1))

    # User still in at least one allowed team -> keep active
    if github_has_team "$gh_user"; then
      continue
    fi

    # Already inactive/deactivated? Skip
    if [ "$status" = "INACTIVE" ] || [ "$status" = "DEACTIVATED" ]; then
      continue
    fi

    deactivate_status=$(curl -s -u "${ADMIN_USERNAME}:${ADMIN_PASSWORD}" \
      -o /tmp/deactivate-response -w "%{http_code}" \
      -X PUT "$MGMT_API_URL/management/organizations/DEFAULT/environments/DEFAULT/users/${user_id}/status?status=DEACTIVATED" \
      || echo "000")

    if [ "$deactivate_status" = "200" ]; then
      total_deactivated=$((total_deactivated + 1))
      echo "🔒 Deactivated GitHub user ${gh_user} (${user_id})"
    else
      echo "⚠️ Failed to deactivate user ${gh_user} (${user_id}), status ${deactivate_status}" >&2
      # Show response body if available
      if [ -f /tmp/deactivate-response ]; then
        cat /tmp/deactivate-response >&2 || true
      fi
    fi
  done <<EOF
$users_json
EOF

  page=$((page + 1))
done

echo "✅ Reconciliation complete. Checked ${total_checked} GitHub users, deactivated ${total_deactivated}."
