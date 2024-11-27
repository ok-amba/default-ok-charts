# default-ok-charts
A Helm chart respository for default k8s definitions

This repository contains default charts for everyday use. The soul purpose being to standardize the way 

## Add the repository
```sh
helm repo add ok-defaults https://ok-amba.github.io/default-ok-charts
helm repo update
```

## Dev branch helm releases
All helm charts are released to a public repository as a dev release everytime a chart is changed in a non-main branch. \
Each commit is build and published to the dev repo with a tag containing the chart version and an appended commit hash. \
The following is an example of depending on the devx-dashboard using the development OCI images.

```yaml
dependencies:
  - name: devx-dashboard
    version: "2.1.0-0931bd05e59241b926cff38fb05a17890158bbd3"
    repository: "oci://europe-west3-docker.pkg.dev/tinkerbell-329710/ok-public-registry/helm-dev"
```
The docker repository containing the OCI dev images is:

```
europe-west3-docker.pkg.dev/tinkerbell-329710/ok-public-registry/helm-dev
```

This is the link to the repository through googles console -> [link](https://console.cloud.google.com/artifacts/docker/tinkerbell-329710/europe-west3/ok-public-registry)