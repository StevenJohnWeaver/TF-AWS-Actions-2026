# -----------------------------------------------------------------------------
# Demo scenario: "Scheduled maintenance"
#
# The web instance occasionally needs maintenance (patching, AMI rebuild,
# EBS work, etc.) and the runbook calls for it to be gracefully stopped
# first. Instead of a human hand-jamming `aws ec2 stop-instances` (or a
# side-channel script that Terraform knows nothing about), we model the
# stop as a first-class Terraform Action tied to the resource it targets.
#
# aws_ec2_stop_instance docs:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/actions/ec2_stop_instance
# -----------------------------------------------------------------------------

variable "maintenance_window" {
  description = <<-EOT
    Free-form marker for the current maintenance window (e.g. a date, a
    change-ticket ID, "2026-09-09-patching"). Changing this value is what
    trips the action_trigger below and stops aws_instance.web before the
    next apply proceeds. Leave unchanged for normal applies.
  EOT
  type        = string
  default     = "none"
}

# The action itself: stops aws_instance.web when invoked. On its own this
# action does nothing during a normal apply -- it only runs when either
# (a) something triggers it via a lifecycle action_trigger (below), or
# (b) it's invoked directly, e.g. from the HCP Terraform "Actions" tab, or
#     via the Runs API with `invoke-action-addrs`.
action "aws_ec2_stop_instance" "web_maintenance" {
  config {
    instance_id = aws_instance.web.id
    # Give the OS time to flush/shut down cleanly instead of a hard force-stop.
    timeout = 300
  }
}

# Wiring for "automatic" invocation: bump var.maintenance_window (e.g. in
# a PR, or via a `-var` override on a targeted run) and Terraform will stop
# the instance as a pre-condition of the next apply -- a real maintenance
# gate, not just a demo button.
resource "terraform_data" "maintenance_trigger" {
  input = var.maintenance_window

  lifecycle {
    action_trigger {
      events  = [before_update]
      actions = [action.aws_ec2_stop_instance.web_maintenance]
    }
  }

  depends_on = [aws_instance.web]
}
