---
description: "AI Agent Teams 기반 종합 웹 테스트 v5 - 11개 전문 에이전트 (터치인터랙션+이미지최적화 추가)"
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

11개의 전문 Claude AI 에이전트가 팀을 구성하여 대상 웹 앱을 심층 테스트합니다:

1. **build-validator** - 빌드/보안 사전 검증 (CVE, tsconfig, Tailwind, 미커밋 파일)
2. **test-lead** - 팀 리더, 전체 오케스트레이션 및 리포트 생성
3. **page-explorer** - 페이지 탐색 및 구조 분석 (OG/PWA 메타 수집)
4. **functional-tester** - 기능/인터랙션 테스트 + DB 반영 확인
5. **visual-inspector** - UI/접근성/반응형 검사
6. **api-interceptor** - API/네트워크 분석 (og:image content-length 검증)
7. **perf-auditor** - 성능 측정 및 감사
8. **social-share-auditor** - OG 메타태그, og:image, KakaoTalk, PWA 검증
9. **db-validator** - Supabase/DB CRUD 실제 동작 검증
10. **touch-interaction-validator** *(v5 신규)* - 터치/스와이프 인터랙션 검증
11. **image-optimizer** *(v5 신규)* - 이미지 용량·WebP·Next.js Image 최적화 검증

## v5 신규 기능

### touch-interaction-validator (Phase 2)
MWC 2026 세션에서 발견된 실제 터치 버그 패턴 검증:
- **touch-action 미설정 탐지**: `onTouchStart` 핸들러가 있는데 `touch-action` CSS 없으면 스와이프 무반응
  - 수정: `style={{ touchAction: 'pan-y' }}` 추가
- **React key prop 누락**: 동적 src `<img>`에 `key` 없으면 모달에서 페이지 변경 시 이미지 미교체
  - 수정: `<img key={pageId} src={...} />`
- **100vh vs 100dvh**: iOS Safari 주소창 높이 처리
- **스와이프 임계값 분석**: 40px(탭 네비) vs 60px(모달 뷰어) 패턴
- **Playwright 스와이프 시뮬레이션**: 실제 터치 이벤트 dispatch

### image-optimizer (Phase 2)
MWC 세션에서 발견된 이미지 최적화 이슈:
- **대용량 이미지 탐지**: 1MB+ 이미지 (PDF→JPG 변환 시 페이지당 2-4MB 발생)
- **WebP 사용 현황**: JPG/PNG 대비 WebP ~60% 절감 가능
- **Next.js Image 컴포넌트 검증**: `<img>` 직접 사용 시 자동 최적화 미적용
- **WebP 변환 가이드**: `cwebp` 명령어 자동 생성

## 실행 흐름

- **Phase 0**: build-validator가 빌드/보안 사전 검증 (Playwright 불필요)
- **Phase 1**: page-explorer가 앱 구조 + OG/PWA 메타 파악, page-map 생성
- **Phase 2**: 9개 에이전트가 병렬로 심층 테스트 실행
- **Phase 3**: test-lead가 결과를 취합하여 REPORT.md 생성

## 출력

- `tests/results/build-report.json` - 빌드/보안 검증
- `tests/results/page-map.json` - 페이지 구조 맵
- `tests/results/functional-report.json` - 기능 테스트 결과
- `tests/results/visual-report.json` - 시각/접근성 결과
- `tests/results/api-report.json` - API/네트워크 분석 (og:image 검증 포함)
- `tests/results/performance-report.json` - 성능 감사
- `tests/results/social-share-report.json` - 소셜 공유 & PWA
- `tests/results/db-report.json` - DB/API CRUD 검증
- `tests/results/touch-report.json` - 터치/스와이프 인터랙션 검증 *(v5 신규)*
- `tests/results/image-report.json` - 이미지 최적화 분석 *(v5 신규)*
- `tests/results/REPORT.md` - 종합 리포트

## 사전 요구사항

- **Playwright MCP 서버**: Phase 1-2에 필요 (Phase 0 빌드 검증은 불필요)
- **curl**: og:image 및 API 검증에 사용
- **Python 3**: 환경 변수 및 설정 파싱에 사용

## 참고

자세한 실행 프로토콜: `skills/playwright-test/SKILL.md`
각 에이전트 동작 정의: `agents/*.md`
