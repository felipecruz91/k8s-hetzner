data "hcloud_image" "k8s_image" {
  id = 78182617
}

data "hcloud_image" "k8s_image_containerd" {
  id = 78183075
}

resource "hcloud_ssh_key" "default" {
  name       = "my-ssh-key"
  public_key = file("${var.ssh_identity}.pub")
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
