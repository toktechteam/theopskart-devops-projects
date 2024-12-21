provider "aws" {
  region  = "us-west-2"
  profile = "system"
}

# Key pair code
resource "aws_key_pair" "my_key" {
  key_name   = "my_key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "local_file" "private_key" {
  content  = aws_key_pair.my_key.key_name
  filename = "${path.module}/my_key.pem"
}

# IAM role and policy for SSM
resource "aws_iam_role" "ssm_role" {
  name = "ssm_role"

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
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my_key.key_name

  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  tags = {
    Name = "my_instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              exec > /var/log/user-data.log 2>&1
              set -x

              # Install SSM Agent
              sudo yum install -y amazon-ssm-agent
              sudo systemctl enable amazon-ssm-agent
              sudo systemctl start amazon-ssm-agent

              # Install Nginx
              sudo yum install -y nginx
              sudo systemctl enable nginx
              sudo systemctl start nginx

              # Fetch the token for IMDSv2
              TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

              # Retry mechanism for instance metadata
              MAX_RETRIES=10
              RETRY_INTERVAL=5

              for i in $(seq 1 $MAX_RETRIES); do
                INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
                PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)
                if [ -n "$INSTANCE_ID" ] && [ -n "$PUBLIC_IP" ]; then
                  break
                fi
                sleep $RETRY_INTERVAL
              done

              # Check if the values were retrieved successfully
              if [ -z "$INSTANCE_ID" ] || [ -z "$PUBLIC_IP" ]; then
                echo "Failed to retrieve instance metadata"
                exit 1
              fi

              # Configure index.html
              echo "<html><body style='background-color:lightgreen;'><h1>Hello This instance is created using terraform script</h1><p>Instance ID: $INSTANCE_ID</p><p>Public IP: $PUBLIC_IP</p></body></html>" | sudo tee /usr/share/nginx/html/index.html
              EOF
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "ssm_instance_profile"
  role = aws_iam_role.ssm_role.name
}

# Security group and instance code
resource "aws_security_group" "my_sg" {
  name_prefix = "my_sg"

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
    key    = "terraform/terraform.tfstate"
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