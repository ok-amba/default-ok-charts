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
      - "observability"
      - "env:prod"
    thresholds:
       critical: 5
```

# Log query example
```yaml
  - name: "argo cd log check"
    type: "log alert"
    query: "logs(\"source:argocd status:(error OR critical OR emergency) -\\\"Watch failed\\\" -\\\"helm template\\\"\").index(\"*\").rollup(\"count\").last(\"5m\") > 20"
    message: "pod {{pod_name.name}} is complaining on {{kube_namespace.name}}"
    tags:
      - "team:observability"
      - "project:observability"
      - "env:prod"
    thresholds:
       critical: 5
       warning: 2
```

Below are some optional properties you can add to the monitor object, with their default values.
```yaml
    priority: 4
    notifyAudit: "false"
    requireFullWindow: "false"
    notifyNoData: "false"
    noDataTimeframe: null
    renotifyInterval: 0
    includeTags: "false"
    evaluationDelay: 0
```

### Optional Property Descriptions
**priority**
- Priority is an integer from 1 (high) to 5 (low) indicating alert severity.

**notifyAudit**
- A Boolean indicating whether tagged users are notified on changes to this monitor.

**requireFullWindow**
- A Boolean indicating whether this monitor needs a full window of data before it’s evaluated.
  We highly recommend you set this to false for sparse metrics, otherwise some evaluations are skipped. Default is false.

**notifyNoData**
- A Boolean indicating whether this monitor notifies when data stops reporting.

**noDataTimeframe**
- The number of minutes before a monitor notifies after data stops reporting. Datadog recommends at least 2x the monitor
  timeframe for metric alerts or 2 minutes for service checks.
  If omitted, 2x the evaluation timeframe is used for metric alerts, and 24 hours is used for service checks.

**renotifyInterval**
- The number of minutes after the last notification before a monitor re-notifies on the current status.
  It only re-notifies if it’s not resolved.

**includeTags**
- A Boolean indicating whether notifications from this monitor automatically inserts its triggering tags into the title.

**evaluationDelay**
- Time (in seconds) to delay evaluation, as a non-negative integer. For example, if the value is set to 300 (5min), the
  timeframe is set to last_5m and the time is 7:00, the monitor evaluates data from 6:50 to 6:55. This is useful for AWS CloudWatch
  and other backfilled metrics to ensure the monitor always has data during evaluation.
