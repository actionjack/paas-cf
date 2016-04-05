resource "aws_elb" "router" {
  name = "${var.env}-cf-router-elb"
  subnets = ["${split(",", var.infra_subnet_ids)}"]
  idle_timeout = "${var.elb_idle_timeout}"
  cross_zone_load_balancing = "true"
  security_groups = [
    "${aws_security_group.web.id}",
  ]

  health_check {
    target = "TCP:443"
    interval = "${var.health_check_interval}"
    timeout = "${var.health_check_timeout}"
    healthy_threshold = "${var.health_check_healthy}"
    unhealthy_threshold = "${var.health_check_unhealthy}"
  }
  listener {
    instance_port = 443
    instance_protocol = "ssl"
    lb_port = 443
    lb_protocol = "ssl"
    ssl_certificate_id = "${var.router_external_cert_arn}"
  }
}

resource "aws_security_group" "elb_to_router" {
  name = "${var.env}-elb-to-router"
  description = "Security group from router ELB to router VMs"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = ["${aws_elb.router.source_security_group_id}"]
  }

  tags {
    Name = "${var.env}-elb-to-router"
  }
}


resource "aws_elb" "ssh-proxy-router" {
  name = "${var.env}-ssh-proxy-elb"
  subnets = ["${split(",", var.infra_subnet_ids)}"]
  idle_timeout = "${var.elb_idle_timeout}"
  cross_zone_load_balancing = "true"
  security_groups = [
    "${aws_security_group.sshproxy.id}",
    "${var.bosh_managed_security_group_id}",
  ]

  health_check {
    target = "TCP:2222"
    interval = "${var.health_check_interval}"
    timeout = "${var.health_check_timeout}"
    healthy_threshold = "${var.health_check_healthy}"
    unhealthy_threshold = "${var.health_check_unhealthy}"
  }
  listener {
    instance_port = 2222
    instance_protocol = "tcp"
    lb_port = 2222
    lb_protocol = "tcp"
  }
}

resource "aws_elb" "ingestor_elb" {
  name = "${var.env}-ingestor-elb"
  subnets = ["${split(",", var.infra_subnet_ids)}"]
  idle_timeout = "${var.elb_idle_timeout}"
  cross_zone_load_balancing = "true"
  internal = "true"
  security_groups = [
    "${aws_security_group.ingestor_elb.id}",
    "${var.bosh_managed_security_group_id}",
  ]

  health_check {
    target = "TCP:5514"
    interval = "${var.health_check_interval}"
    timeout = "${var.health_check_timeout}"
    healthy_threshold = "${var.health_check_healthy}"
    unhealthy_threshold = "${var.health_check_unhealthy}"
  }
  listener {
    instance_port = 5514
    instance_protocol = "tcp"
    lb_port = 5514
    lb_protocol = "tcp"
  }
  listener {
    instance_port = 2514
    instance_protocol = "tcp"
    lb_port = 2514
    lb_protocol = "tcp"
  }
}

resource "aws_elb" "es_master_elb" {
  name = "${var.env}-cf-es-elb"
  subnets = ["${split(",", var.infra_subnet_ids)}"]
  idle_timeout = "${var.elb_idle_timeout}"
  cross_zone_load_balancing = "true"
  internal = "true"
  security_groups = [
    "${aws_security_group.elastic_master_elb.id}",
    "${var.bosh_managed_security_group_id}",
  ]

  health_check {
    target = "TCP:9200"
    interval = "${var.health_check_interval}"
    timeout = "${var.health_check_timeout}"
    healthy_threshold = "${var.health_check_healthy}"
    unhealthy_threshold = "${var.health_check_unhealthy}"
  }
  listener {
    instance_port = 9200
    instance_protocol = "tcp"
    lb_port = 9200
    lb_protocol = "tcp"
  }
}

resource "aws_iam_server_certificate" "logsearch" {
  name_prefix = "${var.env}-logsearch-"
  certificate_body = "${file("generated-certificates/logsearch.crt")}"
  private_key = "${file("generated-certificates/logsearch.key")}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "logsearch_elb" {
  name = "${var.env}-logsearch-elb"
  subnets = ["${split(",", var.infra_subnet_ids)}"]
  idle_timeout = "${var.elb_idle_timeout}"
  cross_zone_load_balancing = "true"
  security_groups = [
    "${aws_security_group.logsearch_elb.id}",
    "${var.bosh_managed_security_group_id}",
  ]

  health_check {
    target = "TCP:5602"
    interval = "${var.health_check_interval}"
    timeout = "${var.health_check_timeout}"
    healthy_threshold = "${var.health_check_healthy}"
    unhealthy_threshold = "${var.health_check_unhealthy}"
  }

  listener {
    instance_port = 5602
    instance_protocol = "tcp"
    lb_port = 443
    lb_protocol = "ssl"
    ssl_certificate_id = "${aws_iam_server_certificate.logsearch.arn}"
  }
}

resource "aws_iam_server_certificate" "metrics" {
  name_prefix = "${var.env}-metrics-"
  certificate_body = "${file("generated-certificates/metrics.crt")}"
  private_key = "${file("generated-certificates/metrics.key")}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "metrics_elb" {
  name = "${var.env}-metrics-elb"
  subnets = ["${split(",", var.infra_subnet_ids)}"]
  idle_timeout = "${var.elb_idle_timeout}"
  cross_zone_load_balancing = "true"
  security_groups = [
    "${aws_security_group.metrics_elb.id}",
    "${var.bosh_managed_security_group_id}",
  ]

  health_check {
    target = "TCP:3000"
    interval = "${var.health_check_interval}"
    timeout = "${var.health_check_timeout}"
    healthy_threshold = "${var.health_check_healthy}"
    unhealthy_threshold = "${var.health_check_unhealthy}"
  }
  listener {
    instance_port = 3000
    instance_protocol = "tcp"
    lb_port = 443
    lb_protocol = "ssl"
    ssl_certificate_id = "${aws_iam_server_certificate.metrics.arn}"
  }

  listener {
    instance_port = 3001
    instance_protocol = "tcp"
    lb_port = 3001
    lb_protocol = "ssl"
    ssl_certificate_id = "${aws_iam_server_certificate.metrics.arn}"
  }
}
