{{- define "tekmetric-backend.name" -}}
tekmetric-backend
{{- end -}}

{{- define "tekmetric-backend.labels" -}}
app.kubernetes.io/name: {{ include "tekmetric-backend.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
