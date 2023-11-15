variable "description" {
  type        = string
  description = "(Optional) A description for the AWS Verified Access endpoint."
  default     = null
}

variable "domain" {
  type        = string
  description = "(Required) The DNS domain the application will use. Eg: example.com"
}

variable "application_name" {
  type        = string
  description = "(Required) The DNS record created into the domain set into the domain variable for the application. Eg: myapplication"
}

variable "verified_access_group_id" {
  type        = string
  description = "(Required) The ID of the AWS Verified Access group that this endpoint will use."
}

variable "domain_certificate_arn" {
  type        = string
  description = "(Required) The ARN of a public TLS/SSL certificate imported into or created with ACM, it can validate the domain defined into the `domain` variable or the application record plus the domain set into the `application_name` and the `domain` variables, for example if the `application_name` variable is `myapp` and the `domain` variable is `example.com` the required certificate will need to validate `myapp.example.com`."
}

variable "endpoint_type" {
  type        = string
  description = "(Optional, defaults to load-balancer) The type of AWS Verified Access endpoint. Incoming application requests will be sent to an IP address, load balancer or a network interface depending on the endpoint type specified. Possible values: load-balancer | network-interface"
  default     = "load-balancer"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the endpoint's LoadBalancer or Interface is deployed, required by the generated Security group."
}

variable "security_group_ids" {
  type        = list(string)
  description = "(Optional) The IDs of the security groups for the endpoint. If none is specified, a new security group will be created allowing the port specified into the endpoint type."
  default     = []
}

variable "endpoint_kms_enabled" {
  type        = bool
  description = "(Optional) Set to true to enable the endpoint encryption, this module will create the required KMS."
  default     = false
}

variable "endpoint_kms_alias" {
  type        = string
  description = "(Optional) The alias to assign to the generated KMS key for the endpoint."
  default     = ""
}

variable "endpoint_policy_enabled" {
  type        = bool
  description = "(Optional) Enable the Verified Access policy setting, define the policy with the policy_document variable."
  default     = false
}

variable "endpoint_policy_document" {
  type        = string
  description = "(Required if policy_enabled == true) Policy to be applied to the endpoint."
  default     = null
}

variable "endpoint_cidr_block" {
  type        = string
  description = "(Optional) The CIDR block to allow access into the generated Security Group."
  default     = "0.0.0.0/0"
}

variable "load_balancer_arn" {
  type        = string
  description = "(Required if endpoint_type == load-balancer) The ARN of the INTERNAL NLB or ALB in use by the application."
  default     = null
}

variable "load_balancer_subnet_ids" {
  type        = set(string)
  description = "(Required if endpoint_type == load-balancer) The IDs of the subnets where the Load balancer is deployed. These are supposed to be private subnets."
  default     = null
}

variable "network_interface_id" {
  type        = string
  description = "(Required if endpoint_type==network-interface) The ID of the Network Interface that the Endpoint will target."
  default     = null
}

variable "port" {
  type        = number
  description = "(Optional, defaults to 80) The port that the endpoint will use to connect to the load balancer or network interface. This is the protocol configured on the target group or used by network interfaces for the running application, the Verified Endpoint will always expose port use https/443."
  default     = 80
}

variable "protocol" {
  type        = string
  description = "(Optional, defaults to http) IP protocol the endpoint will use to connect to the load balancer or network interface. This is the protocol configured on the target group or used by network interfaces for the running application, the Verified Endpoint will always expose port use https/443. Possible values: https or http."
  default     = "http"
}

variable "enable_record_creation" {
  type        = bool
  description = "(Optional, defaults to `true`) Create the record (made by the variables `application_name`.`domain`) into the Route53 zone defined by the variable `domain`."
  default     = true
}
