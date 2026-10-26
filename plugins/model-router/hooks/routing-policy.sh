#!/usr/bin/env bash
# SessionStart: stdout becomes context for the session.
# Set MODEL_ROUTER_DISABLE=1 to turn the policy off without uninstalling.
[ "${MODEL_ROUTER_DISABLE:-}" = "1" ] && exit 0

cat <<'POLICY'
## Model routing (model-router plugin)

Delegate by complexity. Use the cheapest tier that can do the job well, and
keep judgment calls in the main session.

- model-router:scout (Haiku): read-only, mechanical work. Finding files or
  symbols, reading and summarizing logs, kubectl get/describe output, Helm or
  Kustomize rendering, listing what references what. Fan out several in
  parallel for broad searches.
- model-router:worker (Sonnet): well-specified changes. Single-service edits,
  writing or fixing tests, bumping image tags or chart versions, adding a
  resource to existing manifests, following an established pattern.
- model-router:architect (Opus): design decisions, incident root cause across
  services, changes to networking/RBAC/storage/autoscaling, migrations, anything
  touching production or hard to roll back, and second opinions on a risky diff.

Rules:
- If the task fits in a handful of tool calls you can make yourself, do it
  inline; delegation has overhead.
- Escalate, don't retry: if a scout or worker comes back unsure or wrong, hand
  the task up a tier instead of rerunning the same tier.
- Never delegate to a cheaper tier anything that mutates a live cluster
  (kubectl apply/delete/scale/rollout, helm upgrade, terraform apply). Those
  stay with the main session or architect and need the user's confirmation.
- Give every subagent a self-contained brief: goal, files or resources, what
  done looks like. It cannot see this conversation.
- When you route, say which tier in one short line (e.g. "→ scout: find all
  HPAs referencing the api deployment").
POLICY
