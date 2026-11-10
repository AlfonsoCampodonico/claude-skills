# Blog posts

If you're in his blog repo, its `new-post` skill owns front matter, figures and
checks. This file is only the writing.

## Front matter that's writing

- **title:** a question or a plain claim. "Why is my pod Pending?", "Slop, taste,
  and principles", "Should you study software engineering?"
- **excerpt:** one sentence, the hook, not a summary. "Agents write the code now.
  The degree was never really about the code."

## Opinion posts (500 to 800 words)

Shape:

1. `## The question` (or the topic as one word: `## Slop`). State it in one or
   two sentences, then answer it straight away from him: "So the short answer
   from me, someone who teaches it and works in it: yes."
2. Two or three sections that turn the idea over, with headings that are short
   phrases in a pair or a set: "What got cheap" / "What didn't", or "Slop" /
   "Taste" / "Principles".
3. The case against his own view, as its own section: "When I'd say no".
4. A close of one to three short lines that lands the point. A link to another of
   his posts is fine if it fits ("something to be mad about").

He states opinions as his, gives the strongest version of the other side, and
names where the idea came from.

## Technical posts (1,200 to 1,700 words)

Shape:

1. `## Why <follow one X / build your own>`: one paragraph on what the post
   follows and why it's worth it, then "The short version: …" in one or two
   sentences.
2. `## How it works, in one minute`: five numbered steps with a bold lead each,
   then an everyday analogy in two sentences ("It's like a host seating a
   party…").
3. `## The deep dive`: the real mechanism, one concrete example followed all the
   way (a named pod, a real command). Code blocks short and real. Tables for
   comparisons ("The differences that bit me").
4. `## What's next` (bullets, bold lead) and/or `## What I learned` (two bullets,
   bold lead, one sentence each).
5. Footnotes (`[^versions]`) for asides, version caveats and vendor lists.

## Example opening

```markdown
## Why build your own

A sandbox makes one promise: code you don't trust runs, and nothing it does
reaches anything you care about. You can rent that from a dozen vendors today.
I wanted to know what it takes to keep that promise myself, so I built one from
the bottom up.
```

Not:

```markdown
Every semester I stand in front of a room of undergraduates and explain… Then I
go back to my day job… That contradiction finally got loud enough to deal with.
```

(Invented scene, setup-and-reveal, and the point arrives in paragraph three.)
