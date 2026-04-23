# CSnCOMPANY — Your AI Team in Claude Code

A virtual company of specialist AI agents for Claude Code. Each plugin is a team member with a clear role: CEO, Designer, Architect, QA, Reviewer, DevOps, and more. They collaborate from idea to ship.

## The Team

| Member | Plugin | Slash Command | Role |
|--------|--------|--------------|------|
| 🧭 **CEO** | `cs-ceo` | `/cs-ceo` | Orchestrator — estimates effort, autonomously delegates across CS-test / CS-plan / CS-codebase-review / cs-design / cs-smart-run |
| 💬 **PM (Clarifier)** | `cs-clarify` | `/cs-clarify` | 4-agent Socratic elicitation — surfaces hidden assumptions, validates scope, prevents over-engineering before planning |
| 🏗️ **Architect** | `CS-plan` | `/CS-plan "feature"` | 4-agent TDD + Clean Architecture planner — domain analysis, architecture design, test strategy, implementation checklist |
| 🎨 **Designer** | `cs-design` | `/cs-design` | 5-agent parallel design review — visual hierarchy, interaction quality, design system consistency, responsive/a11y, anti-pattern detection |
| 🎨 **Design System Guide** | `cs-design-sample1` | `/cs-design-sample1` | Crextio-inspired reference: warm cream palette, amber/slate accents — audit & apply to Tailwind/Next.js dashboards |
| 🧪 **QA Engineer** | `CS-test` | `/CS-test` | 14-agent web testing — security, SEO, performance, a11y, DB, PWA, touch, image optimization |
| 🔍 **Code Reviewer** | `CS-codebase-review` | `/CS-codebase-review` | 5-agent parallel review — Architecture, Quality, Security, Performance, Maintainability |
| 🚢 **DevOps (Ship Gate)** | `cs-ship` | `/cs-ship` | 4-agent pre-PR validation — spec compliance, coverage, commit messages |
| ⚡ **Team Lead (Runner)** | `cs-smart-run` | `/cs-smart-run` | Two-phase orchestrator — plan with Opus, execute with Sonnet agents in parallel |
| 📚 **Knowledge Keeper** | `cs-experiencing` | `/cs-experiencing` | Meta-router across CS-test / CS-plan / CS-codebase-review / cs-design, with versioned learnings |
| 🗣️ **Language Coach** | `convo-maker` | `/convo-maker` | Convert session Q&A into natural American English conversations for language learning |

## Typical Workflow

```
  /cs-clarify → /CS-plan → /cs-design → build → /CS-test
                                                    ↓
                    /CS-codebase-review → /cs-ship → PR
```

Or let the CEO decide: `/cs-ceo "build a dashboard"` and it dispatches the right members automatically.

## Installation

### Option 1 — One-liner via Claude Code (recommended)

```
/plugin marketplace add intenet1001-commits/CSnCOMPANY
```

Then install whichever members you want:

```
/plugin install cs-ceo@cs-plugins
/plugin install cs-clarify@cs-plugins
/plugin install CS-plan@cs-plugins
/plugin install cs-design@cs-plugins
/plugin install cs-design-sample1@cs-plugins
/plugin install CS-test@cs-plugins
/plugin install CS-codebase-review@cs-plugins
/plugin install cs-ship@cs-plugins
/plugin install cs-smart-run@cs-plugins
/plugin install cs-experiencing@cs-plugins
/plugin install convo-maker@cs-plugins
```

### Option 2 — Manual

```bash
git clone https://github.com/intenet1001-commits/CSnCOMPANY ~/.claude/plugins/marketplaces/cs-plugins
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
    "cs-ceo@cs-plugins": true,
    "cs-clarify@cs-plugins": true,
    "CS-plan@cs-plugins": true,
    "cs-design@cs-plugins": true,
    "cs-design-sample1@cs-plugins": true,
    "CS-test@cs-plugins": true,
    "CS-codebase-review@cs-plugins": true,
    "cs-ship@cs-plugins": true,
    "cs-smart-run@cs-plugins": true,
    "cs-experiencing@cs-plugins": true,
    "convo-maker@cs-plugins": true
  }
}
```

Restart Claude Code to load the plugins.

## Architecture — Lead-Agent Pattern

All multi-agent members use the **lead-agent pattern**: main context spawns one lead agent; the lead orchestrates N specialist workers internally. Raw agent outputs never accumulate in the main conversation.

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
  ├─ architecture    → architecture-report.json
  ├─ quality         → quality-report.json
  ├─ security        → security-report.json
  ├─ performance     → performance-report.json
  └─ maintainability → maintainability-report.json
  → REVIEW.md
```

### cs-design (5 agents, parallel)

```
SKILL → design-lead
  ├─ visual-hierarchy     → visual-hierarchy.json
  ├─ interaction-quality  → interaction-quality.json
  ├─ design-system        → design-system.json
  ├─ responsive-a11y      → responsive-a11y.json
  └─ anti-pattern         → anti-pattern.json
  → DESIGN-REVIEW.md
```

## Usage Examples

```
/cs-ceo "build a user dashboard"
/cs-clarify "add payment integration"
/CS-plan "user authentication with email + JWT"
/cs-design https://example.com
/CS-test https://example.com
/CS-codebase-review ./src --focus security
/cs-ship
/cs-smart-run "add dark mode to the dashboard"
```

## License

MIT — see [LICENSE](LICENSE).

## Links

- [한국어 문서](README.ko.md)
- [GitHub Repository](https://github.com/intenet1001-commits/CSnCOMPANY)
