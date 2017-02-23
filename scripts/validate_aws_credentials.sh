#!/bin/bash
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

if [ -z "$AWS_ACCOUNT" ]; then
  echo "No AWS_ACCOUNT specified, please populate the environment variable"
  exit 255;
fi

aws iam get-user > /dev/null 2>&1
if [[ $? != 0 ]]; then
  echo "Current AWS credentials are invalid, please refresh them using create_sts_token.sh"
  exit 255;
fi

# shellcheck disable=SC1090
source "${SCRIPT_DIR}/common.sh"
check_aws_account_used "${AWS_ACCOUNT}"
