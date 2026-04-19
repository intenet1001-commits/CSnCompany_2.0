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
