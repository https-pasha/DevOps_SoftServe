provider "google" {
    credentials = file("tribal-bonsai-292315-2901a39c0f31.json")
    project = "tribal-bonsai-292315"
    region  = "us-central1"
    zone    = "us-central1-a"
    user_project_override = true
}

resource "google_compute_instance" "vm_instance" {
    name = "terraform-instance-${count.index + 1}"
    machine_type = "f1-micro"
    count        = 2
    
  
    boot_disk {
        initialize_params {
            image = "ubuntu-os-cloud/ubuntu-2004-lts"
        }
    }

    network_interface {
        network = google_compute_network.vpc_network.self_link
        access_config {
        }
    }

    metadata = {
        ssh-keys = "labime_infini:${file("C:/Users/38068/.ssh/id_rsa.pub")}"
    }

    provisioner "local-exec" {
        command = "${self.network_interface.0.access_config.0.nat_ip} >> ips.txt"
    }
    
    provisioner "remote-exec" {
        inline = [
            "${self.network_interface.0.access_config.0.nat_ip} >> ~/IP-address.txt"
        ]
    
        connection {
            type = "ssh"
            user = "labime_infini"
            private_key = file("~/.ssh/id_rsa")
            host = self.network_interface.0.access_config.0.nat_ip
        }
    }    
}

output "ip_addr" {
    value = "${google_compute_instance.vm_instance.*.network_interface.0.access_config.0.nat_ip}"
}

resource "google_compute_firewall" "default" {
    name    = "kreeptos"
    network = google_compute_network.vpc_network.name
    allow {
        protocol = "tcp"
        ports = ["22"]
    }
    
    allow {
        protocol = "tcp"
        ports    = ["80-9090"]
    }
}

resource "google_compute_network" "vpc_network" {
  name                    = "my-network-72"
  auto_create_subnetworks = "true"
}
