# ArgoCD Deployment Guide

This guide outlines the steps to deploy ArgoCD and set up the necessary configurations.

---

## Steps to Deploy ArgoCD

### 1. Create ArgoCD Installation File

Create a file named `argocd-install.yaml` with the following content:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: argocd
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: argocd-server
  namespace: argocd
  
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: argocd-server
  namespace: argocd
spec:
  replicas: 1
  selector:
    matchLabels:
      app: argocd-server
  template:
    metadata:
      labels:
        app: argocd-server
    spec:
      serviceAccountName: argocd-server
      containers:
        - name: argocd-server
          image: argoproj/argocd:v2.0.5
          ports:
            - containerPort: 8080
          args:
            - server
---
apiVersion: v1
kind: Service
metadata:
  name: argocd-server
  namespace: argocd
  labels:
    app: argocd-server
spec:
  ports:
    - name: http
      port: 80
      targetPort: 8080
      nodePort: 30080
    - name: https
      port: 443
      targetPort: 8080
      nodePort: 30443
  selector:
    app: argocd-server
  type: NodePort
---

```

### 2. Apply the Configuration

Run the following command to apply the ArgoCD installation file:

```bash
kubectl apply -f argocd-install.yaml
```

---

## Create the ArgoCD Application

Save the ArgoCD Application manifest in a file named `argocd-application.yaml` and apply it:

```bash
kubectl apply -f argocd-application.yaml
```

---

## Access the ArgoCD Dashboard

### Use Port Forwarding

Run the following command to forward the ArgoCD server port to your local machine:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
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

---

## How It Works

Once deployed, ArgoCD will monitor your Git repository for any changes to the deployment or service files. It will automatically sync the changes to your Kubernetes cluster, ensuring a seamless GitOps workflow.
