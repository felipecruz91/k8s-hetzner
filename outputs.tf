
output "master_ip_addr" {
  value = [hcloud_server.master.ipv4_address]
}

output "node_ip_addrs" {
  value = [hcloud_server.worker.*.ipv4_address]
}

output "worker_containerd_ip_addrs" {
  value = hcloud_server.workercontainerd.*.ipv4_address
}

output "kubeadm_join_command" {
  value = data.external.kubeadm_join.result["command"]
}
