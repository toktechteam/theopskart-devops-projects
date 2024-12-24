# Kubernetes Setup and Configuration Guide

To achieve the setup described, follow the steps below. This guide provides a high-level overview and detailed instructions to complete the tasks.

## Steps Involved

1. **User Data Script for EC2 Setup**:
    - Install Minikube
    - Install Helm
    - Install ArgoCD
    - Install kubectl

2. **Simple Application Code**:
    - A basic Kubernetes deployment and service YAML for a simple application (e.g., Nginx).

3. **GitHub Workflow for Image Build and Push**:
    - A GitHub Actions workflow to build and push Docker images to Docker Hub.

4. **Prometheus and Grafana Setup**:
    - Helm charts for Prometheus and Grafana
    - Configuration for alert manager

---
## To provision the ec2 instance with the user data script, follow the steps below:
export AWS_PROFILE=system
terraform plan
terraform apply --auto-approve

## 1. User Data Script for EC2 Setup

```bash
#!/bin/bash
# Update and install dependencies
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y
sudo apt-get install -y docker-ce
sudo systemctl enable docker
sudo systemctl start docker

# Wait for Docker to start
sleep 10

# Install Minikube
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/

# Start Minikube with Docker driver
sudo minikube start --driver=docker --force --cpus 4 --memory 10240

# Wait for Minikube to start
sleep 20

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Wait for kubectl to be ready
sleep 10

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Install ArgoCD CLI
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd-linux-amd64
sudo mv argocd-linux-amd64 /usr/local/bin/argocd
```

---

## 2. Simple Application Code

Create a file `nginx-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
   name: nginx-service
spec:
   selector:
      app: nginx
   ports:
      - protocol: TCP
        port: 80
        targetPort: 80
        nodePort: 31014
   type: NodePort
```

---

# Verify the kubectl deployment Example Below & [Enable Port 31014 in Ec2 Security Group]
[root@ip-172-31-20-232 ~]# kubectl get svc
NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
kubernetes         ClusterIP   10.96.0.1        <none>        443/TCP        42m
nginx-deployment   NodePort    10.105.200.113   <none>        80:31014/TCP   11m

kubectl port-forward --address 0.0.0.0 svc/nginx-deployment 31014:80

## 3. GitHub Workflow for Image Build and Push

Create a file `.github/workflows/docker-image.yml`:

```yaml
name: Build and Push Docker Image

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v1

    - name: Log in to Docker Hub
      uses: docker/login-action@v1
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}

    - name: Build and push
      uses: docker/build-push-action@v2
      with:
        push: true
        tags: ${{ secrets.DOCKER_USERNAME }}/my-app:latest
```

---

## 4. Prometheus and Grafana Setup

Create a file `prometheus-grafana-setup.sh`:

```bash
#!/bin/bash
# Add Helm repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Prometheus
helm install prometheus prometheus-community/prometheus --namespace monitoring --create-namespace

# Install Grafana
helm install grafana grafana/grafana --namespace monitoring

# Get Grafana admin password
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

---

## 5. Alert Manager Configuration

Create a file `alertmanager-config.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: alertmanager-config
  namespace: monitoring
data:
  alertmanager.yml: |
    global:
      resolve_timeout: 5m
    route:
      group_by: ['alertname']
      group_wait: 30s
      group_interval: 5m
      repeat_interval: 12h
      receiver: 'slack-notifications'
    receivers:
    - name: 'slack-notifications'
      slack_configs:
      - api_url: 'https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX'
        channel: '#alerts'
        send_resolved: true
```

Apply the configuration:

```bash
kubectl apply -f alertmanager-config.yaml
```

---

## Summary

1. Use the provided user data script to set up Minikube, Helm, ArgoCD, and kubectl on an EC2 instance.
2. Deploy the simple Nginx application using the provided YAML file.
3. Set up GitHub Actions to build and push Docker images securely.
4. Install Prometheus and Grafana using Helm and configure alert manager for monitoring.

This setup provides a comprehensive environment for managing Kubernetes deployments using GitOps principles.
