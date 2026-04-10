# playwright-test-v5 자동 실행 설정

## 세션 시작 시 자동 행동

이 디렉토리(`playwright-test-v5`)에서 Claude Code 세션이 시작되면:

1. **즉시 사용자에게 다음을 안내**:
   ```
   playwright-test-v5 디렉토리입니다.
   테스트할 URL을 입력하면 14개 AI 에이전트 팀이 자동으로 실행됩니다.
   ```

2. **URL 감지 자동 실행**: 사용자 메시지에 `http://` 또는 `https://`가 포함되면 `/playwright-test` 스킬을 즉시 실행 (명시적 명령 불필요)

3. **`/playwright-test` 명령**: URL과 함께 또는 단독으로 입력하면 agent teams 시작

## URL 자동 트리거 규칙

사용자가 URL만 입력한 경우 (예: `https://example.com`):
→ 즉시 `playwright-test-v5:playwright-test` 스킬을 해당 URL로 실행

사용자가 URL 없이 메시지를 보낸 경우:
→ AskUserQuestion으로 테스트할 URL 요청

## Agent Teams 구성 (14개)

- **build-validator**: 빌드/보안/의존성 사전 검증
- **test-lead**: 팀 리더 및 최종 리포트 생성
- **page-explorer**: 페이지 구조 + OG/PWA 분석
- **functional-tester**: 기능/인터랙션 + DB 반영
- **visual-inspector**: UI/접근성/반응형
- **api-interceptor**: 네트워크 + og:image 검증
- **perf-auditor**: Core Web Vitals 성능 측정
- **social-share-auditor**: OG/KakaoTalk/PWA 검증
- **db-validator**: DB CRUD 실제 동작 검증
- **touch-interaction-validator**: 터치/스와이프 인터랙션 (v5 신규)
- **image-optimizer**: 이미지 최적화 분석 (v5 신규)
- **security-auditor**: HTTP 보안 헤더·쿠키 플래그·민감정보 감사 *(v5 신규)*
- **seo-auditor**: 메타태그·canonical·robots.txt·sitemap·구조화 데이터 *(v5 신규)*
- **error-resilience**: 404 페이지·콘솔에러·깨진링크·에러바운더리 *(v5 신규)*

## 허용 도구

TeamCreate, Task, TaskCreate, TaskUpdate, TaskList, TaskGet, SendMessage, ToolSearch
