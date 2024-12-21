# DevOps Learning Series

## Purpose of the Project

The purpose of this project series is to provide a comprehensive learning experience in DevOps, taking you from a beginner level to mastery. Each project is designed to progressively enhance your skills, making your professional journey smoother and more confident. These projects are crafted using my 12 years of industry experience, incorporating real-world scenarios.

DevOps is all about continuous improvement, and I embrace this philosophy by continually updating and expanding this series as I learn and grow.

I invite you to join me on this journey and allow me the opportunity to share my expertise with you for a better learning experience.

## Beginner-Level DevOps Task: Automate Routine Tasks with Bash Scripts

### Task

Automate routine system tasks using Bash scripts.

### Objective

Develop scripts to handle repetitive operations, such as log cleanup, backups, or system updates.

### Steps

1. **Create a Bash script to automate tasks like removing temporary files in `/tmp` or archiving outdated logs.**
2. **Utilize basic shell commands (e.g., `rm`, `cp`, `mv`) combined with loops and conditionals for functionality.**
3. **Test the script thoroughly by scheduling it to run automatically using cron jobs.**

### Steps Involved

1. **Create Dummy Files and Folders for Testing:**
    - Create dummy files older than 7 days in `/tmp`.
    - Create empty directories in `/tmp`.
    - Create dummy log files older than 30 days in `/var/log/myapp`.

2. **Write the Cleanup Script:**
   ```bash
   #!/bin/bash

   # Define the directory to clean
   DIR="/tmp"

   # Find and remove files older than 7 days
   find $DIR -type f -mtime +7 -exec rm -f {} \;

   # Find and remove empty directories
   find $DIR -type d -empty -exec rmdir {} \;

   echo "Cleanup completed for $DIR"
   ```

3. **Write the Archiving Script:**
   ```bash
   #!/bin/bash

   # Define the log directory and archive directory
   LOG_DIR="/var/log/myapp"
   ARCHIVE_DIR="/var/log/myapp/archive"

   # Create the archive directory if it doesn't exist
   mkdir -p $ARCHIVE_DIR

   # Find and move logs older than 30 days to the archive directory
   find $LOG_DIR -type f -name "*.log" -mtime +30 -exec mv {} $ARCHIVE_DIR \;

   # Compress the archived logs
   find $ARCHIVE_DIR -type f -name "*.log" -exec gzip {} \;

   echo "Archiving completed for $LOG_DIR"
   ```

4. **Schedule the Scripts with `cron`:**
    - Open the `crontab` editor:
      ```bash
      crontab -e
      ```
    - Add the following lines to schedule the scripts:
        - To run the cleanup script daily at midnight:
          ```bash
          0 0 * * * /path/to/cleanup_script.sh
          ```
        - To run the archiving script weekly on Sundays at 2 AM:
          ```bash
          0 2 * * 0 /path/to/archive_script.sh
          ```
    - Save and exit the `crontab` editor.

By following these steps, you will automate routine system tasks using Bash scripts and schedule them to run automatically using cron jobs.

## Provisioning Infrastructure for the Task

### Prerequisites

1. **Set up an AWS Free Tier account.**
2. **Generate AWS IAM Access Keys** for a user with sufficient permissions.
3. **Install the latest version of Terraform.**
4. **Use a laptop running Windows or macOS.**

### Steps to Provision an EC2 Instance

#### 1. Install and Configure AWS CLI

- **Install the AWS CLI** on your system (instructions provided in the [AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)).
- **Configure the AWS CLI** using the access keys:

```bash
aws configure
```

Specify the IAM access key, secret key, default region (e.g., `us-west-2`), and output format (json or text).

#### 2. Set Up Terraform

- **Install Terraform** (instructions available at [Terraform documentation](https://learn.hashicorp.com/tutorials/terraform/install-cli)).

- **Write a Terraform script** to create an EC2 instance in the `us-west-2` region. Example Terraform code:

```hcl
provider "aws" {
  profile = "your-aws-profile"
  region  = "us-west-2"
}

resource "aws_instance" "web" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI
  instance_type = "t2.micro"

  tags = {
    Name = "DevOps-Beginner-Instance"
  }
}
```

- **Initialize Terraform and apply the configuration:**

```bash
terraform init
terraform apply
```

#### 3. Verification

- **After provisioning**, retrieve the public IP of the EC2 instance.
- **Open a browser** and access the instance using `http://<public-ip>:80`. A verification webpage should appear.

#### 4. Access the Instance and Run Commands

- **Use the AWS Management Console** to connect to the instance via the SSM Connect button.
- **Run the provided commands** to complete the task (e.g., testing file creation, web server setup, etc.).

#### 5. Cleanup

- **Verify that all required tasks are completed.**
- **Delete all created resources** to avoid incurring costs:

```bash
terraform destroy
```

- **Remove unnecessary files and folders** related to the task.

By following these steps, you can provision, verify, and clean up the infrastructure effectively while practicing essential DevOps skills.