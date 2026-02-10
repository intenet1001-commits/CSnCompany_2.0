# Playwright Test v2 - AI Agent Teams 기반 종합 웹 테스트

## 개요

6개의 전문 Claude AI 에이전트로 구성된 팀이 대상 웹 앱을 심층 테스트합니다. 각 에이전트는 Playwright MCP 도구를 사용하여 실제 브라우저에서 테스트를 수행합니다.

## 사용법

```
/playwright-test [URL]
```

**예시**:
```
/playwright-test https://example.com
/playwright-test http://localhost:3000
```

## 에이전트 팀 구성

| 에이전트 | 역할 | Phase |
|----------|------|-------|
| **test-lead** | 팀 리더 - 오케스트레이션 및 리포트 생성 | 전체 |
| **page-explorer** | 페이지 탐색 및 구조 분석 | 1 |
| **functional-tester** | 기능/인터랙션 테스트 | 2 |
| **visual-inspector** | UI/접근성/반응형 검사 | 2 |
| **api-interceptor** | API/네트워크 분석 | 2 |
| **perf-auditor** | 성능 측정 및 감사 | 2 |

## 실행 프로토콜

이 스킬이 실행되면, 당신(실행 에이전트)이 **test-lead 역할**을 수행합니다. 아래 프로토콜을 정확히 따르세요.

### 사전 준비

1. URL 인자를 확인합니다. URL이 없으면 사용자에게 요청합니다.
2. 결과 디렉토리를 생성합니다:

```bash
mkdir -p tests/results tests/screenshots
```

### Playwright MCP 사전 검증

Phase 1 시작 전에 Playwright MCP 사용 가능 여부를 확인합니다:

```
ToolSearch(query: "+playwright navigate")
```

- ToolSearch 결과에 `mcp__playwright__browser_navigate`가 포함되어 있으면 → 정상 진행
- ToolSearch 결과에 Playwright 도구가 없으면 → 아래 메시지를 사용자에게 출력하고 중단:

```
❌ Playwright MCP 서버가 설정되지 않았습니다.

설정 방법:
1. Claude Code 설정에서 MCP 서버를 추가하세요
2. Playwright MCP 서버 패키지: @anthropic/mcp-playwright
3. 설정 후 다시 /playwright-test를 실행하세요
```

### Phase 1: 팀 생성 및 탐색

1. **팀 생성**: `TeamCreate`로 팀을 생성합니다.

```
TeamCreate(team_name: "playwright-test-v2", description: "AI 웹 테스트 팀")
```

2. **탐색 태스크 생성**:

```
TaskCreate(
  subject: "웹 앱 구조 탐색 및 page-map 생성",
  description: "대상 URL을 방문하여 페이지 구조, 라우트, 요소, 프레임워크를 분석하고 tests/results/page-map.json을 생성",
  activeForm: "웹 앱 구조 탐색 중"
)
```

3. **page-explorer 스폰**: Task tool로 에이전트를 스폰합니다.

```
Task(
  subagent_type: "general-purpose",
  name: "page-explorer",
  team_name: "playwright-test-v2",
  model: "sonnet",
  prompt: "당신은 page-explorer 에이전트입니다. agents/page-explorer.md의 프로토콜을 따릅니다.

대상 URL: [URL]

목표: Playwright MCP 도구를 사용하여 대상 URL의 웹 앱 구조를 탐색하고 tests/results/page-map.json을 생성하세요.

실행 순서:
1. ToolSearch로 Playwright 도구 로드 (+playwright navigate, +playwright snapshot, +playwright evaluate)
2. 대상 URL 방문 (browser_navigate)
3. 페이지 구조 분석 (browser_evaluate로 링크/폼/버튼/프레임워크 감지)
4. 주요 서브페이지 탐색 (최대 10개)
5. 동적 콘텐츠/SPA/인증 페이지 감지
6. tests/results/page-map.json 작성
7. TaskUpdate(taskId: [태스크ID], status: 'completed') 호출
8. SendMessage(type: 'message', recipient: 'test-lead', content: '탐색 완료. [발견페이지수]개 페이지, [폼수]개 폼, [버튼수]개 버튼 발견. 프레임워크: [감지결과]. page-map.json 생성 완료.', summary: 'page-map 생성 완료') 전송"
)
```

4. page-explorer 완료를 대기합니다.

### Phase 2: 병렬 심층 테스트

page-explorer 완료 후, `tests/results/page-map.json`을 읽고, **4개 에이전트를 동시에 스폰**합니다.

각 에이전트에게 공통으로 전달할 정보:
- 대상 URL
- page-map.json의 핵심 내용 요약
- 출력 파일 경로

먼저, 4개 심층 테스트 태스크를 생성하고 Phase 1 태스크에 대한 의존성을 설정합니다:

```
// Phase 1 태스크 ID를 [phase1TaskId]라 하면:
TaskCreate(subject: "기능 테스트 수행", description: "...", activeForm: "기능 테스트 진행 중")
TaskUpdate(taskId: [funcTaskId], addBlockedBy: [phase1TaskId])

TaskCreate(subject: "시각/접근성 검사 수행", description: "...", activeForm: "시각/접근성 검사 진행 중")
TaskUpdate(taskId: [visualTaskId], addBlockedBy: [phase1TaskId])

TaskCreate(subject: "API/네트워크 분석 수행", description: "...", activeForm: "API/네트워크 분석 진행 중")
TaskUpdate(taskId: [apiTaskId], addBlockedBy: [phase1TaskId])

TaskCreate(subject: "성능 감사 수행", description: "...", activeForm: "성능 감사 진행 중")
TaskUpdate(taskId: [perfTaskId], addBlockedBy: [phase1TaskId])
```

Phase 1 태스크가 완료되면, 4개 에이전트를 **하나의 메시지에서 4개의 Task 호출**로 병렬 스폰합니다:

#### functional-tester 스폰

```
Task(
  subagent_type: "general-purpose",
  name: "functional-tester",
  team_name: "playwright-test-v2",
  model: "sonnet",
  prompt: "당신은 functional-tester 에이전트입니다. agents/functional-tester.md의 프로토콜을 따릅니다.

대상 URL: [URL]
page-map 경로: tests/results/page-map.json

목표: page-map을 읽고 모든 기능적 요소를 테스트하여 tests/results/functional-report.json을 생성하세요.

실행 순서:
1. ToolSearch로 Playwright 도구 로드
2. tests/results/page-map.json 읽기
3. 네비게이션 테스트
4. 폼 테스트 (정상/에지케이스)
5. 버튼/인터랙션 테스트
6. 동적 콘텐츠 테스트
7. tests/results/functional-report.json 작성
8. TaskUpdate(taskId: [할당된태스크ID], owner: 'functional-tester') - 시작 시 owner 설정
9. TaskUpdate(taskId: [할당된태스크ID], status: 'completed') - 완료 시 상태 변경
10. SendMessage(type: 'message', recipient: 'test-lead', content: '기능 테스트 완료. 총 [N]개 테스트 중 [P]개 통과, [F]개 실패. 주요 이슈: [이슈요약]', summary: '기능 테스트 완료') 전송"
)
```

#### visual-inspector 스폰

```
Task(
  subagent_type: "general-purpose",
  name: "visual-inspector",
  team_name: "playwright-test-v2",
  model: "sonnet",
  prompt: "당신은 visual-inspector 에이전트입니다. agents/visual-inspector.md의 프로토콜을 따릅니다.

대상 URL: [URL]
page-map 경로: tests/results/page-map.json

목표: page-map을 읽고 반응형 디자인과 접근성을 검사하여 tests/results/visual-report.json을 생성하세요.

실행 순서:
1. ToolSearch로 Playwright 도구 로드
2. tests/results/page-map.json 읽기
3. 각 페이지를 3가지 뷰포트(Mobile 375x667, Tablet 768x1024, Desktop 1920x1080)에서 검사
4. 스크린샷 캡처 → tests/screenshots/
5. 접근성 검사 (alt 텍스트, ARIA, 레이블, 헤딩 구조 등)
6. 스크린샷 비교 및 레이아웃 검증
7. tests/results/visual-report.json 작성
8. TaskUpdate(taskId: [할당된태스크ID], owner: 'visual-inspector') - 시작 시 owner 설정
9. TaskUpdate(taskId: [할당된태스크ID], status: 'completed') - 완료 시 상태 변경
10. SendMessage(type: 'message', recipient: 'test-lead', content: '시각/접근성 검사 완료. 반응형 이슈 [N]개, 접근성 위반 [N]개. 등급: [등급]', summary: '시각/접근성 검사 완료') 전송"
)
```

#### api-interceptor 스폰

```
Task(
  subagent_type: "general-purpose",
  name: "api-interceptor",
  team_name: "playwright-test-v2",
  model: "sonnet",
  prompt: "당신은 api-interceptor 에이전트입니다. agents/api-interceptor.md의 프로토콜을 따릅니다.

대상 URL: [URL]
page-map 경로: tests/results/page-map.json

목표: 네트워크 트래픽과 API를 분석하여 tests/results/api-report.json을 생성하세요.

실행 순서:
1. ToolSearch로 Playwright 도구 로드
2. tests/results/page-map.json 읽기
3. 각 페이지의 네트워크 요청 캡처 및 분석
4. 콘솔 에러/경고 수집
5. HTTP 상태 코드 검증
6. API 응답 시간 분석
7. tests/results/api-report.json 작성
8. TaskUpdate(taskId: [할당된태스크ID], owner: 'api-interceptor') - 시작 시 owner 설정
9. TaskUpdate(taskId: [할당된태스크ID], status: 'completed') - 완료 시 상태 변경
10. SendMessage(type: 'message', recipient: 'test-lead', content: 'API 분석 완료. 총 [N]개 요청 중 실패 [F]개, 콘솔 에러 [E]개. 등급: [등급]', summary: 'API 분석 완료') 전송"
)
```

#### perf-auditor 스폰

```
Task(
  subagent_type: "general-purpose",
  name: "perf-auditor",
  team_name: "playwright-test-v2",
  model: "sonnet",
  prompt: "당신은 perf-auditor 에이전트입니다. agents/perf-auditor.md의 프로토콜을 따릅니다.

대상 URL: [URL]
page-map 경로: tests/results/page-map.json

목표: Core Web Vitals를 측정하고 성능 등급을 매겨서 tests/results/performance-report.json을 생성하세요.

실행 순서:
1. ToolSearch로 Playwright 도구 로드
2. tests/results/page-map.json 읽기
3. 각 페이지의 Core Web Vitals 측정 (FCP, LCP, CLS, TTFB)
4. DOM 크기 및 리소스 분석
5. 렌더링 블로킹 리소스 감지
6. 성능 등급 계산 및 최적화 제안
7. tests/results/performance-report.json 작성
8. TaskUpdate(taskId: [할당된태스크ID], owner: 'perf-auditor') - 시작 시 owner 설정
9. TaskUpdate(taskId: [할당된태스크ID], status: 'completed') - 완료 시 상태 변경
10. SendMessage(type: 'message', recipient: 'test-lead', content: '성능 감사 완료. 종합 등급: [등급]. FCP=[값], LCP=[값], CLS=[값], TTFB=[값]', summary: '성능 감사 완료') 전송"
)
```

### Phase 3: 결과 취합 및 리포트 생성

모든 에이전트가 완료되면:

1. **결과 파일 읽기**: 5개의 JSON 결과 파일을 모두 읽습니다.
   - `tests/results/page-map.json`
   - `tests/results/functional-report.json`
   - `tests/results/visual-report.json`
   - `tests/results/api-report.json`
   - `tests/results/performance-report.json`

2. **종합 등급 산출**:
   - 기능 테스트 통과율
   - 접근성 위반 수
   - API 에러 수
   - 성능 등급
   - 이들을 종합하여 A/B/C/D/F 등급 결정

3. **REPORT.md 생성**: `tests/results/REPORT.md`에 아래 형식으로 종합 리포트를 작성합니다.

```markdown
# Web Test Report

**대상 URL**: [url]
**테스트 일시**: [timestamp]
**테스트 소요 시간**: [duration]

---

## 종합 등급: [A/B/C/D/F]

[등급에 대한 간략한 설명]

---

## 1. 사이트 구조

- **발견된 페이지**: [count]개
- **감지된 프레임워크**: [framework]
- **주요 라우트**: [route list]
- **특이사항**: [SPA, 인증 페이지 등]

## 2. 기능 테스트 결과

| 항목 | 수치 |
|------|------|
| 총 테스트 | [count] |
| 통과 | [count] |
| 실패 | [count] |
| 통과율 | [rate]% |

### 주요 이슈
[이슈 목록]

## 3. 시각/접근성 검사

| 항목 | 수치 |
|------|------|
| 반응형 이슈 | [count] |
| 접근성 위반 | [count] |
| 스크린샷 수 | [count] |

### 주요 이슈
[이슈 목록]

## 4. API/네트워크 분석

| 항목 | 수치 |
|------|------|
| 총 요청 | [count] |
| 실패 요청 | [count] |
| 콘솔 에러 | [count] |
| 평균 응답시간 | [time]ms |

### 주요 이슈
[이슈 목록]

## 5. 성능 감사

| 메트릭 | 값 | 등급 |
|--------|-----|------|
| FCP | [value] | [grade] |
| LCP | [value] | [grade] |
| CLS | [value] | [grade] |
| TTFB | [value] | [grade] |
| 종합 | - | [grade] |

### 최적화 제안
[우선순위별 제안 목록]

## 6. 권장 개선사항

### 긴급 (High Priority)
[목록]

### 보통 (Medium Priority)
[목록]

### 낮음 (Low Priority)
[목록]

---

*이 리포트는 playwright-test-v2 AI Agent Teams에 의해 자동 생성되었습니다.*
```

4. **팀 종료**:
   각 에이전트에게 순차적으로 shutdown 요청을 보내고 응답을 확인합니다:
   ```
   // 각 에이전트별로:
   SendMessage(type: "shutdown_request", recipient: "page-explorer", content: "테스트 완료, 종료 요청")
   // → 에이전트가 shutdown_response(approve: true) 응답

   SendMessage(type: "shutdown_request", recipient: "functional-tester", content: "테스트 완료, 종료 요청")
   SendMessage(type: "shutdown_request", recipient: "visual-inspector", content: "테스트 완료, 종료 요청")
   SendMessage(type: "shutdown_request", recipient: "api-interceptor", content: "테스트 완료, 종료 요청")
   SendMessage(type: "shutdown_request", recipient: "perf-auditor", content: "테스트 완료, 종료 요청")
   ```
   - 모든 에이전트가 shutdown_response(approve: true)로 응답하면 `TeamDelete` 호출
   - 사용자에게 리포트 경로 안내:
   ```
   ✅ 테스트 완료! 결과 파일:
   - 종합 리포트: tests/results/REPORT.md
   - 기능 테스트: tests/results/functional-report.json
   - 시각/접근성: tests/results/visual-report.json
   - API/네트워크: tests/results/api-report.json
   - 성능 감사: tests/results/performance-report.json
   - 스크린샷: tests/screenshots/
   ```

## 에러 처리

- **page-explorer 실패**: "앱 구조 탐색에 실패했습니다" 메시지와 함께 종료
- **Phase 2 에이전트 실패**: 해당 섹션을 "N/A - 에이전트 실패"로 표시하고 나머지 결과로 리포트 생성
- **Playwright MCP 미설치**: "Playwright MCP 서버가 필요합니다" 안내 메시지 출력
- **URL 접근 불가**: "대상 URL에 접근할 수 없습니다" 에러 메시지

## 타임아웃

- 개별 에이전트: 15분
- 전체 테스트: 30분

## 출력 파일

```
tests/
├── results/
│   ├── page-map.json              # 페이지 구조 맵
│   ├── functional-report.json     # 기능 테스트 결과
│   ├── visual-report.json         # 시각/접근성 결과
│   ├── api-report.json            # API/네트워크 결과
│   ├── performance-report.json    # 성능 감사 결과
│   └── REPORT.md                  # 종합 리포트
└── screenshots/
    ├── {page}-mobile.png
    ├── {page}-tablet.png
    └── {page}-desktop.png
```

## 참고

- 이 스킬은 Playwright MCP 서버가 Claude Code에 설정되어 있어야 합니다.
- 각 에이전트는 ToolSearch를 통해 Playwright MCP 도구를 동적으로 로드합니다.
- 브라우저는 Playwright MCP가 관리하므로 별도 설치가 필요하지 않습니다.
