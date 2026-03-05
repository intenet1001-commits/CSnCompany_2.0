# Playwright Test v5 - AI Agent Teams 기반 종합 웹 테스트

## 개요

11개의 전문 Claude AI 에이전트로 구성된 팀이 대상 웹 앱을 심층 테스트합니다.
v5에서는 **터치 인터랙션 검증** + **이미지 최적화 분석**이 추가됩니다.
(MWC 2026 세션에서 발견된 실제 버그 패턴 기반)

## 사용법

```
/playwright-test [URL]
```

## 에이전트 팀 구성

| 에이전트 | 역할 | Phase | v5 변경 |
|----------|------|-------|---------|
| **build-validator** | 빌드/보안/의존성 사전 검증 | 0 | v4 유지 |
| **test-lead** | 팀 리더 - 오케스트레이션 및 리포트 생성 | 전체 | 11개 에이전트 관리 |
| **page-explorer** | 페이지 탐색 및 구조 분석 | 1 | v4 유지 |
| **functional-tester** | 기능/인터랙션 + DB 반영 테스트 | 2 | v4 유지 |
| **visual-inspector** | UI/접근성/반응형 검사 | 2 | v4 유지 |
| **api-interceptor** | API/네트워크 분석 + og:image 검증 | 2 | v4 유지 |
| **perf-auditor** | 성능 측정 및 감사 | 2 | v4 유지 |
| **social-share-auditor** | OG·og:image·KakaoTalk·PWA 검증 | 2 | v4 유지 |
| **db-validator** | DB CRUD 실제 동작 검증 | 2 | v4 유지 |
| **touch-interaction-validator** | 터치/스와이프 인터랙션 검증 | 2 | **v5 신규** |
| **image-optimizer** | 이미지 용량·WebP·Next.js Image 검증 | 2 | **v5 신규** |

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

### Phase 0: 빌드/배포 사전 검증 (Playwright 불필요)

```
TeamCreate(team_name: "playwright-test-v5", description: "AI 웹 테스트 팀 v5")

TaskCreate(
  subject: "빌드/보안/의존성 사전 검증",
  description: "npm audit, tsconfig, Tailwind 호환성, 미커밋 파일, TypeScript 컴파일 체크",
  activeForm: "빌드 사전 검증 중"
)

Task(
  subagent_type: "general-purpose",
  name: "build-validator",
  team_name: "playwright-test-v5",
  prompt: """당신은 playwright-test-v5의 build-validator입니다.
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
  team_name: "playwright-test-v5",
  prompt: """당신은 playwright-test-v5의 page-explorer입니다.
[URL]을 탐색하고 tests/results/page-map.json을 생성하세요.
OG 메타태그(og:image 포함)와 PWA 정보도 수집하세요.
agents/page-explorer.md의 프로토콜을 따르세요."""
)
```

page-explorer 완료 대기 (SendMessage 수신)

### Phase 2: 병렬 테스트 (9개 에이전트 동시)

```
Task(name: "functional-tester", ...)              # 기능 + DB 반영 확인
Task(name: "visual-inspector", ...)               # UI/접근성
Task(name: "api-interceptor", ...)                # 네트워크 + og:image
Task(name: "perf-auditor", ...)                   # 성능
Task(name: "social-share-auditor", ...)           # OG/KakaoTalk/PWA
Task(name: "db-validator", ...)                   # DB CRUD
Task(name: "touch-interaction-validator", ...)    # 터치/스와이프 (v5 신규)
Task(name: "image-optimizer", ...)                # 이미지 최적화 (v5 신규)
```

**touch-interaction-validator 프롬프트**:
```
당신은 playwright-test-v5의 touch-interaction-validator입니다.
대상 URL: [URL]
출력 파일: tests/results/touch-report.json

agents/touch-interaction-validator.md의 프로토콜을 따르세요.
주요 작업:
1. onTouchStart/onTouchEnd 핸들러가 있는 파일 탐지
2. touch-action CSS 미설정 탐지 (스와이프 무반응 원인)
3. 동적 src img에 key prop 누락 탐지
4. 100vh vs 100dvh 사용 현황 확인
5. 스와이프 임계값 패턴 분석
6. Playwright로 실제 스와이프 시뮬레이션 (가능한 경우)
```

**image-optimizer 프롬프트**:
```
당신은 playwright-test-v5의 image-optimizer입니다.
대상 URL: [URL]
출력 파일: tests/results/image-report.json

agents/image-optimizer.md의 프로토콜을 따르세요.
주요 작업:
1. public/ 디렉토리 이미지 용량 스캔 (1MB+ 탐지)
2. WebP/AVIF 사용 현황 확인
3. Next.js <Image> vs <img> 직접 사용 탐지
4. Next.js Image sizes prop 설정 검증
5. 실제 URL 이미지 응답 크기 확인 (curl)
6. WebP 변환 가이드 생성
```

### Phase 3: 결과 취합 및 REPORT.md 생성

10개 JSON 파일 읽기 후 REPORT.md 생성 (touch + image 섹션 포함).
팀 종료: shutdown_request → shutdown_response 확인 → TeamDelete.

---

## v5 핵심 노하우 (MWC 2026 세션 학습)

### 1. touch-action 미설정 → 스와이프 무반응 (Critical)
- **증상**: `onTouchStart`/`onTouchEnd` 핸들러가 있는데 스와이프가 동작 안 함
- **원인**: `touch-action` CSS 미설정 → 브라우저가 수평 제스처를 가로채서 핸들러 미호출
- **해결**: 스와이프 컨테이너에 `style={{ touchAction: 'pan-y' }}` 추가
- **핀치줌+스와이프**: `touchAction: 'pan-x pan-y pinch-zoom'`
- **탐지**: `grep -rn "onTouchStart" src/` → 같은 파일에 `touchAction` 없으면 위험

### 2. React modal 이미지 교체 불가 (key prop 누락)
- **증상**: `modalPage` state 변경 → 페이지 번호는 증가하지만 이미지가 안 바뀜
- **원인**: React가 같은 `<img>` DOM 요소 재사용 → src 변경만으로는 브라우저 줌 상태 미리셋
- **해결**: `<img key={modalPage} src={...} />` → 강제 리마운트

### 3. PDF/대용량 이미지 최적화
- **발견**: PDF 9페이지 JPG 변환 → 페이지당 2.4~3.7MB, 총 ~26MB
- **영향**: 느린 네트워크(MWC 현장 Wi-Fi)에서 수십 초 로딩
- **해결**: WebP 변환 시 ~60% 절감 (페이지당 ~1MB)
  ```python
  pix.save(f'page-{i+1:02d}.webp')  # PyMuPDF WebP 저장
  ```

### 4. 100vh vs 100dvh (iOS Safari)
- **증상**: iOS Safari에서 모달이 주소창에 가려짐
- **해결**: `100dvh` (dynamic viewport height) 사용

### 5. 스와이프 임계값 최적값
```typescript
// 탭 네비게이션 (낮은 임계값 - 빠른 반응)
if (dt < 500 && Math.abs(dx) > 40 && Math.abs(dx) > Math.abs(dy)) { ... }

// 풀스크린 모달 뷰어 (높은 임계값 - 핀치줌과 구별)
if (dt < 400 && Math.abs(dx) > 60 && Math.abs(dx) > Math.abs(dy) * 1.5) { ... }
```

### 6. landscape 모드 이미지 클리핑 방지
- **해결**: `maxHeight: calc(100dvh - 96px)` → 헤더 높이를 제외한 실제 뷰포트

## v4 핵심 노하우 (계승)

### 7. Vercel 배포 차단: CVE-2025-66478
- Next.js 15.1.7 이하 → Vercel 배포 차단
- **해결**: `npm install next@latest`

### 8. tsconfig path alias 오류
- `"@/*": ["./*"]` → `"@/*": ["./src/*"]` 로 수정

### 9. Tailwind v4 CSS 호환성
- `@tailwind base` → `@import "tailwindcss"` 교체

### 10. og:image content-length: 0 버그
- **탐지**: `curl -sI [og:image URL] | grep content-length` → 0
- **해결**: 정적 PNG + 절대 URL

---

## 출력 파일 목록

| 파일 | 담당 에이전트 | 내용 |
|------|-------------|------|
| `tests/results/build-report.json` | build-validator | 빌드/보안/의존성 검증 |
| `tests/results/page-map.json` | page-explorer | 페이지 구조 + OG/PWA |
| `tests/results/functional-report.json` | functional-tester | 기능 + DB 반영 |
| `tests/results/visual-report.json` | visual-inspector | 시각/접근성 |
| `tests/results/api-report.json` | api-interceptor | 네트워크 + og:image |
| `tests/results/performance-report.json` | perf-auditor | Core Web Vitals |
| `tests/results/social-share-report.json` | social-share-auditor | OG/KakaoTalk/PWA |
| `tests/results/db-report.json` | db-validator | DB CRUD 검증 |
| `tests/results/touch-report.json` | touch-interaction-validator | 터치/스와이프 검증 *(v5)* |
| `tests/results/image-report.json` | image-optimizer | 이미지 최적화 분석 *(v5)* |
| `tests/results/REPORT.md` | test-lead | 종합 리포트 |
