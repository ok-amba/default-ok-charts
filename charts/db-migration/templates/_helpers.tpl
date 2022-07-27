{{- define "db-migration.labels" -}}
app: {{ .Release.Name }}
chart-name: {{ .Chart.Name }}
chart-version: {{ .Chart.Version }}
{{- with .Values.global.labels }}
{{- toYaml . | nindent 0 }}
{{- end -}}
{{- end -}}