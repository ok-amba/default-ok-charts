{{- define "db-migration.name" -}}
{{- $name := (printf "%s-migration" .Release.Name) -}}
{{ .Values.fullnameOverride | default $name | trunc 63 | trimSuffix "-"}}
{{- end -}}

{{- define "db-migration.labels" -}}
app: {{ include "db-migration.name" $ | quote }}
chart-name: {{ .Chart.Name | quote }}
chart-version: {{ .Chart.Version | quote }}
{{- range $k, $v := .Values.global.labels }}
{{ printf "%s: %s" $k ($v | quote) }}
{{- end -}}
{{- range $k, $v := .Values.job.labels }}
{{ printf "%s: %s" $k ($v | quote) }}
{{- end -}}
{{- end -}}
