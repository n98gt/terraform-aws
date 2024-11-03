# k3s deployment

```console
alias tf=terraform
alias hm=helm
```
## download terraform dependencies
```console
cd terraform/project
tf init -backend-config=$(git rev-parse --show-toplevel)/terraform/remote_state_common.tfbackend -backend-config=remote_state.tfbackend
```

## create credentilas file with aws credentials (terraform/credentials)

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

## add iptables rule on bastion host for routing traffic to jenkins ui on k3s vm
```console
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 32000 -j DNAT --to <k3s-vm-internal ip>
```

## install bitnami nginx chart
```console
hm repo add bitnami https://charts.bitnami.com/bitnami
hm install nginx-binami bitnami/nginx
```

## remove bitnami nginx chart
```console
hm uninstall nginx-binami
```

## create jenkins service acc and persistent volume
```console
kubectl apply -f https://raw.githubusercontent.com/jenkins-infra/jenkins.io/master/content/doc/tutorials/kubernetes/installing-jenkins-on-kubernetes/jenkins-sa.yaml ./terraform/task4/files/jenkins_pv.yaml
```

## deploy jenkins helm chart — trigger github action pipeline https://github.com/n98gt/jenkins-helm-aws/actions (name: «Deploy Jenkins Helm Chart»)

## destroy resources
```console
tf destroy
```
