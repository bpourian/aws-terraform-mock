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
    Name = "${var.subnet_name}"
    Resource_Group_VPC = "${var.resource_group_vpc}"
  }
}
