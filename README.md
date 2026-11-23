# workflows

Agent pipelines for shipping and reviewing code with Claude Code: who does what, on which model, in what order.

| Pipeline | When | Diagram | Agent skill |
|---|---|---|---|
| Feature and fix | Building a feature or fix from a Linear ticket | [pipelines/feature-and-fix.md](pipelines/feature-and-fix.md) | [skills/context-gathering](skills/context-gathering/SKILL.md) |
| PR review | A PR requests your review | [pipelines/pr-review.md](pipelines/pr-review.md) | [skills/pr-review-driver](skills/pr-review-driver/SKILL.md) |

Shared template: [templates/pr-review-body.md](templates/pr-review-body.md).

## Layout

```
pipelines/   human-readable flow, diagram, and rules for each pipeline
skills/      Claude Code skills (SKILL.md) agents load to run a pipeline
templates/   output formats the pipelines produce
install.sh   links every skill into ~/.claude/skills
```

## Install

```sh
git clone git@github.com:askwhyharsh/workflows.git ~/.agents/workflows
~/.agents/workflows/install.sh
```

`install.sh` symlinks each `skills/<name>` into `~/.claude/skills/<name>`, so `git pull` updates them in place. It skips any name that already exists and is not a link into this repo.

The feature pipeline's grill stage uses the `grilling` skill from [mattpocock/skills](https://github.com/mattpocock/skills).
