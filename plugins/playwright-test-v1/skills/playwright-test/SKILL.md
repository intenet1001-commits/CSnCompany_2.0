---
name: playwright-test
description: This skill should be used when user asks "test automation", "Playwright test", "E2E test", "web test", "multi-agent test", "functional/visual/API/performance test", "테스트 자동화", "웹 테스트", "기능 테스트", "성능 테스트", or wants to run comprehensive web application testing.
---

# Multi-Agent Playwright Test Automation

> Universal Web Application Test Framework using 5 Specialized Agents

## Purpose

Run comprehensive web application tests by executing 5 specialized agents in parallel:
- **Explorer**: Page discovery and DOM analysis
- **Functional**: Feature and interaction testing
- **Visual**: UI/UX and accessibility testing
- **API**: Network and API validation
- **Performance**: Load time and Core Web Vitals

## Protocol

### Phase 1: Environment Setup

Before running tests, ensure the environment is ready:

```bash
# Check if tests folder exists
ls tests/

# If not, create the test structure
mkdir -p tests/agents/{explorer,functional,visual,api,performance}
mkdir -p tests/shared
mkdir -p tests/results tests/screenshots tests/logs
```

Install dependencies:
```bash
npm install --save-dev playwright @playwright/test axe-core
npx playwright install chromium
```

Add scripts to package.json:
```json
{
  "scripts": {
    "test": "node tests/coordinator.js",
    "test:headless": "HEADLESS=true node tests/coordinator.js",
    "test:debug": "HEADLESS=false SLOW_MO=500 DEVTOOLS=true node tests/coordinator.js",
    "test:clean": "rm -rf tests/results tests/screenshots tests/logs"
  }
}
```

### Phase 2: Test Execution

1. **Start the target server** (Terminal 1):
```bash
npm run dev
# Or your app's startup command
```

2. **Run tests** (Terminal 2):
```bash
# Default execution (headless)
npm test

# Run on different port
TEST_URL=http://localhost:3000 npm test

# Run with visible browser
npm run test:debug
```

### Phase 3: Agent Execution Flow

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

### Phase 4: Result Analysis

Review generated reports:
- `tests/results/REPORT.md` - Unified markdown report
- `tests/results/page-map.json` - Page structure map
- `tests/results/functional-tests.json` - Functional test results
- `tests/results/visual-tests.json` - Visual test results
- `tests/results/api-tests.json` - API test results
- `tests/results/performance-report.json` - Performance metrics

## Agent Details

### Agent 1: Explorer (Discovery Specialist)
**File**: `tests/agents/explorer/index.js`

**Role**:
- BFS crawling of all pages/routes
- DOM structure analysis and selector extraction
- Interactive element catalog generation
- Automatic detection of buttons, forms, input fields

**Output**: `tests/results/page-map.json`

### Agent 2: Functional (Feature Testing Specialist)
**File**: `tests/agents/functional/index.js`

**Role**:
- Page load testing
- Button clickability testing
- Form validation
- Tab/navigation testing

**Output**: `tests/results/functional-tests.json`

### Agent 3: Visual (UI/UX Specialist)
**File**: `tests/agents/visual/index.js`

**Role**:
- Responsive screenshot capture (mobile/tablet/desktop)
- Layout overflow inspection
- Small touch target detection
- Accessibility (a11y) axe-core inspection

**Output**: `tests/results/visual-tests.json`, `tests/screenshots/*.png`

### Agent 4: API (Network Specialist)
**File**: `tests/agents/api/index.js`

**Role**:
- Automatic capture of all XHR/Fetch requests
- API response status code validation
- Request failure detection
- Error response logging

**Output**: `tests/results/api-tests.json`, `tests/results/network-logs.json`

### Agent 5: Performance (Performance Specialist)
**File**: `tests/agents/performance/index.js`

**Role**:
- Page load time measurement
- Core Web Vitals collection (FCP, LCP, CLS)
- Resource timing analysis
- Performance grade determination (A/B/C)

**Output**: `tests/results/performance-report.json`

**Performance Grade Criteria**:
- **A (Good)**: FCP ≤ 1.8s, Load ≤ 3s
- **B (Needs Improvement)**: FCP ≤ 3s, Load ≤ 5s
- **C (Poor)**: Otherwise

## Configuration

**File**: `tests/shared/config.js`

```javascript
module.exports = {
  baseUrl: process.env.TEST_URL || 'http://localhost:9005',

  agents: {
    explorer: { enabled: true, timeout: 15 * 60 * 1000 },
    functional: { enabled: true, timeout: 15 * 60 * 1000 },
    visual: { enabled: true, timeout: 15 * 60 * 1000 },
    api: { enabled: true, timeout: 15 * 60 * 1000 },
    performance: { enabled: true, timeout: 15 * 60 * 1000 }
  },

  browser: {
    headless: process.env.HEADLESS !== 'false',
    slowMo: parseInt(process.env.SLOW_MO) || 0,
    devtools: process.env.DEVTOOLS === 'true'
  },

  viewports: {
    mobile: { width: 375, height: 667 },
    tablet: { width: 768, height: 1024 },
    desktop: { width: 1920, height: 1080 }
  },

  paths: {
    results: './tests/results',
    screenshots: './tests/screenshots',
    logs: './tests/logs'
  },

  retry: {
    maxAttempts: 3,
    delay: 1000
  }
};
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `TEST_URL` | `http://localhost:9005` | Target URL for testing |
| `HEADLESS` | `true` | Hide browser window |
| `SLOW_MO` | `0` | Action delay time (ms) |
| `DEVTOOLS` | `false` | Open developer tools |

## Examples

### Basic Test Run
```bash
# Start server first
npm run dev

# Run all tests
npm test
```

### Test Different Port
```bash
TEST_URL=http://localhost:3000 npm test
```

### Debug Mode (Visible Browser)
```bash
npm run test:debug
```

### External Server Test
```bash
TEST_URL=https://staging.example.com npm test
```

### Disable Specific Agents
In `tests/shared/config.js`:
```javascript
agents: {
  explorer: { enabled: true },
  functional: { enabled: true },
  visual: { enabled: false },     // Disabled
  api: { enabled: true },
  performance: { enabled: false } // Disabled
}
```

## CI/CD Integration

### GitHub Actions Example
```yaml
- name: Run Multi-Agent Tests
  run: |
    npm ci
    npx playwright install chromium
    npm run dev &
    sleep 10
    npm test
  env:
    TEST_URL: http://localhost:3000
    HEADLESS: true

- name: Upload Test Results
  uses: actions/upload-artifact@v3
  with:
    name: test-results
    path: |
      tests/results/
      tests/screenshots/
```

## Completion Signal

When tests complete successfully:
```
<promise>MULTI_AGENT_COMPLETE</promise>
```

## Rules

1. **Server Required**: Target server must be running before testing
2. **Port Verification**: Set correct port via `TEST_URL` environment variable or `config.js`
3. **Chromium Required**: Run `npx playwright install chromium` on first execution
4. **Results Overwritten**: Previous results are overwritten each run
5. **Error Handling**: If an individual agent fails, other agents continue running
6. **Timeout**: Each agent has a maximum 15-minute timeout (adjustable in config)

## Troubleshooting

### Browser Not Installed
```bash
npx playwright install chromium
```

### Different Port
```bash
TEST_URL=http://localhost:YOUR_PORT npm test
```

### Timeout Occurs
Increase timeout in `tests/shared/config.js`:
```javascript
agents: {
  explorer: { enabled: true, timeout: 30 * 60 * 1000 }  // 30 minutes
}
```

### Exclude Specific Pages
Add to `explorePage()` in `tests/agents/explorer/index.js`:
```javascript
if (urlPath.includes('/admin') || urlPath.includes('/internal')) return;
```
