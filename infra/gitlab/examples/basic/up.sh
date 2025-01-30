#!/bin/bash

source ./up.env

vagrant box remove ${ARTIFACT_DIR}/gitlab/${GITLAB_IMAGE_VERSION}/gitlab-ee-${GITLAB_IMAGE_VERSION}.box

vagrant up