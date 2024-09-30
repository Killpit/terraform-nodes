variable "gce_instance_name" {
    description = "Name of the GCE instance name"
    type = string
    default = "mina-node"
}

variable "vpc_cidr" {
  description = "Defines the CIDR block used on Google Cloud VPC created for Google Cloud VPC."
  type        = string
  default     = "10.42.0.0/16"
}