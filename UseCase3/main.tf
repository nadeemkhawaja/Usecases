terraform {
  required_providers {
    aci = {
      source  = "CiscoDevNet/aci"
      #version = "0.5.2"
    }
  }
  #required_version = ">= 0.13"
}

provider "aci" {
  username = "${var.username}"
  password =  "${var.password}"
  url       = "${var.apic_url}"
  insecure = true
}

#### APP CENTRIC TENANT

 resource "aci_tenant" "Tenant-2" {
  name        = "Tenant-2"   
  description = "This is Application-Centric Tenant"
}

resource "aci_vrf" "VRF-2" {
  tenant_dn         = aci_tenant.Tenant-2.id
  name              = "VRF-2"
}

resource "aci_bridge_domain" "BD-2" {
    tenant_dn         = aci_tenant.Tenant-2.id
    relation_fv_rs_ctx    = aci_vrf.VRF-2.id
    name                  = "BD-2"
    arp_flood             = "no"
    ip_learning           = "yes"
    unicast_route         = "yes"
}

resource "aci_subnet" "BD-2-subnet" {
    parent_dn            = aci_bridge_domain.BD-2.id
    ip                   = "192.168.21.1/24"
    scope                = ["public"]
}

resource "aci_application_profile" "APP-2" {
  tenant_dn         = aci_tenant.Tenant-2.id
  name       = "APP-2"
  annotation = "tag"
  description = "Application Centric APP from terraform"
  name_alias = "APP-2"
  prio       = "level1"
}
resource "aci_application_epg" "EPG-2" {

  application_profile_dn  = aci_application_profile.APP-2.id
  name                    = "EPG-2"
  relation_fv_rs_bd       = aci_bridge_domain.BD-2.id
  relation_fv_rs_cons     = [aci_contract.Tenant-2-Contract1.id]
  relation_fv_rs_prov     = [aci_contract.Tenant-2-Contract1.id]
}

resource "aci_contract" "Tenant-2-Contract1" {
  tenant_dn         = aci_tenant.Tenant-2.id
  name                        = "Tenant-2-C1"
 }

 resource "aci_contract_subject" "Tenant-2-Contract1-Sub1" {
   contract_dn                  = aci_contract.Tenant-2-Contract1.id
   name                         = "Tenant-2-Contract1-Sub1"
   relation_vz_rs_subj_filt_att = [aci_filter.allow_icmp.id]
 }

 resource "aci_filter" "allow_icmp" {
  tenant_dn         = aci_tenant.Tenant-2.id
   name      = "allow_icmp"
 }

 resource "aci_filter_entry" "icmp" {
   name        = "icmp"
   filter_dn   = aci_filter.allow_icmp.id
   ether_t     = "ip"
   prot        = "icmp"
   stateful    = "yes"
 }

 resource "aci_epg_to_domain" "EPG-2" {
  application_epg_dn  = aci_application_epg.EPG-2.id
  tdn                 =  "uni/phys-HX02_UCS"
}

resource "aci_epg_to_static_path" "EPG-2" {
  application_epg_dn  = aci_application_epg.EPG-2.id
  tdn  = "topology/pod-1/paths-101/pathep-[eth1/1]"
  annotation = "annotation"
  encap  = "vlan-1100"
  instr_imedcy = "lazy"
  mode  = "regular"
}