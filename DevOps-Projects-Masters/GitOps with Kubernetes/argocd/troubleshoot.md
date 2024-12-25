# Steps to Securely Store and Use GitHub OAuth Credentials

Follow these steps to securely store and use GitHub OAuth credentials in your ArgoCD setup.

---
## Steps to Obtain GitHub OAuth Credentials

Create a GitHub OAuth Application:  
Go to GitHub Developer Settings.
Click on "New OAuth App".
Fill in the required details:
* Application name: Your application name.
* Homepage URL: The URL of your Argo CD server (e.g., https://your-argocd-server).
* Authorization callback URL: The callback URL for Dex (e.g., https://your-argocd-server/dex/callback).

2.Get Client ID and Client Secret:
After creating the OAuth application, you will get a Client ID and Client Secret. These are the values you need to use in your Dex configuration.
## 1. Create a Kubernetes Secret

Store the GitHub client ID and client secret in a Kubernetes secret:

```bash
kubectl create secret generic github-oauth-secret \
  --from-literal=clientID=<your-github-client-id> \
  --from-literal=clientSecret=<your-github-client-secret> \
  -n argocd
```

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: github-oauth-secret
  namespace: argocd
type: Opaque
data:
  clientID: <base64-encoded-client-id>
  clientSecret: <base64-encoded-client-secret>

# echo -n 'your-github-client-id' | base64
#  echo -n 'your-github-client-secret' | base64
```

Replace `<your-github-client-id>` and `<your-github-client-secret>` with your actual GitHub OAuth credentials.

---

## 2. Update the ConfigMap to Reference the Secret

Modify the Dex configuration to reference the secret values. Save the following content in `argocd-cm.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  dex.config: |
    connectors:
    - type: github
      id: github
      name: GitHub
      config:
        clientID: $dex.github.clientID
        clientSecret: $dex.github.clientSecret
        redirectURI: https://your-argocd-server/dex/callback
    oauth2:
      skipApprovalScreen: true
    staticClients:
    - id: argo-cd
      redirectURIs:
      - https://your-argocd-server/auth/callback
      name: Argo CD
      secretEnv: dex-secret
```

Replace `https://your-argocd-server` with your actual ArgoCD server URL.

---

## 3. Update the ArgoCD Deployment to Use the Secret

Ensure the ArgoCD deployment has access to the secret values by adding environment variables. Save the following content in `argocd-server-deployment.yaml`:

```yaml
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
          env:
            - name: dex.github.clientID
              valueFrom:
                secretKeyRef:
                  name: github-oauth-secret
                  key: clientID
            - name: dex.github.clientSecret
              valueFrom:
                secretKeyRef:
                  name: github-oauth-secret
                  key: clientSecret
          command: ["argocd-server"]
```

---

## 4. Apply the Configurations

### Apply the Secret

```bash
kubectl apply -f github-oauth-secret.yaml
```

### Apply the Updated ConfigMap

```bash
kubectl apply -f argocd-cm.yaml
```

### Apply the Updated Deployment

```bash
kubectl apply -f argocd-server-deployment.yaml
```

---

## Summary

This approach ensures that your GitHub OAuth credentials are:

1. Securely stored in Kubernetes secrets.
2. Not exposed in plain text within your configuration files.
3. Referenced dynamically in the ArgoCD configuration and deployment.
