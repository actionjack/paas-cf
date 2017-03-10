#!/bin/sh

set -eu

export PASSWORD_STORE_DIR=${GAC_PASSWORD_STORE_DIR}

GAC_CLIENT_ID=$(pass "google/console/${AWS_ACCOUNT}/client_id")
GAC_CLIENT_SECRET=$(pass "google/console/${AWS_ACCOUNT}/client_secret")

SECRETS=$(mktemp secrets.yml.XXXXXX)
trap 'rm  "${SECRETS}"' EXIT

cat > "${SECRETS}" << EOF
---
secrets:
  google_admin_console_client_id: ${GAC_CLIENT_ID}
  google_admin_console_client_secret: ${GAC_CLIENT_SECRET}
EOF

aws s3 cp "${SECRETS}" "s3://gds-paas-${DEPLOY_ENV}-state/google-admin-console-secrets.yml"
