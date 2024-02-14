# DevX Dashboard Chart

This is a simple chart to ease the deployment of OK DevX Dashboard.


## Example
Below is an example on a minimal deployment of the DevX Dashboard.
```yaml
global:
  projectID: my-project-id

portalUrl: https://devx.org.com

azure:
  tenantId: b8b82166-7e2c-4a71-bb4f-98be8203a03e
  domain: my-org.onmicrosoft.com

viewerGroups:
  - devx-viewer

administratorGroups:
  - devx-admin

backend:
  auth:
    clientId: 3434757d-2aaf-48b8-8697-aa18fc48ca52
    k8sSecretName: devx-client-secret

frontend:
  auth:
    clientId: f6ec2a7d-e070-458d-ab6e-5e8ac66de48e
    oauthScope: <scope>

releaseBoard:
  azureDevOps:
    baseUrl: https://dev.azure.com/my-org
    project: my-devops-project
    boardsQueryId: 23600435-0889-4230-8610-b73c332399e7

  pipelines:
    prod:
      some-repository-name: 405

deadLetter:
  enabled: true
  deadLetterSubscriptions:
    - PubSubSubscriptionName: deadletter-subscription-name1
    - PubSubSubscriptionName: deadletter-subscription-name2

iamServiceAccount:
  workloadIdentity:
    kubernetesNamespace: my-namespace
    gkeProjectID: project-id-where-my-gke-cluster-is
```
