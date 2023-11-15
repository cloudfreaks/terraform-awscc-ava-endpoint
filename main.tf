module "kms_key" {
  enabled = var.endpoint_kms_enabled
  source = "cloudposse/kms-key/aws"
  version = "0.12.1"
  description             = "KMS key for Validated Access Endpoint"
  deletion_window_in_days = 7
  enable_key_rotation     = false
  alias                   = var.endpoint_kms_alias != "" ? "/alias/${var.endpoint_kms_alias}" : "/alias/ava/${var.application_name}"
}

resource "aws_security_group" "ava_endpoint" {
  name        = "${module.this.id}-endpoint-${var.application_name}"
  description = "Allow AVA endpoint inbound traffic to ${var.application_name}"
  vpc_id      = var.vpc_id

  ingress {
    description      = "${var.application_name} AVA Endpoint port"
    from_port        = var.port
    to_port          = var.port
    protocol         = "tcp"
    cidr_blocks      = [var.endpoint_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = module.this.tags
}

resource "awscc_ec2_verified_access_endpoint" "main" {
  application_domain       = "${var.application_name}.${var.domain}"
  attachment_type          = "vpc"
  domain_certificate_arn   = var.domain_certificate_arn
  endpoint_domain_prefix   = var.application_name
  endpoint_type            = var.endpoint_type
  verified_access_group_id = var.verified_access_group_id
  security_group_ids       = length(var.security_group_ids) > 0 ? var.security_group_ids : [aws_security_group.ava_endpoint.id]

  policy_enabled  = var.endpoint_policy_enabled
  policy_document = var.endpoint_policy_document != null ? chomp(var.endpoint_policy_document) : null

  sse_specification = var.endpoint_kms_enabled ? {
    customer_managed_key_enabled = true
    kms_key_arn = join("", module.kms_key[*].key_arn)
  } : null

  load_balancer_options = var.endpoint_type == "load-balancer" ? {
    load_balancer_arn = var.load_balancer_arn
    subnet_ids = var.load_balancer_subnet_ids
    port = var.port
    protocol = var.protocol
  } : null

  network_interface_options = var.endpoint_type == "network-interface" ? {
    network_interface_id = var.network_interface_id
    port = var.port
    protocol = var.protocol
  } : null

  tags = [for k, v in merge(
              module.this.tags, {
                "Name" = "${module.this.id}-endpoint-${var.application_name}"
              }
            ): { key = k, value = v}
          ]
}

data "aws_route53_zone" "selected" {
  name         = var.domain
}

resource "aws_route53_record" "app_dns_record" {
  count   = var.enable_record_creation ? 1 : 0
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.application_name}.${var.domain}"
  type    = "CNAME"
  ttl     = "300"
  records = [awscc_ec2_verified_access_endpoint.main.endpoint_domain]
}
