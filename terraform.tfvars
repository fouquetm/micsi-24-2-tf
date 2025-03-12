# Student
resource_group_name        = "rg-micsi24-2"
trigram                    = "student1"
vnet_address_space         = ["11.0.0.0/16"] # student1 => 11.0.0.0/16, student2 => 12.0.0.0/16, etc.
vm_subnet_address_prefixe  = ["11.0.2.0/24"] # student1 => 11.0.2.0/24, student2 => 12.0.2.0/24, etc.
agw_subnet_address_prefixe = ["11.0.3.0/24"] # student1 => 11.0.3.0/24, student2 => 12.0.3.0/24, etc.
vm_username                = "toto"
vm_password                = "P@ssw0rd2025!"

# Hub
remote_virtual_network_id = "/subscriptions/10ce0944-5960-42ed-8657-1a8177030014/resourceGroups/rg-mfolabs-micsi24/providers/Microsoft.Network/virtualNetworks/vnet-form-fc-01"
traffic_manager_id        = "/subscriptions/10ce0944-5960-42ed-8657-1a8177030014/resourceGroups/rg-mfolabs-micsi24/providers/Microsoft.Network/trafficManagerProfiles/tm-form-fc-01"
tm_endpoint_priority      = 101 # student1 => 101, student2 => 102, etc.
private_dns_zone_name     = "mfolabs.internal"
hub_resource_group_name   = "rg-mfolabs-micsi24"
dns_zone_name             = "students.mfolabs.me"
