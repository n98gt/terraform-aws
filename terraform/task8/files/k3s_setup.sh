#!/usr/bin/env bash

wget -O /usr/bin/k3s "https://github.com/k3s-io/k3s/releases/download/v1.31.1+k3s1/k3s"

chmod +x /usr/bin/k3s

k3s server --kube-apiserver-arg "bind-address=0.0.0.0" &

echo "===> wait for k3s installation"
sleep 120


#  ---------------------------------------------------------------------------------
#  download helm
#  ---------------------------------------------------------------------------------

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

chmod 700 get_helm.sh

./get_helm.sh

#  ---------------------------------------------------------------------------------
#  create custom values file for prometheus
#  ---------------------------------------------------------------------------------

cat <<EOF > /tmp/custom_prometheus_values.yaml
---
server:
  service:
    type: NodePort
    nodePorts:
      http: "31000"
  extraScrapeConfigs:
      - job_name: 'kube-state-metrics'
        static_configs:
          - targets: ['kube-state-metrics.default.svc.cluster.local:8080']
      - job_name: 'node-exporter'
        static_configs:
          - targets: ['node-exporter.default.svc.cluster.local:9100']
alertmanager:
  enabled: false
EOF

#  ---------------------------------------------------------------------------------
#  install prometheus & node-exporter helm charts
#  ---------------------------------------------------------------------------------

helm upgrade --install prometheus oci://registry-1.docker.io/bitnamicharts/prometheus \
  --values /tmp/custom_prometheus_values.yaml \
  --atomic \
  --kubeconfig /etc/rancher/k3s/k3s.yaml

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install kube-state-metrics prometheus-community/kube-state-metrics \
  --atomic \
  --kubeconfig /etc/rancher/k3s/k3s.yaml

helm upgrade --install node-exporter oci://registry-1.docker.io/bitnamicharts/node-exporter \
  --atomic \
  --kubeconfig /etc/rancher/k3s/k3s.yaml

#  ---------------------------------------------------------------------------------
#  install aws cli
#  ---------------------------------------------------------------------------------

apt install -y unzip jq
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install


#  ---------------------------------------------------------------------------------
#  get aws credentials
#  ---------------------------------------------------------------------------------

ROLE_NAME=$(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/)
CREDENTIALS=$(curl -s "http://169.254.169.254/latest/meta-data/iam/security-credentials/${ROLE_NAME}")

AWS_ACCESS_KEY=$(echo "${CREDENTIALS}" | jq -r '.AccessKeyId')
AWS_SECRET_KEY=$(echo "${CREDENTIALS}" | jq -r '.SecretAccessKey')
AWS_SESSION_TOKEN=$(echo "${CREDENTIALS}" | jq -r '.Token')


cat <<EOF > /root/aws_credentials
[default]
aws_access_key_id=${AWS_ACCESS_KEY}
aws_secret_access_key=${AWS_SECRET_KEY}
aws_session_token=${AWS_SESSION_TOKEN}
EOF

export AWS_SHARED_CREDENTIALS_FILE=/root/aws_credentials

#  ---------------------------------------------------------------------------------
#  create custom values file for grafana
#  ---------------------------------------------------------------------------------

cat <<EOF > /tmp/custom_grafana_values.yaml
---
datasources:
  secretDefinition:
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      url: http://prometheus-server.default.svc.cluster.local:80
      access: proxy
      isDefault: true
admin:
  existingSecret: "grafana"
  existingSecretPasswordKey: admin-password
service:
  type: NodePort
  nodePorts:
    grafana: "31001"
dashboardsProvider:
  enabled: true
dashboardsConfigMaps:
  -
    configMapName: grafana-dashboard
    fileName: grafana-dashboard.json
EOF

#  ---------------------------------------------------------------------------------
#  retrive grafana secret from aws secret manager
#  ---------------------------------------------------------------------------------

GRAFANA_ADMIN_PASSWORD=$(aws secretsmanager get-secret-value  --secret-id grafana --query SecretString --output text)

#  ---------------------------------------------------------------------------------
#  create k8s secret for grafana
#  ---------------------------------------------------------------------------------

k3s kubectl create secret generic grafana \
    --from-literal=admin-password="${GRAFANA_ADMIN_PASSWORD}"

#  ---------------------------------------------------------------------------------
#  create grafana dashboard configmap
#  ---------------------------------------------------------------------------------


cat <<EOF > /tmp/grafana-dashboard.json
{
  "annotations": {
    "list": [
      {
        "builtIn": 1,
        "datasource": {
          "type": "grafana",
          "uid": "-- Grafana --"
        },
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "type": "dashboard"
      }
    ]
  },
  "editable": true,
  "fiscalYearStartMonth": 0,
  "graphTooltip": 0,
  "id": 1,
  "links": [],
  "panels": [
    {
      "datasource": "Prometheus",
      "fieldConfig": {
        "defaults": {
          "custom": {
            "drawStyle": "line"
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 0,
        "y": 0
      },
      "id": 1,
      "options": {},
      "targets": [
        {
          "expr": "100 - (avg by (instance) (rate(node_cpu_seconds_total{mode='idle'}[5m])) * 100)",
          "legendFormat": "{{instance}}",
          "refId": "A"
        }
      ],
      "title": "CPU Utilization",
      "type": "timeseries"
    },
    {
      "datasource": "Prometheus",
      "fieldConfig": {
        "defaults": {
          "custom": {
            "drawStyle": "line"
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 12,
        "y": 0
      },
      "id": 2,
      "options": {},
      "targets": [
        {
          "expr": "(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100",
          "legendFormat": "{{instance}}",
          "refId": "B"
        }
      ],
      "title": "Memory Utilization",
      "type": "timeseries"
    },
    {
      "datasource": "Prometheus",
      "fieldConfig": {
        "defaults": {
          "custom": {
            "drawStyle": "line"
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 0,
        "y": 8
      },
      "id": 3,
      "options": {},
      "targets": [
        {
          "expr": "100 - (node_filesystem_free_bytes{fstype!=\"tmpfs\", fstype!=\"rootfs\"} / node_filesystem_size_bytes{fstype!=\"tmpfs\", fstype!=\"rootfs\"} * 100)",
          "legendFormat": "{{instance}}",
          "refId": "C"
        }
      ],
      "title": "Disk Usage",
      "type": "timeseries"
    }
  ],
  "preload": false,
  "refresh": "",
  "schemaVersion": 40,
  "tags": [],
  "templating": {
    "list": []
  },
  "time": {
    "from": "now-6h",
    "to": "now"
  },
  "timepicker": {},
  "timezone": "",
  "title": "test",
  "uid": "ce6c7q2hep0cgb",
  "version": 2,
  "weekStart": ""
}
EOF

k3s kubectl create configmap grafana-dashboard --from-file=/tmp/grafana-dashboard.json

#  ---------------------------------------------------------------------------------
#  install grafana helm chart
#  ---------------------------------------------------------------------------------

helm upgrade --install  grafana oci://registry-1.docker.io/bitnamicharts/grafana \
  --values /tmp/custom_grafana_values.yaml \
  --atomic \
  --kubeconfig /etc/rancher/k3s/k3s.yaml
