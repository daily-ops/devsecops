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

variable "kubemaster-version" {
  type = string
  description = "Kubernetes version"
}

variable "containerd-version" {
  type = string
  description = "Containerd version"
}

variable "kubemaster-image-version" {
  type = string
  description = "Jenkins image version"
}

variable "artifacts-dir" {
  type = string
  description = "Path to the artifacts directory"
}

source "virtualbox-ovf" "kubemaster" {
  vm_name = "kubemaster-${var.kubemaster-image-version}"
  source_path = "${var.image_source_path}/basebox/${var.basebox-version}/basebox-${var.basebox-version}.ovf"
  guest_additions_mode = "disable"
  ssh_username = "ansible"
  ssh_password = "ansible"
  ssh_port = 22
  ssh_timeout = "20m"
  vrdp_port_min = 5051
  vrdp_port_max = 5060
  shutdown_command     = "echo \"ansible\" | sudo -S shutdown now"
  output_directory = "${var.artifacts-dir}/kubemaster/${var.kubemaster-image-version}"
  headless = true  
}

build {
  sources = ["sources.virtualbox-ovf.kubemaster"]

  provisioner "ansible-local" {
    playbook_file   = "playbook-kubemaster.yml"
    extra_arguments = [
      "--extra-vars", "\"kubemaster_version=${var.kubemaster-version} containerd_version=${var.containerd-version}\""
    ]
    inventory_groups = ["kubemaster"]
    timeout         = "20m0s"
  }

  post-processor "vagrant" {
    vagrantfile_template = "Vagrantfile.template"
    keep_input_artifact = true
    output = "${var.artifacts-dir}/kubemaster/${var.kubemaster-image-version}/kubemaster-${var.kubemaster-image-version}.box"
  }

}
