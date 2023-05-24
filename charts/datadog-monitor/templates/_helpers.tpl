

{{- define "datadogmonitor.name" -}}
{{ .Values.fullnameOverride | default .Release.Name | trunc 63 | trimSuffix "-"}}
{{- end -}}

{{- define "datadogmonitor.labels" -}}
app: {{ include "datadogmonitor.name" $ }}
chart-name: {{ .Chart.Name }}
chart-version: {{ .Chart.Version }}
{{- end -}}