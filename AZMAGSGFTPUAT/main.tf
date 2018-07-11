###############################################################################
# Developed by Benjamin Pourian @MagenTys
# Free distribution, free usage
# Demo purposee only
###############################################################################

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "eu-london"
}


resource "aws_vpc" "main" {
  cidr_block       = "${var.cidr_block}"
  instance_tenancy = "dedicated"

  tags {
    Name           = "AZMAGVNET1"
    Resource_Group = "AZMAGRGVNET1"
  }
}
