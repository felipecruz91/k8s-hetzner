# Set the variable value in *.tfvars file
# or using the -var="hcloud_token=..." CLI option
variable "hcloud_token" {
}

# Create a new SSH key
resource "hcloud_ssh_key" "default" {
  name = "my-ssh-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "hcloud_server" "master" {
  name = "master"
  image = "ubuntu-20.04"
  server_type = "cpx11"
  location = "nbg1"
  ssh_keys = [hcloud_ssh_key.default.name]
}

resource "hcloud_network" "mynet" {
  name = "my-net"
  ip_range = "10.0.0.0/8"
}
resource "hcloud_network_subnet" "foonet" {
  network_id = hcloud_network.mynet.id
  type = "cloud"
  network_zone = "eu-central"
  ip_range   = "10.0.1.0/24"
}

resource "hcloud_server_network" "srvnetwork" {
  server_id = hcloud_server.master.id
  network_id = hcloud_network.mynet.id
  ip = "10.0.1.5"
}

# Create a server
resource "hcloud_server" "node" {
  # count = 1 #TODO: Define it as variable
  # name = "node${count.index}"
  name = "node"
  image = "ubuntu-20.04"
  server_type = "cx11"
  location = "nbg1"
  ssh_keys = [hcloud_ssh_key.default.name]
}

resource "hcloud_server_network" "nodenetwork" {
  server_id = hcloud_server.node.id
  network_id = hcloud_network.mynet.id
  ip = "10.0.1.6"
}

output "master_ip_addr" {
  value = [hcloud_server.master.ipv4_address]
}

output "node_ip_addrs" {
  # value = [hcloud_server.node.*.ipv4_address]
  value = [hcloud_server.node.ipv4_address]
}

