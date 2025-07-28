user_name                = "opc"

inst_params_bast         = {
  display_name           = "bastion"
  shape                  = "VM.Optimized3.Flex"
  ocpus                  = 1
  memory_in_gbs          = 16
  boot_vol_size          = 100
}

cn_timeout               = "30m"

rm_pend_display_name     = "rmpe_bast"
