# S3 source IAM and bucket

provider "aws" {
  alias = "source"
}

locals {
  source_bucket_arn        = "arn:aws:s3:::${var.source_bucket_name}"
  source_bucket_object_arn = "arn:aws:s3:::${var.source_bucket_name}/${var.replicate_prefix}*"
  source_root_user_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
}


data "aws_caller_identity" "current" {}

# S3 source IAM
data "aws_iam_policy_document" "source_write" {
  statement {
    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${local.source_bucket_object_arn}",
    ]
  }

  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "${local.source_bucket_arn}",
    ]
  }
}

resource "aws_iam_policy" "source_write" {
  name_prefix = "${local.replication_name}-source-write-"
  policy      = "${data.aws_iam_policy_document.source_write.json}"
}

resource "aws_iam_user" "source_write" {
  name          = "${local.replication_name}-source-write-user"
  force_destroy = true
}

resource "aws_iam_user_policy_attachment" "source_write" {
  user       = "${aws_iam_user.source_write.name}"
  policy_arn = "${aws_iam_policy.source_write.arn}"
}

resource "aws_iam_access_key" "source_write" {
  user     = "${aws_iam_user.source_write.name}"
}


data "aws_iam_policy_document" "source_replication_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "source_replication_policy" {
  statement {
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    resources = [
      "${local.source_bucket_arn}",
    ]
  }

  statement {
    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
    ]

    resources = [
      "${local.source_bucket_object_arn}",
    ]
  }

  statement {
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ObjectOwnerOverrideToBucketOwner",
    ]

    resources = [
      "${local.dest_bucket_object_arn}",
    ]
  }
}

resource "aws_iam_role" "source_replication" {
  name               = "${local.replication_name}-replication-role"
  assume_role_policy = "${data.aws_iam_policy_document.source_replication_role.json}"
}

resource "aws_iam_policy" "source_replication" {
  name     = "${local.replication_name}-replication-policy"
  policy   = "${data.aws_iam_policy_document.source_replication_policy.json}"
}

resource "aws_iam_role_policy_attachment" "source_replication" {
  role       = "${aws_iam_role.source_replication.name}"
  policy_arn = "${aws_iam_policy.source_replication.arn}"
}

# S3 source bucket

resource "aws_s3_bucket" "source" {
  bucket   = "${var.source_bucket_name}"
  region   = "${var.source_region}"

  versioning {
    enabled = true
  }

  replication_configuration {
    role = "${aws_iam_role.source_replication.arn}"

    rules {
      id     = "${local.replication_name}"
      status = "Enabled"
      prefix = "${var.replicate_prefix}"

      destination {
        bucket        = "${local.dest_bucket_arn}"
        storage_class = "STANDARD"

        access_control_translation = {
          owner = "Destination"
        }

        account_id = "${data.aws_caller_identity.current.account_id}"
      }
    }
  }
}
