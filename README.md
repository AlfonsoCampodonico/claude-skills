# claude-skills

Claude Code skills, packaged as a plugin marketplace.

## Install

You need read access to this repo and `gh` (or git over SSH) authenticated.
In Claude Code:

```
/plugin marketplace add AlfonsoCampodonico/claude-skills
/plugin install pr-walkthrough@alfonso-skills
/plugin install pr-body@alfonso-skills
/plugin install alfonso-mode@alfonso-skills
```

Update later with `/plugin marketplace update alfonso-skills`.

## Plugins

### pr-walkthrough

A read-only PR review built around a **workflow diagram** of how the change
moves through the code, followed by **ranked points to consider**: worth
discussing before merge, correctness nits with `file:line`, docs and process,
and what was done well. It checks claims at the real call sites on the PR
head, and runs the tests in a throwaway worktree.

```
/pr-walkthrough https://github.com/org/repo/pull/123
/pr-walkthrough 123 with an image
```

You get:

- a **PR card**;
- a **box-drawn workflow tree** whose nodes carry markers (①②③), with a
  legend of clickable `file:line` references at the PR head;
- **numbered findings**.

Steer it by number:

```
→ fix 1,4 · explain ② · next: §2 controller hooks · image
```

Big PRs (more than 10 files or 400 lines) come in sections. The first reply is
an overview plus the issues worth discussing before merge, and `next` walks
through the rest. Numbering runs on across sections, so `fix 7` always means
the same finding.

`image` renders the tree as a Mermaid PNG via `npx @mermaid-js/mermaid-cli`,
which needs only Node. Green nodes mark new code and red marks gaps.

Reviewing again after the author pushes:

```
/pr-walkthrough 123 rereview
```

lists your earlier findings and threads as addressed / partly / not, then new
findings only. `comment 1,4` drafts review comments in your voice; `post 1,4`
leaves them as a pending review for you to submit. Every review also has a
reading-order files table, a claims check against the description, and a
one-line verdict.

Requirements: `gh`, `git`, and Node (`npx`) for images.

### pr-body

Writes or rewrites a PR title and body: what was wrong, what's fixed, and
before/after screenshots or a short video when the change is visible. Images
are uploaded to the PR itself through GitHub's editor. No emojis, no tests
section, no filler, no Claude attribution.

```
open a PR for this
/pr-body rewrite the description of #42
```

### alfonso-mode

Start a prompt with `/alfonso-mode` and Claude runs the whole loop: orient
on the repo's real CI commands, plan, change in small steps that each pass a
check, verify the result for real with proof, self-review with
`pr-walkthrough` (and `adversarial-review` for risky paths), open the PR with
`pr-body`, then work through CI and review until it's mergeable. It includes
a thrash guard, an ask-first / just-do-it table, and a Conventions section
meant to be edited as habits change.

```
/alfonso-mode fix the flaky ECR prune test and open a PR
```

`/create-verification-skill` (also in this plugin) gives a repo a way for
agents to check their own work: a control CLI under `.claude/skills/verify-<app>/`
(doctor, seed, drive, snapshot, screenshot, record; JSON output, `--dry-run`,
errors that say what to do) and a feature map of every feature and how to
reach it. Run it again in maintain mode to keep both in step with the code.
alfonso-mode calls it when a repo has no way to verify.

Inspired by [@poteto's pstack](https://x.com/poteto/article/2094457600259842065):
verification first, and "build the lever" (turn repeated checks into scripts).

## Adding a skill

1. Create `plugins/<name>/.claude-plugin/plugin.json` and
   `plugins/<name>/skills/<name>/SKILL.md`.
2. Add an entry to `.claude-plugin/marketplace.json`.
3. Run `claude plugin validate .` before pushing.
