# Node.js CRUD Application with Kubernetes and Monitoring

This guide provides step-by-step instructions for deploying a Node.js CRUD application with MongoDB on Kubernetes, managing it using ArgoCD, and monitoring it with Prometheus and Grafana.

## Components

1. **Node.js CRUD Application**:
    - A simple Express.js application with CRUD operations.
    - MongoDB as the database.

2. **Kubernetes Deployment and Service Files**:
    - Deployment YAML file to deploy the application.
    - Service YAML file to expose the application.

3. **ArgoCD Application File**:
    - YAML file to manage the deployment using GitOps.

4. **Prometheus and Grafana Monitoring**:
    - Configuration files to monitor the application.

---

## 1. Node.js CRUD Application

### Application Code

**`app.js`**:
```javascript
const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.json());

mongoose.connect('mongodb://mongo:27017/cruddb', { useNewUrlParser: true, useUnifiedTopology: true });

const itemSchema = new mongoose.Schema({
  name: String,
  description: String
});

const Item = mongoose.model('Item', itemSchema);

app.get('/items', async (req, res) => {
  const items = await Item.find();
  res.json(items);
});

app.post('/items', async (req, res) => {
  const newItem = new Item(req.body);
  await newItem.save();
  res.json(newItem);
});

app.get('/items/:id', async (req, res) => {
  const item = await Item.findById(req.params.id);
  res.json(item);
});

app.put('/items/:id', async (req, res) => {
  const updatedItem = await Item.findByIdAndUpdate(req.params.id, req.body, { new: true });
  res.json(updatedItem);
});

app.delete('/items/:id', async (req, res) => {
  await Item.findByIdAndDelete(req.params.id);
  res.json({ message: 'Item deleted' });
});

app.listen(3000, () => {
  console.log('Server is running on port 3000');
});
```

### Dockerfile

**`Dockerfile`**:
```dockerfile
FROM node:14

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000
CMD ["node", "app.js"]
```

### Dependencies

**`package.json`**:
```json
{
  "name": "crud-app",
  "version": "1.0.0",
  "main": "app.js",
  "dependencies": {
    "express": "^4.17.1",
    "mongoose": "^5.10.9",
    "body-parser": "^1.19.0"
  }
}
```

---

## 2. Kubernetes Deployment and Service Files

### Application Deployment

**`deployment.yaml`**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: crud-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: crud-app
  template:
    metadata:
      labels:
        app: crud-app
    spec:
      containers:
      - name: crud-app
        image: your-dockerhub-username/crud-app:latest
        ports:
        - containerPort: 3000
---
apiVersion: v1
kind: Service
metadata:
  name: crud-app-service
spec:
  selector:
    app: crud-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
  type: LoadBalancer
```

### MongoDB Deployment

**`mongo-deployment.yaml`**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mongo
  template:
    metadata:
      labels:
        app: mongo
    spec:
      containers:
      - name: mongo
        image: mongo:latest
        ports:
        - containerPort: 27017
---
apiVersion: v1
kind: Service
metadata:
  name: mongo-service
spec:
  selector:
    app: mongo
  ports:
  - protocol: TCP
    port: 27017
    targetPort: 27017
  type: ClusterIP
```

---

## 3. ArgoCD Application File

**`argocd-application.yaml`**:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: crud-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: 'https://github.com/your-repo.git'
    targetRevision: HEAD
    path: k8s
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

---

## 4. Prometheus and Grafana Monitoring

### Prometheus Configuration

**`prometheus-config.yaml`**:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    scrape_configs:
      - job_name: 'kubernetes'
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels: [__meta_kubernetes_pod_label_app]
            action: keep
            regex: crud-app
```

### Grafana Configuration

**`grafana-dashboards.yaml`**:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboards
  namespace: monitoring
data:
  dashboards.yaml: |
    apiVersion: 1
    providers:
      - name: 'default'
        orgId: 1
        folder: ''
        type: file
        disableDeletion: false
        editable: true
        options:
          path: /var/lib/grafana/dashboards
```

**`grafana-datasource.yaml`**:
```yaml
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus-server
    isDefault: true
```

---

## Summary

1. **Node.js CRUD Application**: A simple Express.js application with MongoDB.
2. **Kubernetes Deployment and Service Files**: YAML files to deploy the application and MongoDB.
3. **ArgoCD Application File**: YAML file to manage the deployment using ArgoCD.
4. **Prometheus and Grafana Monitoring**: Configuration files to monitor the application.

This setup provides a complete environment to deploy, manage, and monitor a CRUD application on Kubernetes.
