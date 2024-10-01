# Legend Deployment Chart

This Helm chart is a very simple application deployment including an ingress and TLS configuration, and has support for features supported in the previous deployment framework for on-prem projects, such as environment variable secrets and gatekeeper.
Simplicity was a high priority when creating this chart, which does not make it very flexible but applicable for most deployments.

Here's a few bullet points on what it's capable of.
- Configuring a deployment with a "main" container (your application).
- Enabling a Google Cloud SQL Proxy sidecar in the pod with support for Workload Identity.
- Mounting secrets, configmaps or additional volumes into the pods.
- Enabling a service for the deployment.
- Enabling an ingress with TLS.

@todo Make examples for gatekeeper

## Examples 1

First example is a very simple deployment of a pod.

```yaml
deployment:
  replicas: 1
  container:
    image: my-image
    tag: v0.1.5
```

## Examples 2

Below example enables the Google Cloud SQL Proxy sidecar in the pod.

```yaml
global:
  # The Google Project ID.
  # [Required for Cloud SQL Proxy]
  projectID: my-google-project-id

deployment:
  replicas: 1
  serviceAccountName: my-service-account
  container:
    image: my-image
    tag: v0.1.5
    environment:
      ConnectionString: Host=localhost;Port=5432;Database=mydb;...

  cloudSQLProxy:
    enable: true
    instanceName: sqlinstance-name
    secretKeyName: my-service-account-key
```

## Examples 3

Below example enables a service and an ingress definition with the deployment. By default the ingress configuration will create a standard path rule. All traffic with a PathPrefix of "/" will be routed to the service.
You can add more path rules with the `addtionalPaths` property. A TLS configuration will also be created.

```yaml
deployment:
  replicas: 1
  container:
    image: my-image
    tag: v0.1.5
    containerPort: 8080

service:
  enable: true

ingress:
  enable: true
  host: example.org
```

# Example 4

```yaml
global:
  # The Google Project ID.
  # [Required for Cloud SQL Proxy]
  projectID: my-google-project-id

deployment:
  replicas: 1
  serviceAccountName: my-service-account
  container:
    image: my-image
    tag: v0.1.5
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
    instanceName: sqlinstance-name

service:
  enable: true

ingress:
  enable: true
  host: example.org
  additionalPaths:
  - path: /api/
    pathType: Prefix
    backend:
      service:
        name: backend-for-frontend
        port:
          number: 3000
```
