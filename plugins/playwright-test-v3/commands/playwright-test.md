---
description: "AI Agent Teams 기반 종합 웹 테스트 v3 - 7개 전문 에이전트 (소셜 공유/PWA 검증 추가)"
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

7개의 전문 Claude AI 에이전트가 팀을 구성하여 대상 웹 앱을 심층 테스트합니다:

1. **test-lead** - 팀 리더, 전체 오케스트레이션 및 리포트 생성
2. **page-explorer** - 페이지 탐색 및 구조 분석 (OG/PWA 메타 수집 포함)
3. **functional-tester** - 기능/인터랙션 테스트
4. **visual-inspector** - UI/접근성/반응형 검사
5. **api-interceptor** - API/네트워크 분석 (og:image content-length 검증 포함)
6. **perf-auditor** - 성능 측정 및 감사
7. **social-share-auditor** *(v3 신규)* - OG 메타태그 완전성, og:image 실제 응답 검증, KakaoTalk 공유 대응, PWA 유효성

## v3 신규 기능

### social-share-auditor
- `og:image` URL을 직접 fetch하여 `content-length` 검증
  - `content-length: 0` → **critical** (KakaoTalk 썸네일 불가 / edge route 캐시 버그)
- OG 메타태그 9개 완전성 체크 (og:title, og:description, og:url, og:image, og:image:width, og:image:height, og:image:alt, og:type, og:site_name)
- Twitter Card 완전성 체크
- Next.js `opengraph-image.tsx` edge route vs 정적 PNG 구분
- PWA manifest 필수 필드 검증 (name, icons, display)
- manifest 아이콘 `purpose` 필드 분리 여부 검사

### page-explorer 강화
- OG 메타태그 전체를 page-map.json에 수집
- PWA 관련 메타태그 수집 (manifest, apple-mobile-web-app-*)

### api-interceptor 강화
- og:image URL curl 검증 추가 (HTTP 상태 + content-length)
- og:image 타입 분류 (정적 파일 / Next.js edge route / 동적 API)

## 실행 흐름

- **Phase 1**: page-explorer가 앱 구조 + OG/PWA 메타 파악, page-map 생성
- **Phase 2**: 5개 에이전트가 병렬로 심층 테스트 실행
- **Phase 3**: test-lead가 결과를 취합하여 REPORT.md 생성

## 출력

- `tests/results/page-map.json` - 페이지 구조 맵 (OG/PWA 메타 포함)
- `tests/results/functional-report.json` - 기능 테스트 결과
- `tests/results/visual-report.json` - 시각/접근성 검사 결과
- `tests/results/api-report.json` - API/네트워크 분석 결과 (og:image 검증 포함)
- `tests/results/performance-report.json` - 성능 감사 결과
- `tests/results/social-share-report.json` - 소셜 공유 & PWA 결과 *(v3 신규)*
- `tests/results/REPORT.md` - 종합 리포트

## 사전 요구사항

- **Playwright MCP 서버**: Claude Code에 Playwright MCP 서버가 설정되어 있어야 합니다
- **브라우저**: Playwright MCP가 자동 관리 (별도 설치 불필요)
- **curl**: og:image 검증에 사용 (macOS/Linux 기본 포함)

## 참고

자세한 실행 프로토콜은 이 플러그인의 `skills/playwright-test/SKILL.md`를 참조하세요.
각 에이전트의 동작 정의는 `agents/*.md` 파일에 명시되어 있습니다.
