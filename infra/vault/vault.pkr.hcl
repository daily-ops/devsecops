packer {
  required_plugins {
    virtualbox = {
      version = ">= 1.1.0"
      source = "github.com/hashicorp/virtualbox"
    }
    vagrant = {
      version = ">= 1.1.0"
      source = "github.com/hashicorp/vagrant"
    }
    ansible = {
      version = ">= 1.1.0"
      source = "github.com/hashicorp/ansible"
    }
  }
}

variable "image_source_path" {
  type = string
  description = "Path to the basebox image"
}

variable "basebox-version" {
  type = string
  description = "Basebox version"
}

variable "vault-version" {
  type = string
  description = "Jenkins version"
}

variable "vault-image-version" {
  type = string
  description = "Jenkins image version"
}

variable "vault-cert-file" {
  type = string
  description = "Path to the Jenkins certificate file"
}

variable "vault-key-file" {
  type = string
  description = "Path to the Jenkins certificate key file"
}

variable "artifacts-dir" {
  type = string
  description = "Path to the artifacts directory"
}

variable "dns_domain_name" {
  type = string
  description = "DNS domain name - without sub-domain which is hardcoded to 'vault'"
}

source "virtualbox-ovf" "vault" {
  vm_name = "vault-${var.vault-image-version}"
  source_path = "${var.image_source_path}/basebox/${var.basebox-version}/basebox-${var.basebox-version}.ovf"
  guest_additions_mode = "disable"
  ssh_username = "ansible"
  ssh_password = "ansible"
  ssh_port = 22
  ssh_timeout = "20m"
  vrdp_port_min = 5051
  vrdp_port_max = 5060
  shutdown_command     = "echo \"ansible\" | sudo -S shutdown now"
  output_directory = "${var.artifacts-dir}/vault/${var.vault-image-version}"
  headless = true  
}

build {
  sources = ["sources.virtualbox-ovf.vault"]

  provisioner "shell" {
    inline = [
      "sudo mkdir -p /etc/vault/ssl",
      "sudo chmod -R 777 /etc/vault"
    ]
  }

  provisioner "file" {
    source = "${var.vault-cert-file}"
    destination = "/etc/vault/ssl/${basename(var.vault-cert-file)}"
  }

  provisioner "file" {
    source = "${var.vault-key-file}"
    destination = "/etc/vault/ssl/${basename(var.vault-key-file)}"
  }

  provisioner "ansible-local" {
    playbook_file   = "playbook-vault.yml"
    extra_arguments = [
      "--extra-vars", "\"dns_domain_name=${var.dns_domain_name} vault_version=${var.vault-version}\""
    ]
    inventory_groups = ["vault"]
    timeout         = "20m0s"
  }

  post-processor "vagrant" {
    vagrantfile_template = "Vagrantfile.template"
    keep_input_artifact = true
    output = "${var.artifacts-dir}/vault/${var.vault-image-version}/vault-${var.vault-image-version}.box"
  }

}
