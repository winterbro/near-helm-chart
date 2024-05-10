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

{{/*
Create the snapshot download script
*/}}
{{- define "near-node.snapshotScript" -}}
apt update && apt install -y rclone
# Create configuration
mkdir -p $HOME/.config/rclone/
touch $HOME/.config/rclone/rclone.conf
printf "[near_cf]\ntype = s3\nprovider = AWS\ndownload_url = https://dcf58hz8pnro2.cloudfront.net/\nacl = public-read\nserver_side_encryption = AES256\nregion = ca-central-1\n" >> $HOME/.config/rclone/rclone.conf
# Get the latest snapshot date
rclone copy --config $HOME/.config/rclone/rclone.conf --no-check-certificate near_cf://near-protocol-public/backups/{{ .Values.chain.network }}/{{ .Values.chain.kind }}/latest {{ .Values.chain.homeDir }}/
# Save the latest snapshot date to a variable
latest=$(cat {{ .Values.chain.homeDir }}/latest)
# Download the latest snapshot
rclone copy --config $HOME/.config/rclone/rclone.conf --no-check-certificate --progress --transfers=20 \
  near_cf://near-protocol-public/backups/{{ .Values.chain.network }}/{{ .Values.chain.kind }}/${latest:?} {{ .Values.chain.homeDir }}/data/
{{- end -}}
