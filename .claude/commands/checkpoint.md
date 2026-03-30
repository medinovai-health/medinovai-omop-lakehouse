---
description: Create a named checkpoint before a destructive operation
---

Create a git tag: `harness-checkpoint-session-[N]-pre-[OPERATION]`.
Print the rollback command (`git checkout <tag> -- <path>`).
Proceed with the operation only after the tag exists.
