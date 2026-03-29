---
name: commit-changes
description: >-
  Commit and push local changes using git with a well-crafted Conventional
  Commits message. Use when the user asks to commit, save changes, push code,
  or create a git commit. Also use when the user says "commit this", "push
  changes", or references committing work.
---

# Commit Changes

Analyze uncommitted changes, generate a Conventional Commits message, commit,
and push to origin.

## Workflow

### Step 1: Check branch safety

```bash
git rev-parse --abbrev-ref HEAD
```

If the current branch is **`main`** or **`master`**:

1. **Stop.** Do NOT commit on this branch.
2. Ask the user what the new branch should be named. **Never invent a branch
   name yourself.**
3. Once the user provides a name, create and switch to it:

```bash
git checkout -b <user-provided-branch-name>
```

### Step 2: Review uncommitted changes

Run **all three** commands to get full context:

```bash
git status
git diff
git diff --cached
```

- `git diff` shows unstaged changes.
- `git diff --cached` shows already-staged changes.
- If there are no changes at all, inform the user and stop.

### Step 3: Stage changes

```bash
git add -A
```

### Step 4: Craft the commit message

Use the **Conventional Commits** format:

```
<type>(<optional scope>): <short summary>

<optional body>
```

#### Rules

| Element | Guideline |
|---------|-----------|
| **type** | One of: `feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`, `perf`, `ci`, `build`, `revert` |
| **scope** | Optional; the area of the codebase affected (e.g. `auth`, `api`, `ui`) |
| **summary** | Imperative mood, lowercase, no period, max ~72 chars |
| **body** | Explain *what* and *why*, not *how*. Wrap at 72 chars. Separate from summary with a blank line. |

#### Examples

```
feat(auth): add JWT refresh-token rotation

Tokens now rotate on each refresh request, reducing the window for
token reuse attacks. Expired refresh tokens invalidate the entire
family.
```

```
fix(parser): handle empty input without panic
```

```
refactor: extract validation logic into shared module
```

- Derive the type from the nature of the changes (new feature → `feat`, bug
  fix → `fix`, restructuring → `refactor`, etc.).
- Keep the summary concise; move details to the body.
- If changes span multiple unrelated concerns, prefer a single commit that
  summarizes the overall intent. Only suggest splitting if the changes are
  truly independent and the user would benefit from separate commits.

### Step 5: Commit

Pass the message via heredoc to preserve formatting:

```bash
git commit -m "$(cat <<'EOF'
<type>(<scope>): <summary>

<body>
EOF
)"
```

### Step 6: Push to origin

```bash
git push -u origin HEAD
```

If the push is rejected (e.g. no upstream, diverged history), report the
error to the user and **do not force-push** unless explicitly asked.

## Important Constraints

- **Never force-push** unless the user explicitly requests it.
- **Never commit to `main` or `master`** — always branch first (see Step 1).
- **Never invent a branch name** — always ask the user.
- **Never skip the diff review** — the diff is the source of truth for the
  commit message.
- **Never update git config** (user.name, user.email, etc.).
