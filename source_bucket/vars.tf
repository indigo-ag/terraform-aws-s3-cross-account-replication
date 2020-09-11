variable "source_region" {
  type        = "string"
  description = "AWS region for the source bucket"
}

variable "source_bucket_name" {
  type        = "string"
  description = "Name for source s3 bucket"
}

variable "replicate_prefix" {
  type        = "string"
  description = "Prefix to replicate, default \"\" for all objects. Note if specifying, must end in a /"
  default     = ""
}

variable "replication_name" {
  type        = "string"
  description = "Short name to describe this replication"
}
