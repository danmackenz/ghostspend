---
description: Walk through GhostSpend audit findings one at a time and apply approved fixes — shows the exact command for every action and never executes without confirmation
---

# /gs-fix

Invoke the `ghostspend-fix` skill.

1. Confirm a recent `ghostspend-audit` run exists. If findings are stale or
   absent, re-run the audit first (the user may override).
2. Work findings in severity order, critical first.
3. For each finding, present only the options that are actually distinct for
   that finding type.
4. Show the exact command or file diff and require an explicit yes before
   executing anything.
5. Close with a summary: fixed, skipped, needs manual follow-up.
