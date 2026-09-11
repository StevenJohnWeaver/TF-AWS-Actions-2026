# Tests for policies/allowed-instance-types.policy.hcl
#
# Run locally with:
#   tfpolicy test --policies=policies --tests=tests

policytest {
  targets = [
    "../policies/allowed-instance-types.policy.hcl"
  ]
}

# Matches aws_instance.web's current instance_type in main.tf -- should pass.
resource "aws_instance" "approved_type" {
  attrs = {
    instance_type = "t2.nano"
    ami           = "ami-0de716d6197524dd9"
  }
}

# An allowed type, on an update from another allowed type -- should pass.
resource "aws_instance" "approved_type_resize" {
  meta = {
    operation = "update"
  }

  prior_attrs = {
    instance_type = "t2.nano"
    ami           = "ami-0de716d6197524dd9"
  }

  attrs = {
    instance_type = "t3.small"
    ami           = "ami-0de716d6197524dd9"
  }
}

# Outside the allow-list -- should fail. This is the "maintenance window
# resize gone wrong" case the demo's trip-wire moment is built around.
resource "aws_instance" "disallowed_type" {
  expect_failure = true

  attrs = {
    instance_type = "m5.xlarge"
    ami           = "ami-0de716d6197524dd9"
  }
}
