# k3s deployment

```console
alias tf=terraform
alias hm=helm
alias k=kubectl
```
## download terraform dependencies
```console
cd terraform/project
tf init -backend-config=$(git rev-parse --show-toplevel)/terraform/remote_state_common.tfbackend -backend-config=remote_state.tfbackend
```

## create credentilas file with aws credentials (terraform/credentials)

## create file with secret vars
```console
cp secrets.auto.tfvars.example secrets.auto.tfvars
```

## create cloud resources
```console
tf plan -out tfplan
tf apply tfplan
```

## save k3s instance private ip & bastion host public ip to env vars
```console
export K3S_INSTANCE_PRIVATE_IP=$(tf output -raw k3s_vm_private_ip)
export BASTION_HOST_PUBLIC_IP=$(tf output -raw bation_host_public_ip)
```

## ssh into k3s instance through bastion host
```console
ssh -J ubuntu@${BASTION_HOST_PUBLIC_IP} ubuntu@${K3S_INSTANCE_PRIVATE_IP} -i ~/.ssh/private_key
```
## view /etc/rancher/k3s/k3s.yaml content (on k3s instance)
```console
sudo cat /etc/rancher/k3s/k3s.yaml
```

## on local machine create kubeconfig file ~/.kube/config_k3s_aws with content from /etc/rancher/k3s/k3s.yaml file on k3s instance

## save path to kubeconfig to env var
```console
export KUBECONFIG=~/.kube/config_k3s_aws
```

## establish ssh tunnel to bastion host
```console
ssh -L "127.0.0.1:6443:${K3S_INSTANCE_PRIVATE_IP}:6443" ubuntu@${BASTION_HOST_PUBLIC_IP} -i ~/.ssh/private_key
```

## allow traffic redirecting on bastion host
```console
sudo sysctl -w net.ipv4.ip_forward=1
```

## add iptables rules on bastion host for routing traffic to k3s api server and prometheus ui
```console
export K3S_VM_INTERNAL_IP=<tf output k3s_vm_private_ip>
sudo iptables -t nat -A POSTROUTING -o ens5 -p tcp -d ${K3S_VM_INTERNAL_IP} --dport 6443 -j MASQUERADE
sudo iptables -t nat -A PREROUTING -i ens5 -p tcp --dport 6500 -j DNAT --to ${K3S_VM_INTERNAL_IP}:6443
sudo iptables -t nat -A POSTROUTING -o ens5 -p tcp -d ${K3S_VM_INTERNAL_IP} --dport 31000 -j MASQUERADE
sudo iptables -t nat -A PREROUTING -i ens5 -p tcp --dport 80 -j DNAT --to ${K3S_VM_INTERNAL_IP}:31000
sudo iptables -t nat -A POSTROUTING -o ens5 -p tcp -d ${K3S_VM_INTERNAL_IP} --dport 31001 -j MASQUERADE
sudo iptables -t nat -A PREROUTING -i ens5 -p tcp --dport 8000 -j DNAT --to ${K3S_VM_INTERNAL_IP}:31001
```

## prometheus & grafana are installed during k3s instance creation by cloud-init script

## get bastion host public ip `tf output bation_host_public_ip`.
## Prometheus web ui will be available on this address (http://<bation_host_public_ip>:80)
## Grafana web ui will be available on this address (http://<bation_host_public_ip>:8000)

## destroy resources
```console
tf destroy
```
