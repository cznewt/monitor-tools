{{/* Common labels */}}
{{- define "jupyter-monitor-tools.labels" -}}
app.kubernetes.io/name: {{ .Release.Name }}-jupyter
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end }}

{{/* Selector labels */}}
{{- define "jupyter-monitor-tools.selectorLabels" -}}
app: {{ .Release.Name }}-jupyter
{{- end }}

{{/* Resource name */}}
{{- define "jupyter-monitor-tools.fullname" -}}
{{ .Release.Name }}-jupyter
{{- end }}

{{/* Secret name — either user-provided existing or chart-generated */}}
{{- define "jupyter-monitor-tools.secretName" -}}
{{- if .Values.existingSecret -}}
{{ .Values.existingSecret }}
{{- else -}}
{{ include "jupyter-monitor-tools.fullname" . }}-env
{{- end -}}
{{- end }}
