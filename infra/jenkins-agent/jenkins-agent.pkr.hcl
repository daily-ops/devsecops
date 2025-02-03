packer {
  required_plugins {
    virtualbox = {
      version = ">= 1.1.0"
      source = "github.com/hashicorp/virtualbox"
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

variable "iso-url" {
  type = string
  description = "URL to the Ubuntu ISO"
}

variable "iso-checksum" {
  type = string
  description = "SHA256 checksum of the Ubuntu ISO"
}

variable "guest-additions-url" {
  type = string
  description = "URL to the VirtualBox Guest Additions ISO"
}

variable "guest-additions-checksum" {
  type = string
  description = "SHA256 checksum of the VirtualBox Guest Additions ISO"
}

variable "basebox-version" {
  type = string
  description = "Basebox version"
}

variable "agent-image-version" {
  type = string
  description = "Jenkins agent image version"
}

variable "jdk-version" {
  type = string
  description = "jdk version"
}

variable "artifact-dir" {
  type = string
  description = "Path to the artifacts directory"
}

source "virtualbox-ovf" "jenkins-agent" {
  vm_name = "jenkins-agent-${var.agent-image-version}"
  source_path = "${var.image_source_path}/basebox/${var.basebox-version}/basebox-${var.basebox-version}.ovf"
  guest_additions_mode = "disable"
  ssh_username = "ansible"
  ssh_password = "ansible"
  ssh_port = 22
  ssh_timeout = "20m"
  vrdp_port_min = 5051
  vrdp_port_max = 5060
  shutdown_command     = "echo \"ansible\" | sudo -S shutdown now"
  output_directory = "${var.artifact-dir}/jenkins-agent/${var.agent-image-version}"
  headless = true  
}

# source "virtualbox-iso" "jenkins-agent" {
#   guest_os_type = "Ubuntu_64"
#   vm_name = "jenkins-agent-${var.agent-image-version}"
#   iso_url = "${var.iso-url}"
#   iso_checksum = "${var.iso-checksum}"
#   guest_additions_url = "${var.guest-additions-url}"
#   guest_additions_sha256 = "${var.guest-additions-checksum}"
#   ssh_username = "ansible"
#   ssh_password = "ansible"
#   ssh_port = 22
#   ssh_timeout = "30m"
#   nested_virt = true

#   vrdp_port_min = 5100
#   vrdp_port_max = 5200

#   shutdown_command     = "echo \"ansible\" | sudo -S shutdown now"
#   chipset = "ich9"
#   disk_size = 100000
#   nic_type = "82545EM"
#   hard_drive_interface = "sata"
#   sata_port_count = 4
#   cpus = 4
#   memory = 4096
#   headless = true  
#   cd_files                = ["user-data", "meta-data"]
#   cd_label                = "cidata"
#   output_directory        = "${var.artifact-dir}/jenkins-agent/${var.agent-image-version}"
# }

build {
  sources = ["sources.virtualbox-ovf.jenkins-agent"]

  provisioner "ansible-local" {
    playbook_file   = "playbook-jenkins-agent.yml"
    extra_arguments = [
      "--extra-vars", "\"jdk_version=${var.jdk-version}\""
    ]
    inventory_groups = ["jenkins-agent"]
    timeout         = "20m0s"
  }

  post-processor "vagrant" {
    vagrantfile_template = "Vagrantfile.template"
    keep_input_artifact = true
    output               = "${var.artifact-dir}/jenkins-agent/${var.agent-image-version}/jenkins-agent-${var.agent-image-version}.box"
  }
}
