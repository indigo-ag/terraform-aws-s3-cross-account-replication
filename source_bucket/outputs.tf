# Source write IAM user

output "source_write_iam_user_access_key_id" {
  value = "${aws_iam_access_key.source_write.id}"
}

output "source_write_iam_user_secret_access_key" {
  value     = "${aws_iam_access_key.source_write.secret}"
  sensitive = true
}