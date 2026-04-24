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
