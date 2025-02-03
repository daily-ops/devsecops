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

variable "jenkins-version" {
  type = string
  description = "Jenkins version"
}

variable "jenkins-image-version" {
  type = string
  description = "Jenkins image version"
}

variable "jenkins-cert-file" {
  type = string
  description = "Path to the Jenkins certificate file"
}

variable "jenkins-key-file" {
  type = string
  description = "Path to the Jenkins certificate key file"
}

variable "artifacts-dir" {
  type = string
  description = "Path to the artifacts directory"
}

variable "dns_domain_name" {
  type = string
  description = "DNS domain name - without sub-domain which is hardcoded to 'jenkins'"
}

source "virtualbox-ovf" "jenkins" {
  vm_name = "jenkins-${var.jenkins-image-version}"
  source_path = "${var.image_source_path}/basebox/${var.basebox-version}/basebox-${var.basebox-version}.ovf"
  guest_additions_mode = "disable"
  ssh_username = "ansible"
  ssh_password = "ansible"
  ssh_port = 22
  ssh_timeout = "60m"
  vrdp_port_min = 5051
  vrdp_port_max = 5060
  shutdown_command     = "echo \"ansible\" | sudo -S shutdown now"
  output_directory = "${var.artifacts-dir}/jenkins/${var.jenkins-image-version}"
  headless = true  
}

build {
  sources = ["sources.virtualbox-ovf.jenkins"]

  provisioner "shell" {
    inline = [
      "sudo mkdir -p /etc/jenkins/ssl",
      "sudo chmod -R 777 /etc/jenkins"
    ]
  }

  provisioner "file" {
    source = "${var.jenkins-cert-file}"
    destination = "/etc/jenkins/ssl/${basename(var.jenkins-cert-file)}"
  }

  provisioner "file" {
    source = "${var.jenkins-key-file}"
    destination = "/etc/jenkins/ssl/${basename(var.jenkins-key-file)}"
  }

  provisioner "ansible-local" {
    playbook_file   = "playbook-jenkins.yml"
    extra_arguments = [
      "--extra-vars", "\"dns_domain_name=${var.dns_domain_name} jenkins_version=${var.jenkins-version}\""
    ]
    inventory_groups = ["jenkins"]
    timeout         = "20m0s"
  }

  post-processor "vagrant" {
    vagrantfile_template = "Vagrantfile.template"
    keep_input_artifact = true
    output = "${var.artifacts-dir}/jenkins/${var.jenkins-image-version}/jenkins-${var.jenkins-image-version}.box"
  }

}
