#!/bin/sh

set -eu

TAG_PREFIX=$1
AWS_ACCOUNT=$2
DEPLOY_ENV=$3

GIT_EMAIL="the-multi-cloud-paas-team+deployer-ci@digital.cabinet-office.gov.uk"
GIT_USER="gov-paas-${AWS_ACCOUNT}"
GIT_REPO_URL="git@github.com:alphagov/paas-cf.git"

echo Configure SSH
tar xzf git-keys/git-keys.tar.gz
mkdir -p ~/.ssh

cat <<EOF > ~/.ssh/config
Host github.com
  StrictHostKeyChecking no
  IdentityFile $(pwd)/git-key
EOF

version=$(cat release-version/number)
tag="${TAG_PREFIX}${version}"

echo Configure Git
cd paas-cf
git config --global user.email "${GIT_EMAIL}"
git config --global user.name "${GIT_USER}"
git remote add ssh "${GIT_REPO_URL}"

echo "Create tag ${tag}"
git tag -a "${tag}" -m "Version ${version} passed ${AWS_ACCOUNT} \
in environment ${DEPLOY_ENV}"

echo "Push tag ${tag}"
git push ssh "${tag}"