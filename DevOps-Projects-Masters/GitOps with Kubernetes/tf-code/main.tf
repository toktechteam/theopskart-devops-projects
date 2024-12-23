provider "aws" {
  region  = "us-west-2"
  profile = "system"
}

# Key pair code
resource "aws_key_pair" "my_key" {
  key_name   = "mp1_ec2_key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "local_file" "private_key" {
  content  = aws_key_pair.my_key.key_name
  filename = "${path.module}/mp1_ec2_key.pem"
}

# IAM role and policy for SSM
resource "aws_iam_role" "ssm_role" {
  name = "mp1_ssm_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_instance" "my_instance" {
  ami           = "ami-07d9cf938edb0739b" # Ensure this AMI ID is valid in the us-west-2 region
  instance_type = "m5.2xlarge"
  key_name      = aws_key_pair.my_key.key_name

  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  tags = {
    Name = "mp1-server"
  }

  user_data = file("${path.module}/userdata.sh")
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "mp1_ssm_instance_profile"
  role = aws_iam_role.ssm_role.name
}

# Security group and instance code
resource "aws_security_group" "my_sg" {
  name_prefix = "mp1-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## State file configuration
terraform {
  backend "s3" {
    bucket = "terraform-state-bucket-211224"
    key    = "terraform/gitops-k8.tfstate"
    region = "us-west-2"
  }
}

## Output section
output "instance_id" {
  value = aws_instance.my_instance.id
}

output "keypair_location" {
  value = local_file.private_key.filename
}

output "security_group_id" {
  value = aws_security_group.my_sg.id
}