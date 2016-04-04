resource "aws_security_group" "web" {
  name = "${var.env}-cf-web"
  description = "Security group for web that allows web traffic from the office"
  vpc_id = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  /* FIXME: Merge these two ingress block back together once */
  /* https://github.com/hashicorp/terraform/issues/5301 is resolved. */
  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      "${split(",", var.web_access_cidrs)}",
      "${var.concourse_elastic_ip}/32",
    ]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      "${formatlist("%s/32", aws_eip.cf.*.public_ip)}",
    ]
  }

  tags {
    Name = "${var.env}-cf-web"
  }
}
resource "aws_security_group" "sshproxy" {
  name = "${var.env}-sshproxy-cf"
  description = "Security group for web that allows TCP/2222 for ssh-proxy from the office"
  vpc_id = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 2222
    to_port   = 2222
    protocol  = "tcp"
    cidr_blocks = [
      "${split(",", var.office_cidrs)}"
    ]
  }

  tags {
    Name = "${var.env}-cf-sshproxy"
  }
}

resource "aws_security_group" "cf_rds_client" {
  name = "${var.env}-cf-rds-client"
  description = "Security group of the CF RDS clients"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.env}-cf-rds-client"
  }
}

resource "aws_security_group" "ingestor_elb" {
  name = "${var.env}-ingestor-cf"
  description = "Security group for web that allows TCP/5514 for logsearch ingestor"
  vpc_id = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 2514
    to_port   = 2514
    protocol  = "tcp"
    cidr_blocks = [
      "${var.vpc_cidr}"
    ]
  }

  ingress {
    from_port = 5514
    to_port   = 5514
    protocol  = "tcp"
    cidr_blocks = [
      "${var.vpc_cidr}"
    ]
  }

  tags {
    Name = "${var.env}-logsearch-ingestor"
  }
}

resource "aws_security_group" "elastic_master_elb" {
  name = "${var.env}-elastic-cf"
  description = "Security group for elastic master which allows TCP/9200"
  vpc_id = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 9200
    to_port   = 9200
    protocol  = "tcp"
    cidr_blocks = [
      "${var.vpc_cidr}"
    ]
  }

  tags {
    Name = "${var.env}-logsearch-elastic"
  }
}

resource "aws_security_group" "metrics_elb" {
  name = "${var.env}-metrics"
  description = "Security group for graphite/grafana ELB"
  vpc_id = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      "${split(",", var.office_cidrs)}"
    ]
  }

  ingress {
    from_port = 3001
    to_port   = 3001
    protocol  = "tcp"
    cidr_blocks = [
      "${split(",", var.office_cidrs)}"
    ]
  }

  tags {
    Name = "${var.env}-metrics_elb"
  }
}

resource "aws_security_group" "logsearch_elb" {
  name = "${var.env}-logsearch"
  description = "Security group for logsearch ELB"
  vpc_id = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      "${split(",", var.office_cidrs)}"
    ]
  }

  tags {
    Name = "${var.env}-logsearch_elb"
  }
}

resource "aws_security_group" "cf_cells" {
  name = "${var.env}-cf-cells"
  description = "Security group for CF cells"
  vpc_id = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  tags {
    Name = "${var.env}-cf-cells"
  }
}

resource "aws_security_group" "consul_server" {
  name = "${var.env}-consul-server"
  description = "Security group for Consul server"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 8300
    to_port   = 8300
    protocol  = "tcp"
    security_groups = ["${aws_security_group.consul_client.id}"]
  }

  tags {
    Name = "${var.env}-consul-server"
  }
}

resource "aws_security_group" "consul_client" {
  name = "${var.env}-consul-client"
  description = "Security group for Consul clients"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 8301
    to_port   = 8301
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 8301
    to_port   = 8301
    protocol  = "udp"
    self      = true
  }

  tags {
    Name = "${var.env}-consul-client"
  }
}

resource "aws_security_group" "file_server" {
  name = "${var.env}-file_server"
  description = "Security group for file_server"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    security_groups = ["${aws_security_group.file_server_client.id}"]
  }

  tags {
    Name = "${var.env}-file_server"
  }
}

resource "aws_security_group" "file_server_client" {
  name = "${var.env}-file_server-client"
  description = "Security group for file_server clients"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.env}-file_server-client"
  }
}
