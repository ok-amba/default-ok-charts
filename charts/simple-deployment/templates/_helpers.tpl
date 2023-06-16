{{- define "deployment.name" -}}
{{ .Values.fullnameOverride | default .Release.Name | trunc 63 | trimSuffix "-"}}
{{- end -}}

{{- define "deployment.labels" -}}
app: {{ include "deployment.name" $ | quote }}
chart-name: {{ .Chart.Name | quote }}
chart-version: {{ .Chart.Version | quote }}
{{- range $k, $v := .Values.global.labels }}
{{ printf "%s: %s" $k ($v | quote) }}
{{- end -}}
{{- end -}}

{{- define "deployment.dataDogEnvs" -}}
- name: CORECLR_ENABLE_PROFILING
  value: "1"
- name: CORECLR_PROFILER
  value: "{846F5F1C-F9AE-4B07-969E-05C26BC060D8}"
- name: CORECLR_PROFILER_PATH
  value: /app/datadog/linux-x64/Datadog.Trace.ClrProfiler.Native.so
- name: DD_PROFILING_ENABLED
  value: "1"
- name: DD_DOTNET_TRACER_HOME
  value: /app/datadog
- name: DD_TRACE_AGENT_URL
  value: unix:///var/run/datadog/apm.socket
- name: DD_LOGS_INJECTION
  value: 'true'
- name: DD_SERVICE
  value: {{ include "deployment.name" $ }}
- name: DD_VERSION
  value: {{ .Values.deployment.container.tag }}
- name: DD_AGENT_HOST
  valueFrom:
    fieldRef:
      fieldPath: status.hostIP
{{- end -}}

{{- define "deployment.dataDogAnnotations" -}}
ad.datadoghq.com/{{ include "deployment.name" $ }}.logs: '[{"source": "{{ include "deployment.name" $ }}", "service": "{{ include "deployment.name" $ }}"}]'
{{- end -}}

{{- define "deployment.dataDogLabels" -}}
tags.datadoghq.com/service: {{ include "deployment.name" $ | quote }}
tags.datadoghq.com/version: {{ .Values.deployment.container.tag | quote }}
{{- end -}}

{{- define "deployment.livenessProbe" -}}
httpGet:
  path: {{ .livenessProbe.httpGet.path }}
  port: {{ .containerPort }}
initialDelaySeconds: {{ .livenessProbe.initialDelaySeconds }}
periodSeconds: {{ .livenessProbe.periodSeconds }}
timeoutSeconds: {{ .livenessProbe.timeoutSeconds }}
successThreshold: 1
failureThreshold: {{ .livenessProbe.failureThreshold }}
{{- end -}}

{{- define "deployment.readinessProbe" -}}
httpGet:
  path: {{ .readinessProbe.httpGet.path }}
  port: {{ .containerPort }}
initialDelaySeconds: {{ .readinessProbe.initialDelaySeconds }}
periodSeconds: {{ .readinessProbe.periodSeconds }}
timeoutSeconds: {{ .readinessProbe.timeoutSeconds }}
successThreshold: {{ .readinessProbe.successThreshold }}
failureThreshold: {{ .readinessProbe.failureThreshold }}
{{- end -}}

{{- define "deployment.cloudSQLProxy" -}}
{{- with .Values.deployment -}}

{{- /* Below if statments makes sure that you cannot specify to use version 1 of Cloud SQL Proxy */ -}}
{{- if .cloudSQLProxy.imageTag -}}
  {{- if lt ((semver .cloudSQLProxy.imageTag).Major) 2 -}}
  {{- fail "The version of Cloud SQL Proxy is too low. Delete the cloudSQLProxy.imageTag field to use the default version." -}}
  {{- end -}}
{{- end -}}

{{- $projectID := (.cloudSQLProxy.projectId | default $.Values.global.projectID) -}}
{{- if not $projectID }}
{{- fail "The global.projectID is not set. It is required for Cloud SQL Proxy." -}}
{{- end -}}

- name: cloud-sql-proxy
  image: "gcr.io/cloud-sql-connectors/cloud-sql-proxy:{{ .cloudSQLProxy.imageTag | default "2.3.0" }}"
  command:
    - "/cloud-sql-proxy"
    - "{{ $projectID }}:{{ .cloudSQLProxy.region }}:{{ .cloudSQLProxy.instanceName }}"
    - "--credentials-file=/secrets/{{ .cloudSQLProxy.secretKeyName }}/key.json"
    - "--auto-iam-authn"
  securityContext:
    runAsNonRoot: true
  volumeMounts:
    - name: {{ .cloudSQLProxy.secretKeyName }}
      mountPath: "/secrets/{{ .cloudSQLProxy.secretKeyName }}"
      readOnly: true
{{- end -}}
{{- end -}}
