---
name: cs-ship
user-invocable: true
description: |
  Pre-PR validation gate. Use when user types "/cs-ship", "PR 만들기", "배포 준비",
  "구현 완료", or after /CS-plan implementation is done.
  4-agent team: pre-pr-validator, coverage-auditor, commit-crafter, ship-lead.
version: 1.0.0
---

# CS-ship - PR 전 최종 검증 게이트

## 개요

`ship-lead`가 3개 전문 에이전트를 조율하여 PR 생성 전 최종 품질 게이트를 실행합니다.

**핵심 원칙** (kimoring verify-implementation + gstack ship):
- 구현이 PLAN.md와 일치하는가? (3-Way 체크)
- Critical 경로에 테스트가 존재하는가?
- 커밋 메시지가 의미 있는가?
- 합격 기준 미달 시 자동 수정 제안

## 사용법

```
/cs-ship              # 현재 디렉토리 전체 검증
/cs-ship [path]       # 지정 경로 검증
/cs-ship --fix        # 발견된 이슈 자동 수정
```

## 합격 기준 (Pass = PR 승인)

| 항목 | 기준 | 실패 시 |
|------|------|---------|
| 스펙 준수 | PLAN.md 항목 ≥ 90% 구현됨 | Blocked |
| 커버리지 | Critical 경로 테스트 존재 | Warning |
| 커밋 품질 | 의미 있는 메시지 (WIP/fix misc 금지) | Auto-fix 제안 |

## 실행 프로토콜

### Step 0: ship-lead 스폰

```bash
BASE="$HOME/.claude/plugins/marketplaces/cs-plugins/plugins"
LATEST=$(ls -d "$BASE/cs-ship-v"* 2>/dev/null | sort -V | tail -1)
```

ship-lead 에이전트를 스폰하여 팀 오케스트레이션 위임.

### Step 1: 3개 에이전트 병렬 실행

**pre-pr-validator** (sonnet) — bkit 3-Way Contract + kimoring verify:
- PLAN.md 항목 목록 추출
- `git diff main` 또는 구현 파일에서 실제 구현 항목 확인
- 3-Way: PLAN.md ↔ 서버 구현 ↔ 클라이언트 호출 일치 여부
- 미구현 항목: MISSING, 부분 구현: PARTIAL, 완료: DONE
- MISSING 항목이 있으면 → Blocked

**coverage-auditor** (sonnet) — gstack ship + OMC verifier:
- Critical 경로 식별 (비즈니스 핵심 로직)
- 테스트 파일 존재 여부 체크
- VERIFIED/PARTIAL/MISSING 3단계 분류 (OMC 패턴)
- 3회 체크 후 MISSING이면 에스컬레이션 (gstack Iron Law)

**commit-crafter** (haiku) — kimoring merge-worktree:
- `git diff --stat` + `git log --oneline` 분석
- diff 내용 기반 고품질 커밋 메시지 자동 생성
- 금지 패턴 탐지: "WIP", "fix misc", "update", "temp", "asdf"
- Conventional Commits 포맷: `feat/fix/refactor/test: [설명]`

### Step 2: 3회 실패 시 강제 에스컬레이션 (gstack Iron Law)

coverage-auditor가 동일 커버리지 갭에 3회 연속 실패 시:
- "STUCK: [갭 설명]" 리포트 출력
- 추가 시도 금지
- 사용자에게 수동 확인 요청

### Step 3: SHIP-REPORT.md 생성

```markdown
# SHIP-REPORT.md — [날짜] PR 검증 결과

## 판정: ✅ PASS / ❌ BLOCKED / ⚠️ WARNINGS

## 스펙 준수 (pre-pr-validator)
| 항목 | 상태 |
|------|------|
| [PLAN.md 항목 1] | DONE/PARTIAL/MISSING |

## 커버리지 (coverage-auditor)
| 경로 | 테스트 | 상태 |
|------|--------|------|
| [핵심 경로] | [테스트 파일] | VERIFIED/PARTIAL/MISSING |

## 커밋 메시지 제안 (commit-crafter)
```
[생성된 커밋 메시지]
```

## 액션 아이템
1. [Critical — 반드시 수정]
2. [Warning — 권장 수정]
```

### Step 4: 완료 안내

```
✅ CS-ship 완료 — [PASS/BLOCKED/WARNINGS]
📄 SHIP-REPORT.md 생성됨

[PASS] → git commit -m "[커밋 메시지]" && gh pr create
[BLOCKED] → 미구현 항목 수정 후 재실행
[WARNINGS] → 확인 후 진행 여부 결정
```

---

## CS-ship v1 노하우

### 1. pre-pr-validator는 PLAN.md 없어도 동작한다 (2026-04-21)

- **상황**: PLAN.md가 없는 기존 구현에 /cs-ship 실행 시 참조 문서 부재.
- **발견**: PLAN.md가 없으면 git log에서 커밋 히스토리를 읽어 "구현 의도"를 역추론 가능. 커밋 메시지 + 파일명 패턴으로 도메인 파악.
- **교훈**: pre-pr-validator: PLAN.md 있으면 3-Way 체크, 없으면 git log 역추론 모드. 두 모드 모두 DONE/PARTIAL/MISSING 분류 출력.

### 2. commit-crafter는 haiku 모델로도 충분 (2026-04-21)

- **상황**: 커밋 메시지 생성은 단순 텍스트 요약 작업. 고성능 모델 불필요.
- **발견**: OMC + plugins-for-claude-natives 모두 단순 스캔/요약 작업에 haiku 모델 할당.
- **교훈**: commit-crafter는 haiku. `git diff --stat` 출력 분석 후 Conventional Commits 포맷으로 요약. 30초 내 완료.
