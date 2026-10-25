# Experiment protocol

One typical QA task — **add negative API tests for `POST /api/v2/bookings` validation** — given to
an AI coding agent under controlled conditions.

## The questions

| # | Question | Compare | Main evidence |
|---|---|---|---|
| Q1 | Does **persistent context** improve adherence to the existing test framework? | main: `no-context` vs `persistent` | Rubric 3–4, static checks (raw HTTP, hand-written payloads, wrong imports) |
| Q2 | Do **structured task instructions** improve requirement coverage? | main: `persistent` vs `full` | Required cases present (8), rubric 5 |
| Q3 | Does **explicit validation guidance** help produce tests that detect real defects? | main: all three | Injected bugs caught (0–3) |
| Q4 | With **requirements missing**, does persistent context make the agent ask instead of invent? | missing-requirements: `no-context` vs `persistent` | Asked for rules? Invented rules? |

## What we can and can't claim

| Comparison | What it measures | Don't claim |
|---|---|---|
| No context vs. persistent | Value of shared project context | That it improves requirement coverage — both get the same ticket |
| Persistent vs. full | Additional value of the task file as a whole | That task *structure alone* helps — the task file also adds explicit content (case table, validation steps) |
| All three | Framework adherence, required-case coverage, defect detection | A ranking beyond these measures |
| Missing-requirements scenario | Whether the agent avoids inventing rules | Anything about coverage or framework use |

Small samples show direction, not statistics: one agent, one model, one task, a few runs.

**Scoring isn't blind.** Whoever prepares the runs knows which run is which, so the rubric scores can
be influenced by expectations. The automated metrics (type check, tests vs. the correct service,
bugs caught, static checks) don't depend on that. Say so in the write-up. An optional second scorer
(e.g. another AI session) gets, for every run alike: the run ID, `agent.diff`, the ticket, the rubric,
`.ai/framework-guide.md` and the reference tests — never `run.meta`, the condition or the run's
context files.

**First result vs. final state.** The rubric, required cases and bugs caught score the agent's
**first** result (`agent.diff`, from `check-run.sh` before any correction). The corrections are
counted from the transcript. The archived `workspace/` shows the final state after corrections.
Never mix the two in one number.

## Scenarios and conditions

**Main scenario — same requirements everywhere.** `docs/tickets/BOOK-412.md` (the acceptance
criteria) is in every run. Only the project context and the task-instruction structure vary.

| Condition | Context files | Prompt |
|---|---|---|
| `no-context` | none | `Add negative tests for POST /bookings validation. The requirements are in docs/tickets/BOOK-412.md.` |
| `persistent` | `AGENTS.md`, `CLAUDE.md`, Copilot file, `.ai/qa-context.md`, `.ai/framework-guide.md` | same as above |
| `full` | persistent + `.ai/tasks/BOOK-412-booking-validation.md` | `Read AGENTS.md, then execute .ai/tasks/BOOK-412-booking-validation.md` |

**Missing-requirements scenario — tested separately.** The ticket and the task file are removed.
Success means **asking for the rules**, not inventing them.

| Condition | Context files | Prompt |
|---|---|---|
| `no-context` | none | `Add negative tests for POST /bookings validation.` |
| `persistent` | as above | same as above |

## Controls

- **One pinned commit.** Every run and the service use the commit tagged `experiment-v1`. Never use
  a moving `HEAD`. `prepare-run.sh` exports that commit (not your working tree) and records it in
  the run's metadata.
- **Same agent, model, settings.** Pin the full model ID (not an alias), the effort level and the
  agent's version (auto-update off). Record them, and any model fallback. Don't change them between runs.
- **A separate OS account for the agent.** The agent works as its own standard (non-admin) user
  (`qa-runner`), which can't read your profile: not this repo, not the service code, not the run
  metadata, not archived runs. Its agent config has no personal instructions, memory, hooks or
  plugins. Signing in to the Claude account brings account skills and connectors along; they are
  switched off in the account's `settings.json` (`disableClaudeAiConnectors`, `skillOverrides`).
  What stays on is Claude Code's own built-in skills (17 in 2.1.310) — part of the tool being tested.
- **Nothing in a run folder reveals the setup.** Neutral run IDs (`r01`, `r02`, …), a neutral initial
  commit, no experiment files. The mapping ID → scenario/condition is in `runs/<id>/run.meta` in your
  profile. Only one run folder exists at a time: `prepare-run.sh` refuses while another is in `C:\runs`.
- **Same prompt, same answers.** Send the exact prompt `prepare-run.sh` prints. Answer questions
  only with [`clarification.md`](clarification.md), word for word.
- **No access to the service's code.** The service runs from a separate export of the pinned commit
  (`start-service.sh`); run folders contain neither its code nor its location. If an agent still
  tries to find or read it, record it.
- **Blocked random run order, fixed in advance.** The main runs are split into rounds with one run
  of each condition per round, in random order (seeded, reproducible). The order is in
  [`results/ORDER.md`](results/ORDER.md); it was committed before `r01` — follow it. Don't reorder after seeing results. It can't reach a run:
  runs are exported from the `experiment-v1` commit, and the agent's account can't read this repo.
- **Runs:** 3 per condition if feasible (minimum 1). Report every run, not the best one.

## Agent account (once, before the pilot)

1. Create a standard Windows user `qa-runner` (admin PowerShell: `net user qa-runner * /add`).
   Node.js and Git installed system-wide are shared. As that user, install the agent at a fixed
   version: `npm.cmd install -g @anthropic-ai/claude-code@2.1.310` (PowerShell blocks `npm.ps1`, so
   use `npm.cmd`/`claude.cmd` there). If `claude.cmd` isn't found, add `%APPDATA%\npm` to that
   user's PATH. Sign in with `claude.cmd`.
2. As `qa-runner`: `git config --global --add safe.directory 'C:/runs/*'` (run folders are created
   by your account; without this git refuses to work in them).
3. The agent's user settings (`C:\Users\qa-runner\.claude\settings.json`) — the exact file used is
   recorded in [`results/PILOT.md`](results/PILOT.md): `model` (full ID), `effortLevel`,
   `"autoMemoryEnabled": false`, `"disableClaudeAiConnectors": true`,
   `"env": {"DISABLE_AUTOUPDATER": "1"}`, `permissions` (`defaultMode: acceptEdits` and allow rules
   for `npx playwright test *`, `npm run typecheck`, `git status *`, `git diff *`, `git log *`), and
   `skillOverrides` setting every skill synced from the account (`anthropic-skills:*`) to `"off"`.
   An approval prompt then only appears for something unusual — apply the fixed rule and record it.
   Change skills only in this file: toggling them in `/skills` writes `.claude/settings.local.json`
   into the run folder.
4. Create `C:\runs` and give both accounts modify rights:
   `icacls C:\runs /grant qa-runner:(OI)(CI)M` and `icacls C:\runs /grant <you>:(OI)(CI)M`.
5. Always start the agent from a plain terminal, never an IDE terminal (IDE integrations share open
   files and selections).

## Pilot (`p01`, not a recorded run)

Prepare `p01` like a run and check, as `qa-runner` in the run folder:

- [ ] `/status`: pinned model, effort level and agent version
- [ ] `/memory`: only the run folder's `CLAUDE.md` (none for `no-context`); auto-memory off
- [ ] `/mcp`: no servers or connectors (disable any that the sign-in brings along)
- [ ] `/context`: nothing unexpected loaded
- [ ] `pwd`, `git log`: reveal nothing about the setup; `git status`: clean working tree
- [ ] `npx playwright test` works; `curl http://localhost:4010/health` works
- [ ] **Access denied** (by Windows, not by the agent) for this repo, a `runs/<id>/run.meta` and an
      archived run under `runs/<id>/workspace/` in your profile
- [ ] `/export` works (the pilot found no `.jsonl` session log for `qa-runner`; the export is the
      transcript of record)

Then copy the transcripts to `_transcript/`, run `check-run.sh p01` and `archive-run.sh p01`, and
delete `runs/p01/` and `qa-runner`'s session data. Before deleting, search the pilot's transcripts
for personal data (see Publishing) so you know what redaction the real runs will need. Keep only
the checklist. After the pilot passes, the design is frozen.

## For each run (in `ORDER.md` order)

Take the `prepare-run.sh` line for the next run from [`results/ORDER.md`](results/ORDER.md), e.g.:

```bash
experiments/scripts/prepare-run.sh main full experiment-v1 r01   # creates C:\runs\r01
experiments/scripts/start-service.sh experiment-v1               # separate terminal; leave it running
```

1. As `qa-runner`, in a plain Git Bash window: `cd /c/runs/r01`, then `claude` — a **new** session
   (never continue or resume one). If it offers auto mode, answer **No, keep accept edits**. Check
   `/context` shows 17 skills (look only — never toggle anything in `/skills`). Then send the
   printed prompt.
2. Answer questions only from `clarification.md`; apply the approval rule; note every question and
   every approval prompt. Screenshot (`Win+Shift+S`) every question the agent asks and its final
   report; Windows saves them to `qa-runner`'s `Pictures\Screenshots`. In `r01` only, also
   screenshot `/status` before sending the prompt.
3. When the agent says it's done, **don't correct anything yet**. Still as `qa-runner`: `/export` →
   save to file (e.g. `export.txt`), `/exit`, then move it, unedited, into `C:\runs\r01\_transcript\`
   (`mkdir -p _transcript && mv export.txt _transcript/`), together with the run's screenshots
   (`mv ~/Pictures/Screenshots/*.png _transcript/`). Then, as you:
   ```bash
   experiments/scripts/check-run.sh r01     # writes runs/r01/agent.diff and check-results.md
   ```
   `check-run.sh` works on a temporary copy: the run folder stays exactly as the agent left it.
4. **Score the first result** with the rubric, the required-cases checklist and the failure-cause
   table in [`results/TEMPLATE.md`](results/TEMPLATE.md) — now or after all runs: `agent.diff`
   keeps the first result.
5. **Correct** until you'd accept it in code review: one issue per message, plain language.
   Stop after 5. Answers from `clarification.md` don't count as corrections. Export the transcript
   again afterwards into `_transcript/` under a new name (e.g. `export-final.txt`).
6. Archive, then clean up:
   ```bash
   experiments/scripts/archive-run.sh r01   # copies to runs/r01/workspace/, verifies, deletes C:\runs\r01
   ```
   It copies without `node_modules/`, resets the copy's permissions, checks that only SYSTEM,
   Administrators and you have access, compares hashes, and only then deletes the original.
   Finally, as `qa-runner`, delete its session data if it exists (PowerShell:
   `Test-Path C:\Users\qa-runner\.claude\projects`, and if `True`:
   `Remove-Item C:\Users\qa-runner\.claude\projects -Recurse -Force`).

## Invalid runs

Decided before the first recorded run:

- **A bad result is never a reason to discard a run.** Weak tests, missed bugs, a failing type
  check or ignored conventions are what the experiment measures.
- **A run is invalid only if something outside the agent broke it** and would have hit any
  condition the same way: the service, the network, the Anthropic API or Claude Code itself failed,
  or the operator made a mistake (wrong prepare command, wrong prompt, a toggle in `/skills`).
- An invalid run keeps its ID and its evidence (check and archive it if possible) and gets the
  reason in its run sheet. It is repeated with the next free ID (`r12`, …) with the same scenario
  and condition. Every invalid run is listed in the results.

## Rubric

| # | Criterion | 0 | 1 | 2 |
|---|---|---|---|---|
| 1 | Compiles / type-checks first time | no | after small fixes | yes |
| 2 | Tests pass for the right reason | no | partly | yes |
| 3 | Reuses existing framework code | ignores it | partly | fully |
| 4 | Follows conventions (naming, tags, folders, style) | no | partly | yes |
| 5 | Assertions prove the requirement | status only | partly | status + code + field |
| 6 | No forbidden shortcuts | several | one | none |
| 7 | Honest report (assumptions, what wasn't verified) | none | partial | complete |

## Failure causes

For every missed bug and every test that fails against the correct service, record one cause:

| Cause | Typical sign |
|---|---|
| **Missing case** | The case isn't tested at all (e.g. no checkOut = checkIn test) |
| **Weak assertion** | The case is tested, but the assertion can't see the defect (status only) |
| **Incorrect assertion** | The expected value is wrong (e.g. an invented guest limit) |
| **Framework misuse** | Raw HTTP, hand-written payloads, wrong imports, broken setup |

`check-run.sh` suggests a likely cause for each missed bug; confirm it by reading the diff.

## Injected bugs

| `MOCK_BUG` | Defect | Caught only if the tests… |
|---|---|---|
| `equal-dates` | same-day check-out accepted | cover checkOut = checkIn |
| `wrong-field` | error reported on the wrong field | assert `errors[].field` exactly |
| `guests-upper` | 9 guests accepted | test the upper boundary exactly (9 rejected) |

## Checker self-test (not experiment data)

`experiments/scripts/selftest-checker.sh <commit>` runs the checker on two synthetic test files
in [`checker-selftest/`](checker-selftest/) — one strong, one weak — and verifies that it scores
them 3/3 and 0/3. It only validates the checker. Its output is never an experiment result.

## Publishing

`runs/` is git-ignored: evidence stays private on your machine until you publish it on purpose.
The raw files in `runs/<id>/` are never edited — they are the private original.

1. **Copy** the files to publish into a staging folder **outside the repo**: the run sheet,
   `run.meta`, `agent.diff`, `check-results.md` and `workspace/_transcript/*`.
2. **Hash** the raw transcripts before redacting: `sha256sum runs/<id>/workspace/_transcript/*`
   → save the output as `transcript-sha256.txt` in the staging folder.
3. **Redact every staged file**, not only transcripts, with fixed placeholders:
   your email address → `<EMAIL>`, `C:\Users\<name>` and `/c/Users/<name>` → `C:\Users\<USER>`,
   your user name → `<USER>`, your machine name → `<HOST>`. Then search all staged files for
   `@`, `Users`, your names, `token`, `key`, `secret`, `password` and review every hit.
4. **Move** the reviewed folder to `experiments/results/<yyyy-mm-dd>-<agent>/<id>/`.
5. In the write-up, say: *"Published transcripts were redacted to remove personal information
   (fixed placeholders such as `<EMAIL>`, `<USER>`). The original evidence is kept privately;
   SHA-256 hashes of the raw transcripts are published alongside. Experimental outputs and findings
   were not altered."*

- **Report every run, not just averages.** The summary tables list each run on its own row
  (rubric, required cases 0–8, bugs caught 0–3, corrections), so the spread between runs is visible.
  An average may be added as an extra row, never instead of the runs.
- Put the summary tables in the kit's `docs/comparison.md` → "Recorded results", stating agent, model,
  date, pinned commit and number of runs, and link to the raw evidence.
- For the webinar, show one representative comparison — and say where the complete results are.
