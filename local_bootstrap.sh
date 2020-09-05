#!/usr/bin/env bash

function initialise_env() {
  git config --global user.name 'Terraform Foundation'
  git config --global user.email 'nomail@noaddress.info'
  rm -rf /platform/git
  mkdir -p /platform/git
}

function update_repository() {
  SOURCE=0-bootstrap
  GCP_ORG_DOMAIN=$(terraform output -json | jq -r '.gcp_organisation_domain.value')
  REPO=${GCP_ORG_DOMAIN}-${SOURCE}

  # Clone repository
  cd /platform/git
  git clone git@github.com:${TF_VAR_github_organization_name}/${REPO}.git

  # Prepare branch for bootstrap update
  cd /platform/git/${REPO}
  git checkout -B bootstrap_update
  cp -rf /platform/${SOURCE}/* /platform/git/${REPO}/
  mkdir -p /platform/git/${REPO}/.circleci
  cp /platform/build/circleci.yml /platform/git/${REPO}/.circleci/config.yml

  # Commit and push branch
  git add .
  git commit -m 'Bootstrap update'
  git push -f --set-upstream origin bootstrap_update
}

function local_bootstrap() {
#  gcloud auth login --update-adc
  cd /platform/0-bootstrap
  terraform init
  terraform apply

  # Initialise and move state to remote bucket after first terraform execution
  if [ ! -f "backend.tf" ]; then
    SED="s/UPDATE_ME/$(terraform output -json | jq -r '.gcs_bucket_tfstate.value')/g"
    cp backend.tf.example backend.tf
    sed -i "$SED" backend.tf
    sed -i 's/terraform\/bootstrap\/state/terraform\/0-bootstrap\/state/g' backend.tf
    terraform init -force-copy
  fi

  # If terraform command was successful
  if [ $? -eq 0 ]; then
    cd /platform
    mkdir -p ~/.ssh
    cp -f /platform/git.pem ~/.ssh/id_ecdsa
    chmod 0600 ~/.ssh/id_ecdsa
#    update_repository
  fi

}


initialise_env
local_bootstrap


