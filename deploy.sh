#!/usr/bin/env bash

set -e

# Make sure that we have the needed enviromental variables
if [ -z "$DEPLOY_MACHINE" ]; then
  echo "Error: DEPLOY_MACHINE is not set."
  exit 1
fi

export DEPLOY_USER=${DEPLOY_USER:-root}

# We should always build with prod
export MIX_ENV=prod

mix phx.digest
mix release --overwrite

echo "Deploy changes (please press yubikey)"
rsync -avz --delete --no-perms --no-owner --no-group --omit-dir-times _build/prod/rel/hvemerdu/ ${DEPLOY_MACHINE}:/apps/hvemerdu/

echo "Fix SELinux"
ssh -l ${DEPLOY_USER} ${DEPLOY_MACHINE} 'chcon -t bin_t /apps/hvemerdu/bin/hvemerdu'

echo "Restart hvemerdu again"
ssh -l ${DEPLOY_USER} ${DEPLOY_MACHINE} 'systemctl restart hvemerdu'
