---
name: CS-codebase-review
user-invocable: true
description: |
  5-agent parallel codebase review skill. Use when user types "/CS-codebase-review", "코드베이스 리뷰",
  "전체 코드 리뷰", "codebase review", "코드 전체 분석", or wants a comprehensive parallel review
  covering architecture, quality, security, performance, and maintainability.
version: 1.0.0
---

# CS-codebase-review - 5관점 병렬 코드 리뷰

## 개요

`review-lead` 에이전트가 5개의 전문 분석 에이전트 팀을 조율하여 코드베이스 종합 리뷰 리포트를 생성합니다.

main context는 review-lead 하나만 스폰하고, review-lead가 팀 오케스트레이션 전체를 담당합니다.
이 방식으로 main context에 5개 에이전트의 raw output이 누적되지 않아 토큰 효율이 높습니다.

## 사용법

```
/CS-codebase-review                         # 현재 디렉토리 전체 분석
/CS-codebase-review [path]                  # 특정 경로 분석
/CS-codebase-review --focus architecture    # 아키텍처만 분석
/CS-codebase-review [path] --focus security # 특정 경로 보안 분석
```

## 실행 프로토콜

### Step 1: 인자 파싱

```
CODEBASE_PATH = 지정 경로 (미지정 시 현재 작업 디렉토리)
FOCUS         = --focus [aspect] (선택: architecture/quality/security/performance/maintainability)
OUTPUT_DIR    = "review-results"
```

### Step 2: 시작 안내 출력

```
🔍 CS-codebase-review 시작
📂 분석 대상: [CODEBASE_PATH]
🎯 분석 범위: [FOCUS 또는 "전체 (5관점)"]
📁 결과 저장: [OUTPUT_DIR]/

review-lead 에이전트가 [N]개 분석 에이전트 팀을 조율합니다...
```

### Step 3: review-lead 에이전트 스폰

```
Task(
  subagent_type: "general-purpose",
  name: "review-lead",
  model: "sonnet",
  prompt: "당신은 CS-codebase-review의 review-lead입니다. 아래 컨텍스트로 코드 리뷰를 수행하세요.

CODEBASE_PATH: [CODEBASE_PATH]
FOCUS: [FOCUS 또는 "none"]
OUTPUT_DIR: [OUTPUT_DIR]

review-lead.md 프로토콜을 따라 분석 에이전트 팀을 오케스트레이션하고 REVIEW.md를 생성하세요."
)
```

review-lead가 5개 에이전트 조율, 결과 수집, REVIEW.md 합성을 모두 처리합니다.
review-lead 완료 후 결과를 사용자에게 전달합니다.

## 에러 처리

- **review-lead 실패**: 에러 메시지와 함께 수동 실행 방법 안내

## CS-codebase-review v1 노하우

- **토큰 효율**: review-lead가 하위 에이전트 결과를 자체 context에서 처리 → main context 오염 없음
- **--focus 활용**: 특정 관점만 빠르게 확인할 때 유용 (1개 에이전트만 스폰)
- **VERSION 파일**: 새 학습이 추가될 때마다 `/experiencing version-up review` 로 버전 증가

### 2. Security 에이전트에 OWASP Top 10 + STRIDE 위협 모델링 통합 (gstack /cso 학습, 2026-04-13)

- **상황**: 현재 Security 에이전트는 일반적인 코드 보안 검사에 그침. 체계적인 위협 모델 없음.
- **발견**: gstack `/cso`는 OWASP Top 10 + STRIDE(Spoofing, Tampering, Repudiation, Information Disclosure, DoS, Elevation) 위협 모델을 결합. daily 모드(8/10 확신도 게이트)와 comprehensive 모드(2/10 게이트) 구분. 비밀키 고고학(secrets archaeology) + 의존성 공급망 검사 포함.
- **교훈**: Security 에이전트 프로토콜에 OWASP Top 10 체크리스트 + STRIDE 매트릭스 추가. `--deep` 플래그로 comprehensive 모드 활성화 가능. 발견 항목에 `confidence: high|medium|low` 필드 추가.

### 3. High severity 발견 시 5-Why 루트 코즈 분석 추가 (gstack /investigate 학습, 2026-04-13)

- **상황**: review-lead가 high severity 이슈를 발견해도 "무엇이 문제인지"만 리포트. "왜 이 문제가 생겼는지" 분석 없음.
- **발견**: gstack `/investigate`는 증상→원인→근본원인 방향으로 5-Why 체인을 실행. root cause 없이 증상만 수정하면 같은 버그가 재발함.
- **교훈**: review-lead가 High severity 항목 발견 시 해당 항목에 대해 `/investigate` 식 3-Why 분석 추가 실행. REVIEW.md에 "근본 원인" 컬럼 추가.

### 4. localhost-only API의 path traversal 경고 처리 패턴 (2026-04-17)

- **상황**: `POST /api/git-pull`에서 `folderPath`를 검증 없이 `cwd`로 사용하여 CRITICAL 경고 발생
- **발견**: CORS wildcard + localhost-only 설계인 경우, 기존 동일 패턴 엔드포인트(예: `/api/open-folder`)와 비교하면 일관된 설계 결정임. 무조건 fix가 아닌 맥락 판단이 필요.
- **교훈**: Security 리뷰 시 "프로젝트 내 동일 패턴 존재 여부" 확인 후 severity 조정. localhost-only 명시 주석 또는 CLAUDE.md 문서화로 의도적 결정임을 표시하면 future reviewer 혼동 방지.

### 5. Windows WSL distro 감지 — `wsl --list` hang 패턴과 registry 대안 (2026-04-19)

- **상황**: Windows 앱에서 `wsl --list --quiet`로 WSL distro 목록을 조회하는 코드가 4초 이상 blocking됨
- **발견**: Docker Desktop이 WSL2 서비스를 점유 중이면 `wsl.exe`의 모든 하위 명령이 서비스 응답을 기다리며 hang. Windows Registry(`HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss`)에 각 distro의 `DistributionName`이 등록되어 있으므로 PowerShell로 즉시 조회 가능 (WSL 서비스 불필요).
- **교훈**: Windows WSL 관련 코드 리뷰 시 `wsl --list` 의존 패턴을 발견하면 registry 조회 대안 제안. PowerShell 1줄: `Get-ChildItem HKCU:/Software/Microsoft/Windows/CurrentVersion/Lxss | ForEach-Object { (Get-ItemProperty $_.PSPath).DistributionName }`

### 6. Windows에서 WSL 프로세스 SIGKILL 불가 — timeout 기반 중단 신뢰 불가 패턴 (2026-04-19)

- **상황**: WSL bash 명령에 `timeout`, `killSignal: 'SIGKILL'`을 설정해도 10초 이상 hang하는 코드 발견
- **발견**: Windows는 WSL2 프로세스에 SIGKILL을 전달하지 못함. `Bun.spawnSync`, Node.js `child_process.spawnSync`, Rust `child.kill()` 모두 WSL bash 프로세스를 종료하지 못함. Ubuntu WSL 미초기화(first-time setup) 상태에서는 `bash -c "echo ok"`가 interactive TTY를 기다리며 영구 blocking됨.
- **교훈**: Windows 코드에서 `wsl bash ... + timeout` 패턴을 발견하면 위험 플래그. bash 실행 테스트 대신 registry 존재 여부 확인으로 교체 제안. Rust/Node/Bun 어느 런타임이든 동일하게 적용.

### 7. Windows 크로스플랫폼 서브프로세스 호출 — cmd.exe / wt.exe / wsl bash 인용부호·세미콜론·환경 함정 (2026-04-19)

- **상황**: 포트관리기 tmux 버튼이 `cmd /c start wt wsl -- bash -c "..."`로 명령을 실행하는데 WSL 창만 빈 채로 열리고 claude가 실행되지 않는 버그 디버깅
- **발견** (3중 함정):
  1. **wt.exe의 `;` 해석**: Windows Terminal은 `;`를 subcommand 구분자로 취급하며 `"..."` 안에 있어도 동일. bashCmd에 `tmux kill-session; tmux new-session` 같이 세미콜론이 포함되면 명령이 쪼개져 "지정된 파일을 찾을 수 없음" not-found 에러 발생.
  2. **cmd.exe의 `\"` 미지원**: Windows CRT가 argv 빌드 시 내부 쌍따옴표를 `\"`로 escape하지만, cmd.exe는 이를 이해하지 못하고 단순 `"`로 파싱 → 내부 쌍따옴표가 있는 bashCmd는 중간에 끊겨 `bash -c` 인수가 사라지고 기본 WSL 셸만 열림.
  3. **non-login/non-interactive 셸**: `wsl -d Ubuntu -- bash -c`는 `.bashrc`·`.profile`을 로드하지 않아 nvm·`~/.npm-global/bin` 등 사용자 PATH가 비어있음. `npm i -g`로 설치한 CLI가 "command not found"로 조용히 실패.
- **교훈** (리뷰 체크리스트 추가):
  - Windows 대상 서브프로세스 호출 코드를 볼 때 다음 위험 패턴 플래그: bashCmd에 `;` 존재, bashCmd에 `"` 중첩, `wsl -- bash -c` 사용.
  - 권장 해결 패턴:
    - `bash -c` → `bash -lic`로 전환해 login+interactive 셸로 사용자 환경 완전 로드
    - `;` 대신 `(cmd1 || :) && cmd2` 또는 `&&` 체인 사용 (`:` = no-op 성공 반환)
    - 중첩 쌍따옴표 대신 단일 따옴표만 사용하고 escapeSq 헬퍼로 내부 `'` 처리 (`' → '\''`)
    - 실패 시 즉시 창 닫힘 방지: tmux inner를 `cmd || bash -l`로 감싸 login shell fallback 제공 → 사용자가 에러 메시지 확인 후 수동 진단 가능

### 8. Windows Terminal `;` 공격성 + PowerShell spawn 불안정 + TUI OSC override (2026-04-19)

- **상황**: 포트관리기 tmux/Claude 탭 타이틀 기능 구현 중 3개 파생 함정 발견 (위 #7 후속 학습)
- **발견**:
  1. **wt.exe의 `;`는 단일따옴표 안에서도 split됨**: #7에서 "쌍따옴표 안에서도" 언급했지만 **단일따옴표('...')도 뚫음**. 예: OSC 시퀀스 `printf '\033]0;TITLE\007'`의 `;`를 wt가 subcommand 구분자로 취급해 명령이 쪼개지고 "시스템에서 지정된 파일을 찾을 수 없음" 에러. **해결**: `\;`로 이스케이프 → wt가 literal `;`로 unescape해서 subprocess에 전달. bash 단일따옴표는 wt 파서를 속이지 못하므로 wt 레벨에서 처리 필수.
  2. **PowerShell `spawnSync`도 간헐적 5~15s timeout**: #5에서 registry 조회는 빠르다고 적었지만 실제 운영 중 PowerShell 프로세스 자체가 간헐적으로 hang 관찰. **reg.exe로 교체** 시 66ms 고정 응답 (100배+ 빠름). `reg query HKCU\...\Lxss /s /v DistributionName` 포맷 파싱이 간결.
  3. **네이티브 TUI 앱은 자체 OSC로 탭 타이틀 override**: claude/vim/htop 같은 TUI가 시작하면서 `\033]0;<app-title>\007`를 emit → `wt --title` 플래그로 설정한 타이틀이 즉시 덮여씀. tmux는 기본 `set-titles off`라서 자식 OSC를 외부 터미널로 forward 안 해서 isolation 제공. title 유지 필요하면 tmux 안에서 실행하거나 periodic re-emit 필요.
  - **#7 수정 사항**: #7에서 권장한 `bash -c → bash -lic` 전환은 **WSL pty 레이어에서 hang 유발 가능** (`-i` 플래그 특히 위험). 실제로 WSL default PATH가 이미 Windows PATH를 import하므로 `/mnt/c/Users/.../AppData/Roaming/npm`에서 npm global CLI 접근 가능 → `bash -c`로도 충분. nvm 전용 설치가 아니라면 `-lic` 불필요.
- **교훈** (리뷰 체크리스트 확장):
  - Windows 대상 스크립트 리뷰 시 **OSC/ANSI 이스케이프 시퀀스 안의 `;`**를 특히 주의. 단일따옴표 보호로는 부족 — wt에 `\;` 이스케이프 필수.
  - Windows 시스템 조회(`wsl`, `wmic`, registry)에서 `child_process.spawnSync('powershell', ...)` 패턴을 보면 `reg.exe`/`wmic`/`cmd /c` 대안 제안. PowerShell 시작 시간 자체가 수백 ms 이상이고 간헐 hang까지 있어 비용 대비 득실 나쁨.
  - TUI 앱 실행 시 **터미널 속성(title, palette, cursor, ...)의 소유권**을 명확히 추적. 누가 언제 OSC를 emit하는지 그래프 그려보면 디버깅 쉬움. isolation이 필요하면 tmux/screen 같은 멀티플렉서 경유.
  - `bash -i` 플래그를 `-c` 명령과 함께 쓰는 패턴(`bash -lic`, `bash -ic`)은 WSL 환경에서 hang 위험. login+interactive가 정말 필요한지 재검증.
