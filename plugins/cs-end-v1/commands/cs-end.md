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

## 실행 방식

```bash
BASE="$HOME/.claude/plugins/marketplaces/CSnCompany_2-0/plugins"
LATEST_EXP=$(ls -d "$BASE/cs-experiencing-v"* 2>/dev/null | sort -V | tail -1)
SKILL="$LATEST_EXP/skills/experiencing/SKILL.md"
```

`$SKILL`의 프로토콜에 따라 4-Agent를 단일 메시지에 병렬 스폰하여 실행합니다.

## 사용 예

```
/cs-end                  # 표준 종료 (분석 → 버전업 → push)
/cs-end --no-push        # push 생략 (로컬만)
/cs-end --learning-only  # 학습 추출/저장만 (버전업/push 생략)
```
