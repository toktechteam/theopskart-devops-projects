# Resource Cleanup Guide

Follow these steps to clean up the resources created during the setup process:

---

## 1. Delete Kubernetes Resources

Remove the Node.js application, MongoDB, and monitoring resources from the Kubernetes cluster:

```bash
kubectl delete -f deployment.yaml
kubectl delete -f mongo-deployment.yaml
kubectl delete -f prometheus-config.yaml
kubectl delete -f grafana-dashboards.yaml
kubectl delete -f grafana-datasource.yaml
kubectl delete namespace monitoring
```

---

## 2. Remove ArgoCD Application

Delete the ArgoCD application:

```bash
kubectl delete -f argocd-application.yaml
```

---

## 3. Terminate EC2 Instance

Terminate the EC2 instance created for the Minikube setup:

```bash
aws ec2 terminate-instances --instance-ids <instance-id>
```

Replace `<instance-id>` with the actual ID of the instance you want to terminate.

---

## 4. Delete Terraform Resources

If you used Terraform to create infrastructure, run the following command to destroy the resources:

```bash
terraform destroy
```

---

## 5. Remove Docker Images

Remove the Docker images from your local machine:

```bash
docker rmi your-dockerhub-username/crud-app:latest
```

Replace `your-dockerhub-username` with your Docker Hub username.

---

## 6. Clean Up GitHub Actions Secrets

Remove any secrets added to your GitHub repository for Docker Hub credentials:

1. Go to your GitHub repository.
2. Navigate to **Settings** > **Secrets and variables** > **Actions**.
3. Delete the secrets `DOCKER_USERNAME` and `DOCKER_PASSWORD`.

---

By following these steps, you will clean up all the resources created during the setup process. This ensures no unnecessary resources or costs remain after the deployment.
