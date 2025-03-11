variable "student_classroom" {
  type        = string
  description = "Nom de la classe de l'étudiant"
}

variable "student_count" {
  type        = number
  description = "Nombre d'étudiants"  
}

variable "vm_password" {
  type        = string
  description = "Mot de passe de la VM"
}

variable "remote_virtual_network_id" {
  type        = string
  description = "ID du VNET distant"
}

variable "traffic_manager_id" {
  type        = string
  description = "ID du Traffic Manager"
}
