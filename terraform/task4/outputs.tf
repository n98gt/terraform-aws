output "k3s_vm_private_ip" {
  value = aws_instance.k3s.private_ip
}

output "bation_host_public_ip" {
  value = aws_spot_instance_request.bastion.public_ip
}
