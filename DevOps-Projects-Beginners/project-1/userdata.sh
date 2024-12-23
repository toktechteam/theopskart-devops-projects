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