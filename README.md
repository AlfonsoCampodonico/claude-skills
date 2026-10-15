# claude-skills

Claude Code skills, packaged as a plugin marketplace.

## Install

You need read access to this repo and `gh` (or git over SSH) authenticated.
In Claude Code:

```
/plugin marketplace add AlfonsoCampodonico/claude-skills
/plugin install pr-walkthrough@alfonso-skills
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

Requirements: `gh`, `git`, and Node (`npx`) for images.

## Adding a skill

1. Create `plugins/<name>/.claude-plugin/plugin.json` and
   `plugins/<name>/skills/<name>/SKILL.md`.
2. Add an entry to `.claude-plugin/marketplace.json`.
3. Run `claude plugin validate .` before pushing.
