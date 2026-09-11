# Tests for policies/required-tags.policy.hcl
#
# Run locally with:
#   tfpolicy test --policies=policies --tests=tests

policytest {
  targets = [
    "../policies/required-tags.policy.hcl"
  ]
}

# Both required tags present -- should pass.
resource "aws_instance" "fully_tagged" {
  attrs = {
    instance_type = "t2.nano"
    ami           = "ami-0de716d6197524dd9"
    tags = {
      Name        = "HelloWorldServer"
      cost-center = "dev"
    }
  }
}

# Missing cost-center -- should fail. This is the "found it during Search,
# but it's not tagged for cost allocation" case the demo is built around.
resource "aws_instance" "missing_cost_center" {
  expect_failure = true

  attrs = {
    instance_type = "t3.small"
    ami           = "ami-05cf1e9f73fbad2e2"
    tags = {
      Name = "Portable-Village-Graph-Server"
    }
  }
}

# No tags at all -- should fail.
resource "aws_instance" "untagged" {
  expect_failure = true

  attrs = {
    instance_type = "t3.small"
    ami           = "ami-05cf1e9f73fbad2e2"
    tags          = {}
  }
}
