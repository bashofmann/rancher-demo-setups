# Data for AWS module

# AWS data
# ----------------------------------------------------------

# Use latest Ubuntu 20.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "sles" {
  owners      = ["013907871322"]
  most_recent = true

  filter {
    name   = "name"
    values = ["suse-sles-15-sp2*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "opensuse" {
  owners      = ["679593333241"]
  most_recent = true

  filter {
    name   = "name"
    values = ["openSUSE-Leap-15.4*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

#data "aws_ami" "rhel" {
#  most_recent = true
#  owners      = ["309956199498"] # RedHat
#
#  filter {
#    name   = "name"
#    values = ["RHEL-8.3_HVM-*-x86_64-0-Hourly2-GP2"]
#  }
#
#  filter {
#    name   = "virtualization-type"
#    values = ["hvm"]
#  }
#}
