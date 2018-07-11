## AWS Terraform

The aim of this repo is practise the use of `Terraform` and build three VM's.
Two of the VM's will be running a Windows 2016 server and one will be on Ubuntu 16.04 server.

I will be creating resource groups for the machines and virtual networks with their own subnets,
network interface and security groups.

Once you have created the file `beconf.tfvars` and input all the necessary details as listed in the sample file,
you then run the following command.

```
terraform init -backend-config=beconf.tfvars

```
