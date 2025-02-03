#!/bin/bash

###################################################################
# Environment variables - up.env defines the following:
###################################################################
# DNS_DEV_IMAGE_VERSION - version of the dns-dev image to be used
# ARTIFACT_DIR - base directory of the artifacts
###################################################################

source ./up.env

export VAGRANT_HOME=/var/data/vagrant

vagrant destroy -f
