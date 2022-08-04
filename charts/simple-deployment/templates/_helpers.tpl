{{- define "deployment.labels" -}}
app: {{ .Release.Name }}
chart-name: {{ .Chart.Name }}
chart-version: {{ .Chart.Version }}
{{- with .Values.global.labels }}
  {{- toYaml . }}
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
  value: {{ .Release.Name }}
- name: DD_VERSION
  value: {{ .Values.deployment.container.tag }}
- name: DD_AGENT_HOST
  valueFrom:
    fieldRef:
      fieldPath: status.hostIP
{{- end -}}

{{- define "deployment.dataDogAnnotations" -}}
ad.datadoghq.com/{{ .Release.Name }}.logs: '[{"source": "{{ .Release.Name }}"}]'
ad.datadoghq.com/{{ .Release.Name }}.tags: '{"service": "{{ .Release.Name }}"}'
{{- end -}}

{{- define "deployment.dataDogLabels" -}}
tags.datadoghq.com/service: {{ .Release.Name }}
tags.datadoghq.com/version: {{ .Values.deployment.container.tag }}
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
- name: cloud-sql-proxy
  image: "gcr.io/cloudsql-docker/gce-proxy:{{ .cloudSQLProxy.imageTag }}"
  command:
    - "/cloud_sql_proxy"
    - "-instances={{ .cloudSQLProxy.projectId }}:{{ .cloudSQLProxy.region }}:{{ .cloudSQLProxy.instanceName }}=tcp:5432"
    - "-credential_file=/secrets/{{ .cloudSQLProxy.secretKeyName }}/key.json"
    - "-enable_iam_login"
  securityContext:
    runAsNonRoot: true
  volumeMounts:
    - name: {{ .cloudSQLProxy.secretKeyName }}
      mountPath: "/secrets/{{ .cloudSQLProxy.secretKeyName }}"
      readOnly: true
{{- end -}}