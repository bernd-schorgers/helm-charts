{{- /*
Returns the value for volumes
*/ -}}
{{- define "bjw-s.common.lib.pod.field.volumes" -}}
  {{- $rootContext := .ctx.rootContext -}}
  {{- $controllerObject := .ctx.controllerObject -}}

  {{- /* Default to empty list */ -}}
  {{- $volumes := list -}}

  {{- /* TODO: Rework to put "mounts" under container specs */ -}}
  {{- /* TODO: Or rework to put "persistence" under controller spec */ -}}

  {{- /* Loop over persistence items */ -}}
  {{- range $identifier, $persistenceValues := $rootContext.Values.persistence -}}
    {{- $persistenceEnabled := true -}}
    {{- if hasKey $persistenceValues "enabled" -}}
      {{- $persistenceEnabled = $persistenceValues.enabled -}}
    {{- end -}}

    {{- if $persistenceEnabled -}}
      {{- /* Loop over mounts */ -}}
      {{- range .mounts -}}
        {{- if or (has $controllerObject.identifier .controllers) (has "_all_" .controllers) -}}
          {{- $volume := dict "name" $identifier -}}

          {{- /* PVC persistence type */ -}}
          {{- if eq (default "pvc" $persistenceValues.type) "pvc" -}}
            {{- $pvcName := (include "bjw-s.common.lib.chart.names.fullname" $rootContext) -}}
            {{- if $persistenceValues.existingClaim -}}
              {{- /* Always prefer an existingClaim if that is set */ -}}
              {{- $pvcName = $persistenceValues.existingClaim -}}
            {{- else -}}
              {{- /* Otherwise refer to the PVC name */ -}}
              {{- if $persistenceValues.nameOverride -}}
                {{- if not (eq $persistenceValues.nameOverride "-") -}}
                  {{- $pvcName = (printf "%s-%s" (include "bjw-s.common.lib.chart.names.fullname" $rootContext) $persistenceValues.nameOverride) -}}
                {{- end -}}
              {{- else -}}
                {{- $pvcName = (printf "%s-%s" (include "bjw-s.common.lib.chart.names.fullname" $rootContext) $identifier) -}}
              {{- end -}}
            {{- end -}}
            {{- $_ := set $volume "persistentVolumeClaim" (dict "claimName" $pvcName) -}}

          {{- /* configMap persistence type */ -}}
          {{- else if eq $persistenceValues.type "configMap" -}}
            {{- $objectName := (required (printf "name not set for persistence item %s" $identifier) $persistenceValues.name) -}}
            {{- $objectName = tpl $objectName $rootContext -}}
            {{- $_ := set $volume "configMap" dict -}}
            {{- $_ := set $volume.configMap "name" $objectName -}}
            {{- with $persistenceValues.defaultMode -}}
              {{- $_ := set $volume.configMap "defaultMode" . -}}
            {{- end -}}
            {{- with $persistenceValues.items -}}
              {{- $_ := set $volume.configMap "items" . -}}
            {{- end -}}

          {{- /* Secret persistence type */ -}}
          {{- else if eq $persistenceValues.type "secret" -}}
            {{- $objectName := (required (printf "name not set for persistence item %s" $identifier) $persistenceValues.name) -}}
            {{- $objectName = tpl $objectName $rootContext -}}
            {{- $_ := set $volume "secret" dict -}}
            {{- $_ := set $volume.secret "secretName" $objectName -}}
            {{- with $persistenceValues.defaultMode -}}
              {{- $_ := set $volume.secret "defaultMode" . -}}
            {{- end -}}
            {{- with $persistenceValues.items -}}
              {{- $_ := set $volume.secret "items" . -}}
            {{- end -}}

          {{- /* emptyDir persistence type */ -}}
          {{- else if eq $persistenceValues.type "emptyDir" -}}
            {{- $_ := set $volume "emptyDir" dict -}}
            {{- with $persistenceValues.medium -}}
              {{- $_ := set $volume.emptyDir "medium" . -}}
            {{- end -}}
            {{- with $persistenceValues.sizeLimit -}}
              {{- $_ := set $volume.emptyDir "sizeLimit" . -}}
            {{- end -}}

          {{- /* hostPath persistence type */ -}}
          {{- else if eq $persistenceValues.type "hostPath" -}}
            {{- $_ := set $volume "hostPath" dict -}}
            {{- $_ := set $volume.hostPath "path" (required "hostPath not set" $persistenceValues.hostPath) -}}
            {{- with $persistenceValues.hostPathType }}
              {{- $_ := set $volume.hostPath "type" . -}}
            {{- end -}}

          {{- /* hostPath persistence type */ -}}
          {{- else if eq $persistenceValues.type "nfs" -}}
            {{- $_ := set $volume "nfs" dict -}}
            {{- $_ := set $volume.nfs "server" (required "server not set" $persistenceValues.server) -}}
            {{- $_ := set $volume.nfs "path" (required "path not set" $persistenceValues.path) -}}

          {{- /* custom persistence type */ -}}
          {{- else if eq $persistenceValues.type "custom" -}}
            {{- $volume = $persistenceValues.volumeSpec -}}
            {{- $_ := set $volume "name" $identifier -}}

          {{- /* Fail otherwise */ -}}
          {{- else }}
            {{- fail (printf "Not a valid persistence.type (%s)" $persistenceValues.type) }}
          {{- end -}}

          {{- $volumes = append $volumes $volume -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- if not (empty $volumes) -}}
    {{- $volumes | toYaml -}}
  {{- end -}}
{{- end -}}
