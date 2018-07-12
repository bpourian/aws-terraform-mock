###############################################################################
# Developed by Benjamin Pourian @MagenTys
# Free distribution, free usage
# Demo purposee only
###############################################################################

terraform {
    backend "local" {}
}

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region     = "${var.region}"
}

resource "aws_vpc" "main" {
    cidr_block          = "${var.vpc_cidr_block}"
    instance_tenancy    = "default"

    tags {
      Name               = "${var.vpc_name}"
      Resource_Group_VPC = "${var.resource_group_vpc}"
    }
}

resource "aws_internet_gateway" "main" {
    vpc_id = "${aws_vpc.main.id}"

    tags {
      Name               = "${var.i_gateway_name}"
      Resource_Group_VPC = "${var.resource_group_vpc}"
    }
}

resource "aws_route_table" "main" {
    vpc_id = "${aws_vpc.main.id}"

    route {
      cidr_block         = "${var.route_cidr_block}"
      gateway_id         = "${aws_internet_gateway.main.id}"
    }

    tags {
      Name               = "${var.route_name}"
      Resource_Group_VPC = "${var.resource_group_vpc}"
    }
}

resource "aws_main_route_table_association" "main" {
    vpc_id         = "${aws_vpc.main.id}"
    route_table_id = "${aws_route_table.main.id}"
}

resource "aws_subnet" "main" {
    vpc_id                  = "${aws_vpc.main.id}"
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
    private_ips     = ["10.0.0.4"]
    security_groups = ["${aws_security_group.allow_rdp.id}"]

    attachment {
      instance     = "${aws_instance.winserv2016.id}"
      device_index = 1
    }

    tags {
      Name               = "${var.subnet_name}"
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
    security_groups = ["${aws_security_group.allow_rdp.id}"]

    tags {
      Name               = "${var.machine_name}"
      Resource_Group_VPC = "${var.resource_group_ec2}"
    }
}
