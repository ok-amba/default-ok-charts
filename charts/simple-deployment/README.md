# Simple Deployment Chart

This Helm chart is a very simple application deployment including an ingress and TLS configuration. Simplicity was a high priority when creating this chart, which does not make it very flexible but applicable for most deployments.

Here's a few bullet points on what it's capable of.
- Configuring a deployment with a "main" container (your application).
- Enabling a Google Cloud SQL Proxy sidecar in the pod.
- Mounting secrets, configmaps or additional volumes into the pod.
- Enabling a service for the deployment.
- Enabling an ingress with TLS.

## Examples 1

First example is a very simple deployment of a pod.

```yaml
deployment:
  replicas: 1
  container:
    image: my-image:v0.1.5
    tag: latest
```

## Examples 2

Below example enables the Google Cloud SQL Proxy sidecar in the pod.

```yaml
deployment:
  replicas: 1
  container:
    image: my-image:v0.1.5
    tag: latest
    environment:
      ConnectionString: Host=localhost;Port=5432;Database=mydb;...

  cloudSQLProxy:
    enable: true
    imageTag: 1.30.0
    projectId: google-project-id
    region: europe-west3
    instanceName: sqlinstance-name
    secretKeyName: google-service-account-key
```

## Examples 3

Below example enables a service and an ingress definition with the deployment. By default the ingress configuration will create a standard path rule. All traffic with a PathPrefix of "/" will be routed to the service. You can add more path rules with the `addtionalPaths` property. A TLS configuration will also be created.

```yaml
deployment:
  replicas: 1
  container:
    image: my-image:v0.1.5
    tag: latest
    containerPort: 8080

service:
  enable: true

ingress:
  enable: true
  annotations:
    cert-manager.io/cluster-issuer: nginx-http01
  ingressClassName: nginx
  host: example.org
```

# Example 4

```yaml
deployment:
  replicas: 1
  container:
    image: my-image:v0.1.5
    tag: latest
    containerPort: 8080
    resources:
      requests:
        memory: 1000Mi
        cpu: 400m
      limits:
        memory: 2000Mi
        cpu: 1000m

    environment:
      SOME_ENV: some-value

    secrets:
    - very-secret
    - client-secret

    configMaps:
    - name: some-configmap
      mountPath: /some/path

  cloudSQLProxy:
    enable: true
    imageTag: 1.30.0
    projectId: google-project-id
    region: europe-west3
    instanceName: sqlinstance-name
    secretKeyName: google-service-account-key

service:
  enable: true

ingress:
  enable: true
  annotations:
    cert-manager.io/cluster-issuer: nginx-http01
  ingressClassName: nginx
  host: example.org
  addtionalPaths:
  - path: /api/
    pathType: Prefix
    backend:
      service:
        name: backend-for-frontend
        port:
          number: 3000
```