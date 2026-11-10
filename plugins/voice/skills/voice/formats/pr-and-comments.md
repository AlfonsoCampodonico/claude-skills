# PR bodies, comments and messages

## PR bodies

**REQUIRED:** use the `pr-body` skill for structure (what was wrong, what's
fixed, before/after) and its rules. This voice applies to the sentences inside.

## Closing and superseding a PR

One or two sentences: the verdict, then the reason with the evidence.

> Superseded: main was rewritten with these replacements applied across its
> history.

> Closing: <what was tried> doesn't <do what it was for> (<the evidence>).
> Replaced by #<n>, which <does it another way>.

> Duplicate of #<n>, which <does the same thing>; the only difference is <the
> one detail>. Closing in favour of #<n>.

## Merge and coordination notes

Start with what the reader must do. Name the files, lines and the exact change,
then what was checked.

> Merge note: this PR and #<n> compile on their own but not together. #<n>
> changes `<the signature>`, and `<file>` calls the old form twice. Whichever
> merges second should <the exact change> there.

## Review comments

Short, concrete, no praise padding. The problem, the case that breaks it, and
the fix if it's obvious. A question when he isn't sure. `pr-walkthrough` has
the full rules for drafting them.

## Slack and quick replies

One to three sentences. Lowercase is fine for a quick reply, but keep full
sentences. No headings, no bullets unless it's a list of three or more things.
