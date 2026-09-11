# -----------------------------------------------------------------------------
# Demo scenario: "Policy meets Search" -- checking discovered resources
# against governance policy before you ever write an import block.
#
# Requires EC2 instances to carry Name and cost-center tags -- the same two
# tags aws_instance.web already sets in main.tf. Run this alongside
# resource-search.tfquery.hcl (which sets include_resource = true on its
# aws_instance list block, so attrs.tags is actually populated) via:
#
#   terraform query -policies=policies
#
# Every discovered aws_instance gets evaluated against this policy (and
# allowed-instance-types.policy.hcl) as part of that same query run --
# before anything is imported. mandatory_overridable (rather than
# allowed-instance-types.policy.hcl's hard "mandatory") because a missing
# tag on something you're about to import is a fix-it-on-the-way-in issue,
# not a hard stop.
#
# Docs: https://developer.hashicorp.com/terraform/policy
# -----------------------------------------------------------------------------

resource_policy "aws_instance" "required_tags" {
  enforcement_level = "mandatory_overridable"

  locals {
    required_tags = ["Name", "cost-center"]
  }

  enforce {
    condition     = attrs.tags != null && core::contains(core::keys(attrs.tags), "Name")
    error_message = "EC2 instance is missing a \"Name\" tag."
  }

  enforce {
    condition     = attrs.tags != null && core::contains(core::keys(attrs.tags), "cost-center")
    error_message = "EC2 instance is missing a \"cost-center\" tag -- required for cost allocation before it can be imported."
  }
}
