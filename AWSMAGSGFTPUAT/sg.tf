resource "aws_security_group" "allow_rdp" {
  name        = "${var.sec_group_name}"
  description = "Allow rdp inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 21
    to_port     = 21
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5050
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}"]
  }
}
