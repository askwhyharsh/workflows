# Feature and fix pipeline

From a Linear ticket to a raised PR. One Opus **driver** per feature or fix; the orchestrator (e.g. Firstmate) runs many drivers at once. Agent-facing steps: [`skills/context-gathering`](../skills/context-gathering/SKILL.md).

```mermaid
flowchart TD
    U([You]) -->|ticket| O[Orchestrator]
    O -->|spawn, one per feature| D[Driver - Opus]

    subgraph DIR [One shared task directory]
      D --> M[1. Context gathering<br/>Haiku maps codebase vs ticket]
      M --> G[2. Grill<br/>questions relayed via orchestrator]
      G --> P[3. Plan<br/>Fable, medium effort]
      P --> B1[4. Build slice 1<br/>Sonnet]
      P --> B2[4. Build slice 2<br/>Sonnet]
      P --> B3[4. Build slice N<br/>Sonnet]
      B1 & B2 & B3 --> R[5. Review once<br/>fresh Opus, north star = ticket + PR text]
      R -->|HIGH + MEDIUM only| F[6. Fix<br/>new Sonnet]
      F --> PR[7. Push + raise PR]
    end

    G <-.->|each round| O
    O <-.-> U
    PR -->|PR link| O
    PR --> C[After PR: comments and CI<br/>new Sonnet fixer per round]
```

## Models

| Stage | Model | Why |
|---|---|---|
| Driver | Opus | Judgment across the whole lifecycle; coordinates only, so token spend stays small |
| Context gathering | Haiku | Cheap, wide codebase reading |
| Plan | Fable, medium effort | Strong planning from ticket + map + Q&A |
| Build, fix | Sonnet | Implementation |
| Review | Opus, once per PR | Independent judgment without build context |

## Rules

- **One directory.** Every sub-agent runs inside the driver's session, so the mapper, builders, reviewer, and fixers all share one working copy.
- **Parallel only when safe.** Build slices run in parallel when they touch different files; slices sharing a file run in sequence.
- **Review once, when ready.** The Opus review starts only after the whole change is written and the branch is ready to raise. Fixes after it get no second Opus pass unless asked.
- **Fix threshold.** HIGH and MEDIUM findings are fixed before the PR; LOW findings are optional follow-ups.
- **The driver never talks to the user directly.** Grill rounds and outcomes go through the orchestrator.
- **One owner per PR.** After the PR is raised, the same driver handles reviewer comments and CI with new Sonnet fixers.
