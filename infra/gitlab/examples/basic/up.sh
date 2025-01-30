#!/bin/bash

source ./up.env

export VAGRANT_HOME=/var/data/vagrant

vagrant box remove ${ARTIFACT_DIR}/gitlab/${GITLAB_IMAGE_VERSION}/gitlab-ee-${GITLAB_IMAGE_VERSION}.box

vagrant up