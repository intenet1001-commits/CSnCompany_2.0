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

### 4. Electron osascript 자식 프로세스에서 keystroke silent fail — click menu item 사용 (2026-04-27)

- **상황**: Electron 글로벌 단축키로 스니펫 실행 시 `osascript -e 'keystroke "v" using command down'`이 exit 0을 반환하지만 텍스트가 삽입되지 않음.
- **발견**: Electron 자식 프로세스(exec)에서 System Events keystroke "v" using command down은 sandbox/권한 문제로 silent fail. `click menu item "Paste" of menu "Edit" of menu bar item "Edit" of menu bar 1`이 유일하게 신뢰 가능한 대안. 또한 런처 창이 열릴 때 frontmost app을 미리 캡처(previousApp)하지 않으면 창 활성화 후 CS-all 자신이 target이 되는 문제 발생.
- **교훈**: Electron에서 클립보드 → 붙여넣기 자동화: ① showLauncher() 시점에 osascript로 frontmost 저장(previousApp) ② 스니펫 실행 시 autoPaste(value, previousApp) 전달 ③ 붙여넣기는 click menu item "Paste" 방식 사용. keystroke "v" using command down은 Electron 자식 프로세스에서 사용 금지.

### 5. React useState stale closure — async chain의 setData 직후 동일 클로저 data 참조 금지 (2026-04-28)

- **상황**: PortalManager `saveSettings()`에서 `persist(next)` (내부 `setData(next)` + `await PortalAPI.save(next)`) 직후, 같은 onConfirm 클로저의 `syncSupabase()` 실행. devices 테이블 upsert 라인 `name: data.deviceName ?? deviceName ?? null` — React 배칭 때문에 `data.deviceName`은 옛 값, 사용자가 새로 입력한 useState `deviceName`은 신값인데 `??` 순서가 거꾸로라 옛 값이 이김 → Supabase에 새 이름이 영영 안 올라감.
- **발견**: `setX(next)` 는 마이크로태스크 큐에 들어가지만 같은 함수 스코프의 closure 변수는 await 후에도 갱신되지 않음. async chain에서 데이터 흐름은 항상 명시적으로 전달(인자 또는 ref)하거나, 새로 입력된 useState 값을 우선 참조해야 함.
- **교훈**: 코드 리뷰 시 `setX(...)` 직후 같은 함수에서 `x` 또는 `data` 같은 closure-captured 상태를 참조하는 패턴은 **반드시 의심**. 검토 체크리스트에 추가: "async fn 내 setData → 같은 함수 후속 분기가 data 참조? → 직접 인자 전달 또는 fresh useState 사용으로 대체". 비슷한 자기-덮어쓰기 패턴: `fetchKnownDevices()` 가 Supabase 응답으로 로컬 deviceName을 force-overwrite 했던 case도 동일한 클래스 — local-first 정책 명시 필요.

### 6. Next.js App Router createPortal → position:fixed 직접 사용 (2026-04-28)

- **상황**: MentionInput 드롭다운을 `createPortal(dropdown, document.body)` 로 구현. 로컬(npm run dev)에서는 정상, Vercel 프로덕션 빌드에서만 드롭다운 미표시.
- **발견**: Next.js App Router는 "use client" 컴포넌트도 초기 HTML을 서버에서 렌더링. `createPortal`은 `document.body`가 필요해 `mounted` state 체크로 SSR 방지했으나, hydration 타이밍 차이로 프로덕션에서 portal이 조용히 실패. `overflow:hidden` 부모 탈출이 목적이라면 `position:fixed`만으로 충분 — fixed는 CSS spec상 `overflow:hidden` 부모에 영향 받지 않음 (transform 없을 때).
- **교훈**: Next.js App Router에서 드롭다운/툴팁의 `overflow` 탈출은 `position:fixed + getBoundingClientRect()` 로 해결. `createPortal`은 SSR과 충돌 위험이 있어 꼭 필요한 경우(모달 배경 등)만 사용. 로컬과 프로덕션 차이가 있으면 hydration 타이밍 문제를 1순위로 의심.
