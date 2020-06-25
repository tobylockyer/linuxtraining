provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.region}"
}

resource "aws_ebs_volume" "data01" {
  availability_zone = "${var.availabilityzone}"
  size              = 1
}
resource "aws_ebs_volume" "data02" {
  availability_zone = "${var.availabilityzone}"
  size              = 3
}

resource "aws_volume_attachment" "ebs_data02" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.data02.id}"
  instance_id = "${aws_instance.linux.id}"
}

resource "aws_volume_attachment" "ebs_data01" {
  device_name = "/dev/sdi"
  volume_id   = "${aws_ebs_volume.data01.id}"
  instance_id = "${aws_instance.linux.id}"
}

resource "aws_security_group" "ssh_linux_1" {
  name = "ssh_linux_1"

  # Inbound HTTP from anywhere
  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Inbound ssh from anywhere
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Outbound to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "linux" {
    ami             = "ami-7c491f05" #Red Hat 7.5
    instance_type   = "t2.micro"
    tags { Name     = "Training Linux OS" }
    security_groups = ["ssh_linux_1"]
    availability_zone = "${var.availabilityzone}"
    # key_name is your AWS keypair to allow you access
    key_name        = "training"
    provisioner "file" {
        source      = "script.sh"
        destination = "/tmp/scripts.sh"
    }

    provisioner "remote-exec" {
        inline = [
          "chmod +x /tmp/scripts.sh",
          "sudo /tmp/scripts.sh"
        ]
    }
    # Setup user access via SSH
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = "${file("keyfile")}"
      timeout = "2m"
      agent = false
    }
}
