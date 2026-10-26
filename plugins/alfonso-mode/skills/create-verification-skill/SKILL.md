---
name: create-verification-skill
description: Use when a repo has no way for an agent to run and check its own changes, when the user says "make a verification skill", "let agents verify their work here", "set up a control CLI for this app", or "maintain the verification skill" — and when alfonso-mode finds no verification lever in the repo.
---

# Create (or maintain) a verification skill

A verification skill lets any agent in this repo prove its change works
without a human: start the app, drive it, look at it, measure it. It is two
things checked into the repo:

1. **A control CLI**: a small script with subcommands that do the driving.
   Tools, not paragraphs: one command instead of a throwaway script each time.
2. **A feature map**: markdown listing every feature, how a user gets to it,
   and which CLI commands drive it.

The SKILL.md that ties them together lives at
`.claude/skills/verify-<app>/SKILL.md`, so every agent in the repo gets it.

Modes: **create** (none exists) and **maintain** (one exists; bring it up to
date with the code). Pick by checking for `.claude/skills/verify-*`.

## 1. Survey the runtime

Work out what the app is and what can drive it:

| App | Lever |
|---|---|
| Web app / Electron | Chrome DevTools Protocol via Playwright or Puppeteer |
| HTTP API | `curl`/an HTTP client against a local server, with seeded data |
| CLI / TUI | run it with fixtures; for a TUI, a pty (`expect`, `node-pty`) |
| iOS / Android | the simulator or emulator tooling |
| Library | a small example harness that exercises the public API |

Also find: how to install and start the dev env in one step, how to seed a
dev database, how test users and auth work, which external calls need a
test or local double. Missing pieces get built as part of this, smallest first.

## 2. Build the control CLI

`.claude/skills/verify-<app>/control.<ext>`, in the repo's main language
(or Node for anything browser-driven). Start with:

| Group | Commands |
|---|---|
| Health | `doctor` (is everything needed installed and running? says how to fix what isn't), `up`, `down`, `cleanup` |
| Data | `seed`, `reset`, `login <test-user>` |
| Inspect | `snapshot` (accessibility tree or structured state), `screenshot <path>`, `logs` |
| Drive | `open <route>`, `click`, `type`, `press`, `request <method> <path>` |
| Wait | `wait-settle` (network idle, no pending renders or jobs) |
| Measure | `trace`, `perf` (only when the app has perf-sensitive paths) |
| Record | `record <path>` (video or GIF of a flow, for PR proof) |

Make it agent friendly:

- subcommands with rich `--help`, so it discloses itself gradually;
- JSON output by default (`--human` for people);
- errors that say what to do next ("server not running: run `control up`");
- `--dry-run` on anything with side effects;
- composable and deep: a few powerful commands rather than many shallow ones;
- idempotent `up`/`seed`, so reruns are safe.

Test the CLI itself: every subcommand runs once against the real app before
you call it done.

## 3. Build the feature map

`.claude/skills/verify-<app>/references/features/README.md` is the map: one
line per major feature with a link to its file. Walk the app (routes, nav,
commands, endpoints) to build it; don't write it from memory. Each feature
file:

````markdown
# <Feature>

<One line: what it is.>

## Sub-features
- <name>: <what it does>

## How to get there (user's view)
<Clicks, keys, or the request a user makes.>

## Driving it
```bash
<control commands that reach and exercise it>
```

## Gotchas
- <state it needs, flags, flaky timing, things that look broken but aren't>
````

## 4. Write the SKILL.md

Short. Frontmatter description triggers on "verify", "check it works",
"reproduce", "screenshot", "is this fixed". Body: how to bring the app up,
the CLI's command groups (point at `--help` for details), a link to the
feature map, and how to produce proof for a PR (before/after screenshots or a
`record`ed flow). Add a line to the repo's `CLAUDE.md` pointing at it.

## 5. Prove it

Use it for one real check: reproduce a known bug or verify a recent change,
end to end, with the CLI only. Anything you had to do by hand becomes a
command.

## Maintain mode

Run it on a schedule or after big merges:

1. `doctor`, then every subcommand once. Fix what broke.
2. Diff the feature map against the app (new routes, removed screens, renamed
   commands, changed flows). Add, update, and delete entries.
3. Look at recent agent sessions or PRs for steps agents did by hand more
   than once. Turn them into commands.
4. Open a PR with the changes (`pr-body`).

## Common mistakes

| Mistake | Fix |
|---|---|
| A long markdown guide and no CLI | Build the commands; the markdown points at them |
| Human-formatted output only | JSON by default |
| "Error: failed" | Say what failed and the command that fixes it |
| Feature map written from memory | Walk the running app and the routes |
| CLI never run end to end | Section 5 before calling it done |
