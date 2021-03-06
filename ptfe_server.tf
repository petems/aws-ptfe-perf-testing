provider "aws" {
  region = "eu-west-2"
}

data "http" "current_ip" {
  url = "https://ipv4.icanhazip.com/"
}

resource "tls_private_key" "gen_ssh_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "aws_ptfe_demo_keypair" {
  key_name   = "aws-ptfe-demo-psouter"
  public_key = "${tls_private_key.gen_ssh_key.public_key_openssh}"
}

resource "local_file" "aws_ssh_key_pem" {
  depends_on = ["tls_private_key.gen_ssh_key"]
  content    = "${tls_private_key.gen_ssh_key.private_key_pem}"
  filename   = "./keys/aws-ptfe-keypair.pem"
}


data "aws_ami" "xenial_ami" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "image-type"
    values = ["machine"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
}

resource "aws_security_group" "allow_ptfe_access" {
  name = "allow-ptfe-access"

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    self        = true
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    self        = true
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol  = -1
    from_port = 0
    to_port   = 0
    self      = true
  }

  ingress {
    from_port = "22"
    to_port   = "22"
    protocol  = "tcp"

    # Only allow access from current IP
    cidr_blocks = [
      "${chomp(data.http.current_ip.body)}/32",
    ]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8800
    to_port     = 8800
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ebs_volume" "ptfe_data_ebs" {
  availability_zone = "${aws_instance.ptfe_instance.availability_zone}"
  size              = 88
  type              = "gp2"

  tags {
    Name = "ptfe-psouter-ebs_volume"
  }
}

resource "aws_volume_attachment" "ptfe_data_attachment" {
  device_name = "/dev/xvdb" # This is ignored by the instance, which mounts it as /dev/nvme1n1
  instance_id = "${aws_instance.ptfe_instance.id}"
  volume_id   = "${aws_ebs_volume.ptfe_data_ebs.id}"
}

resource "aws_instance" "ptfe_instance" {
  ami                    = "${data.aws_ami.xenial_ami.image_id}"
  instance_type          = "m5.xlarge"
  vpc_security_group_ids = [
    "${aws_security_group.allow_ptfe_access.id}",
  ]

  associate_public_ip_address = true

  key_name = "${aws_key_pair.aws_ptfe_demo_keypair.key_name}"

  root_block_device {
    volume_size = 100
    volume_type = "gp2"
  }

  tags {
    Name = "ptfe_instance"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo DEBIAN_FRONTEND=noninteractive apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install software-properties-common",
      "sudo DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:certbot/certbot -y",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get update -y",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install certbot -y",
      "curl -o install.sh https://install.terraform.io/ptfe/stable",
      # "sudo mkfs -t ext4 /dev/nvme1n1",
      # "sudo mkdir /data",
      # "sudo mount /dev/nvme1n1 /data",
    ]

    connection {
      user        = "ubuntu"
      private_key = "${tls_private_key.gen_ssh_key.private_key_pem}"
    }
  }

}

output "ptfe_instance_ip" {
  value = "${aws_instance.ptfe_instance.public_ip}"
}
