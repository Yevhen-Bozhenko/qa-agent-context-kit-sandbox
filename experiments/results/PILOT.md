# Pilot run `p01` (not a recorded result)

One full run of the procedure before any recorded run, to verify the isolation and the evidence
workflow in practice. Its agent output is **not** experiment data.

| Field | Value |
|---|---|
| Date | 2026-10-25 |
| Scenario / condition | main / full |
| Project snapshot | unreferenced commit `32c0432` (tree `7c703c7…`), the uncommitted state later committed as `experiment-v1` |
| Agent | Claude Code 2.1.310, installed for the agent account with `npm install -g @anthropic-ai/claude-code@2.1.310`, auto-update off |
| Model / effort | `claude-opus-5-5` / `medium` (both pinned in the agent account's `settings.json`) |
| Agent account | `qa-runner`, standard Windows user (member of Users only) |
| Rule for unexpected approval prompts | Approve if it only touches `C:\runs\p01` or `localhost:4010`, deny otherwise, always note it |

## Agent account settings (`C:\Users\qa-runner\.claude\settings.json`)

```json
{
  "model": "claude-opus-5-5",
  "effortLevel": "medium",
  "autoMemoryEnabled": false,
  "disableClaudeAiConnectors": true,
  "env": { "DISABLE_AUTOUPDATER": "1" },
  "permissions": {
    "defaultMode": "acceptEdits",
    "allow": [
      "Bash(npx playwright test *)",
      "Bash(npm run typecheck)",
      "Bash(git status *)",
      "Bash(git diff *)",
      "Bash(git log *)"
    ]
  },
  "skillOverrides": {
    "anthropic-skills:built-in-browser": "off",
    "anthropic-skills:chrome-browser": "off",
    "anthropic-skills:computer-use": "off",
    "anthropic-skills:deep-research": "off",
    "anthropic-skills:docs": "off",
    "anthropic-skills:docx": "off",
    "anthropic-skills:google-workspace": "off",
    "anthropic-skills:import-memory": "off",
    "anthropic-skills:morning": "off",
    "anthropic-skills:pdf": "off",
    "anthropic-skills:pptx": "off",
    "anthropic-skills:skill-creator": "off",
    "anthropic-skills:xlsx": "off"
  }
}
```

Git for `qa-runner`: `git config --global --add safe.directory 'C:/runs/*'`.

## Checklist

| Check | Result |
|---|---|
| `qa-runner` reading this repo (`Get-Content …\README.md`) | ✅ Access is denied (Windows) |
| Run folder as `qa-runner`: `git status` clean, `git log` = "Bookings Team · Initial commit" only, API health reachable, `npx playwright test` 6 passed | ✅ |
| `/status`: version 2.1.310, model `claude-opus-5-5` | ✅ |
| `/effort` | ✅ medium |
| `/memory`: only the run folder's `CLAUDE.md` | ✅ |
| `/mcp` | ✅ no servers or connectors |
| `/skills` | ⚠️ 13 account skills loaded at first → turned off with `skillOverrides`; afterwards 17 skills, all built into Claude Code (see [Skills](#skills-what-the-agent-has-and-why)) |
| Skills off by `settings.json` alone (fresh session in `qa-runner`'s home folder, no project settings) | ✅ `/context` shows 17 skills |
| `/hooks`, `/agents` | ✅ none |
| `/permissions` | ✅ the 5 allow rules |
| `/context` | ✅ nothing unexpected |
| Questions the agent asked | none |
| Approval prompts that appeared | 2, both approved under the rule (run folder / local API only): (1) permission to write the test file; (2) "run the spec twice more and the type check — proceed?" |
| `check-run.sh p01` | ✅ type check PASS · 9 tests passed vs. correct service · bugs caught 3/3 · static checks clean · protected files untouched |
| `check-run.sh` left the run folder unchanged | ✅ (verified separately before the pilot: byte-identical before/after) |
| `archive-run.sh p01` | ✅ 100 files hash-verified, permissions checked, `C:\runs` emptied |
| Personal data in evidence (email, names) | ✅ none found in transcript export, `agent.diff`, `check-results.md`, `run.meta` |
| `qa-runner` reading `runs/p01/run.meta` and `runs/p01/workspace` | ✅ Access is denied (Windows) |
| `qa-runner`: `claude --version` after the run | ✅ still 2.1.310 |
| `qa-runner` session data cleared | ✅ |

## Skills: what the agent has, and why

A *skill* is a packaged set of instructions for one kind of job. Claude sees only each skill's name
and a one-line description, and loads the full instructions only if it decides the skill fits.

| | 13 account skills — **off** | 17 built-in skills — **on** |
|---|---|---|
| Examples | docs, docx, pdf, pptx, xlsx, browser, deep research, morning | code review, security review, simplify, init, settings help, loop, schedule, Claude API help |
| Come from | the signed-in Claude account (shown as "claude.ai sync") | the Claude Code program itself |
| Same for everyone using Claude Code 2.1.310? | no — they depend on the account | yes |
| Part of the agent being tested? | no — personal setup | yes — this is Claude Code as anyone gets it |

The experiment tests Claude Code as people actually install it, so its built-in skills stay on;
turning them off would test a modified tool. They are identical in every run, so they can't explain
a difference between conditions. In the write-up: *"Claude Code 2.1.310 with its built-in skills;
skills synced from the Claude account were turned off."*

Every recorded run checks `/context` (17 skills) before the prompt — look only, never toggle.

## Findings and how they're handled

1. **Account skills.** Signing in to the same Claude account loaded 13 account skills (docs, pdf,
   browser, …). Turned off for the agent account via `skillOverrides` in its user `settings.json`.
2. **Toggling skills writes into the run folder.** Switching skills off in `/skills` saved them to
   `.claude/settings.local.json` *inside* the run folder, so it appeared in the pilot's `agent.diff`.
   Rule for recorded runs: never change anything in `/skills` — only check it.
3. **Auto mode offer.** Claude Code offered auto mode on first start; declined ("keep accept edits").
   Same answer in every run if it appears again.
4. **Transcript.** The `/export` file was saved to `_transcript/`. The raw `.jsonl` session log was
   not found under `C:\Users\qa-runner\.claude\projects`; the export is the transcript of record.
5. **Approval prompts despite the allow list.** Writing the test file and a combined command
   (spec run twice more + type check) still asked for approval — the allow list doesn't cover every
   form an action can take. Both were approved under the fixed rule. Recorded runs apply the same
   rule and note every prompt in the run sheet.
6. **Leftover folder.** An empty `C:\runs\ps01\_transcript` from a typo was found and removed.
   `prepare-run.sh` refuses to start while `C:\runs` isn't empty, so this would have been caught.
7. **Snapshot vs. tag.** `experiment-v1`'s tree differs from the pilot snapshot only by the executable
   bit of `experiments/scripts/archive-run.sh` (contents identical). The snapshot (commit `32c0432`,
   tree `7c703c7…`) existed only locally and was never pushed, so this can't be re-checked from a
   clone; it was verified locally on 2026-10-25 with
   `git diff --stat 7c703c759f69a2fb38acf2ad3a7f6cd7a4dd9886 experiment-v1` → `archive-run.sh | 0`
   (0 lines changed). The snapshot was built without that bit; the scripts ran from the working tree,
   and `experiments/` never reaches a run folder.

## After the pilot

Committed and tagged `experiment-v1` (`72bd854`). `selftest-checker.sh experiment-v1`: strong 3/3
with no warnings, weak 0/3 with warnings — passed. Design frozen from here.
