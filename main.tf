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
  server_type = "cx11"
  location = "nbg1"
  ssh_keys = [hcloud_ssh_key.default.name]
}

# Create a server
resource "hcloud_server" "node" {
  count = 3 #TODO: Define it as variable
  name = "node${count.index}"
  image = "ubuntu-20.04"
  server_type = "cx11"
  location = "nbg1"
  ssh_keys = [hcloud_ssh_key.default.name]
}

output "instance_ip_addrs" {
  value = [hcloud_server.node.*.ipv4_address]
}

