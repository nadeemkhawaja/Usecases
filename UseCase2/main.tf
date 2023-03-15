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

resource "aci_vrf" "VRF-1" {
  tenant_dn         = "uni/tn-Tenant-1"
  name              = "VRF-1"
}

resource "aci_bridge_domain" "BD-1" {
    tenant_dn         = "uni/tn-Tenant-1"
    relation_fv_rs_ctx    = aci_vrf.VRF-1.id
    name                  = "BD-1"
    arp_flood             = "no"
    ip_learning           = "yes"
    unicast_route         = "yes"
}

resource "aci_subnet" "BD-1-subnet" {
    parent_dn            = aci_bridge_domain.BD-1.id
    ip                   = "192.168.20.1/24"
    scope                = ["public"]
}

resource "aci_application_profile" "APP-1" {
  tenant_dn         = "uni/tn-Tenant-1"
  name       = "APP-1"
  annotation = "tag"
  description = "Networking Centric APP from terraform"
  name_alias = "APP-1"
  prio       = "level1"
}

resource "aci_application_epg" "EPG-1" {

  application_profile_dn  = aci_application_profile.APP-1.id
  name                    = "EPG-1"
  relation_fv_rs_bd       = aci_bridge_domain.BD-1.id
  relation_fv_rs_cons     = [aci_contract.Tenant-1-Contract1.id]
  relation_fv_rs_prov     = [aci_contract.Tenant-1-Contract1.id]
}

resource "aci_contract" "Tenant-1-Contract1" {
  tenant_dn                   = "uni/tn-Tenant-1"
  name                        = "Tenant-1-C1"
 }

 resource "aci_contract_subject" "Tenant-1-Contract1-Sub1" {
   contract_dn                  = aci_contract.Tenant-1-Contract1.id
   name                         = "Tenant-1-Contract1-Sub1"
   relation_vz_rs_subj_filt_att = [aci_filter.allow_icmp.id]
 }

 resource "aci_filter" "allow_icmp" {
  tenant_dn                   = "uni/tn-Tenant-1"
   name                     = "allow_icmp"
 }

 resource "aci_filter_entry" "icmp" {
   name        = "icmp"
   filter_dn   = aci_filter.allow_icmp.id
   ether_t     = "ip"
   prot        = "icmp"
   stateful    = "yes"
 }

resource "aci_epg_to_domain" "EPG-1" {
  application_epg_dn  = aci_application_epg.EPG-1.id
  tdn                 =  "uni/phys-HX02_UCS"
}

resource "aci_epg_to_static_path" "EPG-1" {
  application_epg_dn  = aci_application_epg.EPG-1.id
  tdn  = "topology/pod-1/paths-101/pathep-[eth1/1]"
  annotation = "annotation"
  encap  = "vlan-1000"
  instr_imedcy = "lazy"
  mode  = "regular"
}