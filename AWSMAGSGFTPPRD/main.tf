###############################################################################
# Developed by Benjamin Pourian @MagenTys
# Free distribution, free usage
# Demo purposee only
###############################################################################

data "terraform_remote_state" "localstate" {
  backend = "local"

  config {
    path = "../AWSMAGSGFTPUAT/terraform.tfstate"
  }
}

provider "aws" {
    access_key = "${data.terraform_remote_state.localstate.aws_access_key}"
    secret_key = "${data.terraform_remote_state.localstate.aws_secret_key}"
    region     = "${var.region}"
}

resource "aws_subnet" "main" {
    vpc_id                  = "${data.terraform_remote_state.localstate.aws_vpc}"
    cidr_block              = "${var.subnet_cidr_block}"
    availability_zone       = "eu-west-2a"
    map_public_ip_on_launch = true

    tags {
      Name               = "${var.subnet_name}"
      Resource_Group_VPC = "${var.resource_group_vpc}"
    }
}

resource "aws_network_interface" "main" {
    subnet_id       = "${aws_subnet.main.id}"
    private_ips     = ["10.0.1.4"]
    security_groups = ["${data.terraform_remote_state.localstate.aws_security_group}"]

    attachment {
      instance     = "${aws_instance.winserv2016.id}"
      device_index = 1
    }

    tags {
      Name               = "${var.interface_name}"
      Resource_Group_VPC = "${var.resource_group_ec2}"
    }
}

data "aws_ami" "amazon_windows_2016" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2016-English-Full-Base-2018.06.13"]
  }

  filter {
    name = "owner-alias"
    values = ["amazon"]
  }
}

resource "aws_instance" "winserv2016" {
    ami             = "${data.aws_ami.amazon_windows_2016.image_id}"
    instance_type   = "t2.micro"
    subnet_id       = "${aws_subnet.main.id}"
    key_name        = "${var.key_name}"
    security_groups = ["${data.terraform_remote_state.localstate.aws_security_group}"]

    tags {
      Name               = "${var.machine_name}"
      Resource_Group_VPC = "${var.resource_group_ec2}"
    }
}
