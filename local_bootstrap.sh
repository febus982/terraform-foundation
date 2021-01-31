#!/usr/bin/env bash

function initialise_env() {
  git config --global user.name 'Terraform Foundation'
  git config --global user.email 'nomail@noaddress.info'
  rm -rf /platform/git
  mkdir -p /platform/git
}

function update_repository() {
  SOURCE=$1
  REPO=$2
#  GCP_ORG_DOMAIN=$(terraform output -json | jq -r '.gcp_organisation_domain.value')
#  REPO=${GCP_ORG_DOMAIN}-${SOURCE}
#  REPO=${SOURCE}

  # Clone repository
  cd /platform/git || exit
#  git clone git@github.com:${TF_VAR_github_organization_name}/${REPO}.git
  git clone https://${GITHUB_USERNAME}:${GITHUB_PERSONAL_TOKEN}@github.com/febus982/${REPO}.git
#  git clone https://${GITHUB_USERNAME}:${GITHUB_PERSONAL_TOKEN}@github.com/${TF_VAR_github_organization_name}/${REPO}.git

  # Prepare branch for bootstrap update
  cd /platform/git/${REPO} || exit
  git checkout -B bootstrap_update
  cp -rf /platform/${SOURCE}/* /platform/git/${REPO}/
  cp /platform/build/tf-wrapper.sh /platform/git/${REPO}/

  # Commit and push branch
  git add .
  git commit -m 'Bootstrap update'
  git push -f --set-upstream origin bootstrap_update
}

function local_bootstrap() {
#  gcloud auth login --update-adc
  cd /platform/0-bootstrap || exit
  terraform init
  terraform apply

  # Initialise and move state to remote bucket after first terraform execution
#  if [ ! -f "backend.tf" ]; then
#    SED="s/UPDATE_ME/$(terraform output -json | jq -r '.gcs_bucket_tfstate.value')/g"
#    cp backend.tf.example backend.tf
#    sed -i "$SED" backend.tf
#    sed -i 's/terraform\/bootstrap\/state/terraform\/0-bootstrap\/state/g' backend.tf
#    terraform init -force-copy
#  fi

  # If terraform command was successful
  if [ $? -eq 0 ]; then
    mkdir -p ~/.ssh
    update_repository "0-bootstrap" "gcp-org"
  fi

}

#declare -a REPOS_LIST=("0-bootstrap" "1-org" "2-environments" "3-networks" "4-projects" )
#for val in "${REPOS_LIST[@]}"; do
#   echo $val
#done

initialise_env
local_bootstrap


