# NEAR Protocol Helm Chart

This is a Helm chart to deploy NEAR Protocol RPC and Archive nodes.

## TL;DR

```bash
helm repo add near-protocol https://winterbro.github.io/near-helm-chart
helm install near-protocol/near-protocol
```

## Prerequisites

* Kubernetes 1.15+
* Helm
* ([Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator) CRDs (if serviceMonitor.enabled):

## Installing the Chart

To install the chart

```bash
helm repo add near-protocol https://winterbro.github.io/near-helm-chart
helm install near-protocol/near-protocol
```

## Uninstalling the Chart

To uninstall/delete the deployment:

```bash
helm delete <Release Name>
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

Coming...
