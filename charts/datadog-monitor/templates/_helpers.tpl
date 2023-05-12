{{- define "monitor.name" -}}
{{- $name := (printf "%s-monitor" .Release.Name) -}}
{{ .Values.fullnameOverride | default $name | trunc 63 | trimSuffix "-"}}
{{- end -}}