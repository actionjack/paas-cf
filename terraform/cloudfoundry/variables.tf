variable "cf_cidrs" {
  description = "CIDR for cf components subnet indexed by AZ"
  default     = {
    zone0 = "10.0.16.0/24"
    zone1 = "10.0.17.0/24"
    zone2 = "10.0.18.0/24"
  }
}

variable "cell_cidrs" {
  description = "CIDR for cell subnet indexed by AZ"
  default     = {
    zone0 = "10.0.32.0/24"
    zone1 = "10.0.33.0/24"
    zone2 = "10.0.34.0/24"
  }
}

variable "router_cidrs" {
  description = "CIDR for router subnets indexed by AZ"
  default     = {
    zone0 = "10.0.48.0/24"
    zone1 = "10.0.49.0/24"
    zone2 = "10.0.50.0/24"
  }
}

variable "cell_cidr_all" {
  description = "CIDR for all cell subnets"
  default     = "10.0.32.0/20"
}

variable "cf_cidr_all" {
  description = "CIDR for all cell subnets"
  default     = "10.0.16.0/20"
}

variable "router_cidr_all" {
  description = "CIDR for all router subnets"
  default     = "10.0.48.0/20"
}

variable "health_check_interval" {
  description = "Interval between requests for load balancer health checks"
  default     = 5
}

variable "health_check_timeout" {
  description = "Timeout of requests for load balancer health checks"
  default     = 2
}

variable "health_check_healthy" {
  description = "Threshold to consider load balancer healthy"
  default     = 2
}

variable "health_check_unhealthy" {
  description = "Threshold to consider load balancer unhealthy"
  default     = 2
}

variable "elb_idle_timeout" {
  description = "Timeout idle connections after 300 seconds"
  default     = 300
}

variable "subnet0_id" {
    description = "Subnet that is used to provision ELB"
}

variable "cf_subnet_count" {
  description = "Number of CF subnets"
  default     = 2
}

variable "concourse_elastic_ip" {
  description = "Public IP of the deployer-concourse machine"
}

variable "concourse_security_group_id" {
  description = "Security group ID for concourse"
}

variable "secrets_cf_db_master_password" {
  description = "Master password for CF database"
}

variable "cf_db_multi_az" {
  description = "CF database multi availabiliy zones"
}

variable "cf_db_backup_retention_period" {
  description = "CF database backup retention period"
}

variable "cf_db_skip_final_snapshot" {
  descrition = "Whether to skip final RDS snapshot (just before destroy). Differs per environment."
}

variable "system_dns_zone_id" {
  description = "Amazon Route53 DNS zone identifier for the system components. Different per account."
}

variable "system_dns_zone_name" {
  description = "Amazon Route53 DNS zone name for the provisioned environment."
}

variable "apps_dns_zone_id" {
  description = "Amazon Route53 DNS zone identifier for hosted apps. Different per account."
}

variable "apps_dns_zone_name" {
  description = "Amazon Route53 DNS zone name for hosted apps. Differs per account."
}

variable "router_external_cert_arn" {
  description = "Amazon ARN for the public facing certificate to be used on the router"
}

variable "bosh_managed_security_group_id" {
  description = "bosh managed security group id"
}
