# PR review body

Use exactly this order. Write "None" under a heading with nothing to report. Points only, never paragraphs.

Rules: main headings are `###`, category headings are `####`, emoji circles only on the verdict line and category headings, no emoji in the summary, never `#` followed by a number (GitHub links it to an unrelated issue; write "item 1"). The verdict line must match the `gh pr review` flag. The body never describes how the review was made: no "four independent reviews", "reviewers", "lenses", "compiled", "after merging duplicates" or "found on their own". Write it as one review; where coverage helps, name the focused review areas (for example "Review areas: design, scope and tests, security and risk, correctness") and give counts as plain totals ("0 high, 7 medium, 9 low or nit").

---

```markdown
Verdict: APPROVE 🟢
```
or
```markdown
Verdict: REQUESTED_CHANGES 🔴
```

```markdown
### Summary
- Verdict reason in points: findings count by category, what the change does, what was checked, and what was not verified.

#### 🔴 High blockers
- **[File / Component]**: short description. **Why**: impact. **Fix**: expected behavior.

#### 🟠 Medium blockers
- Same point format as High blockers.

#### 🟡 Medium non-blockers
- Same point format; recommended, not blocking.

#### 🟢 Low / nits
- **[File / Component]** (NIT or LOW, read/reproduced/speculative): short description. Optional follow-up.

### Code suggestions
- Exact fixes in GitHub suggestion format, or "None needed".

### Questions
- Questions needing context, or "None".
```

Medium blockers appear only when there are more than 5 MEDIUM findings; otherwise every MEDIUM goes under non-blockers.
