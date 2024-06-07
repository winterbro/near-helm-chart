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
Configuration for the store
*/}}
{{- define "near-node.store" -}}
{{- if and .Values.chain.configOverrides .Values.chain.configOverrides.store .Values.chain.configOverrides.store.path -}}
  {{ .Values.chain.configOverrides.store.path }}
{{- else -}}
  "data"
{{- end -}}
{{- end }}

{{- define "near-node.coldStore" -}}
{{- if and .Values.chain.configOverrides .Values.chain.configOverrides.cold_store .Values.chain.configOverrides.cold_store.path -}}
  {{ .Values.chain.configOverrides.cold_store.path }}
{{- else -}}
  "cold-data"
{{- end -}}
{{- end }}

{{/*
Create the snapshot download script
*/}}
{{- define "isSplitStorageEnabled" -}}
{{- $chain := default dict .Values.chain -}}
{{- $configOverrides := default dict $chain.configOverrides -}}
{{- $splitStorage := default dict $configOverrides.split_storage -}}
{{- default false $splitStorage.enable_split_storage_view_client -}}
{{- end -}}

{{- define "near-node.snapshotScript" -}}
# Install and configure rclone
echo "Installing and configuring rclone"
apt update && apt install -y rclone

RCLONE_CONFIG=$HOME/.config/rclone/rclone.conf

mkdir -p $HOME/.config/rclone/
touch $RCLONE_CONFIG
printf "[near_cf]\ntype = s3\nprovider = AWS\ndownload_url = https://dcf58hz8pnro2.cloudfront.net/\nacl = public-read\nserver_side_encryption = AES256\nregion = ca-central-1\n" >> $RCLONE_CONFIG

# Set node variables
HOME_DIR="{{ .Values.chain.homeDir }}"
NETWORK="{{ .Values.chain.network }}"
KIND="{{ .Values.chain.kind }}"
USE_SPLIT_STORAGE="{{- if include "isSplitStorageEnabled" . -}}true{{- else -}}false{{- end }}"
STORE="{{ include "near-node.store" . }}"
COLD_STORE="{{ include "near-node.coldStore" . }}"

if $USE_SPLIT_STORAGE; then
  echo "Geting date of the latest split storage snapshot"
  rclone copy --config $RCLONE_CONFIG --no-check-certificate near_cf://near-protocol-public/backups/$NETWORK/$KIND/latest_split_storage $HOME_DIR/

  latest=$(cat $HOME_DIR/latest_split_storage)
  echo "Latest snapshot date: $latest"

  echo "Downloading the latest snapshot"
  rclone copy --config $RCLONE_CONFIG --no-check-certificate --progress --transfers=20 \
    near_cf://near-protocol-public/backups/$NETWORK/$KIND/$latest $HOME_DIR/

  # Move and create symlinks for data directories in case of future snapshot downloads
  if $STORE != "hot-data"; then
    mv $HOME_DIR/hot-data $HOME_DIR/$STORE
    ln -s $HOME_DIR/hot-data $HOME_DIR/$STORE
    echo "Moved hot-data to $STORE"
  fi

  if $COLD_STORE != "cold-data"; then
    mv $HOME_DIR/cold-data $HOME_DIR/$COLD_STORE
    ln -s $HOME_DIR/cold-data $HOME_DIR/$COLD_STORE
    echo "Moved cold-data to $COLD_STORE"
  fi
else
  echo "Getting date of the latest snapshot"
  rclone copy --config $RCLONE_CONFIG --no-check-certificate near_cf://near-protocol-public/backups/$NETWORK/$KIND/latest $HOME_DIR/

  latest=$(cat $HOME_DIR/latest)
  echo "Latest snapshot date: $latest"

  echo "Downloading the latest snapshot"
  rclone copy --config $RCLONE_CONFIG --no-check-certificate --progress --transfers=20 \
    near_cf://near-protocol-public/backups/$NETWORK/$KIND/$latest $HOME_DIR/$STORE/
fi
{{- end -}}
