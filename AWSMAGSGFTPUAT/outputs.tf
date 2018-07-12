output "aws_access_key" {
    sensitive = true
    value     = "${var.aws_access_key}"
}

output "aws_secret_key" {
    sensitive = true
    value     = "${var.aws_secret_key}"
}

output "aws_vpc" {
    sensitive = true
    value     = "${aws_vpc.main.id}"
}

output "aws_security_group" {
    sensitive = true
    value     = "${aws_security_group.allow_rdp.id}"
}
