{{- define "deployment.name" -}}
{{ .Values.fullnameOverride | default .Release.Name | trunc 63 | trimSuffix "-"}}
{{- end -}}

{{- define "deployment.labels" -}}
app: {{ include "deployment.name" $ | quote }}
chart-name: legend-deployment
chart-version: {{ .Chart.Version | quote }}
{{- range $k, $v := .Values.global.labels }}
{{ printf "%s: %s" $k ($v | quote) }}
{{- end -}}
{{- end -}}

{{- define "deployment.dataDogAnnotations" -}}
{{- if .Values.deployment.dataDog.enableLogs }}
ad.datadoghq.com/{{ include "deployment.name" $ }}.logs: '[{"source": "{{ include "deployment.name" $ }}", "service": "{{ include "deployment.name" $ }}"}]'
{{- end -}}
{{- end -}}

{{- define "deployment.dataDogLabels" -}}
{{- if .Values.deployment.dataDog.enableLogs }}
tags.datadoghq.com/service: {{ include "deployment.name" $ | quote }}
tags.datadoghq.com/version: {{ .Values.deployment.container.tag | quote }}
{{- end -}}
{{- end -}}

{{- define "deployment.livenessProbe" -}}
httpGet:
  path: {{ .livenessProbe.httpGet.path }}
  port: {{ .containerPort }}
initialDelaySeconds: {{ .livenessProbe.initialDelaySeconds | default 5 }}
periodSeconds: {{ .livenessProbe.periodSeconds | default 10}}
timeoutSeconds: {{ .livenessProbe.timeoutSeconds | default 1 }}
successThreshold: {{ .livenessProbe.failureThreshold | default 1 }}
failureThreshold: {{ .livenessProbe.failureThreshold | default 3 }}
{{- end -}}

{{- define "deployment.readinessProbe" -}}
httpGet:
  path: {{ .readinessProbe.httpGet.path }}
  port: {{ .containerPort }}
initialDelaySeconds: {{ .readinessProbe.initialDelaySeconds | default 5 }}
periodSeconds: {{ .readinessProbe.periodSeconds | default 10}}
timeoutSeconds: {{ .readinessProbe.timeoutSeconds | default 1 }}
successThreshold: {{ .readinessProbe.failureThreshold | default 1 }}
failureThreshold: {{ .readinessProbe.failureThreshold | default 3 }}
{{- end -}}

{{- define "deployment.cloudSQLProxy" -}}
{{- with .Values.deployment -}}
{{- if .cloudSQLProxy.enable }}

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
  image: "gcr.io/cloud-sql-connectors/cloud-sql-proxy:{{ .cloudSQLProxy.imageTag | default "2.7" }}"
  command:
    - "/cloud-sql-proxy"
    - "{{ $projectID }}:{{ .cloudSQLProxy.region | default "europe-west3" }}:{{ .cloudSQLProxy.instanceName }}"
    - "--auto-iam-authn"
    - "--structured-logs"
    - "--health-check"
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
{{- end -}}



{{- /* Gatekeeper */ -}}
{{- define "deployment.gatekeeper" -}}
{{- with .Values.deployment -}}
{{- if .gatekeeper.enable -}}
- name: gatekeeper
  image: "{{ .gatekeeper.image }}"
  args:
{{- /*    - --forbidden-page=/etc/keycloak/templates/forbidden.html.tmpl*/}}
    - "--listen=0.0.0.0:{{ .container.containerPort | add1 }}"
    - "--enable-authorization-header=true"
    - "--upstream-url=http://localhost:{{ .container.containerPort }}"
    - "--client-id={{ .gatekeeper.client }}"
    - "--secure-cookie=true"
    - "--enable-default-deny=true"
    - "--client-secret=$(KCP_CLIENT_OIDC_SECRET)"
    - "--cookie-domain={{ .gatekeeper.cookieDomain }}"
    - "--discovery-url={{ .gatekeeper.keycloak }}"
    - "--encryption-key=$(ENCRYPTION_KEY)"
    - "--enable-refresh-tokens=true"
    - "--verbose"
    {{- .gatekeeper.args | toYaml | nindent 4 }}
  env:
  - name: KCP_CLIENT_OIDC_SECRET
    valueFrom:
      secretKeyRef:
        key: secret
        name: keycloakproxyclient
  - name: ENCRYPTION_KEY
    valueFrom:
      secretKeyRef:
        key: key
        name: gatekeeper-encryption
  ports:
  - containerPort: {{ .container.containerPort | add1 }}
    name: cp-gatekeeper
    protocol: TCP
{{- end -}}
{{- end -}}
{{- end -}}



{{/*
Prometheus annotations
*/}}
{{- define "deployment.prometheusAnnotations" -}}
{{- with .Values.deployment.prometheus -}}
{{- if .enable -}}
prometheus.io/scrape: "true"
{{- if .path -}}
prometheus.io/path: {{ .path | quote }}
{{- end -}}
{{- if .port -}}
prometheus.io/port: {{ .port | quote }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}