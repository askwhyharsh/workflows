# PR review pipeline

Reviewing a PR that requests your review. One Opus **driver** per PR compiles; four Sonnet reviewers review. Agent-facing steps: [`skills/pr-review-driver`](../skills/pr-review-driver/SKILL.md).

```mermaid
flowchart TD
    RQ([Review requested on a PR]) --> O[Orchestrator]
    O -->|spawn| D[Driver - Opus<br/>does not review]
    D -->|shared inputs: diff, ticket, PR text, existing threads, repo rules| A & B & C & E

    subgraph PAR [Four Sonnet reviewers in parallel]
      A[A. Design<br/>structure, coupling, refactors]
      B[B. Scope and tests<br/>ticket vs PR vs code, PR hygiene]
      C[C. Security and risk<br/>bypass, injection, money, secrets, deps]
      E[D. Correctness<br/>logic, edge cases, regressions]
    end

    A & B & C & E -->|findings| CMP[Driver compiles<br/>merge duplicates, drop already-raised,<br/>apply threshold]
    CMP --> POST[Post one review<br/>templates/pr-review-body.md]
    POST -->|review URL + verdict| O
```

## Threshold

- Any HIGH, or more than 5 MEDIUM: request changes.
- Otherwise approve; MEDIUM items are recommended non-blockers, LOW / NIT are optional follow-ups.

## Rules

- The driver judges evidence, not code; when two lenses disagree on severity it keeps the better-evidenced one.
- Reviewers return findings only; the driver posts exactly one review.
- On a PR you did not author: review and comment only. No edits to title or description, no merge, no branch update, no push, no resolving other people's threads, no ticket changes.
- A new review runs only when the author re-requests review.
