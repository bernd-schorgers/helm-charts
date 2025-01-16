{{/*
Validate configMap values
*/}}
{{- define "bjw-s.common.lib.configMap.validate" -}}
  {{- $rootContext := .rootContext -}}
  {{- $configMapValues := .object -}}
  {{- $identifier := .id -}}

  {{- if empty $configMapValues -}}
    {{- fail (printf "There was an error loading ConfigMap: %s. If it was automatically generated from a folder verify that files are properly flagged as `binary` or `escaped`" $identifier) -}}
  {{- end -}}
  {{- if and (empty (get $configMapValues "data")) (empty (get $configMapValues "binaryData")) -}}
    {{- fail (printf "No data or binaryData specified for configMap. (configMap: %s)" $configMapValues.identifier) }}
  {{- end -}}
{{- end -}}

{{/*
Validate configMap from folder values
*/}}
{{- define "bjw-s.common.lib.configMap.fromFolder.validate" -}}
  {{- $rootContext := .rootContext -}}
  {{- $basePath := required "If you're using `configMapsFromFolder` you need to specify a `basePath` key" .basePath -}}
  {{ $topLevelFolders := dict}}
    {{- range $path, $_ := $rootContext.Files.Glob (printf "%s/*/*" $basePath) -}}
        {{- $_ := set $topLevelFolders (dir $path) "" -}}
    {{- end -}}
    {{- $topLevelFoldersList := keys $topLevelFolders | sortAlpha -}}
    {{- if empty $topLevelFoldersList -}}
      {{- fail (printf "No configMaps found in the folder %s" $basePath) }}
    {{- end -}}
{{- end -}}
