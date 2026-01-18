# CS Plugins - Claude Code Plugin Collection

A collection of Claude Code plugins for web application testing and automation.

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

## Installation

```bash
# Install via GitHub URL
/plugin install https://github.com/intenet1001-commits/cs_plugins
```

## Usage

After installation, trigger the skill by saying:

- "Run Playwright test"
- "E2E test this project"
- "Web app performance test"
- "Run functional tests"
- "Check accessibility"

## Quick Start

1. **Install the plugin**:
   ```bash
   /plugin install https://github.com/intenet1001-commits/cs_plugins
   ```

2. **Start your development server**:
   ```bash
   npm run dev
   ```

3. **Ask Claude to run tests**:
   ```
   "Playwright 테스트 실행해줘"
   "Run E2E tests on this project"
   ```

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
