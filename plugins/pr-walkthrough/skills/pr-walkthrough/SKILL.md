---
name: pr-walkthrough
description: Use when the user shares a PR link or number and wants it reviewed, walked through, or explained — "review this PR", "how do these changes fit together", "what should I focus on", "show me the flow", "make a diagram of this PR" — especially when they say not to fix or comment, or ask for something visual.
---

# PR walkthrough

A read-only review whose centerpiece is a **workflow diagram** of how the
change moves through the code, followed by **ranked points to consider**.
It's the reader's map of the PR plus your list of where to look hard.

Read-only by default: no fixes, no GitHub comments, no checkout of the user's
working copy. Fixes happen later, on request, in a separate PR.

## 1. Gather (verify, don't trust the description)

```bash
TMP=$(mktemp -d)   # or the session's scratch/job tmp dir, if it has one
gh pr view <n> --json title,body,author,baseRefName,headRefName,files,commits,reviews,comments
gh pr diff <n> > "$TMP/pr<n>.diff"      # read it with Read
git fetch -q origin pull/<n>/head:review/pr-<n>
git grep -n "<new function names>" review/pr-<n>    # real call sites
git show review/pr-<n>:path/to/file                 # surrounding code
```

- For every hook or new call, open the **call site on the PR head**. Check
  whether it fires on every path the PR claims (success, failure, retry,
  shutdown, early return). Most real findings come from here.
- If `git fetch` is blocked (for example a worktree-isolated session), read
  PR-head files without touching refs:
  `gh api "repos/<o>/<r>/contents/<path>?ref=<headSha>" -H "Accept: application/vnd.github.raw"`.
  To run tests, copy them into a scratch module under `$TMP`. Say in the
  verification line that you did this.
- Run the project's tests in a throwaway worktree:
  `git worktree add "$TMP/pr<n>" review/pr-<n>`. Use the repo's test command
  (race/vet if it has them). Remove the worktree and the `review/` ref when
  done.

## 2. Output: exactly these parts, in this order

1. **One paragraph:** what the PR does and why, in your own words, with the
   author and ticket.
2. **Workflow diagram.** Real function and file names, arrows for call or
   data flow. Mark what is **new** (`──►` to the new hook or metric), mark
   branches (failure, retry, shutdown), and end at the observable effect.
   Then a 2-3 line concrete example of what the user or operator sees, e.g.
   a test assertion or an output line.
3. **Files changed:** one line per file or package, saying its role.
4. **Points to take into consideration**, grouped and numbered continuously:
   - **Worth discussing before merge:** design and production risk.
   - **Correctness nits:** each with `file:line` and a concrete failing
     scenario (input or state → wrong result).
   - **Docs & process:** missing docs, rollout steps, follow-up PRs.
   - **Done well:** one line; it tells the author what to keep.
5. **Verification line:** what you ran and the result, stated plainly.

Every point names a mechanism and a consequence. Drop any point you can't
tie to code you read.

## 3. Choosing the diagram medium

| Situation | Medium |
|---|---|
| Default, terminal session | ASCII box/arrow diagram in a code block |
| More than ~30 lines, many parallel branches, or the user asks for an image | Mermaid → PNG, sent to the user |
| User wants to share with a team, or needs a page | If the Artifact tool is available: an Artifact page with inline SVG (load `artifact-diagramming` and `artifact-design` first). Otherwise, the PNG |

**Rendering Mermaid to PNG** (Node only; no graphviz needed):

```bash
npx -y @mermaid-js/mermaid-cli@11.4.2 -i flow.mmd -o flow.png -b white -s 2
```

Write `flow.mmd` in `$TMP`. Then **Read the PNG to check it renders
legibly**. Deliver it:

- If `SendUserFile` is available, send it with `display: "render"`. If the
  PNG render failed, send the `.mmd` itself the same way; the client renders
  Mermaid inline.
- Otherwise, give the absolute PNG path, and run `open <path>` on macOS.

Still put the
ASCII version (or a short summary) in your text reply, so the answer reads
fine without the image. Use `flowchart TD` for call flow and
`sequenceDiagram` for cross-component message ordering. Colour-code nodes so
the review reads at a glance:

```
classDef new fill:#d4f5d4,stroke:#2e7d32;   %% added by the PR
classDef gap fill:#ffd9d9,stroke:#c62828;   %% path the PR misses / a finding
class startedNode,recordNode new
class noRecordNode gap
```

## Common mistakes

| Mistake | Fix |
|---|---|
| Prose-only summary of the diff | The diagram is required: it's the reason for this skill |
| Restating the PR description's claims ("can't take the app down") | Check each claim at the call site; a wrong claim is a point |
| Generic nits ("add more tests") | Name the uncovered path and what breaks |
| Leaving the `review/pr-<n>` ref or temp worktree behind | Clean up and confirm `git status` is unchanged |
| Saying "can't make images" because graphviz/mmdc is missing | Use the `npx` Mermaid CLI or an Artifact |
