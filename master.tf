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

resource "hcloud_floating_ip" "master" {
  type      = "ipv4"
  server_id = hcloud_server.master.id
}

resource "hcloud_floating_ip_assignment" "master" {
  floating_ip_id = hcloud_floating_ip.master.id
  server_id      = hcloud_server.master.id
}

resource "hcloud_server_network" "srvnetwork" {
  server_id  = hcloud_server.master.id
  network_id = hcloud_network.mynet.id
  ip         = "10.0.1.5"
}

resource "null_resource" "k8s_master" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_ids = hcloud_server.master.name
  }

  connection {
    type        = "ssh"
    host        = hcloud_server.master.ipv4_address
    user        = "root"
    private_key = file("~/.ssh/id_rsa")

  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/run-master.sh",
      "/tmp/run-master.sh"
    ]
  }

  provisioner "local-exec" {
    command    = "./scripts/kubectl-conf.sh ${terraform.workspace} ${hcloud_server.master.ipv4_address} ${hcloud_server_network.srvnetwork.ip} ~/.ssh/id_rsa"
    on_failure = continue
  }
}

data "external" "kubeadm_join" {
  program = ["./scripts/kubeadm-token.sh"]

  query = {
    host = hcloud_server.master.ipv4_address
    key  = "~/.ssh/id_rsa" # private key
  }

  # depends_on = [hcloud_server.master]
  depends_on = [null_resource.k8s_master]
}
