# Simple Deployment Chart

This Helm chart is a very simple application deployment including an ingress and TLS configuration. Simplicity was a high priority when creating this chart, which does not make it very flexible but applicable for most deployments.

Here's a few bullet points on what it's capable of.
- Configuring a deployment with a "main" container (your application).
- Enabling a Google Cloud SQL Proxy sidecar in the pod with support for Workload Identity.
- Mounting secrets, configmaps or additional volumes into the pods.
- Enabling a service for the deployment.
- Enabling an ingress with TLS.
- Internal OK exposure by default in the Gen 2 kubernetes cluster.
  - This is overwriteable with the boolean "exposure", or by setting your specific ingress with ingressClassName in your services' values file.
- Public ingress by default in the GKE Cloud cluster.

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

    # If you are not using Workload Identity, set below field to use a credentials file instead.
    # secretKeyName: my-service-account-key
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
  addtionalPaths:
  - path: /api/
    pathType: Prefix
    backend:
      service:
        name: backend-for-frontend
        port:
          number: 3000
```

## Example 5

**The new ingress in Gen 2 supports two different domains: ok.dk and okcloud.dk**

### Example 5.1: Configuring internal OK exposure
If you want to deploy a new service on the ok.dk domain, and want to expose the ingress privately in OK, the following example can be used. In this case 'exposure' is set to internalOK.

```yaml
ingress:
  enable: true
  host: example.test.ok.dk
  exposure: internalOK
```

### Example 5.2: Configuring public exposure
If you want to deploy a new service on the ok.dk domain, and want to expose the ingress publicly, the following example can be used. In this case 'exposure' is set to public.

```yaml
ingress:
  enable: true
  host: example.test.ok.dk
  exposure: public
```

### 5.3: Using the default privacy of a domain
If you do NOT specify 'exposure' on an ingress controller the domains default will be used instead. Reference the following table for defaults.
|Domain|Default privacy|
|---|---|
|*.ok.dk|internalOK|
|*.okcloud.dk|public|

The below example will result in internal OK exposure because the host is using the ok.dk domain.
```yaml
ingress:
  enable: true
  host: example.test.ok.dk
```

The below example will result in public exposure because the host is using the okcloud.dk domain.
```yaml
ingress:
  enable: true
  host: example.test.okcloud.dk
```

### Domains supported by simple-deployment
Note that if you're using a domain that is not in the following table simple-deployment will throw an error. \
All possible domain/env combinations are listed below along with the supported ingress exposure.

| Domain  | Supports internalOK | Supports Public | Environment|
| ---| --- | --- | --- |
|**ok.dk**||||
|*.test.ok.dk                   |yes  |yes  |test|
|*.prod-test.ok.dk              |yes  |yes  |prodtest|
|*.ok.dk                        |yes  |yes  |prod|
|**okcloud.dk**||||
|*.test.okcloud.dk              |no   |yes  |test|
|*.prod-test.okcloud.dk         |no   |yes  |prodtest|
|*.okcloud.dk                   |no   |yes  |prod|

# Exampel 6: External Secret Store (Gen2)
Prequisite: Extrnal Secret Store must be enabled on the given project. If possible, please use the nuget package instead.
Furthermore, the deployment must be in gen2.

In order to use the external secret store to create a kubernetes secret, the simple-deployment can be templated as follows.

``` yaml
  deployment:
    container:
      externalSecrets:
      - name: "secret-name1"
        data:
        - key: "key1"
          remoteSecret: "remote-secret-name1"
      - name: "secret-name2"
        data:
        - key: "key1"
          remoteSecret: "remote-secret-name2"
        - key: "key2"
          remoteSecret: "remote-secret-name3"
      environment:
        secret1Key1Path: /secrets/secret-name1/key1
        secret2Key1Path: /secrets/secret-name2/key1
        secret2Key1Path: /secrets/secret-name2/key2

```
It's possible to map one to one or multiple remote secrets into one kubernetes secret. The secret will automatically be mounted as a file with path `/secrets/<SECRET NAME>/<KEY NAME>`.

