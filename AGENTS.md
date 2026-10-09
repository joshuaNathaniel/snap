# AGENTS.md

<!-- axx:begin (managed by `axx init`; edit outside this block) -->
## Acceptance tests (axx)
axx (github.com/nimbusxr/axx, "axxeptance") is a human-readable acceptance testing framework.
- Writing tests: `axx steps` lists every step, a line each (read it once; `axx steps show <id>` gives one
  step's documentation); write one scenario per acceptance criterion with those steps, never
  invented ones; `axx up` once, then `axx run --compact`, which also reports what validate and lint find;
  `axx down` when done.
- Use the axx MCP tools when you have them: `steps_search` without a query is the step list, then
  `scenarios_run` (it reports what `feature_validate` and `lint_run` find) and `failure_context`.
- If `.agents/skills` has the axx skills, they teach the details: axx-acceptance-tests, axx-test-data
  (fixture factories), axx-debugging. `axx skills install` installs or updates them.
- Feature files are acceptance criteria a person can read, in plain language, with the steps as
  written. No programming constructs in Gherkin.
- Every scenario uses unique data (ids, names, keys): scenarios run in parallel and data persists.
- Check what the service did (a response property, a row, an event) and why it refused, not only
  status codes.
- Steps come from the packs in `axx-packs.yaml` (`axx pack list`, `axx pack add <name>`). Configuration is in
  `axx.yaml` (`axx schema --outline` lists its keys); features in `features/`.
- Repeating payloads, seeds or mock bodies: fixture factories generate them (`axx fixtures`;
  optional, strongly recommended where data repeats); `axx fixtures adopt` turns hand-written ones into one.
<!-- axx:end -->
