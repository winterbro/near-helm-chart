{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "near-node.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "near-node.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "near-node.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create a default namespace
*/}}
{{- define "near-node.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "near-node.labels" -}}
helm.sh/chart: {{ include "near-node.chart" . }}
{{ include "near-node.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "near-node.selectorLabels" -}}
app.kubernetes.io/name: {{ include "near-node.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "near-node.snapshotScript" -}}
{{- if .Values.chain.snapshotScript -}}
{{ .Values.chain.snapshotScript }}
{{- else -}}
HTTP_URL="https://snapshot.neardata.xyz"

: "${CHAIN_ID:={{ .Values.chain.network }}}"
: "${THREADS:=16}"
: "${TPSLIMIT:=4096}"
: "${BWLIMIT:=10G}"
: "${RPC_TYPE:={{ .Values.chain.kind }}}"
: "${DATA_PATH:={{ .Values.chain.homeDir }}/data}"
: "${RETRIES:=20}"
: "${CHECKERS:=$THREADS}"
: "${LOW_LEVEL_RETRIES:=10}"
: "${ENABLE_HTTP_NO_HEAD:=false}"

PREFIX="$CHAIN_ID/$RPC_TYPE"

HTTP_NO_HEAD_FLAG=""
if [ "$ENABLE_HTTP_NO_HEAD" = true ]; then
  HTTP_NO_HEAD_FLAG="--http-no-head"
fi

LATEST=$(curl -s "$HTTP_URL/$PREFIX/latest.txt")
echo "Latest snapshot block: $LATEST"

: "${BLOCK:=$LATEST}"

main() {
  mkdir -p "$DATA_PATH"
  echo "Snapshot block: $BLOCK"

  if [ -d "$DATA_PATH" ] && [ -n "$(ls -A "$DATA_PATH")" ]; then
    echo "Data path exists and is not empty, skipping --http-no-head flag on rclone"
    HTTP_NO_HEAD_FLAG=""
  fi

  FILES_PATH="/tmp/files.txt"
  curl -s "$HTTP_URL/$PREFIX/$BLOCK/files.txt" -o "$FILES_PATH"

  EXPECTED_NUM_FILES=$(wc -l < "$FILES_PATH")
  echo "Downloading $EXPECTED_NUM_FILES files with $THREADS threads"

  rclone copy \
    --no-traverse \
    $HTTP_NO_HEAD_FLAG \
    --multi-thread-streams 1 \
    --tpslimit "$TPSLIMIT" \
    --bwlimit "$BWLIMIT" \
    --max-backlog 1000000 \
    --transfers "$THREADS" \
    --checkers "$CHECKERS" \
    --buffer-size 128M \
    --http-url "$HTTP_URL" \
    --files-from="$FILES_PATH" \
    --retries "$RETRIES" \
    --retries-sleep 1s \
    --low-level-retries "$LOW_LEVEL_RETRIES" \
    --progress \
    :http:"$PREFIX/$BLOCK/" "$DATA_PATH"

  ACTUAL_NUM_FILES=$(find "$DATA_PATH" -type f | wc -l)
  echo "Downloaded $ACTUAL_NUM_FILES files, expected $EXPECTED_NUM_FILES"

  if [[ "$ACTUAL_NUM_FILES" -ne "$EXPECTED_NUM_FILES" ]]; then
    echo "Error: Downloaded files count mismatch"
    exit 1
  fi
}

main "$@"
{{- end -}}
{{- end -}}
