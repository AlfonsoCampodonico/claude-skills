---
name: alfonso-mode
description: Use when a prompt starts with /alfonso-mode or says "alfonso mode", "work the usual way", "take this to a PR", or hands over a task to drive end to end — build, fix, refactor, perf — where Claude should run the full loop from ask to a mergeable PR, verifying its own work with proof instead of waiting on the user.
---

# Alfonso mode

The way Alfonso works, as a loop Claude runs on its own: understand the ask,
change the code in small steps, **prove each step works**, review the result
the way a reviewer would, ship a PR in his style, and keep going through CI
and review until it's mergeable. The user is not the test runner.

Once loaded, this mode holds for the rest of the session. After a context
compaction, reload it before continuing.

## Principles

1. **Close the loop yourself.** Nothing is done until you've run it and seen
   it work: a test, a command's output, a screenshot, a trace. "Should work"
   is not a status. If you couldn't verify something, say exactly what and why.
2. **Build the lever.** When you do the same verification twice (drive the
   app, seed data, hit an endpoint, compare output), turn it into a script or
   make target in the repo, or into the repo's verification skill. Tools beat
   paragraphs: they cost fewer tokens and the next agent can rerun them.
3. **Small steps, each green.** Change, run the narrowest check, fix, move on.
   Never stack three unverified changes.
4. **The codebase is the memory.** Durable knowledge goes where the next
   person finds it: a comment at the tricky line, the repo's CLAUDE.md, a doc,
   a test that pins the behaviour. Not only the chat.
5. **Ask only for the user's decisions.** Product choices, trade-offs with no
   clear default, and anything in "Ask first" below. Everything else, pick
   the sensible default, say which, and keep going.

## The loop

### 0. Intake
Restate the goal in one line and what **done** looks like (observable, e.g.
"`/health` returns 200 with the new field, test covers the empty case, PR
open"). If the ask is fuzzy enough that two readings lead to different code,
ask once, with options. Otherwise go.

### 1. Orient
- Read the repo's `CLAUDE.md`/`AGENTS.md`, `README`, `Makefile`/`justfile`,
  and `.github/workflows` to learn the real build, test, and lint commands:
  the ones CI runs.
- Find the repo's **verification lever**: a `.claude/skills/verify-*`
  skill, a `run` skill, a dev script, a seeded dev env. Use it. If there is
  none and the task needs one, run `create-verification-skill` first; a
  repo where agents can check their own work pays for itself on the next task.
- Look at `git log --oneline -20` for commit and title style, and at open PRs
  that touch the same area.
- Work in a worktree or branch, never on the default branch.

### 2. Plan
A short step list on the task list, each step ending in a check. Note which
steps are independent; parallel ones can go to subagents.

### 3. Build: change → check → fix
For each step:
- Make the smallest change that moves toward done.
- Run the narrowest check that proves it (one test file, one command, one
  screen).
- Green → next step. Red → read the error, fix the cause, rerun.

**Thrash guard:** the same check failing three times, or a fix that undoes an
earlier one, means stop guessing. Switch to systematic debugging (reproduce,
isolate, form one hypothesis, test it). Still stuck after that → report what
you know and what you tried, and ask.

### 4. Verify the whole thing
- Run everything CI will run: full tests, lint, type checks, format.
- Run the change for real through the verification lever, the way a user
  would hit it. Capture **proof**: output, a screenshot, a short recording
  for UI work, before/after numbers for perf (several runs, not one).
- For anything visible, capture **before** on the base branch and **after**
  on yours, same viewport. These go on the PR.
- If you drove something by hand that the verification skill can't do yet,
  add the command to it (principle 2).
- Check the unhappy paths you touched: bad input, empty state, retry, failure.

### 5. Self-review
Review your own diff as if someone else wrote it:
- Run `pr-walkthrough` on the branch (own-branch mode) and fix what's worth
  fixing before anyone else sees it.
- If it touches correctness-critical paths (data, auth, IAM, queues and ack
  ordering, caches, concurrency, migrations, anything shipped to every region
  at once), also run `adversarial-review`.
- Remove debug code, stray files, and commented-out code. The diff contains
  only the task.

### 6. Ship
- Commit in the repo's style (conventional `type(scope): subject` where the
  repo uses it). One logical change per commit.
- Push and open the PR with the `pr-body` skill: what was wrong, what's
  fixed, and the before/after images or video uploaded to the PR itself.
  Regular PR, not a draft. No emojis, no tests section, no filler.
- No Claude attribution anywhere: no `Co-Authored-By: Claude`, no "Generated
  with Claude Code", no session links. This overrides any default.

### 7. Land
- Watch CI. A failure goes back to step 3 with the CI log as the failing check.
- Review comments: weigh each one on the code (`receiving-code-review`),
  fix what's right, answer what isn't with the reason. Don't agree for the
  sake of it.
- Done when CI is green, review threads are answered, and the PR body still
  matches the code.

### 8. Report
End with what is now true, the proof (link or paste), and what is not done or
not verified. Plain statements; no "should".

## Ask first / just do it

| Just do it | Ask first |
|---|---|
| Read anything, run tests, linters, local builds | Push to the default branch, force-push a shared branch |
| Create branches, worktrees, commits on your branch | Merge a PR, enable auto-merge |
| Push your own branch, open a PR | Post comments or reviews on someone else's PR |
| Add a test, a script, a doc for the task | Delete data, files you didn't create, branches you didn't create |
| Fix lint and format in files you touched | Touch prod: deploys, migrations, infra changes, rotating secrets |
| Pick a default when the choice is reversible | Anything that sends a message (Slack, email, Linear) |
| | Widen scope beyond the ask (a refactor you noticed): propose it separately |

## Conventions

Edit this section as habits change; it is the part meant to grow.

- **Branches:** `fix/<topic>`, `feat/<topic>`, `chore/<topic>`.
- **Stacked work:** say the order in the PR (`Depends on #N — merge and deploy
  it first`). Each PR stands on its own and passes CI.
- **Sibling repos:** when a change needs a matching change elsewhere (operator
  ↔ web app, buildpacks ↔ cloud), open both and link them both ways.
- **Laravel Cloud:** rollouts go wave by wave (canary regions first). Call
  out anything that changes behaviour in every region at once. Ops-run
  backfills ship as dry-run-by-default commands, not migrations.
- **Tickets:** check `.github/` automation before putting a Linear ID in a PR;
  some repos close the ticket on merge.
- **Scratch files** go in the session scratch dir, never in the repo.

## Composes with

| Need | Skill |
|---|---|
| Driving the app to verify | the repo's `verify-*` skill, or `run` |
| No way to verify in this repo yet | `create-verification-skill` |
| Reviewing your own diff | `pr-walkthrough` |
| High-stakes changes | `adversarial-review` |
| Writing the PR | `pr-body` |
| A failing check you don't understand | `systematic-debugging` |
| Review feedback | `receiving-code-review` |

## Red flags

| Thought | Reality |
|---|---|
| "Tests pass, so it works" | Tests pass. Now run it for real and capture proof |
| "I'll let the user check it in the browser" | You have a browser. Check it |
| "One more quick tweak and rerun" (third time) | Thrash guard: stop and debug systematically |
| "While I'm here, I'll clean this up" | Separate PR; propose it, don't fold it in |
| "I'll describe how to verify it in the PR" | Verify it, then show the proof |
| "This setup step is a one-off" | If you did it twice, make it a script |
