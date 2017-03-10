#!/bin/sh
set -e
set -u

get_gac_secrets() {
  # shellcheck disable=SC2154
  secrets_uri="s3://${state_bucket}/google-admin-console-secrets.yml"
  export gac_client_id
  export gac_client_secret
  if aws s3 ls "${secrets_uri}" > /dev/null ; then
    secrets_file=$(mktemp -t gac-secrets.XXXXXX)

    aws s3 cp "${secrets_uri}" "${secrets_file}"
    gac_client_id=$("${SCRIPT_DIR}"/val_from_yaml.rb secrets.google_admin_console_client_id "${secrets_file}")
    gac_client_secret=$("${SCRIPT_DIR}"/val_from_yaml.rb secrets.google_admin_console_client_secret "${secrets_file}")

    rm -f "${secrets_file}"
  fi
}
