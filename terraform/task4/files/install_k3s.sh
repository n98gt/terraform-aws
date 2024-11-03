#!/usr/bin/env bash

wget -O /usr/bin/k3s "https://github.com/k3s-io/k3s/releases/download/v1.31.1+k3s1/k3s"

chmod +x /usr/bin/k3s

k3s server --kube-apiserver-arg "bind-address=0.0.0.0" &
