{{/*
This template serves as a blueprint for Cronjob objects that are created
using the common library.
*/}}
{{- define "bjw-s.common.class.cronjob" -}}

---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: {{ include "bjw-s.common.lib.chart.names.fullname" . }}
  {{- with include "bjw-s.common.lib.controller.metadata.labels" . }}
  labels: {{- . | nindent 4 }}
  {{- end }}
  {{- with include "bjw-s.common.lib.controller.metadata.annotations" . }}
  annotations: {{- . | nindent 4 }}
  {{- end }}
spec:
  concurrencyPolicy: "{{ .Values.controller.cronjob.concurrencyPolicy }}"
  startingDeadlineSeconds: {{ .Values.controller.cronjob.startingDeadlineSeconds }}
  schedule: "{{ .Values.controller.schedule }}"
  jobTemplate:
    spec:
      selector:
        matchLabels:
          {{- include "bjw-s.common.lib.metadata.selectorLabels" . | nindent 10 }}
      template:
        metadata:
          {{- with include ("bjw-s.common.lib.metadata.podAnnotations") . }}
          annotations:
            {{- . | nindent 8 }}
          {{- end }}
          labels:
            {{- include "bjw-s.common.lib.metadata.selectorLabels" . | nindent 12 }}
            {{- with .Values.podLabels }}
            {{- toYaml . | nindent 12 }}
            {{- end }}
        spec:
          {{- include "bjw-s.common.lib.controller.pod" . | nindent 10 }}
{{- end -}}
