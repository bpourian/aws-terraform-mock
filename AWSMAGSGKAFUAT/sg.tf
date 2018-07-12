resource "aws_security_group" "allow_ssh" {
  name        = "${var.sec_group_name}"
  description = "Allow ssh inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8030
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}"]
  }
}
