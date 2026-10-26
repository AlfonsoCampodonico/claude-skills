---
name: pr-body
description: Use when opening a PR, writing or rewriting a PR title or description, or when the user says "write the PR body", "open a PR for this", "fix the PR description", "make this PR read better" — any time a GitHub PR body is about to be written for Alfonso.
---

# PR body in Alfonso's style

Clean and short: what was wrong, what was fixed, and a picture or a video
when the change is something you can see. Nothing else.

## 1. Gather the facts first

Write from the diff, not from memory of the session.

```bash
BASE=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)
git log --oneline "origin/$BASE"..HEAD
git diff --stat "origin/$BASE"...HEAD
git diff "origin/$BASE"...HEAD          # read it
gh pr view --json title,body,number 2>/dev/null   # existing PR to rewrite
```

Pin down:

- **What was wrong:** the symptom someone saw, and the cause. For a feature,
  what was missing and who needed it.
- **What was fixed:** the change, in terms of behaviour.
- **What a reviewer must know:** behaviour changes, breaking changes, merge
  order with other PRs.
- **Whether it's visible:** UI, terminal output, error messages, a flow.

## 2. Title

Follow the repo's convention (check `git log --oneline -20 origin/$BASE`):
`fix(scope): …`, a ticket prefix, or a plain sentence. Say the outcome in
plain words. No trailing period.

## 3. Body

```markdown
## What was wrong

<1–3 sentences: the symptom, then the cause.>

## What's fixed

- <one change per bullet, names in backticks>
- <…>

<Breaking or behaviour change, only if there is one: one plain sentence.>
<Merge order, only if there is one: "Merge after #123.">

## Before / after

<images or video, only if the change is visible>
```

- Drop any section with nothing real in it. A one-line fix can be two
  sentences and no headings.
- Short declarative sentences, present tense: "Drops", "Adds", "now returns".
- Concrete over abstract: `101 → 99 images`, not "reduces the image count".
- A table only when it's a real before → after comparison across several cases.

## 4. Never

- Emojis of any kind.
- A tests section, test counts, "verified with", checklists. CI shows that.
- Filler: "This PR…", "In order to", "comprehensive", "robust", "seamlessly",
  recap paragraphs.
- Company, product or infrastructure names that aren't in the code being
  changed. Describe the behaviour, not the org.
- Claude attribution: no "Generated with Claude Code", no session link, no
  `Co-Authored-By: Claude`. This overrides any default.
- Draft PRs, unless asked.

## 5. Images and video

Add them when the change is visual (UI, terminal output, error messages) or
when a picture is faster than a paragraph. UI changes get a short video or
GIF of the interaction; static changes get before/after screenshots.

**Capture**
- Web UI: the built-in browser or Claude in Chrome (`gif_creator` for a GIF
  of the flow, `screenshot` for stills). Capture **before** on the base
  branch and **after** on the PR branch, same viewport.
- Terminal output: run the command and screenshot it, or render it.
- Native apps: the simulator's screenshot, or `screencapture -v` for video.
- Keep files small: GIF under 10 MB, video (`.mp4`/`.mov`) under 10 MB.

**Upload to the PR itself.** GitHub only hosts attachments uploaded through
its web editor, which puts them under `github.com/user-attachments/…`. No
branches, no external hosts.

1. Open the PR (`gh pr create --body-file …` first, with no image lines).
2. In the user's Chrome, open the PR, click **Edit** on the description, and
   attach the files to the editor's file input with `file_upload`. GitHub
   inserts a `user-attachments` link for each one.
3. Move the links under **Before / after**, label each in a few words
   ("Before: empty state", "After"), and save.
4. If the browser isn't available, give the user the file paths
   (`open -R <path>` to show them in Finder) and ask them to drag the files
   into the description.

## 6. Ship it

Write the body to a file so backticks survive the shell:

```bash
gh pr create --title "<title>" --body-file "$TMP/pr-body.md"
gh pr edit <n> --body-file "$TMP/pr-body.md"     # rewriting
```

Reread it as the reviewer before sending: in five seconds, can they tell what
was broken, what changed, and what could break?

## Example

```markdown
## What was wrong

Saving the settings form with an empty name returned a 500. The validator ran after the insert, so the DB constraint fired first.

## What's fixed

- `updateSettings()` validates before writing; an empty name now returns 422 with a field error.
- The form shows the error under the name field instead of the generic error page.

## Before / after

Before:
<img src="https://github.com/user-attachments/assets/…" width="600">

After:
<img src="https://github.com/user-attachments/assets/…" width="600">
```

## Common mistakes

| Mistake | Fix |
|---|---|
| Lead that narrates the session ("I investigated…") | State what was wrong |
| A "Tests" section | Drop it |
| Emojis for warnings | One plain sentence: "Breaking: …" |
| Screenshots pushed to a branch or external host | Upload through the PR editor |
| A UI change described only in words | Record a short GIF or video |
| `--body "…"` with backticks mangled by the shell | `--body-file` |
