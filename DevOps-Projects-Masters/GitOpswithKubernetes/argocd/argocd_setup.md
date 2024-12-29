# ArgoCD Deployment Guide

This guide outlines the steps to deploy ArgoCD and set up the necessary configurations.

---

## Steps to Deploy ArgoCD



### 1. Setup ArgoCD

Run the following command to apply the ArgoCD installation file:

```bash
kubectl apply -f argocd-ns.yaml

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.13.2/manifests/install.yaml
```
## Access the ArgoCD Dashboard

### Use Port Forwarding

Run the following command to forward the ArgoCD server port to your local machine:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443 --address 0.0.0.0

OR
kubectl port-forward svc/argocd-server -n argocd 8080:80 --address 0.0.0.0

OR 
nohup kubectl port-forward svc/argocd-server -n argocd 8080:443 > port-forward.log 2>&1 &
```

Open your browser and navigate to:

```
https://localhost:8080
If you are runing it as minikube on ec2 then add the port in sg and access with your ec2-ip and port.
```

---

## Login to ArgoCD

### Default Credentials

- **Username**: `admin`
- **Password**: Retrieve the initial password using the following command:

```bash
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode
```
Image:


---

## How It Works

Once deployed, ArgoCD will monitor your Git repository for any changes to the deployment or service files. It will automatically sync the changes to your Kubernetes cluster, ensuring a seamless GitOps workflow.
