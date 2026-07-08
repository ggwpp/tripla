{{/*
Expand the name of the chart.
*/}}
{{- define "tripla-apps.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
Backend fully qualified app name. 
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "tripla-apps.backendFullname" -}}
{{- printf "%s-backend" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Frontend fully qualified app name. 
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "tripla-apps.frontendFullname" -}}
{{- printf "%s-frontend" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "tripla-apps.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "commonLabels" -}}
helm.sh/chart: {{ include "tripla-apps.chart" . }}
{{ include "commonSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "commonSelectorLabels" -}}
app.kubernetes.io/name: {{ include "tripla-apps.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Backend common labels
*/}}
{{- define "tripla-apps.backendLabels" -}}
{{ include "commonLabels" . }}
app.kubernetes.io/component: "backend"
{{- end }}

{{/*
Frontend common labels
*/}}
{{- define "tripla-apps.frontendLabels" -}}
{{ include "commonLabels" . }}
app.kubernetes.io/component: "frontend"
{{- end }}


{{/*
Backend selector labels
*/}}
{{- define "tripla-apps.backendSelectorLabels" -}}
{{ include "commonSelectorLabels" . }}
app.kubernetes.io/component: "backend"
{{- end }}


{{/*
Frontend selector labels
*/}}
{{- define "tripla-apps.frontendSelectorLabels" -}}
{{ include "commonSelectorLabels" . }}
app.kubernetes.io/component: "frontend"
{{- end }}
