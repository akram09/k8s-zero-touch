locals {
  kubernetes_nodes = {
    "master-node"  = { size = "c-2" },
    "node-1"   = { size = "c-4" },
    "node-2" = { size = "c-4" },
  }
}



resource "digitalocean_droplet" "map" {
    for_each = local.kubernetes_nodes
    image = "ubuntu-20-04-x64"
    name = each.key
    region = "fra1"
    size = each.value.size
    ssh_keys = [
      data.digitalocean_ssh_key.akram09_pc.id
    ]

  connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    private_key = file(var.PVT_KEY)
    timeout = "2m"
  } 
}

output "ip_master" {
  description = "The IP address of the master node "
  value = digitalocean_droplet.map["master-node"].ipv4_address
} 


output "ip_node-1" {
  description = "The IP address of the node 1"
  value = digitalocean_droplet.map["node-1"].ipv4_address
} 

output "ip_node-2" {
  description = "The IP address of the node 2"
  value = digitalocean_droplet.map["node-2"].ipv4_address
} 

