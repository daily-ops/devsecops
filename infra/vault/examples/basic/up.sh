#!/bin/bash

source ./up.env

export VAGRANT_HOME=/var/data/vagrant

vagrant box remove ${ARTIFACT_DIR}/vault/${VAULT_IMAGE_VERSION}/vault-${VAULT_IMAGE_VERSION}.box

vagrant up