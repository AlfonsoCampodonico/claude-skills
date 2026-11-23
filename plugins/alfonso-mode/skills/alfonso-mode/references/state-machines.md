# State machines

Loaded from alfonso-mode when the code being touched moves something through
a lifecycle. `<skill dir>` below is the alfonso-mode skill folder (the parent
of this file's folder).

Code that moves something through a lifecycle (a deployment, a job, an
order, a provisioning request, a UI fetch) is a state machine whether or not
anyone wrote it as one. When it's implicit, every caller re-derives the
current state its own way, and bugs hide in the combinations nobody listed.

**Signals of an implicit one:**
- a `status`/`state`/`phase` string or enum column, matched with `if`/`switch`
  in more than one file;
- clusters of booleans (`isLoading`, `isError`, `hasFetched`, `is_ready`,
  `is_provisioning`) where only some combinations make sense;
- nullable timestamps standing in for phases (`started_at`, `finished_at`,
  `failed_at`, `cancelled_at`);
- retry counters, `attempts`, "pending" queues, reconcile loops, webhooks
  that set a field and hope;
- `// should never happen` branches, and guards like `if (x && !y && z)`.

**What to do with it:**
1. **Map it from the code, not memory:** every state, every transition, who
   triggers each (user action, job, webhook, timer), and where it's written.
   `grep` every write to the field.
2. **Write the rules** the person who owns the behaviour would agree to, in
   their words: "a paid order is never charged again", "a deleted
   environment has no running instances". If the code has no field that
   lets you check a rule, that's a finding. Never soften a rule so the
   current code passes it.
3. **Name the end states.** A state with no way out is either a correct end
   (`paid`, `failed`, `deleted`) or a stuck bug. Say which, for each.
4. **Draw it** as a Mermaid `stateDiagram-v2`, labelled for the reader:
   states as what they see or care about ("Provisioning", "Lease held,
   write pending"), arrows as what happens ("the user cancels", "the health
   check fails [after 3 tries]"). No variable names, function names or enum
   constants in labels. Keep it to about 20 arrows: merge states that act the
   same and drop arrows that repeat others, but never merge two states that
   break different rules, and keep every state on a bug path.
   **Render every chart with pele**, the same way every time:
   ```bash
   node <skill dir>/scripts/render-diagram.mjs "$TMP/states.mmd" "$TMP/states"
   # → states.svg (states link to the code) and states.png
   ```
   - Give each state a `click` line to the code that writes it, pinned to a
     SHA: `click Deleting href "https://github.com/<o>/<r>/blob/<sha>/app/Jobs/DeleteEnvironment.php#L42"`.
   - Mark states on a bug path: `classDef breaks fill:#ffd9d9,stroke:#c62828`
     and `class Deleting breaks`. States your change adds:
     `classDef new fill:#d4f5d4,stroke:#2e7d32`.
   - Read the PNG before delivering it. Send it with `SendUserFile`
     (`display: "render"`) when available, otherwise link the file under the
     Mermaid text. On the PR, upload the PNG through the editor (`pr-body`)
     and keep the Mermaid source in a collapsed `<details>`.
   - If the render fails, say so in one line; the Mermaid text still carries
     the chart.
5. **Show each bug as a path:** the shortest sequence of steps from a start
   state to the state that breaks a rule (stuck state, illegal combination,
   transition written in two places with different rules). Mark that state
   on the chart.
6. **Replay each path against the real code**, one test step per arrow,
   usually as an E2E test. If the bug doesn't reproduce, assume the map is
   wrong until you show it isn't. The reproduced path becomes the failing
   test for the fix.
7. **When your change adds a state or a transition**, add it to the map
   first, then check every reader of the field handles it.
8. **When cleaning up is in scope:** one enum for the states, one place that
   performs transitions and rejects illegal ones, data that only exists in
   the states that need it (a discriminated union, not optional fields).
   Readers ask the machine; they don't re-derive state from flags.
9. **When it's out of scope:** write the map down anyway (comment at the
   field, or the PR) and propose the cleanup separately.

For a machine with concurrency (two workers, a webhook racing a job, retries
across a queue) where drawing it by hand isn't enough, model-check it: write a small
TLA+ spec in the scratch dir with each rule as an invariant, run TLC, and
take its counterexamples as the bug paths.

**Hand-off** (in the explanation or the PR): the chart, one line per bug
(the rule, in the reader's words, and the path), and what the map leaves
out.

The transition table is the best unit test target in the codebase: pure,
many cases, cheap to run.
