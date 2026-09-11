# -----------------------------------------------------------------------------
# Demo scenario: "What's out there that we're not managing?"
#
# A wide, multi-resource-type sweep of the account (not just EC2) so the
# HCP Terraform Search & Import page has a rich, varied result set to show
# off -- multiple providers' worth of resource types, mixed Managed /
# Unmanaged status, real names and identities.
#
# Local CLI (`terraform query`) just lists what matches -- it doesn't know
# about Terraform state. Run the same query from the HCP Terraform
# workspace's Search & Import page (after pushing this file) to see the
# Managed / Unmanaged / Unknown status column, which cross-references this
# workspace's state.
#
# NOTE: this file is discovery-only. Nothing here should be turned into a
# committed `import` block without deliberately deciding to bring that
# resource under this workspace's management -- several of the resources
# this will find (S3 buckets, IAM roles/users, Route53 zones, Lambda
# functions, etc.) belong to real, unrelated projects in this account.
#
# Docs: https://developer.hashicorp.com/terraform/language/import/bulk
# -----------------------------------------------------------------------------

list "aws_instance" "instances" {
  provider = aws

  # Full attributes (not just identity) so tags/instance_type are
  # available for policy evaluation -- see policies/*.policy.hcl and
  # `terraform query -policies=policies`.
  include_resource = true
}

list "aws_ebs_volume" "volumes" {
  provider = aws
}

list "aws_eip" "eips" {
  provider = aws
}

list "aws_key_pair" "key_pairs" {
  provider = aws
}

list "aws_db_instance" "databases" {
  provider = aws
}

list "aws_s3_bucket" "buckets" {
  provider = aws
}

list "aws_dynamodb_table" "tables" {
  provider = aws
}

list "aws_lambda_function" "functions" {
  provider = aws
}

list "aws_cloudfront_distribution" "distributions" {
  provider = aws
}

list "aws_route53_zone" "zones" {
  provider = aws
}

# Includes AWS service-linked roles (AWSServiceRoleFor...) alongside
# hand-created ones -- left unfiltered on purpose to widen the result set.
list "aws_iam_role" "roles" {
  provider = aws
}

list "aws_iam_user" "users" {
  provider = aws
}
