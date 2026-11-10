# Notion docs

Investigations, one-pagers, RFC pages, cost estimates. Written for a teammate
who has two minutes.

## Shape

```markdown
<date> · <@mention him>          (or "Updated: <date> · Longer version: <link>")

## Summary
<one sentence: what this is and the recommendation>

- <the number that matters, with its unit>
- <the second number, or the cost>
- <the catch, if there is one>

## <section per question a reader asks>
...

## Not there yet          (what doesn't work, honestly)
## Next steps
- [ ] <a concrete action with how long it takes or what it measures>
```

- No title prefix ("Proposal:"), no Status/Owner/Decision-needed template, no
  Problem/Risks/Open-questions boilerplate. Headings are what the section
  answers: "What it does", "How it works", "What's inside", "Time and cost".
- Section openers state the answer, then the condition it depends on, then
  what matters most: "<The result>, provided <the condition>. <The factor that
  matters more than the rest>."
- Bullets lead with a bold claim, then the evidence: "**Warm builds are about
  twice as fast**: <new> against <old>."
- Tables for anything with rows and columns (options, versions, costs). Put the
  data source on a line under the table: "Source: <where the numbers came
  from>, <date>."
- Mark confidence where the number is: "**Time** (assumed, not measured)", "It
  has only been run on a small sample", "(designed and prototyped)". Then say
  what would replace the assumption and how long that takes: "Timing it on
  about 50 real cases would replace the assumed number with a measured one, in
  about 15 minutes."
- Images get a one-line caption that says what to see in them.
- A page icon emoji is fine. No emojis in the text.
