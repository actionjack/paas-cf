output "environment" {
  value = "${var.env}"
}

output "zone0" {
  value = "${var.zones.zone0}"
}

output "zone1" {
  value = "${var.zones.zone1}"
}

output "region" {
  value = "${var.region}"
}

output "bosh_subnet_id" {
  value = "${element(split(",", var.infra_subnet_ids), 0)}"
}

output "bosh_security_group" {
  value = "${aws_security_group.bosh.name}"
}

output "default_security_group" {
  value = "${aws_security_group.bosh_managed.name}"
}

output "bosh_managed_security_group_id" {
  value = "${aws_security_group.bosh_managed.id}"
}

output "bosh_client_security_group" {
  value = "${aws_security_group.bosh_client.name}"
}

output "microbosh_static_private_ip" {
  value = "${var.microbosh_static_private_ip}"
}

output "microbosh_static_public_ip" {
  value = "${aws_eip.bosh.public_ip}"
}

output "compiled_cache_bucket_host" {
  value = "s3-${var.region}.amazonaws.com"
}

output "compiled_cache_bucket_name" {
  value = "shared-cf-bosh-blobstore-${var.aws_account}"
}
