#!/bin/bash

source ./up.env

export VAGRANT_HOME=/var/data/vagrant

vagrant box remove ${ARTIFACT_DIR}/jenkins-agent/${AGENT_IMAGE_VERSION}/jenkins-agent-${AGENT_IMAGE_VERSION}.box

vagrant up