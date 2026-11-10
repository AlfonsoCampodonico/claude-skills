---
name: voice
description: Use when writing or rewriting anything that goes out under Alfonso's name or for him to publish - a blog post, a recipe, a Notion doc or one-pager, a PR body, a review or closing comment, a Slack message, a talk outline - or when he says "in my voice", "sound like me", "make this read like me", "less AI".
---

# Writing in Alfonso's voice

He writes the way he explains things to a colleague: the point first, in plain
words, with real numbers, and nothing that isn't doing work. He has opinions and
says them as his own. He is exact about what he has measured and what he hasn't.

Pick the format file, then write with the rules below:

| Writing | Read |
|---|---|
| Blog post, essay, opinion piece | `formats/blog.md` |
| Recipe | `formats/recipe.md` |
| Notion doc, one-pager, RFC, investigation | `formats/notion.md` |
| PR body, review comment, closing comment, Slack | `formats/pr-and-comments.md` |

`samples.md` has his own writing, one excerpt per register. Read the one closest
to what you're writing before you draft.

## The voice

- **Lead with the answer.** The first paragraph says what this is and where it
  lands. "The short version: …" is his move when a piece is long.
- **Short declarative sentences, plain words.** "Writing code got cheap." One idea
  per sentence. Contractions are fine.
- **Concrete over abstract.** Numbers with units, names in backticks, the actual
  error, the actual command: "A 300-token answer at 30 ms per token takes 9
  seconds.", "17 virtio devices on x86_64, 92 on aarch64".
- **First person when it's his view.** "So the short answer from me: yes." "I
  wanted neither root nor a weaker bar." Not "one might argue".
- **Status words are exact.** Measured, estimated, assumed, prototyped, designed,
  in review, only run on a dev sample. Write the one that's true, next to the
  claim it qualifies: "(assumed, not measured)".
- **A colon carries the payoff.** "Let the bottom catch a little before you stir:
  that's flavour." Commas, colons, parentheses and full stops. No em dashes.
- **Explain why in one clause.** "Rest it 30 minutes. This is what lets it roll
  out without fighting back."
- **Give credit, link the source.** Primary sources (docs, papers, the original
  post). "Make this case better than I can." "Which I stole from the Zen of Python."
- **Dry, occasional humour**, from the material, not bolted on. One aside, not a
  string of quips.
- **End on the point, not a summary.** A short line that lands: "Slop is the
  default. Taste is how you see past it." Or just stop.
- **British spelling** in prose (flavour, colour, sanitised, favour), **metric
  units** and °C.

## Never

- Invent anecdotes, family history, places, dates, numbers about his life or
  work, or who said what. If the piece needs one, write `[ANECDOTE: …?]` and list
  it for him to fill in.
- Signposts: "In this post", "Below:", "Let's dive in", "It's worth noting", "In today's …",
  "Here's the thing", recap paragraphs, a closing "In summary".
- Words: delve, robust, seamless, leverage, comprehensive, crucial, game-changer,
  unlock, elevate, landscape, journey, tapestry.
- Setups that announce a reveal ("Here's what I kept seeing.", "That
  contradiction finally got loud enough.") or "It's not X, it's Y" pivots.
- Emojis in text. (A Notion page icon is fine.)
- Exclamation marks, except inside code or a quote.
- Company, product or infra names that aren't already in the material.

## Casual register

Only when he asks for it (a shitpost, a remix, "write it like spite driven
development"): all lowercase, dropped apostrophes ("its", "dont", "thats"), no
full stop at the end of a paragraph, numbered lists of short beats, goals and
non-goals as jokes. See the casual sample. Never use this register unasked, and
don't add typos to the normal register.

## Spanish

He also writes in Spanish (Venezuelan, teaches in it). Same rules: tuteo, plain
words, no anglicisms where a common Spanish word exists, technical terms stay in
English when that's what engineers say ("pod", "deploy").

## Before you hand it over

1. Reread the first paragraph: does it say the point?
2. Delete every sentence that restates the one before it.
3. Search the draft for the Never list, `—` and `!`.
4. Check every number, link and status word is true. If you couldn't check one,
   say so in your reply.
5. List every `[ANECDOTE: …]` and opinion you drafted for him to confirm.
