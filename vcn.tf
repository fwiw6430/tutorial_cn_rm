resource "oci_core_virtual_network" "vcn" {
  compartment_id             = var.compartment_ocid
  display_name               = var.vcn_params.display_name
  cidr_block                 = var.vcn_params.vcn_cidr
  dns_label                  = var.vcn_params.dns_label
}

resource "oci_core_internet_gateway" "igw" {
  count                      = var.private_bastion ? 0 : 1
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.vcn.id
  display_name               = var.igw_display_name
}

resource "oci_core_nat_gateway" "ngw" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.vcn.id
  display_name               = var.ngw_display_name
}

resource "oci_core_subnet" "public_sub" {
  count                      = var.private_bastion ? 0 : 1
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.vcn.id
  display_name               = var.public_subnet_params.display_name
  cidr_block                 = var.public_subnet_params.cidr_block
  dns_label                  = var.public_subnet_params.dns_label
  prohibit_public_ip_on_vnic = var.public_subnet_params.is_subnet_private
  security_list_ids          = [oci_core_security_list.sl[var.public_subnet_params.sl_name].id]
  route_table_id             = oci_core_route_table.public_rt.id
}

resource "oci_core_subnet" "private_sub" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.vcn.id
  display_name               = var.private_subnet_params.display_name
  cidr_block                 = var.private_subnet_params.cidr_block
  dns_label                  = var.private_subnet_params.dns_label
  prohibit_public_ip_on_vnic = var.private_subnet_params.is_subnet_private
  security_list_ids          = [oci_core_security_list.sl[var.private_subnet_params.sl_name].id]
  route_table_id             = oci_core_route_table.private_rt.id
}

resource "oci_core_security_list" "sl" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.vcn.id
  for_each                   = var.sl_params
  display_name               = each.value.display_name
  dynamic "ingress_security_rules" {
    iterator                 = ingress_rules
    for_each                 = each.value.ingress_rules
    content {
      stateless              = ingress_rules.value.stateless
      protocol               = ingress_rules.value.protocol
      source                 = ingress_rules.value.source
      dynamic "tcp_options" {
        iterator             = tcp_options
        for_each             = (lookup(ingress_rules.value, "tcp_options", null) != null) ? ingress_rules.value.tcp_options : []
        content {
          max                = tcp_options.value.max
          min                = tcp_options.value.min
        }
      }
      dynamic "udp_options" {
        iterator             = udp_options
        for_each             = (lookup(ingress_rules.value, "udp_options", null) != null) ? ingress_rules.value.udp_options : []
        content {
          max                = udp_options.value.max
          min                = udp_options.value.min
        }
      }
    }
  }
  dynamic "egress_security_rules" {
    iterator                 = egress_rules
    for_each                 = each.value.egress_rules
    content {
      stateless              = egress_rules.value.stateless
      protocol               = egress_rules.value.protocol
      destination            = egress_rules.value.destination
    }
  }
}

resource "oci_core_route_table" "public_rt" {
  count                      = var.private_bastion ? 0 : 1
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.vcn.id
  display_name               = var.public_rt_params.display_name
#  dynamic "route_rules" {
#    iterator                 = rt_rules
#    for_each                 = var.public_rt_params.rt_rules
#    content {
      description            = var.public_rt_params.description
      destination            = var.public_rt_params.destination
      destination_type       = var.public_rt_params.destination_type
      network_entity_id      = oci_core_internet_gateway.igw.id
#    }
#  }
}

resource "oci_core_route_table" "private_rt" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.vcn.id
  display_name               = var.private_rt_params.display_name
#  dynamic "route_rules" {
#    iterator                 = rt_rules
#    for_each                 = var.private_rt_params.rt_rules
#    content {
      description            = var.private_rt_params.description
      destination            = var.private_rt_params.destination
      destination_type       = var.private_rt_params.destination_type
      network_entity_id      = oci_core_internet_gateway.ngw.id
#    }
#  }
}
