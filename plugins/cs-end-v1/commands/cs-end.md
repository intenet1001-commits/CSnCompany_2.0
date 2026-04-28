---
description: "CS 세션 종료 자동화 - 4-Agent 병렬 분석 → 학습 저장 → 활성 플러그인 버전업 → GitHub push (/cs-end)"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Task, Agent, AskUserQuestion
---

# /cs-end — CS Session Closing

세션을 안전하게 종료하면서 학습을 영속화하고 변경된 플러그인을 자동으로 버전업·푸시합니다.

## ⚠️ Author-Only Command

`/cs-end` is designed for the **plugin author** (`intenet1001-commits`). It commits and pushes changes back to the marketplace repository.

If you are not the author, Phase 4 (git push) is automatically skipped — your local learnings are still saved.

## 실행 순서

0. **Phase 0 — Origin 확인** (자동)
   ```bash
   REMOTE=$(git -C "$HOME/.claude/plugins/marketplaces/CSnCompany_2-0" remote get-url origin 2>/dev/null)
   if [[ "$REMOTE" != *"intenet1001-commits"* ]]; then
     AUTO_NO_PUSH=true  # Phase 4 skip
   fi
   ```
   `origin`이 `intenet1001-commits`가 아니면 자동으로 `--no-push` 모드로 전환합니다.

1. **Phase 1 — 4-Agent 병렬 분석**
   - `doc-updater` — 문서 업데이트 필요 항목 추출
   - `learning-extractor` — TIL/패턴/결정 사항 추출
   - `version-scout` — 변경된 플러그인 자동 탐지
   - `followup-suggester` — 다음 세션 follow-up 제안
2. **Phase 2 — 학습 영속화** (cs-experiencing 노하우 섹션 + CHANGELOG 갱신)
3. **Phase 3 — 변경 플러그인 버전업** (VERSION 파일 + plugin.json bump)
4. **Phase 4 — Git commit + push** (atomic commit, marketplace.json 동기화)
5. **Phase 5 — Push 완료 리포트** (두 레포 상태 명확 구분 출력)

## 실행 방식

```bash
BASE="$HOME/.claude/plugins/marketplaces/CSnCompany_2-0/plugins"
LATEST_EXP=$(ls -d "$BASE/cs-experiencing-v"* 2>/dev/null | sort -V | tail -1)
SKILL="$LATEST_EXP/skills/experiencing/SKILL.md"
```

`$SKILL`의 프로토콜에 따라 4-Agent를 단일 메시지에 병렬 스폰하여 실행합니다.

## Phase 5 — Push 완료 리포트

모든 phase가 끝난 뒤 두 레포의 push 상태를 **반드시 구분하여** 출력합니다.

### 탐지 로직

```bash
MARKETPLACE_DIR="$HOME/.claude/plugins/marketplaces/CSnCompany_2-0"
MARKETPLACE_NAME="CSnCompany_2-0"

# 작업 중인 프로젝트 레포 탐지 (마켓플레이스와 다른 git root)
PROJECT_DIR=$(git rev-parse --show-toplevel 2>/dev/null)
if [[ "$PROJECT_DIR" == "$MARKETPLACE_DIR" || -z "$PROJECT_DIR" ]]; then
  # CWD가 마켓플레이스 자체이거나 git repo가 없으면 세션 컨텍스트에서 추론
  PROJECT_DIR=""
fi
PROJECT_NAME=$(basename "$PROJECT_DIR" 2>/dev/null)

# 각 레포 push 상태 확인
check_push_status() {
  local dir="$1"
  local ahead
  ahead=$(git -C "$dir" rev-list --count @{u}..HEAD 2>/dev/null)
  local behind
  behind=$(git -C "$dir" rev-list --count HEAD..@{u} 2>/dev/null)
  local branch
  branch=$(git -C "$dir" branch --show-current 2>/dev/null)
  local remote
  remote=$(git -C "$dir" remote get-url origin 2>/dev/null | sed 's/.*github.com[:/]//' | sed 's/\.git$//')
  echo "$ahead|$behind|$branch|$remote"
}
```

### 출력 포맷

Phase 4 완료 직후, 다음 형식으로 출력합니다:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Push 완료 리포트
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [마켓플레이스]  CSnCompany_2-0
   ✅ PUSHED     branch: main → intenet1001-commits/CSnCompany_2-0
   (또는)
   ⏭️  SKIPPED   --no-push 모드 / author 아님

 [프로젝트]      <project-name>
   ✅ PUSHED     branch: main → <owner>/<repo>
   (또는)
   ⚠️  UNPUSHED  <N>개 커밋이 아직 remote에 없음
                 → git -C <path> push origin <branch>
   (또는)
   ─  해당없음   세션 중 별도 프로젝트 레포 없음

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 판정 기준

| 상태 | 조건 |
|------|------|
| `✅ PUSHED` | `ahead == 0` (local이 remote와 동일하거나 push 직후) |
| `⚠️ UNPUSHED` | `ahead > 0` (local에 push 안 된 커밋 존재) |
| `⏭️ SKIPPED` | `--no-push` 플래그 또는 `AUTO_NO_PUSH=true` |
| `─ 해당없음` | 프로젝트 레포 탐지 불가 또는 마켓플레이스와 동일 |

## 사용 예

```
/cs-end                  # 표준 종료 (분석 → 버전업 → push)
/cs-end --no-push        # push 생략 (로컬만)
/cs-end --learning-only  # 학습 추출/저장만 (버전업/push 생략)
```
