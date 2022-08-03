# Worker nodes with docker as the default container runtime
resource "hcloud_server" "worker" {
  count       = var.worker_nodes_count
  name        = "worker-${count.index}"
  image       = data.hcloud_image.k8s_image.id
  server_type = var.worker_server_type
  location    = var.worker_location
  ssh_keys    = [hcloud_ssh_key.default.name]
}

resource "hcloud_server_network" "worker_networks" {
  count      = var.worker_nodes_count
  server_id  = hcloud_server.worker[count.index].id
  network_id = hcloud_network.mynet.id
  ip         = "10.0.1.${6 + count.index}" // Consecutive IP addresses starting from 10.0.1.5 (master node IP address).
}

# Worker nodes with containerd as the default container runtime
resource "hcloud_server" "workercontainerd" {
  count       = var.worker_nodes_containerd_count
  name        = "worker-containerd-${count.index}"
  image       = data.hcloud_image.k8s_image_containerd.id
  server_type = var.worker_containerd_server_type
  location    = var.worker_containerd_location
  ssh_keys    = [hcloud_ssh_key.default.name]
}

resource "hcloud_server_network" "worker_containerd_networks" {
  count      = var.worker_nodes_containerd_count
  server_id  = hcloud_server.workercontainerd[count.index].id
  network_id = hcloud_network.mynet.id
  ip         = "10.0.1.${17 + count.index}"
}

resource "null_resource" "k8s_workers" {

  count = var.worker_nodes_count
  triggers = {
    # hcloud_server_worker_names = "${join(",", hcloud_server.worker.*.name)}"
    hcloud_server_worker_names = hcloud_server.worker[count.index].name
  }

  connection {
    type        = "ssh"
    host        = hcloud_server.worker[count.index].ipv4_address
    user        = "root"
    private_key = file("${var.ssh_identity}")
  }

  provisioner "remote-exec" {
    inline = [
      data.external.kubeadm_join.result.command
    ]
  }

}

resource "null_resource" "k8s_workers_containerd" {

  count = var.worker_nodes_containerd_count
  triggers = {
    hcloud_server_workercontainerd_names = hcloud_server.workercontainerd[count.index].name
  }

  connection {
    type        = "ssh"
    host        = hcloud_server.workercontainerd[count.index].ipv4_address
    user        = "root"
    private_key = file("${var.ssh_identity}")
  }

  provisioner "remote-exec" {
    inline = [
      data.external.kubeadm_join.result.command
    ]
  }

}
