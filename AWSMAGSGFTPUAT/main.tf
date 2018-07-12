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
    instance_tenancy    = "dedicated"

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
      cidr_block             = "${var.route_cidr_block}"
      gateway_id             = "${aws_internet_gateway.main.id}"
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
    vpc_id     = "${aws_vpc.main.id}"
    cidr_block = "${var.subnet_cidr_block}"

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

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = "${aws_security_group.allow_rdp.id}"
  network_interface_id = "${aws_network_interface.main.id}"
}

resource "aws_eip" "one" {
    vpc                       = true
    network_interface         = "${aws_network_interface.main.id}"
    associate_with_private_ip = "10.0.0.4"
}

data "aws_ami" "amazon_windows_2016" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2016*", "Base"]
  }

  filter {
    name = "owner-alias"
    values = ["amazon"]
  }
}

resource "aws_instance" "winserv2016" {
    connection {
    type     = "winrm"
    user     = "${var.admin_username}"
    password = "${var.admin_password}"

    # set from default of 5m to 10m to avoid winrm timeout
    timeout = "10m"
  }


    ami             = "${data.aws_ami.amazon_windows_2016.image_id}"
    # ami             = "ami-479b7520"
    instance_type   = "t2.micro"
    # security_groups = ["${aws_security_group.allow_rdp.name}"]
    subnet_id       = "${aws_subnet.main.id}"
    key_name        = "${var.key_name}"

    tags {
      Name               = "${var.machine_name}"
      Resource_Group_VPC = "${var.resource_group_ec2}"
  }
}
