locals {
  dest_bucket_arn          = "arn:aws:s3:::${var.dest_bucket_name}"
  dest_bucket_object_arn   = "arn:aws:s3:::${var.dest_bucket_name}/${var.replicate_prefix}*"
  replication_name         = "tf-${var.replication_name}"
}
