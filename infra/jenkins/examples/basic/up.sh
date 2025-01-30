#!/bin/bash

source ./up.env

vagrant box remove ${ARTIFACT_DIR}/jenkins/${JENKINS_IMAGE_VERSION}/jenkins-${JENKINS_IMAGE_VERSION}.box

vagrant up