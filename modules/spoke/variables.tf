variable "student_classroom" {
  type        = string
  description = "Nom de la classe de l'étudiant"
}

variable "student_number" {
  type        = number
  description = "Numéro de l'étudiant"
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