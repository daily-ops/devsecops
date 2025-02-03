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

variable "artifact-dir" {
  type = string
  description = "Path to the artifacts directory"
}

variable "ca-file" {
  type = string
  description = "Path to the CA file"
}

variable "ca-int-file" {
  type = string
  description = "Path to the CA intermediate file"
}

source "virtualbox-iso" "basebox" {
  guest_os_type = "Ubuntu_64"
  vm_name = "basebox-${var.basebox-version}"
  iso_url = "${var.iso-url}"
  iso_checksum = "${var.iso-checksum}"
  guest_additions_url = "${var.guest-additions-url}"
  guest_additions_sha256 = "${var.guest-additions-checksum}"
  ssh_username = "ansible"
  ssh_password = "ansible"
  ssh_port = 22
  ssh_timeout = "60m"
  nested_virt = true

  vrdp_port_min = 5100
  vrdp_port_max = 5200

  shutdown_command     = "echo \"ansible\" | sudo -S shutdown now"
  chipset = "ich9"
  disk_size = 100000
  nic_type = "82545EM"
  hard_drive_interface = "sata"
  sata_port_count = 4
  cpus = 4
  memory = 4096
  headless = true  
  cd_files                = ["user-data", "meta-data"]
  cd_label                = "cidata"
  output_directory        = "${var.artifact-dir}/basebox/${var.basebox-version}"
}

build {
  sources = ["sources.virtualbox-iso.basebox"]

  provisioner "shell" {
    inline = [
      "mkdir /tmp/extra-tls",
      "chmod 755 /tmp/extra-tls"
    ]
  }

  provisioner "file" {
    source = "${var.ca-file}"
    destination = "/tmp/extra-tls/${basename(var.ca-file)}"
  }

  provisioner "file" {
    source = "${var.ca-int-file}"
    destination = "/tmp/extra-tls/${basename(var.ca-int-file)}"
  }

  provisioner "shell" {
    inline = [
      "sudo mv /tmp/extra-tls/*.crt /usr/local/share/ca-certificates/",
      "sudo update-ca-certificates"
    ]
  }

  post-processor "vagrant" {
    keep_input_artifact = true
    output               = "${var.artifact-dir}/basebox/${var.basebox-version}/basebox-${var.basebox-version}.box"
  }
}
