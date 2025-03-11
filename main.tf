module "spoke" {
  count  = var.student_count
  source = "./modules/spoke"

  #global
  student_classroom = var.student_classroom
  student_number    = count.index + 1
  #vm
  vm_password = var.vm_password
  #peering
  remote_virtual_network_id = var.remote_virtual_network_id
  #traffic manager
  traffic_manager_id = var.traffic_manager_id
}
