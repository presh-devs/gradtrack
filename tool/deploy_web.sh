#!/usr/bin/env bash
# Build the real (Supabase) web app and deploy it to Cloudflare Pages.
#
# One-time setup (see docs/setup/deploy.md):
#   npx wrangler@4 login
#   npx wrangler@4 pages project create gradll --production-branch main
#
# Usage:  tool/deploy_web.sh
#         PAGES_PROJECT=my-name tool/deploy_web.sh   # if you named it differently
set -euo pipefail
cd "$(dirname "$0")/.."

project="${PAGES_PROJECT:-gradll}"

if [[ ! -f env.json ]]; then
  echo "env.json is missing. Deploying without it would publish the demo build." >&2
  echo "Copy env.example.json to env.json and fill in your Supabase URL and publishable key." >&2
  exit 1
fi

flutter build web --release --dart-define-from-file=env.json

# Record which commit is live; flag it when the tree has uncommitted changes.
dirty=false
if [[ -n "$(git status --porcelain)" ]]; then
  echo "Note: you have uncommitted changes; they are included in this deploy."
  dirty=true
fi

npx --yes wrangler@4 pages deploy build/web \
  --project-name "$project" \
  --branch main \
  --commit-hash "$(git rev-parse HEAD)" \
  --commit-message "$(git log -1 --pretty=%s)" \
  --commit-dirty="$dirty"
