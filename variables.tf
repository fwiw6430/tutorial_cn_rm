variable "vcn_params" {
  description          = "VCN Parameters: vcn_cidr, display_name, dns_label"
  type                 = map(string)
}
variable "igw_display_name" {
  description          = "Internet Gateway display name"
  type                 = string
}
variable "ngw_display_name" {
  description          = "NAT Gateway display name"
  type                 = string
}
variable "subnet_params" {
  description          = "Subnet Parameters"
  type = map(object({
    display_name       = string
    cidr_block         = string
    dns_label          = string
    is_subnet_private  = bool
    sl_name            = string
    rt_name            = string
  })) 
}
variable "sl_params" {
  description          = "Security List Params"
  type = map(object({
    display_name       = string
    ingress_rules      = list(object({
      stateless        = string
      protocol         = string
      source           = string
      tcp_options      = list(object({
        min            = number
        max            = number
      }))
      udp_options      = list(object({
        min            = number
        max            = number
      }))
    }))
    egress_rules       = list(object({
      stateless        = string
      protocol         = string
      destination      = string
    }))
  }))
}
variable "rt_params" {
  description          = "Route Table Params"
  type                 = map(object({
    display_name       = string
    rt_rules = list(object({
      description      = string
      destination      = string
      destination_type = string
      target_is_igw    = bool
    }))
  }))
}
variable "user_name" { 
  description          = "User name to be used to access instances via SSH"
  type                 = string
} 
variable "inst_params_bast" {
  description          = "Instance Parameters for bastion"
  type                 = map(string)
}
variable "rm_pend_display_name" {
  description          = "Resource manager private endpoint display name"
  type                 = string
}

# Variables under are defined in schema.html
variable "compartment_ocid" {
  description          = "Compartment OCID where resources reside"
  type                 = string
}
variable "ad" {
  description          = "Availability Domain where OCI resources reside"
  type                 = string
}
variable "ssh_key" {
  description          = "SSH public key to login bastion"
  type                 = string
}
variable "private_bastion" {
  description          = "Connect bastion to private subnet"
  type                 = bool
}
variable "exist_vcn" {
  description          = "Deploy HPC/GPU cluster on existing VCN"
  type                 = bool
}
variable "vcn_ocid" { 
  description          = "Pre-exsisting VCN OCID for HPC/GPU cluster to be deployed in"
  type                 = string
  default              = ""
}
variable "public_ocid" { 
  description          = "Pre-exsisting public subnet OCID for HPC/GPU cluster to be deployed in"
  type                 = string
  default              = ""
}
variable "private_ocid" { 
  description          = "Pre-exsisting private subnet OCID for HPC/GPU cluster to be deployed in"
  type                 = string
  default              = ""
}
variable "comp_shape" { 
  description          = "Compute/GPU node shape"
  type                 = string
}
variable "comp_image" { 
  description          = "Compute/GPU node image OCID"
  type                 = string
}
variable "comp_boot_vol_size" { 
  description          = "Compute/GPU node boot volume size in GB"
  type                 = number
}
# "-" in variable name causes issue to handle its value in Terraform scripts
variable "comp_cloud_config" {
  description          = "Compute/GPU node cloud-config file"
  type                 = string
}
variable "comp_nps_x9" {
  description          = "Compute/GPU node NPS (NUMA nodes Per Socket) for BM.Optimized3.36"
  type                 = string
  default              = "NPS1"
}
variable "comp_nps_gpu40" {
  description          = "Compute/GPU node NPS (NUMA nodes Per Socket) for BM.GPU4.8"
  type                 = string
  default              = "NPS4"
}
variable "comp_nps_gpu80" {
  description          = "Compute/GPU node NPS (NUMA nodes Per Socket) for BM.GPU.A100-v2.8"
  type                 = string
  default              = "NPS4"
}
variable "comp_smt" {
  description          = "Compute/GPU node SMT (Simultanious Multi Threading) enabled in BIOS"
  type                 = bool
  default              = true
}
variable "cn_display_name" { 
  description          = "Cluster display name postfix"
  type                 = string
}
variable "cn_node_count" { 
  description          = "Compute/GPU node count"
  type                 = number
}

