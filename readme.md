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

## add iptables rule on bastion host for routing traffic to jenkins ui on k3s vm
```console
sudo iptables -t nat -A POSTROUTING -o ens5 -p tcp -d <k3s-vm-internal ip> --dport 32000 -j MASQUERADE
sudo iptables -t nat -A PREROUTING -i ens5 -p tcp --dport 32000 -j DNAT --to <k3s-vm-internal ip>
```
## add iptables rule on bastion host for routing traffic to k3s api server
```console
sudo iptables -t nat -A POSTROUTING -o ens5 -p tcp -d <k3s-vm-internal ip> --dport 6443 -j MASQUERADE
sudo iptables -t nat -A PREROUTING -i ens5 -p tcp --dport 6500 -j DNAT --to <k3s-vm-internal ip>:6443
```

## add iptables rule on bastion host to route http traffic to nodejs app
```console
sudo iptables -t nat -A POSTROUTING -o ens5 -p tcp -d <k3s-vm-internal ip> --dport 31000 -j MASQUERADE
sudo iptables -t nat -A PREROUTING -i ens5 -p tcp --dport 80 -j DNAT --to <k3s-vm-internal ip>:31000
```

## create jenkins service acc and persistent volume (delete and recreated pv in case of jenkins helm reinstallments)
```console
kubectl apply -f https://raw.githubusercontent.com/jenkins-infra/jenkins.io/master/content/doc/tutorials/kubernetes/installing-jenkins-on-kubernetes/jenkins-sa.yaml ./terraform/task6/files/jenkins_pv.yaml
```

## on vm with k3s change permissions for /data/jenkins-volume dir
```console
sudo chmod 777 /data/jenkins-volume/
```

## install jenkins to k3s by running github action https://github.com/n98gt/jenkins-helm-aws/actions/workflows/deploy.yml


## install jenkins plugins
```
https://plugins.jenkins.io/aws-credentials/
https://plugins.jenkins.io/amazon-ecr/
https://plugins.jenkins.io/docker-workflow/
```

## destroy resources
```console
tf destroy
```
