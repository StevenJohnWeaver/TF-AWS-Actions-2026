# -----------------------------------------------------------------------------
# Demo scenario: "Governance guardrail" -- Terraform policy (HCL-native, beta)
#
# Restricts aws_instance.instance_type to a small, cheap allow-list. This is
# the same idea as a Sentinel "allowed-instance-types" hard-mandatory policy
# from the earlier TFE series episodes, rewritten in Terraform policy's HCL
# syntax instead of Sentinel's own language -- no new DSL to learn, just HCL
# you already know.
#
# aws_instance.web in main.tf uses t2.nano, so a normal apply passes. Bump
# instance_type to something outside the allow-list (e.g. "m5.xlarge") to
# trip the mandatory block for the demo.
#
# Docs: https://developer.hashicorp.com/terraform/policy
# -----------------------------------------------------------------------------

policy {
  terraform_config {
    required_version = ">= 1.16.0"
  }
}

resource_policy "aws_instance" "allowed_instance_types" {
  operations        = ["create", "update"]
  enforcement_level = "mandatory"

  locals {
    allowed_types = ["t2.nano", "t2.micro", "t3.micro", "t3.small"]
  }

  enforce {
    condition     = core::contains(local.allowed_types, attrs.instance_type)
    error_message = "instance_type \"${attrs.instance_type}\" is not on the approved list (${core::join(", ", local.allowed_types)}). Use an approved dev-tier instance type or request an exception."
    info_message  = "Checking instance_type \"${attrs.instance_type}\" against the approved list."
  }
}
