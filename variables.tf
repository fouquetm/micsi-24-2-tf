variable "resource_group_name" {
  type        = string
  description = "Nom du groupe de ressources"
}

variable "trigram" {
  type = map(object({
    vnet_address_space         = list(string)
    agw_subnet_address_prefixe = list(string)
    vm_subnet_address_prefixe  = list(string)
  }))
  description = "permet de contextualiser une infra. ex: mfo"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Adresse IP du VNET"
}

variable "vm_subnet_address_prefixe" {
  type        = list(string)
  description = "Adresse IP du sous-réseau des VMs"
}

variable "agw_subnet_address_prefixe" {
  type        = list(string)
  description = "Adresse IP du sous-réseau de l'App Gateway"
}

variable "vm_username" {
  type        = string
  description = "Nom d'utilisateur de la VM"
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

variable "tm_endpoint_priority" {
  type        = number
  description = "Priorité de l'endpoint Traffic Manager"
}
