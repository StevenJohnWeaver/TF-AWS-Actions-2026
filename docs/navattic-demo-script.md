# Navattic Demo Script: "Stop for Maintenance" — Terraform Actions

A self-paced product tour showing how a Terraform Action lets a team stop an
EC2 instance for maintenance as a governed, auditable operation — from the
UI or from a script — without a side-channel `aws ec2 stop-instances` that
Terraform doesn't know about.

**Capture list before you build:** you'll need screenshots/recordings of
(1) the code in an editor, (2) a completed `apply` run in HCP Terraform,
(3) the EC2 instance running in the AWS console, (4) the workspace's
**Actions** tab, (5) the Invoke action dialog, (6) the run/invocation detail
page, (7) the EC2 instance stopped in the AWS console, (8) the
`trigger-action.sh` script in an editor and a terminal running it, and
(9) the Actions invocation history showing both invocations.

---

## Intro screen (modal, before Step 1)

**Headline:** Day-2 operations, without leaving Terraform

**Body:** Most "day 2" work — patching, maintenance windows, incident
response — happens outside your Terraform config, in scripts nobody
versions and runbooks nobody audits. Terraform Actions change that: they let
you define operational tasks, like stopping an instance for maintenance, as
part of your configuration — invokable from the UI, the CLI, or a script,
and fully tracked. Let's walk through it.

**CTA:** Start tour →

---

## Step 1 — The infrastructure

**Screen:** Code editor / GitHub view of `main.tf` — `aws_instance.web`.

**Hotspot:** the `aws_instance "web"` block.

**Headline:** A standard EC2 instance, standard Terraform

**Body:** Nothing exotic here — a `t2.nano` instance, an EBS volume, a load
balancer in front of it. This is the "before" picture: infrastructure
managed the normal way, no special hooks for what's coming next.

**CTA:** Next →

---

## Step 2 — The action, defined alongside the resource

**Screen:** Code editor — `maintenance-action.tf`, scrolled to the
`action "aws_ec2_stop_instance" "web_maintenance"` block.

**Hotspot:** the `action` block, and the `instance_id = aws_instance.web.id`
line specifically.

**Headline:** The maintenance stop lives in version control too

**Body:** This `action` block declares a stop operation against
`aws_instance.web` — provided out of the box by the AWS provider. It's
plain HCL, reviewed in the same pull request as the infrastructure it
targets, not a shell script someone keeps on their laptop.

**CTA:** Next →

---

## Step 3 — Ship it

**Screen:** HCP Terraform — a completed, successful **Apply** run for
`Cloudability-Run-Task-2026`, showing the resources created.

**Hotspot:** the run status badge ("Applied") and the resource list.

**Headline:** One apply, infrastructure and action together

**Body:** A normal `terraform apply` creates the instance — the action
doesn't do anything on its own yet. It's just registered as part of this
workspace's configuration, ready to be invoked whenever maintenance is
actually needed.

**CTA:** Next →

---

## Step 4 — The instance, running

**Screen:** AWS Console — EC2 instances list, `HelloWorldServer` /
`aws_instance.web`, state = **Running**.

**Hotspot:** the "running" state pill.

**Headline:** Live and serving traffic

**Body:** The instance is up. Now let's say a maintenance ticket comes in —
an AMI patch, an EBS operation, whatever it is — and the runbook says: stop
the instance first.

**CTA:** Next →

---

## Step 5 — Find the action

**Screen:** HCP Terraform — workspace sidebar, **Actions** tab, showing
`aws_ec2_stop_instance.web_maintenance` in the list.

**Hotspot:** the action row / the ellipsis (`⋯`) menu.

**Headline:** Every action, in one place

**Body:** The **Actions** tab lists every action declared in this
workspace's configuration, with its invocation history. No hunting through
scripts or wikis to find out what operational levers exist for this
infrastructure — they're right here, next to the resources they act on.

**CTA:** Next →

---

## Step 6 — Invoke it

**Screen:** HCP Terraform — "Invoke action" dialog open, run-type selector
visible.

**Hotspot:** the **Invoke** button, and the run-type dropdown (call out
"Apply" as the selected option, not "Preview with plan-only run").

**Headline:** One click, gracefully stopped

**Body:** Choosing **Apply** and clicking **Invoke** kicks off a real HCP
Terraform run that calls the `aws_ec2_stop_instance` action — the same
governed run pipeline as any other apply, just scoped to this one
operation.

**CTA:** Next →

---

## Step 7 — Watch it happen

**Screen:** HCP Terraform — run detail page for the invoked run, action
status = success.

**Hotspot:** the action status / log output showing the stop completing.

**Headline:** A real, auditable run

**Body:** This isn't a fire-and-forget API call — it's a tracked run with a
log, a status, and a timestamp, same as any plan or apply in this
workspace. Anyone auditing this workspace later sees exactly when the
instance was stopped, by whom, and why (that's the run message).

**CTA:** Next →

---

## Step 8 — Confirm the stop

**Screen:** AWS Console — same EC2 instance, state = **Stopped**.

**Hotspot:** the "stopped" state pill.

**Headline:** Stopped, cleanly

**Body:** The instance gracefully shut down — file systems flushed, no
force-stop. Maintenance can now proceed.

**CTA:** Next →

---

## Step 9 — Same thing, from a script

**Screen:** Code editor — `scripts/trigger-action.sh`.

**Hotspot:** the `invoke-action-addrs` line in the `curl` payload.

**Headline:** The UI isn't the only door in

**Body:** A person clicking Invoke works fine for an ad hoc maintenance
window. But this same action can be triggered by *anything* that can call
an API — a cron job, a ticketing-system webhook, a monitoring alert. This
script calls the exact same HCP Terraform Runs API endpoint the Invoke
button uses, with `invoke-action-addrs` pointing at the same action.

**CTA:** Next →

---

## Step 10 — Run it headless

**Screen:** Terminal — `./scripts/trigger-action.sh` running, output
showing the triggered-run confirmation and link.

**Hotspot:** the "Run triggered" output line.

**Headline:** Automation, not another one-off script

**Body:** One command, no HCP Terraform UI required. This is what plugging
Terraform Actions into a real ops workflow looks like — a maintenance
scheduler or alerting tool fires this instead of a human remembering to
click a button.

**CTA:** Next →

---

## Step 11 — One history, every source

**Screen:** HCP Terraform — Actions invocation history for
`web_maintenance`, showing at least two invocations with different
**Invocation method** values (Direct / UI vs. Direct / API).

**Hotspot:** the **Invocation method** column.

**Headline:** Every invocation, wherever it came from

**Body:** Whether the stop was triggered by a click in the UI or a script
hitting the API, it lands in the same invocation history — same audit
trail, same accountability. That's the difference between an operational
action and a script someone ran once and forgot about.

**CTA:** Finish tour →

---

## Closing screen

**Headline:** Day-2 ops, governed like everything else

**Body:** Terraform Actions bring operational tasks — stopping an instance,
running a Lambda, firing a webhook — into the same version-controlled,
reviewed, audited workflow as the infrastructure they act on. No more
tribal-knowledge scripts living outside Terraform's view.

**CTA:** [Talk to us] / [Explore the docs] — swap for whatever your actual
follow-up CTA is.
