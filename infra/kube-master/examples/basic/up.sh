#!/bin/bash

source ./up.env

export VAGRANT_HOME=/var/data/vagrant

vagrant box remove ${ARTIFACT_DIR}/kubemaster/${KUBEMASTER_IMAGE_VERSION}/kubemaster-${KUBEMASTER_IMAGE_VERSION}.box

vagrant up