#!/bin/bash

print_usage() {
    echo "Please provide the build.env file with the following variables:"
    echo "###################################################################"
    echo "BASEBOX_VERSION - version of the basebox to be used, e.g. 1.0.0"
    echo "IMAGE_SOURCE_PATH - path to the base image to be used, e.g. /storage/basebox/1.0.0/basebox-1.0.0.box"
    echo "ARTIFACT_DIR - base directory of the artifacts, e.g. /storage"
    echo "DNS_DEV_IMAGE_VERSION - version of the dns-dev image to be built, e.g. 1.0.0"
    echo "DOMAIN_NAME - domain name to be used, e.g. example.com"
    echo "###################################################################"
}

if [ ! -f ./build.env ]; then
    print_usage
    exit 1
fi

source ./build.env

export VAGRANT_HOME=/var/data/vagrant

rm -rf ${ARTIFACT_DIR}/dns_dev/${DNS_DEV_IMAGE_VERSION}

export PACKER_LOG=1
export PACKER_LOG_PATH=$(pwd)/packer_$(date +%H%M%d%m).log

packer build -var "basebox-version=${BASEBOX_VERSION}" \
    -var "image_source_path=${IMAGE_SOURCE_PATH}" \
    -var "artifacts-dir=${ARTIFACT_DIR}" \
    -var "dns_dev-image-version=${DNS_DEV_IMAGE_VERSION}" \
    -var "dns_domain_name=${DOMAIN_NAME}" \
    dns_dev.pkr.hcl