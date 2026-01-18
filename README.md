# CS Plugins - Claude Code Plugin Collection

A collection of Claude Code plugins for web application testing, automation, and document generation.

## Available Plugins

### playwright-test

Multi-agent Playwright test automation for web applications using 5 specialized agents:

| Agent | Role |
|-------|------|
| **Explorer** | Page discovery, DOM analysis, selector extraction |
| **Functional** | Page load, button click, form validation testing |
| **Visual** | Responsive screenshots, accessibility (axe-core) |
| **API** | XHR/Fetch capture, status code validation |
| **Performance** | Core Web Vitals, load time measurement |

### report-writer

Professional Korean business report writer with structured formatting:

| Feature | Description |
|---------|-------------|
| **Hierarchical Numbering** | I. → 1. → • → (1) → - multi-level structure |
| **Korean Typography** | 나눔명조 font with proper formatting |
| **python-docx Compatible** | Generate .docx files programmatically |
| **Collapsible Sections** | Word 2016+ expand/collapse support |
| **Table Formatting** | Headers, content, and title styling |

## Installation

### Via Claude Code (Recommended)

```
/plugin marketplace add intenet1001-commits/cs_plugins
/plugin install playwright-test
/plugin install report-writer
```

### Via Shell

```bash
curl -fsSL https://raw.githubusercontent.com/intenet1001-commits/cs_plugins/main/install.sh | bash
```

### Manual Clone

```bash
git clone https://github.com/intenet1001-commits/cs_plugins ~/.claude/plugins/marketplaces/cs_plugins
```

## Usage

After installation, trigger the skills by saying:

**playwright-test:**
- "Run Playwright test"
- "E2E test this project"
- "Web app performance test"

**report-writer:**
- "보고서 작성해줘"
- "Create a business report"
- "DOCX 문서 생성"

## Quick Start

1. **Install** (see [Installation](#installation) above)
2. **Restart Claude Code** to load the new plugins
3. **Use the skills**: `"Run Playwright test"` or `"보고서 작성해줘"`

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Test Coordinator                          │
├─────────────────────────────────────────────────────────────┤
│  Phase 1: Run Explorer first (generate page map)             │
│                                                              │
│  Phase 2: Run remaining 4 agents in parallel                 │
│           ┌──────────┬──────────┬──────────┬──────────┐      │
│           │Functional│  Visual  │   API    │Performance│      │
│           └──────────┴──────────┴──────────┴──────────┘      │
│                                                              │
│  Phase 3: Aggregate results and generate unified report      │
└─────────────────────────────────────────────────────────────┘
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `TEST_URL` | `http://localhost:9005` | Target URL for testing |
| `HEADLESS` | `true` | Hide browser window |
| `SLOW_MO` | `0` | Action delay time (ms) |
| `DEVTOOLS` | `false` | Open developer tools |

## Output Files

After test execution, results are generated in:

```
tests/
├── results/
│   ├── REPORT.md               # Unified markdown report
│   ├── page-map.json           # Page structure map
│   ├── functional-tests.json   # Functional test results
│   ├── visual-tests.json       # Visual test results
│   ├── api-tests.json          # API test results
│   └── performance-report.json # Performance metrics
└── screenshots/                # Responsive screenshots
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

Issues and pull requests are welcome!

## Links

- [Korean Documentation](README.ko.md)
- [GitHub Repository](https://github.com/intenet1001-commits/cs_plugins)
