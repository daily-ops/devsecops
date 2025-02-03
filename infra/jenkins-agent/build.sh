#!/bin/bash

print_usage() {
    echo "Please provide the build.env file with the following variables:"
    echo "###################################################################"
    echo "BASEBOX_VERSION - version of the basebox to be used, e.g. 1.0.0"
    echo "IMAGE_SOURCE_PATH - path to the base image to be used, e.g. /storage/basebox/1.0.0/basebox-1.0.0.box"
    echo "ISO_URL - URL of the ISO installer to be used, e.g. file:///media/ubuntu-24.04.1-live-server-amd64.iso"
    echo "ISO_CHECKSUM - checksum of the ISO installer to be used, e.g. sha256:af53e34c5a5ec143f3418ac01d00ed5f33f6b31bfdc92eb4714c99d9bccb6602"
    echo "GUEST_ISO_URL - URL of the guest additions ISO installer to be used, e.g. file:///media/VBoxGuestAdditions_6.1.50.iso"
    echo "GUEST_ISO_CHECKSUM - checksum of the guest additions ISO installer, e.g. sha256:af53e34c5a5ec143f3418ac01d00ed5f33f6b31bfdc92eb4714c99d9bccb6602"
    echo "AGENT_IMAGE_VERSION - version of the box to be built, e.g. 1.0.0"
    echo "JDK_VERSION - version of the JDK to be installed, e.g. 17"
    echo "ARTIFACT_DIR - base directory of the artifacts, e.g. /storage"
    echo "###################################################################"
}


if [ ! -f ./build.env ]; then
    print_usage
    exit 1
fi

source ./build.env

rm -rf ${ARTIFACT_DIR}/jenkins-agent/${AGENT_VERSION}

touch meta-data

export VAGRANT_HOME=/var/data/vagrant
export PACKER_LOG=1
export PACKER_LOG_PATH=$(pwd)/packer_$(date +%H%M%d%m).log

packer build -var "iso-url=${ISO_URL}" \
    -var "image_source_path=${IMAGE_SOURCE_PATH}" \
    -var "iso-checksum=${ISO_CHECKSUM}" \
    -var "guest-additions-url=${GUEST_ISO_URL}" \
    -var "guest-additions-checksum=${GUEST_ISO_CHECKSUM}" \
    -var "basebox-version=${BASEBOX_VERSION}" \
    -var "agent-image-version=${AGENT_IMAGE_VERSION}" \
    -var "jdk-version=${JDK_VERSION}" \
    -var "artifact-dir=${ARTIFACT_DIR}" \
    jenkins-agent.pkr.hcl