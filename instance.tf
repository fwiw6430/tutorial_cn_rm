resource "tls_private_key" "ssh" {
  algorithm                 = "RSA"
  rsa_bits                  = "4096"
}

resource "oci_core_instance" "bastion" {
  compartment_id            = var.compartment_ocid
  display_name              = var.inst_params_bast.display_name
  availability_domain       = var.ad
  shape                     = var.inst_params_bast.shape
  shape_config {
    ocpus                   = var.inst_params_bast.ocpus
    memory_in_gbs           = var.inst_params_bast.memory_in_gbs
  }
  create_vnic_details {
    subnet_id               = var.exist_vcn ? var.private_bastion ? var.private_ocid : var.public_ocid : var.private_bastion ? oci_core_subnet.sub["private"].id : oci_core_subnet.sub["public"].id
    assign_public_ip        = var.private_bastion ? false : true
  }
  source_details {
    source_id               = var.comp_image
    source_type             = "image"
    boot_volume_size_in_gbs = var.inst_params_bast.boot_vol_size
  }
  metadata                  = {
    ssh_authorized_keys     = "${var.ssh_key}\n${tls_private_key.ssh.public_key_openssh}"
    user_data               = "${base64encode(file("./user_data/cloud-init_bast.cfg"))}"
  }
  preserve_boot_volume      = false
}

resource "oci_resourcemanager_private_endpoint" "rms_private_endpoint" {
  count                     = 1
  compartment_id            = var.compartment_ocid
  display_name              = var.rm_pend_display_name
  vcn_id                    = oci_core_virtual_network.vcn.id
  subnet_id                 = oci_core_subnet.sub["private"].id
}

resource "null_resource" "bastion" {
  depends_on                = [oci_core_instance.bastion]
  triggers                  = {
    bastion                 = oci_core_instance.bastion.id
  }
  provisioner "file" {
    content                 = tls_private_key.ssh.private_key_pem
    destination             = "/home/${var.user_name}/.ssh/id_rsa"
    connection {
      host                  = data.oci_resourcemanager_private_endpoint_reachable_ip.rmpe_bast_ip[0].ip_address
      type                  = "ssh"
      user                  = var.user_name
      private_key           = tls_private_key.ssh.private_key_pem
    }
  }
  provisioner "remote-exec" {
    inline                  = [
      "chmod 600 /home/${var.user_name}/.ssh/id_rsa",
    ]
    connection {
      host                  = data.oci_resourcemanager_private_endpoint_reachable_ip.rmpe_bast_ip[0].ip_address
      type                  = "ssh"
      user                  = var.user_name
      private_key           = tls_private_key.ssh.private_key_pem
    }
  }
  provisioner "remote-exec" {
    inline                  = [
      for instance in data.oci_core_instance.cn_instances :
        "echo ${instance.display_name} | sudo tee -a ~${var.user_name}/hostlist.txt"
    ]
    connection {
      host                  = data.oci_resourcemanager_private_endpoint_reachable_ip.rmpe_bast_ip[0].ip_address
      type                  = "ssh"
      user                  = var.user_name
      private_key           = tls_private_key.ssh.private_key_pem
    }
  }
}
data "oci_resourcemanager_private_endpoint_reachable_ip" "rmpe_bast_ip" {
    count                   = 1
    private_endpoint_id     = oci_resourcemanager_private_endpoint.rms_private_endpoint[0].id
    private_ip              = tostring(oci_core_instance.bastion.private_ip)
}
