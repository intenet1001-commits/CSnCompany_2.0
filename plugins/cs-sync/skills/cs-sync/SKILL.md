---
name: cs-sync
description: Use this skill when the user types "/cs-sync", "플러그인 동기화", "sync plugins", "push and sync", or wants to commit, push cs_plugins to GitHub and update the local marketplace.
user-invocable: true
---

# CS-Sync - Plugin Workspace Sync

> Commit → Push to GitHub → Update local marketplace in one command

## What This Skill Does

After editing plugins in `/Users/gwanli/cs_plugins/plugins/`, this skill:
1. Commits staged/modified files in `cs_plugins`
2. Pushes to `intenet1001-commits/cs_plugins` (main branch)
3. Pulls updates into the local marketplace at `~/.claude/plugins/marketplaces/cs-plugins`

---

## Protocol

### Step 1: Check git status

Run:
```bash
git -C /Users/gwanli/cs_plugins status
```

Show the user which files are modified. If nothing to commit, report and stop.

### Step 2: Stage and commit

Ask the user for a commit message, OR if they didn't provide one, auto-generate a concise message based on the modified files (e.g., `feat: update convo-maker auto-save rule`).

Then run:
```bash
git -C /Users/gwanli/cs_plugins add -p  # or specific files
git -C /Users/gwanli/cs_plugins commit -m "<message>\n\nCo-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

> Stage only files in `plugins/` — skip `.bkit/`, `.omc/`, `.tdd-plans/`, `plugins/docs/` unless explicitly requested.

### Step 3: Push to GitHub

```bash
git -C /Users/gwanli/cs_plugins push origin main
```

### Step 4: Update local marketplace

```bash
git -C /Users/gwanli/.claude/plugins/marketplaces/cs-plugins pull
```

### Step 5: Confirm

Report:
- Which files were committed
- Push result (branch + commit hash)
- Pull result (Fast-forward or already up to date)
