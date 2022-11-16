variable "DO_PAT" {}
variable "PVT_KEY" {}

terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}


provider "digitalocean" {
  token = var.DO_PAT
}

# You should change "akram09-pc" with the name of the ssh key uploaded in digital ocean
data "digitalocean_ssh_key" "akram09_pc" {
  name = "akram09_pc"
}
