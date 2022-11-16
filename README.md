## What is ? 
The project encapsulate scripts I have made in order to setup a kubernetes cluster in different ways. The goal is to simplify the abstraction to create a k8 cluster using different ways.

## What is included ?
### Simple setup with vagrant and ansible 
[Vagrant](https://www.vagrantup.com/) offer management capabilities over local virtual machines, in the other way [Ansible](https://www.ansible.com/) is a RedHat open source tool to configure and manage IT infrastructure, it is usually used to provision machines and to configure a network. 

With the use of these tools we can setup a zero touch local kubernetes cluster, where the nodes are virtual machines created by vagrant, and the installation of kubernetes is done with ansible. 

### Vagrant with kubespray 
[Kubespray](https://github.com/kubernetes-sigs/kubespray) is a CNCF heberged project, that allow the creation of production ready k8s cluster, it contains a set of advanced ansible playbooks in order to setup a k8s cluster that can directly be used in production. 

With the use of kubespray we deploy a vagrant local production cluster. 

### Digital Ocean with kubespray and Terraform
Digital ocean already provide a way to create a production ready kubernetes cluster from its dashboard, but these clusters are very limited as they are managed by digital ocean. Some of the limitations is that we can't change the cni. 

[Terraform](https://www.terraform.io/) is a tool that allow the management of cloud resources, it can be used in order to create virtual machines, load balancers, and way more. Terraform can be configured for different cloud provider, in our case we set it up for digital ocean. We therefore use kubespray in order to setup the cluster. 
