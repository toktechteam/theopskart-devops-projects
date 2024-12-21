# Task 01 

DevOps-Projects-Intermediate
Task: Deploy a web application using a CI/CD pipeline.

Objective: Learn to automate deployment of web applications using CI/CD tools and Infrastructure as Code (IaC).

Steps:

Use GitLab CI/CD or GitHub Actions to create a pipeline.
Stages: Code Checkout > Build > Test > Deploy.
Deploy a simple web app on an AWS EC2 instance or containerize it using Docker.
Use Terraform to provision the required infrastructure.
Provision Infrastructure:

Use AWS Free Tier to provision resources.
Install Terraform, configure AWS CLI, and create an EC2 instance in us-west-2.
Deploy a Dockerized web application on the instance:
Use nginx or a sample HTML file as the app.
Verify the setup by accessing the app via the public IP on port 80.
Additional Challenge:

Use a reverse proxy or SSL setup.
Configure automated notifications for pipeline results (Slack or email).
Cleanup:

Test the deployment and log outputs.
Remove resources using terraform destroy.

