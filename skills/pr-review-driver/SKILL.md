---
name: pr-review-driver
description: Review someone else's PR with an Opus driver and four parallel Sonnet reviewers (design, scope and tests, security and risk, correctness), then post one compiled review. Use when a PR requests your review, or when you are an Opus driver briefed to review a PR.
---

You are the review **driver**. You do not review the code yourself: four independent Sonnet reviewers do, and you compile their findings into one review and post it.

Diagram and rationale: [`pipelines/pr-review.md`](../../pipelines/pr-review.md).

## 1. Prepare

- Check out the PR head (`gh pr checkout <n> -R <owner>/<repo>`) in a scratch copy. Never push to the PR branch and never edit the PR.
- Collect the shared inputs every reviewer gets: the PR URL, title and body, the linked Linear issue (description, acceptance criteria, comments), existing review threads and comments (so nobody repeats them), and the paths of the repo's `CLAUDE.md` / `AGENTS.md` (root and per-directory) and `CONTRIBUTING.md`.

## 2. Launch four reviewers in parallel

Use the Agent tool with `model: sonnet`, one sub-agent per lens, all in this copy, all launched in one message. Give each the shared inputs and its lens, plus these common rules:

- Read the diff (`gh pr diff <n> -R <owner>/<repo>`) and only the code around it; skip lockfiles and generated files unless the lens says otherwise.
- Stay inside your lens; another reviewer owns the others.
- Every finding: file:line, a concrete failure scenario, severity (HIGH / MEDIUM / LOW / NIT), and a verification tag (read / reproduced / speculative). Drop vague style opinions and anything already raised in an existing thread.
- Return findings only; never post to GitHub.

**Lens A - Design.** How the code is designed: module boundaries and where new logic lives, coupling, duplication of existing helpers, naming, abstractions that are too shallow or too clever, consistency with the surrounding architecture, behaviour or contract changes beyond the PR's stated aim, and concrete refactors worth making.

**Lens B - Scope and tests.** Linear ticket versus PR title, description and code: every acceptance criterion implemented, nothing out of scope slipped in, the description matches what the code does, and every acceptance criterion has a test that would fail without the change. PR hygiene per the repo's `CONTRIBUTING.md`: branch name, Conventional Commits, one logical change per commit, title `[TICKET-ID] <type>(<scope>): <subject>`, the required body sections, a ticket reference, and doc comments on new public items.

**Lens C - Security and risk.** What an attacker or a bad day can do: authn and authz, server-side versus client-only enforcement and ways to bypass a gate; input validation, injection, SSRF, unsafe deserialisation, open redirects; money paths (amounts, decimals, rounding, fees, slippage, replay, double submit, check-then-use races); secrets, tokens or PII in code, logs, errors or analytics; CORS and cookies; error paths that let a request through when a check fails; retries that double-execute; missing rate limits; new or bumped dependencies and lockfile drift.

**Lens D - Correctness.** Whether the code does what it means to: logic errors, edge cases (null, empty, zero, max, off-by-one, time zones, concurrency), error handling and recovery, regressions in callers of changed code, state and cache consistency, and whether the tests exercise the new paths. Run the relevant specs when cheap.

## 3. Compile

Done when every reviewer has returned. Then:

- Merge duplicates across lenses into one finding, keeping the strongest evidence.
- Drop findings already raised in existing threads.
- Keep each reviewer's severity unless two lenses disagree; then take the better-evidenced one. You judge evidence, not code.
- Apply the threshold below.

### Threshold

- Any HIGH, or more than 5 MEDIUM: request changes.
- Otherwise approve, listing MEDIUM items as recommended non-blockers and LOW / NIT items as optional follow-ups (never as skippable).

## 4. Post

Post ONE review with `gh pr review <n> -R <owner>/<repo>` (`--request-changes` or `--approve` to match the verdict), using [`templates/pr-review-body.md`](../../templates/pr-review-body.md) exactly. On a PR you did not author, only review and comment: never edit its title or description, merge, update its branch, push, resolve other people's threads, or change the ticket.

Finish by reporting each lens's raw findings, what you merged or dropped and why, what was run, and the posted review URL with its verdict.

Finding format: Every finding, in every category, uses this shape: a numbered bold title of 3 to 9 words on its own line ("1. **Title**", numbering restarts in each category, Where and Brief indented under it) (LOW and NIT items add "(LOW|NIT, read|reproduced|speculative)" after it); "- **Where:** <file, symbol, line>" only when a location matters; "- **Brief:** <at most 100 words: the problem, why it matters, then **Fix:** the expected change>". A blank line separates findings.
