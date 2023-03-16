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

resource "aci_tenant" "Tenant-1" {
  name        = "${var.tenant-1_name}"   
  description = "This is Network-Centric Tenant"
}

resource "aci_tenant" "Tenant-2" {
  name        = "${var.tenant-2_name}"    
  description = "This is Application-Centric Tenant"
}

resource "aci_local_user" "test" {
    name                = "test"
    account_status      = "active"
    annotation          = "test-admin"
    cert_attribute      = "example"
    clear_pwd_history   = "no"
    description         = "test-tenant-admin from terraform"
    email               = "example@email.com"
    expiration          = "2030-01-01 00:00:00"
    expires             = "yes"
    first_name          = "fname"
    last_name           = "lname"
    name_alias          = "alias_name"
    otpenable           = "no"
    otpkey              = ""
    phone               = "1234567890"
    pwd                 = "Vzure123"
    pwd_life_time       = "20"
    pwd_update_required = "no"
    rbac_string         = "example"
}

resource "aci_user_security_domain" "test" {
  local_user_dn  = aci_local_user.test.id
  name  = "test"
  annotation = "orchestrator:terraform"
  name_alias = "test"
  description = "from Terraform"
}

resource "aci_user_security_domain_role" "test" {
  user_domain_dn  = aci_user_security_domain.test.id
  annotation      = "orchestrator:terraform"
  name            = "tenant-admin"
  priv_type       = "writePriv"
  name_alias      = "user_role_alias"
  description     = "From Terraform"
}

resource "aci_user_security_domain" "all" {
  local_user_dn  = aci_local_user.test.id
  name  = "all"
  annotation = "orchestrator:terraform"
  name_alias = "all"
  description = "from Terraform"
}

resource "aci_user_security_domain_role" "all" {
  user_domain_dn  = aci_user_security_domain.test.id
  annotation      = "orchestrator:terraform"
  name            = "admin"
  priv_type       = "readPriv"
  name_alias      = "user_role_alias"
  description     = "From Terraform"
}

resource "aci_aaa_domain" "test" {
  name        = "test"
  description = "from terraform"
  annotation  = "aaa_domain_tag"
  name_alias  = "test"
}

resource "aci_aaa_domain_relationship" "test_relationship_tenant-1" {
  aaa_domain_dn = resource.aci_aaa_domain.test.id
  parent_dn     = aci_tenant.Tenant-1.id
}

resource "aci_aaa_domain_relationship" "test_relationship_tenant-2" {
  aaa_domain_dn = resource.aci_aaa_domain.test.id
  parent_dn     = aci_tenant.Tenant-2.id
}
