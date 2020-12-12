variable "hcloud_token" {
}

variable "worker_nodes_count" {
}

variable "worker_nodes_containerd_count" {
}

variable "master_name" {
}

variable "master_server_type" {
}

variable "master_location" {
}

variable "worker_server_type" {
}

variable "worker_location" {
}

variable "worker_containerd_location" {
}

data "hcloud_image" "k8s_image" {
  id = 27792940
}

data "hcloud_image" "k8s_image_containerd" {
  id = 27798244
}

resource "hcloud_ssh_key" "default" {
  name       = "my-ssh-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "hcloud_server" "master" {
  name        = var.master_name
  image       = data.hcloud_image.k8s_image.id
  server_type = var.master_server_type
  location    = var.master_location
  ssh_keys    = [hcloud_ssh_key.default.name]

  provisioner "file" {
    source      = "scripts/run-master.sh"
    destination = "/tmp/run-master.sh"

    connection {
      type        = "ssh"
      user        = "root"
      host        = self.ipv4_address
      private_key = file("~/.ssh/id_rsa")
    }
  }

}


data "external" "kubeadm_join" {
  program = ["./scripts/kubeadm-token.sh"]

  query = {
    host = hcloud_server.master.ipv4_address
    key  = "~/.ssh/id_rsa"
  }

  depends_on = [hcloud_server.master]
}

resource "null_resource" "k8s_master" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_ids = hcloud_server.master.name
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    type        = "ssh"
    host        = hcloud_server.master.ipv4_address
    user        = "root"
    private_key = file("~/.ssh/id_rsa") #  "kubeadm join ${aws_instance.web.private_ip}",

  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/run-master.sh",
      "/tmp/run-master.sh"
    ]
  }
}

resource "null_resource" "k8s_workers" {

  count = var.worker_nodes_count
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    # hcloud_server_worker_names = "${join(",", hcloud_server.worker.*.name)}"
    hcloud_server_worker_names = hcloud_server.worker[count.index].name
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    type        = "ssh"
    host        = hcloud_server.worker[count.index].ipv4_address #TODO CHANGE!!!
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
  }

  provisioner "remote-exec" {
    inline = [
      data.external.kubeadm_join.result.command
    ]
  }

}

resource "hcloud_network" "mynet" {
  name     = "my-net"
  ip_range = "10.0.0.0/8"
}
resource "hcloud_network_subnet" "foonet" {
  network_id   = hcloud_network.mynet.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

resource "hcloud_server_network" "srvnetwork" {
  server_id  = hcloud_server.master.id
  network_id = hcloud_network.mynet.id
  ip         = "10.0.1.5"
}

# Create a server
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


# Create a server
resource "hcloud_server" "workercontainerd" {
  count       = var.worker_nodes_containerd_count
  name        = "worker-containerd-${count.index}"
  image       = data.hcloud_image.k8s_image_containerd.id
  server_type = var.worker_server_type
  location    = var.worker_containerd_location
  ssh_keys    = [hcloud_ssh_key.default.name]
}

resource "hcloud_server_network" "worker_containerd_networks" {
  count      = var.worker_nodes_containerd_count
  server_id  = hcloud_server.workercontainerd[count.index].id
  network_id = hcloud_network.mynet.id
  ip         = "10.0.1.${17 + count.index}"
}

