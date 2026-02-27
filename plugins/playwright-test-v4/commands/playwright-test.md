---
description: "AI Agent Teams 기반 종합 웹 테스트 v4 - 9개 전문 에이전트 (빌드검증+DB검증+소셜공유 추가)"
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

9개의 전문 Claude AI 에이전트가 팀을 구성하여 대상 웹 앱을 심층 테스트합니다:

1. **build-validator** *(v4 신규)* - 빌드/보안 사전 검증 (CVE, tsconfig, Tailwind, 미커밋 파일)
2. **test-lead** - 팀 리더, 전체 오케스트레이션 및 리포트 생성
3. **page-explorer** - 페이지 탐색 및 구조 분석 (OG/PWA 메타 수집)
4. **functional-tester** - 기능/인터랙션 테스트 + DB 반영 확인
5. **visual-inspector** - UI/접근성/반응형 검사
6. **api-interceptor** - API/네트워크 분석 (og:image content-length 검증)
7. **perf-auditor** - 성능 측정 및 감사
8. **social-share-auditor** - OG 메타태그, og:image, KakaoTalk, PWA 검증
9. **db-validator** *(v4 신규)* - Supabase/DB CRUD 실제 동작 검증

## v4 신규 기능

### build-validator (Phase 0)
배포 전 다음 항목을 자동 탐지:
- **보안 취약점**: `npm audit` + Next.js CVE 버전 체크
  - 예: CVE-2025-66478 (15.1.7 이하 → Vercel 배포 차단)
- **tsconfig path alias**: `@/*` → `./src/*` 올바른지 확인
  - 오류 패턴: `"./src/*"` → `"./*"` 로 잘못 변경 시 전체 모듈 not found
- **Tailwind 호환성**: v4 프로젝트에서 v3 CSS 문법 사용 감지
  - 오류 패턴: `@tailwind base` 사용 시 v4에서 빌드 실패
  - 수정: `@import "tailwindcss"` + `@config "../../tailwind.config.ts"`
- **미커밋 필수 파일**: postcss.config.mjs, next.config.ts 등 git 누락 감지
- **위험한 미사용 import**: `cookies` from `next/headers` 미사용 시 빌드 실패
- **TypeScript 컴파일**: 소스 파일 타입 오류

### db-validator (Phase 2)
DB 연동 API를 실제로 호출하여 검증:
- Supabase 환경 변수 존재 확인
- POST → GET → DELETE CRUD 사이클 전체 검증
- 에러 처리 검증 (400/404 응답 확인)
- 응답 스키마 구조 검증

### functional-tester 강화
- 폼 제출 후 DB 반영 확인 (화면에 즉시 표시되는지)
- 네트워크 요청 검증 (올바른 API 엔드포인트로 가는지)

## 실행 흐름

- **Phase 0**: build-validator가 빌드/보안 사전 검증 (Playwright 불필요)
- **Phase 1**: page-explorer가 앱 구조 + OG/PWA 메타 파악, page-map 생성
- **Phase 2**: 7개 에이전트가 병렬로 심층 테스트 실행
- **Phase 3**: test-lead가 결과를 취합하여 REPORT.md 생성

## 출력

- `tests/results/build-report.json` - 빌드/보안 검증 *(v4 신규)*
- `tests/results/page-map.json` - 페이지 구조 맵
- `tests/results/functional-report.json` - 기능 테스트 결과
- `tests/results/visual-report.json` - 시각/접근성 결과
- `tests/results/api-report.json` - API/네트워크 분석 (og:image 검증 포함)
- `tests/results/performance-report.json` - 성능 감사
- `tests/results/social-share-report.json` - 소셜 공유 & PWA
- `tests/results/db-report.json` - DB/API CRUD 검증 *(v4 신규)*
- `tests/results/REPORT.md` - 종합 리포트

## 사전 요구사항

- **Playwright MCP 서버**: Phase 1-2에 필요 (Phase 0 빌드 검증은 불필요)
- **curl**: og:image 및 API 검증에 사용
- **Python 3**: 환경 변수 및 설정 파싱에 사용

## 참고

자세한 실행 프로토콜: `skills/playwright-test/SKILL.md`
각 에이전트 동작 정의: `agents/*.md`
