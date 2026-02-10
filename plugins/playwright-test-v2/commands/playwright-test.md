---
description: "AI Agent Teams 기반 종합 웹 테스트 - 6개 전문 에이전트가 협력하여 웹 앱을 심층 분석합니다"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Task, ToolSearch, TaskCreate, TaskUpdate, TaskList, TaskGet, TeamCreate, TeamDelete, SendMessage
---

# /playwright-test [url]

AI Agent Teams를 활용한 종합 웹 앱 테스트를 실행합니다.

## 사용법

```
/playwright-test https://example.com
/playwright-test http://localhost:3000
```

## 설명

6개의 전문 Claude AI 에이전트가 팀을 구성하여 대상 웹 앱을 심층 테스트합니다:

1. **test-lead** - 팀 리더, 전체 오케스트레이션 및 리포트 생성
2. **page-explorer** - 페이지 탐색 및 구조 분석
3. **functional-tester** - 기능/인터랙션 테스트
4. **visual-inspector** - UI/접근성/반응형 검사
5. **api-interceptor** - API/네트워크 분석
6. **perf-auditor** - 성능 측정 및 감사

## 실행 흐름

- **Phase 1**: page-explorer가 앱 구조를 파악하고 page-map 생성
- **Phase 2**: 4개 에이전트가 병렬로 심층 테스트 실행
- **Phase 3**: test-lead가 결과를 취합하여 REPORT.md 생성

## 출력

- `tests/results/page-map.json` - 페이지 구조 맵
- `tests/results/functional-report.json` - 기능 테스트 결과
- `tests/results/visual-report.json` - 시각/접근성 검사 결과
- `tests/results/api-report.json` - API/네트워크 분석 결과
- `tests/results/performance-report.json` - 성능 감사 결과
- `tests/results/REPORT.md` - 종합 리포트

## 사전 요구사항

- **Playwright MCP 서버**: Claude Code에 Playwright MCP 서버가 설정되어 있어야 합니다
  - 미설치 시 자동으로 안내 메시지가 출력됩니다
  - 패키지: `@anthropic/mcp-playwright`
- **브라우저**: Playwright MCP가 자동 관리 (별도 설치 불필요)
- **디스크 공간**: 스크린샷 저장을 위한 여유 공간 필요

## 참고

자세한 실행 프로토콜은 이 플러그인의 `skills/playwright-test/SKILL.md`를 참조하세요.
각 에이전트의 동작 정의는 `agents/*.md` 파일에 명시되어 있습니다.
