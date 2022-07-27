{{- define "deployment.labels" -}}
app: {{ .Release.Name }}
chart-name: {{ .Chart.Name }}
chart-version: {{ .Chart.Version }}
{{- with .Values.global.labels }}
  {{- toYaml . }}
{{- end -}}
{{- end -}}