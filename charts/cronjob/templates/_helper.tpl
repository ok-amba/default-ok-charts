{{- define "cronjob.labels" -}}
app: {{ .Release.Name | quote }}
chart-name: cronjob
chart-version: {{ .Chart.Version | quote }}
{{- range $k, $v := .Values.global.labels }}
{{ printf "%s: %s" $k ($v | quote) }}
{{- end -}}
{{- end -}}

{{- define "cronjob.dataDogAnnotations" -}}
ad.datadoghq.com/{{ .Values.name }}.logs: '[{"source": "{{ .Values.name }}", "service": "{{ .Values.name }}"}]'
{{- end -}}

{{- define "cronjob.cloudSQLProxy" -}}
{{- if not .Values.global.projectID }}
{{- fail "The global.projectID is not set. It is required for Cloud SQL Proxy." -}}
{{- end -}}

{{- with .Values.job -}}
- name: cloud-sql-proxy
  image: "gcr.io/cloud-sql-connectors/cloud-sql-proxy:{{ .cloudSQLProxy.imageTag | default "2.4.0" }}"
  command:
    - "/cloud-sql-proxy"
    - "{{ $.Values.global.projectID }}:{{ .cloudSQLProxy.region | default "europe-west3" }}:{{ .cloudSQLProxy.instanceName }}"
    - "--auto-iam-authn"
    - "--structured-logs"
    - "--quitquitquit"
    {{- if .cloudSQLProxy.secretKeyName }}
    - "--credentials-file=/secrets/{{ .cloudSQLProxy.secretKeyName }}/key.json"
    {{- end }}
  securityContext:
    runAsNonRoot: true
  {{- if .cloudSQLProxy.secretKeyName }}
  volumeMounts:
    - name: {{ .cloudSQLProxy.secretKeyName }}
      mountPath: "/secrets/{{ .cloudSQLProxy.secretKeyName }}"
      readOnly: true
  {{- end -}}
{{- end -}}
{{- end -}}
