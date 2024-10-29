{{- define "deployment.name" -}}
{{ .Values.fullnameOverride | default .Release.Name | trunc 63 | trimSuffix "-"}}
{{- end -}}

{{- define "deployment.labels" -}}
app: {{ include "deployment.name" $ | quote }}
chart-name: sftpgo
chart-version: {{ .Chart.Version | quote }}
{{- range $k, $v := .Values.global.labels }}
{{ printf "%s: %s" $k ($v | quote) }}
{{- end -}}
{{- end -}}
