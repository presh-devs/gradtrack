#!/usr/bin/env bash
# Build the web app and serve it on http://localhost:8080.
# Uses env.json (Supabase URL + publishable key) when present; otherwise the
# app runs in demo mode with sample data.
set -euo pipefail
cd "$(dirname "$0")/.."
args=(--release)
if [[ -f env.json ]]; then
  args+=(--dart-define-from-file=env.json)
  echo "Using Supabase settings from env.json"
else
  echo "No env.json, so building in demo mode"
fi
flutter build web "${args[@]}"
exec python3 tool/serve_web.py "${1:-8080}"
