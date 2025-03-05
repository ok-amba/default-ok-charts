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
## Example 5

**The new ingress in Gen 2 supports exposure levels**

### Example 5.1: Configuring internal OK exposure
If you want to deploy a new service on the ok.dk domain, and want to expose the ingress internal OK, the following example can be used. In this case 'exposure' is set to internalOK.

```yaml
ingress:
  enable: true
  host: example.private.test.ok.dk
  exposure: internalOK
```

### Example 5.2: Configuring public exposure
If you want to deploy a service on the ok.dk domain, and want to expose the ingress publicly, the following example can be used. In this case 'exposure' is set to public.

```yaml
ingress:
  enable: true
  host: example.test.ok.dk
  exposure: public
```

### 5.3: Using the default exposure of a domain
If you do NOT specify 'exposure' on an ingress the domains default will be used instead. Reference the following table for defaults.
|Domain|Default privacy|
|---|---|
|*.ok.dk|internalOK|

The below example will result in a internal OK exposure because the host is using the ok.dk domain.
```yaml
ingress:
  enable: true
  host: example.test.ok.dk
```


# Exampel 6: External Secret Store
Prequisite: Extrnal Secret Store must be enabled on the given project. If possible, please use the nuget package instead.

In order to use the external secret store to create a kubernetes secret, the legend-deployment can be templated as follows.

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

Another possiblity is to reference the secret as an environment variable directly. However this is not recommended due to how trivial it is inspect a container environment variables. This approach is only recommended during migration of a service.

``` yaml
  deployment:
    container:
      externalSecretsRef:
      - secretName: "kubernetes-secret-name1"
        data:
        - secretKey: "key1"
          refName: "remote-secret-ref1"

```
In this case the secret in the remote store should be named `SecretName__secretKey` e. g. `kubernetes-secret-name1__key1`. e. g.the output will then be kubernetes secret with name `kubernetes-secret-name1` with key `key1`. This is a limitation of the remote store not being able to contain multiple keys and naming conventions for a given kubernetes secret. The secret is automatically referenced as an environment variable with the refName so that an environment variable is created with name e. g. `remote-secret-ref1`. The secret can be mapped to another environment variable with:

``` yaml
  deployment:
    container:
      secretEnvironmentRef:
      - name: "environment-variable1"
        secret: "kubernetes-secret-name1"
        key: "key1"
```
