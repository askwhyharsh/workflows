---
name: context-gathering
description: The driver pipeline that takes a Linear ticket to a raised PR, for features and fixes alike. Use when the user says "context gathering", asks to implement a feature or make a code change tied to a Linear ticket, or when you are an Opus driver briefed to run this pipeline.
---

One **driver** per feature or fix: an Opus agent that the orchestrator spawns and supervises. The driver owns the work from ticket to merged PR and does it through sub-agents (Agent tool, `model:` set per stage). Every sub-agent works in the driver's own task directory, so the same copy passes from mapper to builders to reviewer to fixers.

The driver coordinates: it reads reports, decides, and hands work out. Heavy code reading and all code writing go to sub-agents.

Diagram and rationale: [`pipelines/feature-and-fix.md`](../../pipelines/feature-and-fix.md).

## Orchestrator's part

1. Spawn the driver on Opus (one per feature; many may run at once). Its instructions carry the Linear ticket id and name this skill.
2. Relay the grill. Each round the driver raises a decision request naming a file with that round's numbered questions and its recommended answers. Show the user the round (selectable options where the questions allow), then send the answers back. Keep going until the user says they are satisfied.
3. Report the raised PR to the user with its link and title.

## Driver's stages

1. **Context gathering.** Read the Linear ticket in full: description, comments, attachments, parent and linked issues. Launch a `haiku` sub-agent to **map** the codebase against it: every file, module, route, type, and test the ticket touches; patterns and helpers to reuse; contracts crossed; unknowns as questions. Done when every ticket requirement maps to code locations or an open question.
2. **Grill.** Run the `grilling` skill's rounds, but deliver each round through the orchestrator and wait for the answers; the driver never addresses the user directly. Done when the user is satisfied. Keep the full Q&A.
3. **Plan.** Launch a `fable` sub-agent at `effort: medium` with the ticket, the map, and the Q&A. It returns slices (files, acceptance checks, tests), their dependencies, and the draft PR title (`[TICKET-ID] type(scope): subject`) and body.
4. **Build.** Launch one `sonnet` sub-agent per slice. Slices that touch disjoint files run in parallel; slices sharing a file run in sequence. Each commits locally and returns. Done when every slice is in and the project's checks pass.
5. **Review, once.** Launch a fresh `opus` sub-agent with no build context. Its **north star** is the Linear ticket plus the draft PR title and description; it checks the branch diff against them, then the repo's `CLAUDE.md` / `AGENTS.md` and `CONTRIBUTING.md`, and grades findings HIGH / MEDIUM / LOW per [the review threshold](../pr-review-driver/SKILL.md#threshold).
6. **Fix.** Launch a new `sonnet` sub-agent with only the HIGH and MEDIUM findings. It fixes them in the same directory and commits. No second Opus review unless the user asks.
7. **Raise.** Push and open the PR, then report the PR link to the orchestrator.

## After the PR

The driver stays the PR's one owner. Each round of reviewer comments or CI failures goes to a new `sonnet` fixer sub-agent in the same directory; the driver replies on threads and re-requests review only from reviewers who have not approved. No new Opus review.
