#!/bin/bash

print_usage() {
    echo "Please provide the build.env file with the following variables:"
    echo "###################################################################"
    echo "BASEBOX_VERSION - version of the basebox to be used, e.g. 1.0.0"
    echo "IMAGE_SOURCE_PATH - path to the base image to be used, e.g. /storage/basebox/1.0.0/basebox-1.0.0.box"
    echo "ARTIFACT_DIR - base directory of the artifacts, e.g. /storage"
    echo "KUBEMASTER_VERSION - version of kube to be installed, i.e. 1.31.1"
    echo "CONTAINERD_VERSION - version of containerd to be installed, i.e. 1.5.2"
    echo "KUBEMASTER_IMAGE_VERSION - target build version of kube virtual machine image, i.e. 0.0.1"
    echo "###################################################################"
}

if [ ! -f ./build.env ]; then
    print_usage
    exit 1
fi

source ./build.env

rm -rf ${ARTIFACT_DIR}/kubemaster/${KUBEMASTER_IMAGE_VERSION}

export VAGRANT_HOME=/var/data/vagrant
export PACKER_LOG=1
export PACKER_LOG_PATH=$(pwd)/packer_$(date +%H%M%d%m).log

packer build -var "basebox-version=${BASEBOX_VERSION}" \
    -var "image_source_path=${IMAGE_SOURCE_PATH}" \
    -var "kubemaster-version=${KUBEMASTER_VERSION}" \
    -var "containerd-version=${CONTAINERD_VERSION}" \
    -var "artifacts-dir=${ARTIFACT_DIR}" \
    -var "kubemaster-image-version=${KUBEMASTER_IMAGE_VERSION}" \
    kubemaster.pkr.hcl