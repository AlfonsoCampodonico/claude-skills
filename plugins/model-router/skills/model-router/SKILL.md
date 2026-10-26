---
name: model-router
description: Use when the user asks to route a task by complexity, pick a model for a task, save cost by delegating to cheaper models, or types /model-router. Classifies the task, splits it into parts, and dispatches each part to the scout (Haiku), worker (Sonnet) or architect (Opus) subagent.
---

# Model router

Split the task, pick a tier per part, dispatch, then integrate the results
yourself. The main session owns the plan and the final answer.

## 1. Classify each part

| Signal | Tier |
|---|---|
| Find, list, read, summarize; output is facts, not decisions | `model-router:scout` (Haiku) |
| Change is specified: you could write the acceptance check now | `model-router:worker` (Sonnet) |
| Needs a decision, a diagnosis, or touches prod / is hard to undo | `model-router:architect` (Opus) |
| A few tool calls you can make yourself | do it inline, no subagent |

Bump a tier up when any of these hold: more than one service or repo is
involved, the cause is unknown, the change touches networking, RBAC, storage,
autoscaling, secrets or data migrations, or a cheaper tier already failed.

Infra examples:

- "Which deployments mount the `db-creds` secret?" → scout
- "Tail the ingress-nginx logs for 502s in the last hour and summarize" → scout
- "Bump the api image to v2.14 in the staging overlay and render it" → worker
- "Add a PodDisruptionBudget for the worker deployment like the api one" → worker
- "Pods OOMKill only on the new node pool, why?" → scout to gather, architect to diagnose
- "Should we move from cluster-autoscaler to Karpenter?" → architect

## 2. Dispatch

- Run independent scouts in parallel in one message.
- Brief each subagent as if it has never seen the conversation: goal, the
  files, namespaces or resources involved, what done looks like.
- Typical shape for a bug: scouts gather evidence → architect diagnoses →
  worker implements → you review the diff.

## 3. Integrate

- Check subagent claims before passing them on; a scout's summary is a lead,
  not proof.
- If a tier comes back unsure or wrong, escalate one tier instead of rerunning
  the same one.
- Anything that mutates a live cluster or cloud resources stays with you, and
  you confirm with the user first.

Tell the user the routing in one line per part, e.g.
`→ scout ×3: gather pod events, node conditions, recent deploys`.

## Turning it off

The SessionStart hook loads the routing policy into every session. Set
`MODEL_ROUTER_DISABLE=1` in the environment (or in `settings.json` under
`env`) to keep the agents and this skill but drop the always-on policy.
