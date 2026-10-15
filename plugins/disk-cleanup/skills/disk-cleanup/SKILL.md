---
name: disk-cleanup
description: Use when the user wants to free disk space, says the disk is full, or asks to clean up unused things — Rust target/ dirs or cargo caches, Claude conversations or background-job scratch, merged or stale git worktrees.
---

# Disk cleanup

Survey, show a table, get approval, then delete bucket by bucket with a
safety filter on each. Never delete before the user picks buckets.

Use `$CLAUDE_JOB_DIR/tmp` (or a mktemp dir) for scratch files. Report free
space (`df -h /`) before and after each bucket.

## 1. Survey (read-only)

Run these in parallel:

```bash
df -h / | tail -1
du -sh ~/.cargo ~/.rustup ~/.claude/projects ~/.claude/jobs 2>/dev/null
# Rust target dirs: only those next to a Cargo.toml
find ~/Github ~/Projects ~/.codex ~/.cursor -type d -name target -prune 2>/dev/null |
  while read d; do [ -f "$(dirname "$d")/Cargo.toml" ] && du -sh "$d"; done | sort -hr
# Repos with extra worktrees
find ~/Github -maxdepth 4 -name .git -type d | while read g; do r=$(dirname "$g");
  n=$(git -C "$r" worktree list | wc -l); [ "$n" -gt 1 ] && echo "$r $n"; done
```

`~/.claude/jobs/<id>/tmp` is usually the biggest surprise: finished
background jobs leave full repo copies and build outputs there (one job held
59 GB). Read each job's `state.json`: the `state` field says whether it is
`done`, `working`, `blocked`, `stopped`, or `failed`.

Classify worktrees with `scripts/classify-worktrees.sh <repo>`. Run it for
every repo at once (`&`, then `wait`). It uses `gh` to match squash-merged PRs,
which `git branch --merged` misses.

Present one table: bucket, size, what it covers, and any risky items called
out. Then ask with AskUserQuestion (multiSelect) which buckets to run.

## 2. Buckets and their safety filters

### Finished-job scratch
- Only jobs whose `state.json` has `state == "done"`. Skip the current job
  (`$CLAUDE_JOB_DIR`) and every other state.
- Delete only the `tmp/` contents (`rm -rf tmp && mkdir tmp`). Keep
  `state.json` and `timeline.jsonl` so the jobs list still works.
- envtest/Go caches are read-only: if `rm` fails, `chmod -R u+w tmp`
  first.

### Merged worktrees
Remove only `MERGED_PR` / `MERGED_ANCESTOR` worktrees (plus `git worktree
prune` for `PRUNABLE`) that also pass all of these:
- **No modified tracked files** (no `+DIRTY`).
- **No meaningful untracked files.** Check `git status --porcelain`
  for `??` lines. Build/tool dirs like `.make/` are fine. Notes, images, new
  test dirs, or `PR-NOTES.md` mean keep it and list it for the user.
- **Not a meta-repo with nested repos.** If the worktree contains untracked
  directories that are themselves git repos (e.g. a workspace repo whose
  subprojects are separate repos), "ancestor of main" says nothing about the
  nested work. Never remove these; only clean their `target/` dirs.
- **Not locked by a live session.** `git worktree remove` refuses locked
  worktrees and the lock reason names a pid. Unlock and remove only if
  `ps -p <pid>` shows it dead. Leave live ones alone.

For removal, use `git -C <wt> worktree remove --force <wt>`. Go module caches
inside worktrees are read-only, so the removal can fail **after** git has
already dropped its metadata, leaving an orphan dir whose `.git` file points
at a missing `gitdir`. Handle it by running `chmod -R u+w <wt>` before
removing. For orphans, confirm the `gitdir:` target no longer exists, then
`rm -rf` the directory. Run `git worktree prune` in each repo afterwards.

Don't delete local branches unless the user asks; they cost nothing.

### Rust `target/` dirs and cargo caches
- Only `target/` dirs whose parent has a `Cargo.toml`.
- Skip dirs in use: check `ps aux | grep -E 'cargo|rustc|nodemon'` for live
  `cargo run`/watch processes and skip their project's `target/`. Also skip
  worktrees locked by live sessions.
- `chmod -R u+w` before `rm -rf` (some build outputs are read-only).
- Cargo caches can be regenerated: `~/.cargo/registry/cache`,
  `~/.cargo/registry/src` and `~/.cargo/git/checkouts`. Leave `~/.rustup`
  (toolchains) unless asked.

### Old Claude conversations
- Delete `~/.claude/projects/*/*.jsonl` older than N days (default 30)
  and their matching `<session-uuid>/` sidecar dirs.
- **Never touch `~/.claude/projects/*/memory/`.**
- Project dir names start with `-` (e.g. `-Users-alice-Github-foo`), so
  use `--` or `./` prefixes with `basename`, `ls`, and `rm`, or work from
  `find` output.

## 3. Report

Give a final table with the GB freed per bucket and free space before → after.
Then list what was deliberately kept and why (dirty, untracked notes, live
lock, nested repos, running dev server), so the user can decide on those by
hand.
