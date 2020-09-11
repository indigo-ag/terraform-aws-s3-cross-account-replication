locals {
  source_bucket_arn        = "arn:aws:s3:::${var.source_bucket_name}"
  source_bucket_object_arn = "arn:aws:s3:::${var.source_bucket_name}/${var.replicate_prefix}*"
  source_root_user_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
}
