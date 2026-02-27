# Playwright Test v4 - AI Agent Teams 기반 종합 웹 테스트

## 개요

9개의 전문 Claude AI 에이전트로 구성된 팀이 대상 웹 앱을 심층 테스트합니다.
v4에서는 **빌드/배포 사전 검증** + **DB CRUD 실제 동작 검증**이 추가됩니다.

## 사용법

```
/playwright-test [URL]
```

## 에이전트 팀 구성

| 에이전트 | 역할 | Phase | v4 변경 |
|----------|------|-------|---------|
| **build-validator** | 빌드/보안/의존성 사전 검증 | 0 | **v4 신규** |
| **test-lead** | 팀 리더 - 오케스트레이션 및 리포트 생성 | 전체 | 9개 에이전트 관리 |
| **page-explorer** | 페이지 탐색 및 구조 분석 | 1 | v3 유지 |
| **functional-tester** | 기능/인터랙션 + DB 반영 테스트 | 2 | DB 반영 확인 추가 |
| **visual-inspector** | UI/접근성/반응형 검사 | 2 | v3 유지 |
| **api-interceptor** | API/네트워크 분석 + og:image 검증 | 2 | 엔드포인트 직접 테스트 추가 |
| **perf-auditor** | 성능 측정 및 감사 | 2 | v3 유지 |
| **social-share-auditor** | OG·og:image·KakaoTalk·PWA 검증 | 2 | v3 유지 |
| **db-validator** | DB CRUD 실제 동작 검증 | 2 | **v4 신규** |

## 실행 프로토콜

이 스킬이 실행되면, 당신(실행 에이전트)이 **test-lead 역할**을 수행합니다.

### 사전 준비

1. URL 인자 확인. 없으면 사용자에게 요청.
2. 결과 디렉토리 생성:

```bash
mkdir -p tests/results tests/screenshots
```

### Playwright MCP 사전 검증 (Phase 1-2용)

```
ToolSearch(query: "+playwright navigate")
```

- `mcp__playwright__browser_navigate` 발견 → 정상
- 없음 → Phase 0 (build-validator)는 실행 가능, Phase 1-2는 경고 후 건너뜀

### Phase 0: 빌드/배포 사전 검증 (v4 신규, Playwright 불필요)

```
TeamCreate(team_name: "playwright-test-v4", description: "AI 웹 테스트 팀 v4")

TaskCreate(
  subject: "빌드/보안/의존성 사전 검증",
  description: "npm audit, tsconfig, Tailwind 호환성, 미커밋 파일, TypeScript 컴파일 체크",
  activeForm: "빌드 사전 검증 중"
)

Task(
  subagent_type: "general-purpose",
  name: "build-validator",
  team_name: "playwright-test-v4",
  prompt: """당신은 playwright-test-v4의 build-validator입니다.
현재 디렉토리의 Next.js/React 프로젝트를 분석하여 배포 전 문제를 탐지하세요.
agents/build-validator.md의 프로토콜을 따르세요.
결과를 tests/results/build-report.json에 저장하세요.
완료 후 test-lead에게 결과 요약을 SendMessage로 전송하세요."""
)
```

build-validator 완료 후:
- build-report.json 읽기
- grade가 F면: "⚠️ 빌드 검증 F등급: [이슈]" 를 사용자에게 표시
- 계속 진행 (배포 문제가 있어도 테스트는 유용)

### Phase 1: 팀 생성 및 탐색

```
TaskCreate(
  subject: "웹 앱 구조 탐색 및 page-map 생성",
  description: "대상 URL을 방문하여 페이지 구조, OG 메타태그, PWA 정보 분석",
  activeForm: "웹 앱 구조 탐색 중"
)

Task(
  subagent_type: "general-purpose",
  name: "page-explorer",
  team_name: "playwright-test-v4",
  prompt: """당신은 playwright-test-v4의 page-explorer입니다.
[URL]을 탐색하고 tests/results/page-map.json을 생성하세요.
OG 메타태그(og:image 포함)와 PWA 정보도 수집하세요.
agents/page-explorer.md의 프로토콜을 따르세요."""
)
```

page-explorer 완료 대기 (SendMessage 수신)

### Phase 2: 병렬 테스트 (7개 에이전트 동시)

```
Task(name: "functional-tester", ...)    # 기능 + DB 반영 확인
Task(name: "visual-inspector", ...)     # UI/접근성
Task(name: "api-interceptor", ...)      # 네트워크 + og:image
Task(name: "perf-auditor", ...)         # 성능
Task(name: "social-share-auditor", ...) # OG/KakaoTalk/PWA
Task(name: "db-validator", ...)         # DB CRUD (v4 신규)
```

**db-validator 프롬프트 예시**:
```
당신은 playwright-test-v4의 db-validator입니다.
대상 URL: [URL]
page-map.json 경로: tests/results/page-map.json
출력 파일: tests/results/db-report.json

agents/db-validator.md의 프로토콜을 따르세요.
주요 작업:
1. DB 기술 스택 탐지 (Supabase, Prisma 등)
2. 환경 변수 존재 확인
3. /api/comments CRUD 사이클 테스트
4. 에러 처리 검증 (400, 404 응답)
5. 응답 스키마 검증
```

**functional-tester 프롬프트 예시**:
```
당신은 playwright-test-v4의 functional-tester입니다.
대상 URL: [URL]
page-map.json 경로: tests/results/page-map.json
출력 파일: tests/results/functional-report.json

v4 강화 사항: 폼 제출 후 DB 반영 확인 (제출 전후 댓글 수 비교)
네트워크 요청으로 올바른 API 엔드포인트 호출 확인
agents/functional-tester.md의 프로토콜을 따르세요.
```

### Phase 3: 결과 취합 및 REPORT.md 생성

8개 JSON 파일 읽기 후 REPORT.md 생성 (build + db 섹션 포함).
팀 종료: shutdown_request → shutdown_response 확인 → TeamDelete.

---

## v4 핵심 노하우 (이번 세션 학습)

### 1. Vercel 배포 차단: Next.js 보안 취약점
- **CVE-2025-66478**: Next.js 15.1.7 이하 → Vercel이 배포 자체를 차단
- **탐지**: `npm audit` + `node -e "require('./node_modules/next/package.json').version"`
- **해결**: `npm install next@latest` (16.x+)

### 2. tsconfig path alias 오류
- **증상**: `Module not found: @/lib/utils`, `@/components/*` 전체 실패
- **원인**: `"@/*": ["./*"]` (프로젝트 루트) → src 하위 파일 못 찾음
- **탐지**: `tsconfig.json`의 `paths["@/*"]` 값 확인
- **해결**: `"@/*": ["./src/*"]` 로 수정

### 3. Tailwind v4 CSS 호환성 오류
- **증상**: `Cannot apply unknown utility class 'text-white'` 빌드 실패
- **원인**: Tailwind v4(`@tailwindcss/postcss`) + v3 CSS 문법(`@tailwind base`) 혼용
- **탐지**: package.json에서 `tailwindcss ^4` + globals.css에서 `@tailwind base` 확인
- **해결**:
  ```css
  /* 변경 전 (v3 문법) */
  @tailwind base;
  @tailwind components;
  @tailwind utilities;

  /* 변경 후 (v4 문법) */
  @import "tailwindcss";
  @config "../../tailwind.config.ts";  /* 커스텀 테마가 있는 경우 */
  ```

### 4. 미커밋 필수 파일 → Vercel 빌드 실패
- **증상**: 로컬에서는 동작하지만 Vercel에서 실패
- **원인**: `postcss.config.mjs`, `next.config.ts` 등이 git에 없음
- **탐지**: `git ls-files --error-unmatch [파일명]`
- **해결**: `git add [파일명] && git commit`

### 5. 위험한 미사용 import → PageNotFoundError
- **증상**: `Cannot find module for page: /api/admin/config` (Next.js 16)
- **원인**: `import { cookies } from "next/headers"` import만 하고 미사용
- **탐지**: import는 있는데 함수 본문에서 `cookies()` 미호출
- **해결**: 미사용 import 제거

### 6. Supabase CRUD 검증 패턴
```bash
# POST 테스트
curl -X POST "$BASE_URL/api/comments" \
  -H "Content-Type: application/json" \
  -d '{"type":"restaurant","placeId":"1","nickname":"테스터","content":"테스트","rating":5}'
# → 201 + {"comment": {"id": "..."}} 확인

# GET으로 반영 확인
curl "$BASE_URL/api/comments?type=restaurant&id=1"
# → comments 배열에 방금 생성한 id 포함 확인

# DELETE
curl -X DELETE "$BASE_URL/api/comments/[id]"
# → 200 + {"success": true} 확인
```

### 7. og:image content-length: 0 버그 (v3 계승)
- **원인**: Next.js edge runtime이 첫 실행 실패 시 Vercel이 0byte 캐시
- **탐지**: `curl -sI [og:image URL] | grep content-length` → 0
- **해결**: `opengraph-image.tsx` 삭제 + 정적 PNG + 절대 URL

---

## 출력 파일 목록

| 파일 | 담당 에이전트 | 내용 |
|------|-------------|------|
| `tests/results/build-report.json` | build-validator | 빌드/보안/의존성 검증 *(v4)* |
| `tests/results/page-map.json` | page-explorer | 페이지 구조 + OG/PWA |
| `tests/results/functional-report.json` | functional-tester | 기능 + DB 반영 |
| `tests/results/visual-report.json` | visual-inspector | 시각/접근성 |
| `tests/results/api-report.json` | api-interceptor | 네트워크 + og:image |
| `tests/results/performance-report.json` | perf-auditor | Core Web Vitals |
| `tests/results/social-share-report.json` | social-share-auditor | OG/KakaoTalk/PWA |
| `tests/results/db-report.json` | db-validator | DB CRUD 검증 *(v4)* |
| `tests/results/REPORT.md` | test-lead | 종합 리포트 |
