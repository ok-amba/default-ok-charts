# NATS-streaming Chart

Fork of https://github.com/nats-io/k8s/blob/main/helm/charts/stan/values.yaml that allows specifying auth credentials through a secret. The auth credentials can also be synced through an ExternalSecret using the `stan.auth.secretRef.externalSecret` options.
This fork also removes a lot of the original configuration options as well as setting some default values that are specific to the Gen 2 on-prem cluster.

There will be no maintenance efforts for this chart other than fixes to critical bugs and secrutiy issues.