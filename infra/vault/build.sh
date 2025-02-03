#!/bin/bash

print_usage() {
    echo "Please provide the build.env file with the following variables:"
    echo "###################################################################"
    echo "BASEBOX_VERSION - version of the basebox to be used, e.g. 1.0.0"
    echo "IMAGE_SOURCE_PATH - path to the base image to be used, e.g. /storage/basebox/1.0.0/basebox-1.0.0.box"
    echo "ARTIFACT_DIR - base directory of the artifacts, e.g. /storage"
    echo "VAULT_VERSION - version of vault to be installed, i.e. 1.11.0
    echo "VAULT_CERT_FILE - path to tls certificate file, the file name is required to match the DNS name, i.e. /storage/tls/vault.dummydomain.com.crt
    echo "VAULT_KEY_FILE - path to tls private key of the certificate, the file name is required to match the DNS name, i.e. /storage/tls/vault.dummydomain.com.key
    echo "VAULT_IMAGE_VERSION - target build version of vault virtual machine image, i.e. 0.0.1
    echo "DOMAIN_NAME - base domain name to be used, e.g. dummydomain.com"
    echo 
    echo "NOTE:"
    echo "TLS is not implemented yet however the variables are still required."
    echo "It can be configured manually post provisioning."
    echo "The certificate and key files are uploaded to /etc/vault/ssl/ directory."
    echo "###################################################################"
}

if [ ! -f ./build.env ]; then
    print_usage
    exit 1
fi

source ./build.env

rm -rf ${ARTIFACT_DIR}/vault/${VAULT_IMAGE_VERSION}

export VAGRANT_HOME=/var/data/vagrant
export PACKER_LOG=1
export PACKER_LOG_PATH=$(pwd)/packer_$(date +%H%M%d%m).log

packer build -var "basebox-version=${BASEBOX_VERSION}" \
    -var "image_source_path=${IMAGE_SOURCE_PATH}" \
    -var "vault-version=${VAULT_VERSION}" \
    -var "vault-key-file=${VAULT_KEY_FILE}" \
    -var "vault-cert-file=${VAULT_CERT_FILE}" \
    -var "artifacts-dir=${ARTIFACT_DIR}" \
    -var "vault-image-version=${VAULT_IMAGE_VERSION}" \
    -var "dns_domain_name=${DOMAIN_NAME}" \
    vault.pkr.hcl