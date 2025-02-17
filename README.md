## Off-line platform for DevSecOps practices

Provision an off-line infrastructure platform consisting of Gitlab, Jenkins, Vault, Sonarqube, Kubernetes, Prometheus, Grafana through the use of Vagrant, Packer, Virtualbox, Ansible. The platform is aimed to get familiar with provisioning tool and yet also to facilitate in the process of onboarding new application and provisioning and delivering application platform, and required tools into Cloud or local servers as showcasing. There are several configuration items hard-coded due to current assumption that this is running in one of the machines in the homelab.

#### Pre-requiresite:

- Packer
- VirtualBox
- SSH-Key for `ansible` user
- Anything required by each box as input parameters.
- Terraform


#### Installation Guides: 

The scripts in relation to platform are located under [infra](./infra) directory. Each individual virtual machine support different fuction. It uses the ovf built from the basebox to speed up the build process. The `build.sh` can be used to build box file for Vagrant to be imported where the `examples` directory contains sample scripts. The `examples` directory underneath each box desmonstrates a basic method to launch the box.


|Box name|Purpose|
|-|-|
|basebox|Base box|
|dns-dev|DNS server|
|gitlab|Gitlab server|
|jenkins-agent|Jenkins agent node|
|jenkins|Jenkins master node|
|kube-master|Kubernetes master node|
|vault|Vault server|

#### Issues

Please visit outstanding [issues](https://github.com/daily-ops/devsecops/issues)



