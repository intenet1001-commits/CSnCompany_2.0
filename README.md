# CS Plugins — Claude Code Plugin Collection

Claude Code plugins for web testing, planning, and code review.

## Plugins

| Plugin | Slash Command | What it does |
|--------|--------------|-------------|
| **CS-test** | `/CS-test` | 14-agent web testing — security, SEO, performance, accessibility, DB, PWA, touch, image optimization |
| **CS-plan** | `/CS-plan "feature"` | TDD + Clean Architecture 4-agent plan — domain analysis, architecture design, test strategy, implementation checklist |
| **CS-codebase-review** | `/CS-codebase-review` | 5-agent parallel codebase review — Architecture, Quality, Security, Performance, Maintainability |
| **cs-sync** | `/cs-sync` | Commit → push cs_plugins to GitHub → update local marketplace in one command |
| **smart-run** | `/smart-run` | Two-phase orchestrator: Plan with Opus → Execute with Sonnet agents in parallel |
| **convo-maker** | `/convo-maker` | Convert session Q&A into natural American English conversations for language learning |
| **experiencing** | `/experiencing` | Meta-router for CS-test, CS-plan, CS-codebase-review domains |

## Installation

```bash
git clone https://github.com/intenet1001-commits/cs_plugins ~/.claude/plugins/marketplaces/cs-plugins
```

Then enable plugins in `~/.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "cs-plugins": {
      "source": {
        "source": "local",
        "path": "~/.claude/plugins/marketplaces/cs-plugins"
      }
    }
  },
  "enabledPlugins": {
    "CS-test@cs-plugins": true,
    "CS-plan@cs-plugins": true,
    "CS-codebase-review@cs-plugins": true,
    "cs-sync@cs-plugins": true,
    "smart-run@cs-plugins": true,
    "convo-maker@cs-plugins": true,
    "experiencing@cs-plugins": true
  }
}
```

Restart Claude Code to load the plugins.

## Architecture

All multi-agent plugins use the **lead-agent pattern** — main context spawns one lead agent, the lead orchestrates N specialist workers internally. Raw agent outputs never accumulate in the main conversation.

```
main context
  └─ SKILL.md (thin wrapper: parse args, spawn 1 lead Task)
       └─ lead agent (own context: orchestrate N workers)
            ├─ worker-1 → result file
            ├─ worker-2 → result file
            └─ worker-N → result file
            → synthesize final doc → return to main context
```

### CS-test (14 agents, 2-phase)

```
SKILL → test-lead
  Phase 1: build-validator, page-explorer (sequential)
  Phase 2: functional, visual, api-interceptor, perf, security,
           seo, social-share, touch, image, db, error-resilience (parallel)
  → REPORT.md
```

### CS-plan (4 agents, parallel)

```
SKILL → plan-lead
  ├─ domain-analyst    → domain-analysis.md
  ├─ arch-designer     → architecture.md
  ├─ tdd-strategist    → tdd-strategy.md
  └─ checklist-builder → implementation-checklist.md
  → PLAN.md
```

### CS-codebase-review (5 agents, parallel)

```
SKILL → review-lead
  ├─ architecture  → architecture-report.json
  ├─ quality       → quality-report.json
  ├─ security      → security-report.json
  ├─ performance   → performance-report.json
  └─ maintainability → maintainability-report.json
  → REVIEW.md
```

## Usage Examples

```
/CS-test https://example.com
/CS-plan "user authentication with email + JWT"
/CS-codebase-review
/CS-codebase-review ./src --focus security
/cs-sync
/smart-run "add dark mode to the dashboard"
```

## License

MIT
