variable "dest_region" {
  type        = "string"
  description = "AWS region for the destination bucket"
}

variable "replicate_prefix" {
  type        = "string"
  description = "Prefix to replicate, default \"\" for all objects. Note if specifying, must end in a /"
  default     = ""
}

variable "dest_bucket_name" {
  type        = "string"
  description = "Name for dest s3 bucket"
}

variable "create_dest_bucket" {
  type        = "string"
  description = "Boolean for whether this module should create the destination bucket"
  default     = "true"
}

variable "replication_name" {
  type        = "string"
  description = "Short name to describe this replication"
}
