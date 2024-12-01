#!/usr/bin/env bash

wget -O /usr/bin/k3s "https://github.com/k3s-io/k3s/releases/download/v1.31.1+k3s1/k3s"

chmod +x /usr/bin/k3s

k3s server --kube-apiserver-arg "bind-address=0.0.0.0" &

echo "===> wait for k3s installation"
sleep 120

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

chmod 700 get_helm.sh

./get_helm.sh

cat <<EOF > /tmp/custom_values.yaml
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


helm upgrade --install prometheus oci://registry-1.docker.io/bitnamicharts/prometheus \
  --values /tmp/custom_values.yaml \
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
