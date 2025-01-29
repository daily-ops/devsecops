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

variable "dns_dev-image-version" {
  type = string
  description = "DNS development environment image version"
}

variable "artifacts-dir" {
  type = string
  description = "Path to the artifacts directory"
}

variable "dns_domain_name" {
  type = string
  description = "DNS domain name"
}

source "virtualbox-ovf" "dns_dev" {
  vm_name = "dns_dev-${var.dns_dev-image-version}"
  source_path = "${var.image_source_path}/basebox/${var.basebox-version}/basebox-${var.basebox-version}.ovf"
  guest_additions_mode = "disable"
  ssh_username = "ansible"
  ssh_password = "ansible"
  ssh_port = 22
  ssh_timeout = "20m"
  vrdp_port_min = 5051
  vrdp_port_max = 5060
  shutdown_command     = "echo \"ansible\" | sudo -S shutdown now"
  output_directory = "${var.artifacts-dir}/dns_dev/${var.dns_dev-image-version}"
  headless = true  
}

build {
  sources = ["sources.virtualbox-ovf.dns_dev"]

  provisioner "ansible-local" {
    playbook_file   = "playbook-dns_dev.yml"
    extra_arguments = [
      "--extra-vars", "dns_domain_name=${var.dns_domain_name}"
    ]
    inventory_groups = ["dns_dev"]
    timeout         = "20m0s"
  }

  post-processor "vagrant" {
    vagrantfile_template = "Vagrantfile.template"
    keep_input_artifact = true
    output = "${var.artifacts-dir}/dns_dev/${var.dns_dev-image-version}/dns_dev-${var.dns_dev-image-version}.box"
  }

}
