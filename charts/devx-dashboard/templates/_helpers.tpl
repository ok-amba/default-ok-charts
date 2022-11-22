{{- define "devx.name" -}}
{{ $.Values.fullnameOverride | default .Release.Name | trunc 63 | trimSuffix "-"}}
{{- end -}}

{{- define "devx.labels" -}}
app: {{ include "devx.name" $ }}
chart-name: {{ .Chart.Name }}
chart-version: {{ .Chart.Version }}
{{- with .Values.global.labels }}
  {{- toYaml . }}
{{- end -}}
{{- end -}}

{{- define "devx.dataDogAnnotations" -}}
{{- if .Values.dataDog.enableLogs -}}
ad.datadoghq.com/{{ include "devx.name" $ }}.logs: '[{"source": "{{ include "devx.name" $ }}", "service": "{{ include "devx.name" $ }}"}]'
{{- end -}}
{{- end -}}

{{- define "devx.dataDogLabels" -}}
{{- if $.Values.dataDog.enableLogs -}}
tags.datadoghq.com/service: {{ include "devx.name" $ }}
tags.datadoghq.com/version: {{ .Chart.Version }}
{{- end -}}
{{- end -}}

