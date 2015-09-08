variable "region" {}

variable "atlas_username" {}
variable "atlas_environment" {}
variable "atlas_token" {}
variable "name" {}

variable "iam_admins" {}
variable "email_from" {}

variable "vpc_cidr" {}
variable "public_subnets" {}
variable "private_subnets" {}
variable "ephemeral_subnets" {}
variable "azs" {}

variable "bastion_instance_type" {}
variable "nat_instance_type" {}

variable "openvpn_instance_type" {}
variable "openvpn_ami" {}
variable "openvpn_admin_user" {}
variable "openvpn_admin_pw" {}
variable "openvpn_cidr" {}

variable "domain" {}
variable "main_a_records" {}
variable "main_mx_records" {}
variable "main_txt_gsv_records" {}
variable "www_cname" {}

variable "pg_name" {}
variable "pg_username" {}
variable "pg_password" {}
variable "pg_port" {}

variable "pg_m_az" {}
variable "pg_m_multi_az" {}
variable "pg_m_instance_type" {}
variable "pg_m_storage_gbs" {}
variable "pg_m_iops" {}
variable "pg_m_storage_type" {}
variable "pg_m_apply_immediately" {}
variable "pg_m_publicly_accessible" {}
variable "pg_m_storage_encrypted" {}
variable "pg_m_maintenance_window" {}
variable "pg_m_backup_retention_period" {}
variable "pg_m_backup_window" {}

variable "pg_r_az" {}
variable "pg_r_multi_az" {}
variable "pg_r_instance_type" {}
variable "pg_r_storage_gbs" {}
variable "pg_r_iops" {}
variable "pg_r_storage_type" {}
variable "pg_r_apply_immediately" {}
variable "pg_r_publicly_accessible" {}
variable "pg_r_storage_encrypted" {}
variable "pg_r_maintenance_window" {}
variable "pg_r_backup_retention_period" {}
variable "pg_r_backup_window" {}

variable "redis_instance_type" {}
variable "redis_port" {}
variable "redis_initial_cached_nodes" {}
variable "redis_apply_immediately" {}
variable "redis_maintenance_window" {}

variable "rabbitmq_instance_type" {}
variable "rabbitmq_count" {}
variable "rabbitmq_username" {}
variable "rabbitmq_password" {}
variable "rabbitmq_vhost" {}

variable "consul_ips" {}
variable "consul_instance_type" {}

variable "vault_instance_type" {}
variable "vault_count" {}

variable "app_instance_type" {}
variable "app_blue_nodes" {}
variable "app_green_nodes" {}

provider "aws" {
  region = "${var.region}"
}

atlas {
  name = "${var.atlas_username}/${var.atlas_environment}"
}

module "access" {
  source = "../../access"

  name       = "${var.name}"
  iam_admins = "${var.iam_admins}"
}

module "scripts" {
  source = "../../scripts"
}

module "network" {
  source = "../../network"

  name     = "${var.name}"
  vpc_cidr = "${var.vpc_cidr}"
  azs      = "${var.azs}"
  region   = "${var.region}"
  key_name = "${module.access.main_key_name}"
  key_path = "${module.access.main_key_path}"

  public_subnets    = "${var.public_subnets}"
  private_subnets   = "${var.private_subnets}"
  ephemeral_subnets = "${var.ephemeral_subnets}"

  bastion_instance_type = "${var.bastion_instance_type}"
  nat_instance_type     = "${var.nat_instance_type}"
  openvpn_instance_type = "${var.openvpn_instance_type}"

  openvpn_ami        = "${var.openvpn_ami}"
  openvpn_admin_user = "${var.openvpn_admin_user}"
  openvpn_admin_pw   = "${var.openvpn_admin_pw}"
  openvpn_dns_ips    = "${var.consul_ips}"
  openvpn_cidr       = "${var.openvpn_cidr}"
  openvpn_ssl_cert   = "${module.access.main_cert_crt_path}"
  openvpn_ssl_key    = "${module.access.main_cert_key_path}"
}

module "artifacts" {
  source = "artifacts"

  atlas_username = "${var.atlas_username}"
  name           = "${var.name}"
}

module "data" {
  source = "../../data"

  name       = "${var.name}"
  azs        = "${var.azs}"
  key_name   = "${module.access.main_key_name}"
  key_path   = "${module.access.main_key_path}"
  vpc_id     = "${module.network.vpc_id}"
  vpc_cidr   = "${module.network.vpc_cidr}"

  private_subnet_ids   = "${module.network.private_subnet_ids}"
  ephemeral_subnet_ids = "${module.network.ephemeral_subnet_ids}"
  public_subnet_ids    = "${module.network.public_subnet_ids}"

  consul_server_user_data = "${module.scripts.ubuntu_consul_server_user_data}"
  consul_client_user_data = "${module.scripts.ubuntu_consul_client_user_data}"
  vault_user_data         = "${module.scripts.ubuntu_vault_user_data}"
  atlas_username          = "${var.atlas_username}"
  atlas_environment       = "${var.atlas_environment}"
  atlas_token             = "${var.atlas_token}"

  pg_name     = "${var.pg_name}"
  pg_username = "${var.pg_username}"
  pg_password = "${var.pg_password}"
  pg_port     = "${var.pg_port}"

  pg_m_az                      = "${var.pg_m_az}"
  pg_m_multi_az                = "${var.pg_m_multi_az}"
  pg_m_instance_type           = "${var.pg_m_instance_type}"
  pg_m_storage_gbs             = "${var.pg_m_storage_gbs}"
  pg_m_iops                    = "${var.pg_m_iops}"
  pg_m_storage_type            = "${var.pg_m_storage_type}"
  pg_m_apply_immediately       = "${var.pg_m_apply_immediately}"
  pg_m_publicly_accessible     = "${var.pg_m_publicly_accessible}"
  pg_m_storage_encrypted       = "${var.pg_m_storage_encrypted}"
  pg_m_maintenance_window      = "${var.pg_m_maintenance_window}"
  pg_m_backup_retention_period = "${var.pg_m_backup_retention_period}"
  pg_m_backup_window           = "${var.pg_m_backup_window}"

  pg_r_az                      = "${var.pg_r_az}"
  pg_r_multi_az                = "${var.pg_r_multi_az}"
  pg_r_instance_type           = "${var.pg_r_instance_type}"
  pg_r_storage_gbs             = "${var.pg_r_storage_gbs}"
  pg_r_iops                    = "${var.pg_r_iops}"
  pg_r_storage_type            = "${var.pg_r_storage_type}"
  pg_r_apply_immediately       = "${var.pg_r_apply_immediately}"
  pg_r_publicly_accessible     = "${var.pg_r_publicly_accessible}"
  pg_r_storage_encrypted       = "${var.pg_r_storage_encrypted}"
  pg_r_maintenance_window      = "${var.pg_r_maintenance_window}"
  pg_r_backup_retention_period = "${var.pg_r_backup_retention_period}"
  pg_r_backup_window           = "${var.pg_r_backup_window}"

  redis_instance_type        = "${var.redis_instance_type}"
  redis_port                 = "${var.redis_port}"
  redis_initial_cached_nodes = "${var.redis_initial_cached_nodes}"
  redis_apply_immediately    = "${var.redis_apply_immediately}"
  redis_maintenance_window   = "${var.redis_maintenance_window}"

  # Number of AMIs must match count of 1, to update, `terraform taint`
  # and replace pinned with latest one at a time
  rabbitmq_amis          = "${module.artifacts.rabbitmq_latest}"
  rabbitmq_instance_type = "${var.rabbitmq_instance_type}"
  rabbitmq_count         = "${var.rabbitmq_count}"
  rabbitmq_username      = "${var.rabbitmq_username}"
  rabbitmq_password      = "${var.rabbitmq_password}"
  rabbitmq_vhost         = "${var.rabbitmq_vhost}"

  ssl_cert_name     = "${module.access.main_cert_name}"
  ssl_cert_crt      = "${module.access.main_cert_crt_path}"
  ssl_cert_key      = "${module.access.main_cert_key_path}"
  bastion_host      = "${module.network.bastion_ip}"
  bastion_user      = "${module.network.bastion_user}"

  # Number of AMIs must match count of 3, to update, `terraform taint`
  # and replace pinned with latest one at a time
  consul_amis          = "${module.artifacts.consul_latest},${module.artifacts.consul_latest},${module.artifacts.consul_latest}"
  consul_ips           = "${var.consul_ips}"
  consul_instance_type = "${var.consul_instance_type}"

  # Number of AMIs must match count of 2, to update, `terraform taint`
  # and replace pinned with latest one at a time
  vault_amis          = "${module.artifacts.vault_latest},${module.artifacts.vault_latest}"
  vault_instance_type = "${var.vault_instance_type}"
  vault_count         = "${var.vault_count}"
}

module "compute" {
  source             = "../../compute"

  name               = "${var.name}"
  azs                = "${var.azs}"
  vpc_cidr           = "${var.vpc_cidr}"
  domain             = "${var.domain}"
  email_from         = "${var.email_from}"
  vpc_id             = "${module.network.vpc_id}"
  public_subnet_ids  = "${module.network.public_subnet_ids}"
  private_subnet_ids = "${module.network.private_subnet_ids}"
  ssl_cert_crt       = "${module.access.main_cert_crt_path}"
  ssl_cert_key       = "${module.access.main_cert_key_path}"
  key_name           = "${module.access.main_key_name}"
  key_path           = "${module.access.main_key_path}"
  smtp_id            = "${module.access.smtp_id}"
  smtp_password      = "${module.access.smtp_password}"

  consul_client_user_data = "${module.scripts.windows_consul_client_user_data}"
  atlas_username          = "${var.atlas_username}"
  atlas_environment       = "${var.atlas_environment}"
  atlas_token             = "${var.atlas_token}"
  consul_ips              = "${module.data.consul_ips}"

  pg_name     = "${var.pg_name}"
  pg_endpoint = "${module.data.pg_endpoint}"
  pg_username = "${module.data.pg_username}"
  pg_password = "${module.data.pg_password}"

  redis_host     = "${module.data.redis_host}"
  redis_port     = "${module.data.redis_port}"
  redis_password = "${module.data.redis_password}"

  rabbitmq_host     = "${module.data.rabbitmq_host}"
  rabbitmq_port     = "${module.data.rabbitmq_port}"
  rabbitmq_username = "${module.data.rabbitmq_username}"
  rabbitmq_password = "${module.data.rabbitmq_password}"
  rabbitmq_vhost    = "${module.data.rabbitmq_vhost}"

  bastion_host     = "${module.network.bastion_ip}"
  bastion_user     = "${module.network.bastion_user}"
  vault_private_ip = "${element(split(",", module.data.vault_private_ips), 0)}"
  vault_domain     = "vault.${var.domain}"

  statsite_address = ""

  app_instance_type = "${var.app_instance_type}"
  app_blue_ami      = "${module.artifacts.app_latest}"
  app_blue_nodes    = "${var.app_blue_nodes}"
  app_green_ami     = "${module.artifacts.app_pinned}"
  app_green_nodes   = "${var.app_green_nodes}"
}

/*
module "route53" {
  source = "../../network/route53"

  name   = "${var.name}"
  domain = "${var.domain}"
  region = "${var.region}"
  vpc_id = "${module.network.vpc_id}"

  main_a_records       = "${var.main_a_records}"
  main_mx_records      = "${var.main_mx_records}"
  main_txt_gsv_records = "${var.main_txt_gsv_records}"
  www_cname            = "${var.www_cname}"

  vpn_ips = "${module.network.openvpn_ip}"

  app_dns_name = "${module.compute.app_elb_dns_name}"
  app_zone_id  = "${module.compute.app_elb_zone_id}"
}
*/

module "dns" {
  source = "../../dns"

  domain         = "${var.domain}"
  app_dns_name   = "${module.compute.app_dns_name}"
  app_zone_id    = "${module.compute.app_zone_id}"
  vault_dns_name = "${module.data.vault_dns_name}"
  vpn_ip         = "${module.network.openvpn_ip}"
}

resource "null_resource" "consul_ready" {
  provisioner "remote-exec" {
    connection {
      user         = "ubuntu"
      host         = "${element(split(",", module.data.consul_ips), 0)}"
      key_file     = "${module.access.main_key_path}"
      bastion_host = "${module.network.bastion_ip}"
      bastion_user = "${module.network.bastion_user}"
    }

    inline = [ <<COMMANDS
#!/bin/bash
set -e

# Join Consul cluster
consul join ${replace(module.data.consul_ips, ",", " ")}

# Remote commands utilize Consul's KV store, wait until ready
SLEEPTIME=1
cget() { curl -sf "http://127.0.0.1:8500/v1/kv/service/consul/ready?raw"; }

# Wait for the Consul cluster to become ready
while ! cget | grep "true"; do
  if [ $SLEEPTIME -gt 24 ]; then
    echo "ERROR: CONSUL DID NOT COMPLETE SETUP! Manual intervention required."
    exit 2
  else
    echo "Blocking until Consul is ready, waiting $SLEEPTIME second(s)..."
    sleep $SLEEPTIME
    ((SLEEPTIME+=1))
  fi
done

COMMANDS ]
  }
}

resource "null_resource" "remote_commands" {
  depends_on = ["null_resource.consul_ready"]

  provisioner "remote-exec" {
    connection {
      user         = "ubuntu"
      host         = "${element(split(",", module.data.consul_ips), 0)}"
      key_file     = "${module.access.main_key_path}"
      bastion_host = "${module.network.bastion_ip}"
      bastion_user = "${module.network.bastion_user}"
    }

    inline = [
      "${module.data.remote_commands}",
      "${module.compute.remote_commands}",
    ]
  }
}

output "configuration" {
  value = <<CONFIGURATION

Domain:       https://${module.dns.main}
Bastion IP:   ${module.network.bastion_ip}
OpenVPN IP:   ${module.network.openvpn_ip}
RabbitMQ IP:  ${module.data.rabbitmq_private_ips}
Name Servers: ${module.dns.ns1},${module.dns.ns2},${module.dns.ns3},${module.dns.ns4}

The below IAM users have been created.
  Users: ${module.access.admin_users}
  Access Key Ids: ${module.access.admin_access_key_ids}
  Secret Access Keys: ${module.access.admin_secret_access_keys}
  Statuses: ${module.access.admin_statuses}

DNS records have been set for all ${var.name} services, please add NS records for ${var.domain} pointing to:
  ${module.dns.ns1}
  ${module.dns.ns2}
  ${module.dns.ns3}
  ${module.dns.ns4}

The environment is accessible via an OpenVPN connection:
  Server:   ${module.network.openvpn_ip}
  Server:   https://${module.dns.vpn}/
  Username: ${var.openvpn_admin_user}
  Password: ${var.openvpn_admin_pw}

You can administer the OpenVPN Access Server here:
  https://${module.network.openvpn_ip}/admin
  https://${module.dns.vpn}/admin

Once you're on the VPN, you can...

Visit the Consul UI here:
  http://${element(split(",", var.consul_ips), 0)}:8500/ui
  http://consul.service.consul:8500/ui

Administer RabbitMQ here:
  http://${element(split(",", module.data.rabbitmq_private_ips), 0)}:15672
  http://${module.data.rabbitmq_host}:15672
  Username: ${var.rabbitmq_username}
  Password: ${var.rabbitmq_password}
CONFIGURATION
}
