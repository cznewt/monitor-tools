{{/* Common labels */}}
{{- define "monitor-tools.labels" -}}
app.kubernetes.io/name: {{ .Release.Name }}-monitor-tools
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end }}

{{/* Selector labels */}}
{{- define "monitor-tools.selectorLabels" -}}
app: {{ .Release.Name }}-monitor-tools
{{- end }}

{{/* Resource name */}}
{{- define "monitor-tools.fullname" -}}
{{ .Release.Name }}-monitor-tools
{{- end }}

{{/* Secret name — either user-provided existing or chart-generated */}}
{{- define "monitor-tools.secretName" -}}
{{- if .Values.existingSecret -}}
{{ .Values.existingSecret }}
{{- else -}}
{{ include "monitor-tools.fullname" . }}-env
{{- end -}}
{{- end }}

{{/* Shared pod spec used by both Job and CronJob templates */}}
{{- define "monitor-tools.podSpec" -}}
containers:
  - name: monitor-tools
    image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
    imagePullPolicy: {{ .Values.image.pullPolicy }}
    command: {{ toJson .Values.job.command }}
    {{- if or .Values.env .Values.existingSecret }}
    envFrom:
      - secretRef:
          name: {{ include "monitor-tools.secretName" . }}
    {{- end }}
    {{- if .Values.configs }}
    volumeMounts:
      - name: configs
        mountPath: /config
    {{- end }}
    resources:
      {{- toYaml .Values.resources | nindent 6 }}
{{- if .Values.configs }}
volumes:
  - name: configs
    configMap:
      name: {{ include "monitor-tools.fullname" . }}-configs
{{- end }}
{{- with .Values.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.tolerations }}
tolerations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.affinity }}
affinity:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}
