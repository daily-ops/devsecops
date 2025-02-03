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

variable "gitlab-ee-version" {
  type = string
  description = "GitLab EE version"
}

variable "gitlab-image-version" {
  type = string
  description = "GitLab image version"
}

variable "gitlab-cert-file" {
  type = string
  description = "Path to the GitLab certificate file"
}

variable "gitlab-key-file" {
  type = string
  description = "Path to the GitLab certificate key file"
}

variable "artifacts-dir" {
  type = string
  description = "Path to the artifacts directory"
}

variable "dns_domain_name" {
  type = string
  description = "DNS domain name - without sub-domain which is hardcoded to 'gitlab'"
}

source "virtualbox-ovf" "gitlab-ee" {
  vm_name = "gitlab-ee-${var.gitlab-image-version}"
  source_path = "${var.image_source_path}/basebox/${var.basebox-version}/basebox-${var.basebox-version}.ovf"
  guest_additions_mode = "disable"
  ssh_username = "ansible"
  ssh_password = "ansible"
  ssh_port = 22
  ssh_timeout = "60m"
  vrdp_port_min = 5051
  vrdp_port_max = 5060
  shutdown_command     = "echo \"ansible\" | sudo -S shutdown now"
  output_directory = "${var.artifacts-dir}/gitlab/${var.gitlab-image-version}"
  headless = true  
}

build {
  sources = ["sources.virtualbox-ovf.gitlab-ee"]

  provisioner "shell" {
    inline = [
      "sudo mkdir -p /etc/gitlab/ssl",
      "sudo chmod -R 777 /etc/gitlab"
    ]
  }

  provisioner "file" {
    source = "${var.gitlab-cert-file}"
    destination = "/etc/gitlab/ssl/${basename(var.gitlab-cert-file)}"
  }

  provisioner "file" {
    source = "${var.gitlab-key-file}"
    destination = "/etc/gitlab/ssl/${basename(var.gitlab-key-file)}"
  }

  provisioner "shell" {
    inline = [
      "sudo chmod -R 700 /etc/gitlab",
      "sudo chmod -R 600 /etc/gitlab/ssl"
    ]
  }

  provisioner "ansible-local" {
    playbook_file   = "playbook-gitlab-ee.yml"
    extra_arguments = [
      "--extra-vars", "dns_domain_name=${var.dns_domain_name}"
    ]
    inventory_groups = ["gitlab"]
    timeout         = "20m0s"
  }

  post-processor "vagrant" {
    vagrantfile_template = "Vagrantfile.template"
    keep_input_artifact = true
    output = "${var.artifacts-dir}/gitlab/${var.gitlab-image-version}/gitlab-ee-${var.gitlab-image-version}.box"
  }

}
