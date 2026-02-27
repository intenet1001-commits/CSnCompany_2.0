# Playwright Test v3 - AI Agent Teams 기반 종합 웹 테스트

## 개요

7개의 전문 Claude AI 에이전트로 구성된 팀이 대상 웹 앱을 심층 테스트합니다.
v3에서는 **소셜 공유(KakaoTalk/SNS) 대응 검증**과 **PWA 유효성 검사**가 추가됩니다.

## 사용법

```
/playwright-test [URL]
```

## 에이전트 팀 구성

| 에이전트 | 역할 | Phase | v3 변경 |
|----------|------|-------|---------|
| **test-lead** | 팀 리더 - 오케스트레이션 및 리포트 생성 | 전체 | 7개 에이전트 관리, 소셜 섹션 추가 |
| **page-explorer** | 페이지 탐색 및 구조 분석 | 1 | OG/PWA 메타태그 수집 추가 |
| **functional-tester** | 기능/인터랙션 테스트 | 2 | 동일 |
| **visual-inspector** | UI/접근성/반응형 검사 | 2 | 동일 |
| **api-interceptor** | API/네트워크 분석 | 2 | og:image content-length 검증 추가 |
| **perf-auditor** | 성능 측정 및 감사 | 2 | 동일 |
| **social-share-auditor** | OG·og:image·KakaoTalk·PWA 검증 | 2 | **v3 신규** |

## 실행 프로토콜

이 스킬이 실행되면, 당신(실행 에이전트)이 **test-lead 역할**을 수행합니다.

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
- 없으면 → 아래 메시지 출력 후 중단:

```
❌ Playwright MCP 서버가 설정되지 않았습니다.

설정 방법:
1. Claude Code 설정에서 MCP 서버를 추가하세요
2. Playwright MCP 서버 패키지: @anthropic/mcp-playwright
3. 설정 후 다시 /playwright-test를 실행하세요
```

### Phase 1: 팀 생성 및 탐색

1. **팀 생성**:
```
TeamCreate(team_name: "playwright-test-v3", description: "AI 웹 테스트 팀 v3")
```

2. **탐색 태스크 생성**:
```
TaskCreate(
  subject: "웹 앱 구조 탐색 및 page-map 생성 (OG/PWA 메타 포함)",
  description: "대상 URL을 방문하여 페이지 구조, 라우트, OG 메타태그, PWA 정보를 분석하고 tests/results/page-map.json을 생성",
  activeForm: "웹 앱 구조 탐색 중"
)
```

3. **page-explorer 스폰**:
```
Task(
  subagent_type: "general-purpose",
  name: "page-explorer",
  team_name: "playwright-test-v3",
  prompt: "당신은 playwright-test-v3의 page-explorer입니다. [URL]을 탐색하고 tests/results/page-map.json을 생성하세요. OG 메타태그(og:image 포함)와 PWA 정보(manifest)도 반드시 수집해야 합니다. agents/page-explorer.md의 프로토콜을 따르세요."
)
```

4. page-explorer 완료 대기 (SendMessage 수신)

### Phase 2: 병렬 테스트 (5개 에이전트 동시 스폰)

page-map.json 확인 후:

```
Task(name: "functional-tester", team_name: "playwright-test-v3", ...)
Task(name: "visual-inspector",  team_name: "playwright-test-v3", ...)
Task(name: "api-interceptor",   team_name: "playwright-test-v3", ...)  // og:image 검증 포함
Task(name: "perf-auditor",      team_name: "playwright-test-v3", ...)
Task(name: "social-share-auditor", team_name: "playwright-test-v3", ...)  // v3 신규
```

social-share-auditor 프롬프트 예시:
```
당신은 playwright-test-v3의 social-share-auditor입니다.
대상 URL: [URL]
page-map.json 경로: tests/results/page-map.json (ogMeta, pwaInfo 필드 참조)
출력 파일: tests/results/social-share-report.json

agents/social-share-auditor.md의 프로토콜을 따르세요.
특히 og:image URL을 curl로 직접 fetch하여 content-length를 검증하는 것이 핵심입니다.
```

### Phase 3: 결과 취합 및 REPORT.md 생성

모든 에이전트 완료 후 6개 JSON 파일을 읽고 REPORT.md를 생성합니다.
소셜 공유 & PWA 섹션을 반드시 포함합니다.

## v3 핵심 노하우 (이번 세션 학습)

### og:image content-length: 0 버그
- **증상**: KakaoTalk/SNS 공유 시 썸네일이 표시되지 않음
- **원인**: Next.js edge runtime(`opengraph-image.tsx`)이 첫 실행 실패 시 Vercel이 0byte 응답을 캐시
- **탐지**: `curl -sI [og:image URL] | grep content-length` → `0`이면 버그
- **해결**: `opengraph-image.tsx` 삭제 + `public/og-image.png` 정적 파일 + `layout.tsx` 명시적 절대 URL

### Next.js opengraph-image.tsx 우선순위 버그
- **증상**: `metadata.openGraph.images` 설정해도 적용 안 됨
- **원인**: `app/opengraph-image.tsx` 파일이 존재하면 Next.js가 images 설정을 무시
- **탐지**: HTML에서 og:image URL에 `?[hash]`가 붙어있으면 edge route 사용 중
- **해결**: `opengraph-image.tsx` 삭제

### KakaoTalk OG 캐시
- 코드 수정 후에도 이전 결과가 계속 표시됨
- 해결: https://developers.kakao.com/tool/debugger/sharing 에서 캐시 초기화 필수

## 출력 파일 목록

| 파일 | 담당 에이전트 | 내용 |
|------|-------------|------|
| `tests/results/page-map.json` | page-explorer | 페이지 구조 + OG/PWA 메타 |
| `tests/results/functional-report.json` | functional-tester | 기능 테스트 결과 |
| `tests/results/visual-report.json` | visual-inspector | 시각/접근성 결과 |
| `tests/results/api-report.json` | api-interceptor | 네트워크 + og:image 검증 |
| `tests/results/performance-report.json` | perf-auditor | Core Web Vitals |
| `tests/results/social-share-report.json` | social-share-auditor | OG/KakaoTalk/PWA |
| `tests/results/REPORT.md` | test-lead | 종합 리포트 |
