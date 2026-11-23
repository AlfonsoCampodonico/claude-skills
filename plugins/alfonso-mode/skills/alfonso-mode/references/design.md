# Design, then plan

Loaded from alfonso-mode at step 2 when the change needs more than a step list.

Match the design effort to the change. Most changes need none:

| Change | Design work |
|---|---|
| Small and contained | None. A step list is enough |
| Crosses module or service boundaries, moves ownership, adds an API | Sketch 2–3 designs, each starting from how callers use it, then types and boundaries. Pick one with the trade-off that decided it |
| An open question you could answer by running something | A throwaway prototype in the scratch dir, not a debate. Several variants, driven and captured (screenshots, timings) so the choice rests on evidence |
| Shared code other code will use (package, API, CLI, chart values) | Write the README or usage example first, from the caller's side. It becomes the target you check the implementation against |
| Expensive to reverse (data model, wire format, cache keys, infra topology) | Competing sketches from separate subagents (`model-router:architect`), then pick a base and take the best ideas from the rest. Show the user before building |
| Spans several PRs | A written plan, after the design settles: one section per PR, each ending in its own proof that it works (passing tests alone don't count) |

- **Plans come last.** Settle open questions with prototypes, then write the
  plan. Don't send a plan with no code behind it to adversarial review; it
  invents risks that won't happen. Review the diff instead.
- **The design isn't sacred.** If the implementation keeps needing the same
  workaround in unrelated places, or only compiles with `any` or forced casts,
  the design is wrong. Scrap it and redesign instead of patching around it.
- **Migrations:** state the bar up front, e.g. "output matches the old
  version exactly, bugs included", so the migration doesn't quietly fix
  things and make old and new impossible to compare.
