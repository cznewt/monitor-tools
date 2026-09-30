{{/* Labels every object carries next to its own app.kubernetes.io/name */}}
{{- define "demo-apps.labels" -}}
app.kubernetes.io/part-of: {{ .Values.partOf }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end }}

{{/* Image of a demo app: the override, else <registry>/demo-<signal>-<runtime>:<tag>.
     Call with (dict "root" $ "signal" "metrics-prom" "runtime" "go" "override" "") */}}
{{- define "demo-apps.image" -}}
{{- if .override -}}
{{ .override }}
{{- else -}}
{{ .root.Values.imageRegistry }}/demo-{{ .signal }}-{{ .runtime }}:{{ .root.Values.imageTag }}
{{- end -}}
{{- end }}

{{/* Pod scheduling shared by every workload */}}
{{- define "demo-apps.scheduling" -}}
{{- with .Values.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.tolerations }}
tolerations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}
