# S3 destination bucket

provider "aws" {
  alias = "destination"
}

locals {
  dest_bucket_arn          = "arn:aws:s3:::${var.dest_bucket_name}"
  dest_bucket_object_arn   = "arn:aws:s3:::${var.dest_bucket_name}/${var.replicate_prefix}*"
  replication_name         = "tf-${var.replication_name}"
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "dest_bucket_policy" {
  statement {
    sid = "replicate-objects-from-${data.aws_caller_identity.current.account_id}-to-prefix-${var.replicate_prefix}"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ObjectOwnerOverrideToBucketOwner",
    ]

    resources = [
      "${local.dest_bucket_object_arn}",
    ]

    principals {
      type = "AWS"

      identifiers = [
        "${local.source_root_user_arn}",
      ]
    }
  }
}

resource "aws_s3_bucket" "dest" {
  count    = "${var.create_dest_bucket == "true" ? 1 : 0}"
  bucket   = "${var.dest_bucket_name}"
  region   = "${var.dest_region}"
  policy   = "${data.aws_iam_policy_document.dest_bucket_policy.json}"

  versioning {
    enabled = true
  }
}