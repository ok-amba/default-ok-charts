# Datadog Monitors

This Helm Chart is used for deploying DataDog Monitors
for more examples, visit # https://github.com/DataDog/datadog-operator/tree/main/examples/datadogmonitor


# Metric query example
```yaml
  - name: "argocd metric check" 
    type: "query alert"
    query: "avg(last_15m):anomalies(avg:argocd.api_server.go.memstats.heap.alloc_bytes{*,*,*} by {host,kube_cluster_name}, 'basic', 2, direction='both', interval=60, alert_window='last_15m', count_default_zero='true') >= 1"
    message: "pod {{pod_name.name}} is complaining on {{kube_namespace.name}}"
    tags:
      - "team:observability"
      - "env:prod"
    thresholds:
       critical:
       warning:
    priority:
```

# Log query example
```yaml
  - name: "argo cd log check"
    type: "log alert"
    query: "logs(\"source:argocd status:(error OR critical OR emergency) -\\\"Watch failed\\\" -\\\"helm template\\\"\").index(\"*\").rollup(\"count\").last(\"5m\") > 20"
    message: "pod {{pod_name.name}} is complaining on {{kube_namespace.name}}"
    tags:
      - "team:observability"
      - "env:prod"
    priority:          # default 4
    thresholds:
      critical:        # Needs to be quoted eg "10"
      warning:         # Needs to be quoted eg "5"
    notifyAudit:       # default false
    requireFullWindow: # default false
    notifyNoData:      # default false
    noDataTimeframe:   # 
    renotifyInterval:  # default 0
    includeTags:       # default false
    evaluationDelay:   # default 300
    enableLogsSample:  # default true
```