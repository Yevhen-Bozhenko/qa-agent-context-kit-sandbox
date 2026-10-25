# Run order

Fixed before the first recorded run and committed before `r01`. Follow it top to bottom; don't
reorder after seeing results. If a run has to be repeated (e.g. the agent crashed), give it the
next free ID (`r12`, …) and note why — never reuse an ID. What counts as a reason:
"Invalid runs" in [`../PROTOCOL.md`](../PROTOCOL.md).

**Design:** 11 runs, all from tag `experiment-v1` (commit `72bd854fd6f082c2ec0f2537d3b814122024628b`):
the `main` scenario 3 × `no-context`, 3 × `persistent`, 3 × `full`, plus `missing-requirements`
1 × `no-context` and 1 × `persistent`.

**Blocked randomisation.** The main runs are split into 3 rounds. Each round has exactly one run of
each condition, in random order. The two missing-requirements runs sit between the rounds, also in
random order. So every condition is spread evenly over time (a model update, server load or the
operator getting more practised can't line up with one condition), and nobody chose the order.

| Run | Round | Scenario | Condition | Prepare (as you, Git Bash) |
|---|---|---|---|---|
| r01 | 1 | main | full | `experiments/scripts/prepare-run.sh main full experiment-v1 r01` |
| r02 | 1 | main | no-context | `experiments/scripts/prepare-run.sh main no-context experiment-v1 r02` |
| r03 | 1 | main | persistent | `experiments/scripts/prepare-run.sh main persistent experiment-v1 r03` |
| r04 | — | missing-requirements | persistent | `experiments/scripts/prepare-run.sh missing-requirements persistent experiment-v1 r04` |
| r05 | 2 | main | full | `experiments/scripts/prepare-run.sh main full experiment-v1 r05` |
| r06 | 2 | main | persistent | `experiments/scripts/prepare-run.sh main persistent experiment-v1 r06` |
| r07 | 2 | main | no-context | `experiments/scripts/prepare-run.sh main no-context experiment-v1 r07` |
| r08 | — | missing-requirements | no-context | `experiments/scripts/prepare-run.sh missing-requirements no-context experiment-v1 r08` |
| r09 | 3 | main | no-context | `experiments/scripts/prepare-run.sh main no-context experiment-v1 r09` |
| r10 | 3 | main | persistent | `experiments/scripts/prepare-run.sh main persistent experiment-v1 r10` |
| r11 | 3 | main | full | `experiments/scripts/prepare-run.sh main full experiment-v1 r11` |

## How the order was generated

Fisher–Yates shuffles with a seeded PRNG (mulberry32), seeded with the first 8 hex digits of the
`experiment-v1` commit SHA: first the order of the two missing-requirements runs, then each round's
three conditions. Anyone can reproduce it:

```bash
node -e '
const seed = process.argv[1];
let h = parseInt(seed.slice(0, 8), 16) >>> 0;
const rand = () => { h = (h + 0x6D2B79F5) >>> 0; let t = h; t = Math.imul(t ^ (t >>> 15), t | 1); t ^= t + Math.imul(t ^ (t >>> 7), t | 61); return ((t ^ (t >>> 14)) >>> 0) / 4294967296; };
const shuffle = (a) => { for (let i = a.length - 1; i > 0; i--) { const j = Math.floor(rand() * (i + 1)); [a[i], a[j]] = [a[j], a[i]]; } return a; };
const mr = shuffle([["missing-requirements", "no-context"], ["missing-requirements", "persistent"]]);
const round = (n) => shuffle(["no-context", "persistent", "full"]).map((c) => ["main", c, n]);
const runs = [...round(1), [...mr[0], "-"], ...round(2), [...mr[1], "-"], ...round(3)];
runs.forEach(([s, c, r], i) => console.log(`r${String(i + 1).padStart(2, "0")} ${r} ${s} ${c}`));
' "$(git rev-parse 'experiment-v1^{commit}')"
```
