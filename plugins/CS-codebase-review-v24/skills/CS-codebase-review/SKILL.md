---
name: CS-codebase-review
user-invocable: false
description: 5-agent parallel codebase review
version: 1.0.0
---

# CS-codebase-review 노하우

### 1. Bun.spawn()에서 bare 'bash' ENOENT — 항상 /bin/bash 전체 경로 사용 (2026-04-24)

- **상황**: macOS에서 Bun.spawn() / spawn()으로 bash 명령을 실행 시 `ENOENT: no such file or directory, posix_spawn 'bash'` 에러 발생
- **발견**: Bun이 spawn할 때 PATH 환경변수가 없어 bare `bash`를 찾지 못함. 특히 api-server.ts가 Vite dev 서버 또는 Tauri에서 indirect하게 실행될 때 발생.
- **교훈**: `Bun.spawn()`/`spawn()` 커맨드 배열에는 항상 `"/bin/bash"` 전체 경로 사용. WSL 관련 spawn(`bash -c bashCmd`)은 예외 — Windows CMD에서 WSL로 넘기는 경우라 그대로 둬도 됨.

### 2. macOS 폴더 선택 다이얼로그 — 숨은 폴더 표시 + 상대 경로 자동 확장 (2026-04-24)

- **상황**: 프로젝트 폴더 열기에서 `.claude/...` 경로가 열리지 않음. Finder 다이얼로그에서 dot 폴더(.git, .claude 등)도 안 보임.
- **발견**: (1) AppleScript `choose folder`에 `invisibles shown true` 옵션 추가하면 숨은 폴더 표시. (2) open-folder API에서 `~`로 시작하거나 `/`로 시작하지 않는 경로는 `HOME + '/' + path`로 자동 확장하면 `.claude/`, `~/` 같은 편의 경로 모두 처리 가능.
- **교훈**: macOS 폴더 관련 API 구현 시 두 패턴 세트를 함께 적용. 입력 경로 정규화는 API 진입점에서 처리해야 클라이언트 측 버그를 방지할 수 있음.

### 3. AJPark 세션 기반 HTTP 자동화: form action 파싱 + manual redirect + Base64 인코딩 (2026-04-26)

- **상황**: JS onClick으로 form submit하는 레거시 파킹 시스템(AJPark)을 Playwright 없이 plain fetch로 자동화
- **발견**: form action에 jsessionid 포함(`login;jsessionid=XXX`), j_username=Base64(ID), j_password=plain text(SHA256 주석 처리됨). `redirect: 'manual'`로 각 redirect hop에서 쿠키를 개별 수집해야 세션 유지됨. `getSetCookie()` API(Node 18.14+)가 다중 Set-Cookie 헤더를 올바르게 처리함.
- **교훈**: 레거시 시스템 HTTP 자동화 시 ① HTML에서 form action 파싱(URL에 jsessionid 포함 여부 확인) ② `redirect: 'manual'`로 hop별 쿠키 수집 ③ 브라우저 DevTools로 실제 전송되는 필드와 인코딩 방식 확인 — 이 3단계를 먼저 수행할 것.
