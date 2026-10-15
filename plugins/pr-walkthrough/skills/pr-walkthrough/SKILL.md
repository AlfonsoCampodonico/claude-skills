---
name: pr-walkthrough
description: Use when the user shares a PR link or number and wants it reviewed, walked through, or explained — "review this PR", "how do these changes fit together", "what should I focus on", "show me the flow", "make a diagram of this PR" — especially for large PRs, when they say not to fix or comment, or ask for something visual.
---

# PR walkthrough

A read-only review built for reading a PR comfortably in the terminal, even
a big one. It has three parts:

- a **PR card**;
- a **workflow tree** whose nodes carry markers (①②③) that map to clickable
  `file:line` references;
- **numbered findings**.

The user steers by number: `fix 3`, `explain ②`, `next`.

Read-only until the user says otherwise: no fixes, no GitHub comments, no
checkout of the user's working copy.

## 1. Gather (verify, don't trust the description)

```bash
TMP=$(mktemp -d)   # or the session's scratch/job tmp dir, if it has one
gh pr view <n> --json title,body,author,baseRefName,headRefName,headRefOid,additions,deletions,files,commits,reviews,comments
gh pr diff <n> > "$TMP/pr<n>.diff"      # read it with Read
git fetch -q origin pull/<n>/head:review/pr-<n>
git grep -n "<new function names>" review/pr-<n>    # call sites, with line numbers
git show review/pr-<n>:path/to/file                 # surrounding code
```

- For every new hook or call, open the **call site on the PR head**. Check
  whether it fires on every path the PR claims: success, failure, retry,
  shutdown, early return. Most real findings come from here.
- **Take every line number from the PR head**, using `git grep -n` on
  `review/pr-<n>`, never the base branch or the local checkout. The card
  states the head SHA they refer to.
- If `git fetch` is blocked, download the PR head instead. You still get
  exact line numbers and a tree the tests can run in, and no refs are
  touched:
  ```bash
  mkdir -p "$TMP/head" && gh api "repos/<o>/<r>/tarball/<headSha>" | tar -xz -C "$TMP/head" --strip-components=1
  grep -rn "<new function names>" "$TMP/head"     # line numbers at the head
  ```
  Run the tests inside `$TMP/head`. Never estimate a line number from a
  diff hunk.
- Run the repo's tests in a throwaway worktree:
  `git worktree add "$TMP/pr<n>" review/pr-<n>`. Use race or vet if the repo
  has them. Remove the worktree and the `review/` ref when done.

## 2. Size the PR, then pace the replies

| PR size | Replies |
|---|---|
| Small: ≤ 10 files and ≤ 400 changed lines | Everything in one reply |
| Big: anything larger | **Reply 1:** card, a one-paragraph summary, an **overview tree** with one branch per subsystem, the list of sections, the files table, and **only** the "Worth discussing before merge" findings. Hold nits, docs and "done well" for their sections. **Each later reply:** one section, with its own tree, legend and findings (all groups), sent when the user says `next` or names the section |

Markers and finding numbers **run on across sections**, never restarting, so
`fix 7` is unambiguous for the whole review.

## 3. Output: these parts, in this order

**1. PR card**, as a code block:

```
PR #67  feat: expose process supervision metrics in Prometheus format
by gjreasoner · INFRA-573 · +686 −0 · 9 files · base main (2 releases behind)
head 279103b · go vet ✓ · go test -race 75/75 ✓
```

**2. What and why:** one paragraph in your own words.

**3. Workflow tree**, in the style of section 4. Directly under the code
block, add the **legend**. It goes outside the code block, so the
references are clickable:

① `main.go:105` · ② `internal/stacks/shutdown.go:18` ·
③ `internal/stacks/shutdown.go:96` · ④ `internal/controller/controller.go:541` ·
⑤ `internal/controller/controller.go:373` · ⑥ `main.go:135`

Then give 1–2 lines of concrete observable effect, such as a test assertion
or an output line.

**4. Files changed**, as a table:

| file | ± | role | nodes |
|---|---|---|---|
| `internal/metrics/metrics.go` | +267 | registry + text exposition | — |
| `internal/stacks/shutdown.go` | +10 | start/exit hooks | ② ③ |

**5. Findings**, numbered 1…n, grouped under these headings in this order:
**Worth discussing before merge**, **Correctness nits**, **Docs & process**,
**Done well**. Each finding has this shape:

> **4. Restarts counted before the STOP check** · `internal/controller/controller.go:541` · at ④
> `ProcessRestarted` runs before the goroutine re-checks STOP, so a restart cancelled by shutdown is counted but never launched.

The first line is the claim, the location and the marker. The second line is
mechanism → consequence. Drop any finding you can't tie to code you read.

**6. Verification:** what you ran and the result, stated plainly.

**7. Action footer**, always the last line:

```
→ fix 1,4 · explain ② · next: §2 controller hooks · image
```

## 4. Workflow tree style

````
main.go
 ├─ log proxy start (existing)
 ├─ ① if stack.EnableMetrics:
 │     metrics.NewServer(listen).Start(ctx) ── bind fails → slog.Error, continue
 ├─ ctrl.Start() ───────────────────────────────────────────────────────────────────────────┐
 │                                                                                          │
 │   Process.Run (service only)                                                             │
 │    └─ ② ShutdownHandler.StartProcess ──► ProcessStarted            starts++ running++    │
 │   cmd.Start / cmd.Wait                                                                   │
 │    └─ ③ ShutdownHandler.ShutdownProcess ──► ProcessExited          exits{code,phase}++   │
 │         (every exit, oneshot too, even if LogsDisabled)            last_exit_code/ts     │
 │                                                                    running-- (service)   │
 │   controller loop: proc not running                                                      │
 │    └─ ④ restartProcess ── IncrementAttempts ► ProcessRestarted     restarts++            │
 │          └─ retries exhausted → failedCh                                                 │
 │              └─ ⑤ main loop ──► RetriesExhausted                   exhausted++           │
 │                  └─ transitionToStop ──► Stopping()                stopping=1            │
 │                     (exits after this get phase="stopping")                              │
 │   SIGTERM path ── transitionToStop ──► Stopping()                                        │
 ◄──────────────────────────────────────────────────────────────────────────────────────────┘
 ├─ reaper drain → cancel → ctrl.Done, reaper.Done, logproxy.Done
 └─ ⑥ metricsCancel() → <-metricsServer.Done   (endpoint stays up through drain)
````

The rules that make it read like that:

- **Trunk and branches:** use `├─` `└─` `│`, indented under the caller. Read
  top to bottom in execution order, starting at the real entry point.
- **New code:** use `──►` from the call site to the new hook. The hook's
  effect (counter, log line, state) goes in **one right-hand column**, aligned
  across the whole tree.
- **Long-running spans:** a loop, a lifecycle or a goroutine that the trunk
  waits on gets a box. Start it with `───┐` on the opening row, keep `│` on
  the right edge, and close with `◄───┘` where control returns to the trunk.
- **Side paths stay inline:** `── bind fails → slog.Error, continue`.
- **Markers:** ①–⑳ (then `[21]`, `[22]`…). Put one before every node that the
  legend, a finding or the files table refers to, and on no other node.
- **Alignment:** pad with spaces so the box edge and the effect column line up
  exactly. Keep the tree to 100 columns or less; if it would be wider, split
  it into sections. For a big tree, generate the padding with a short script
  rather than counting by eye.
- **Missing pieces** (a path the PR skips) get a trailing `✗ <what's missing>`,
  and a finding that cites the node.

## 5. Handling the follow-ups

| User says | Do |
|---|---|
| `explain ②` | Show the code at that marker's `file:line` (about ±15 lines on the PR head), then 2–4 sentences on what it does and why it matters |
| `fix 1,4` | Leave read-only mode for just those findings. Follow the repo's branch and PR rules (a separate branch or PR, never the author's branch unless asked). Reference the finding numbers in the commit or PR |
| `next` / `§2` | The next section: its tree, legend and findings, with numbering continued |
| `image` | Render the current tree as Mermaid → PNG (section 6) |

## 6. Image output (on request, or when a tree passes ~40 rows)

```bash
npx -y @mermaid-js/mermaid-cli@11.4.2 -i flow.mmd -o flow.png -b white -s 2
```

- Write `flow.mmd` in `$TMP`. Put the **same markers** in the node labels
  (`"② StartProcess"`) so the image and the legend agree.
- Colour-code the nodes:
  `classDef new fill:#d4f5d4,stroke:#2e7d32` for code the PR adds,
  `classDef gap fill:#ffd9d9,stroke:#c62828` for findings and missed paths.
- Read the PNG to check it's legible before you deliver it.
- **Delivering it:**
  - If `SendUserFile` is available, send it with `display: "render"`. If the
    render failed, send the `.mmd` the same way.
  - Otherwise, give the path, and run `open <path>` on macOS.
- If the user wants a page to share and the Artifact tool exists, build an
  Artifact with an inline SVG instead. Load `artifact-diagramming` and
  `artifact-design` first.

## Common mistakes

| Mistake | Fix |
|---|---|
| Line numbers from the base branch or the local checkout | `git grep -n` on `review/pr-<n>`, and put the head SHA in the card |
| A marker in the tree with no legend entry, or the other way round | Check that every marker appears in both before sending |
| `file:line` only inside the code block, where it isn't clickable | The legend and findings go outside the code block |
| Numbering restarted in section 2 | Keep markers and findings running on across sections |
| A 40-file PR dumped in one reply | Size it (section 2): overview first, then one section per reply |
| Every finding group in reply 1 of a big PR | Reply 1 gets only "Worth discussing before merge"; the rest goes to the sections |
| "Tests not run, fetch blocked" | Use the tarball fallback and run them there |
| Effect column or box edge drifting | Generate the padding with a script |
| Restating the PR description's claims | Check each claim at the call site; a wrong claim is a finding |
| Leaving the `review/pr-<n>` ref or temp worktree behind | Clean up and confirm `git status` is unchanged |
