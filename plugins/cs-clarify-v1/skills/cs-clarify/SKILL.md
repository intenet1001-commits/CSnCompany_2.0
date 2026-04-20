---
name: cs-clarify
user-invocable: true
description: |
  Requirements clarification before planning. Use when user types "/cs-clarify", "요구사항 명료화",
  "뭐부터 시작", "범위 확인", or before /CS-plan when the request is vague or complex.
  4-agent Socratic elicitation: requirements-interviewer, scope-validator, assumption-mapper, clarify-lead.
version: 1.0.0
---

# CS-clarify - 요구사항 명료화

## 개요

`clarify-lead`가 3개 전문 에이전트를 조율하여 플랜/구현 전 요구사항을 명료화합니다.

**핵심 원칙** (Karpathy "Think Before Coding"):
- 해석이 여러 가지인 경우 하나를 선택하지 않는다
- "더 단순한 대안은?" 먼저 묻는다
- 숨겨진 가정을 명시화한다
- 성공 기준을 선언적으로 정의한다

## 사용법

```
/cs-clarify "기능 설명"          # 전체 명료화 (4-agent)
/cs-clarify --quick "기능 설명"  # 빠른 명료화 (인터뷰 3문항만)
```

## 실행 프로토콜

### Step 0: clarify-lead 스폰

```bash
BASE="$HOME/.claude/plugins/marketplaces/cs-plugins/plugins"
LATEST=$(ls -d "$BASE/cs-clarify-v"* 2>/dev/null | sort -V | tail -1)
```

clarify-lead 에이전트를 스폰하여 팀 오케스트레이션 위임.

### Step 1: 3개 에이전트 병렬 실행

**requirements-interviewer** (sonnet):
- Socratic 질문 생성: 목표, 제약, 성공 기준, 컨텍스트 4개 차원 평가
- 가장 약한 차원에 집중하여 1개 질문 생성 (라운드당 1개, 최대 3라운드)
- 사용자 답변을 AskUserQuestion으로 수집

**scope-validator** (sonnet):
- "시니어 엔지니어가 과대설계라 할 수 있는가?" 자기검증
- MVP 버전 vs 풀 버전 비교 제시
- YAGNI 원칙: 명시적으로 요청되지 않은 기능 제거

**assumption-mapper** (sonnet):
- 숨겨진 가정 목록화: 기술 선택, 사용자 행동, 인프라, 타이밍
- 각 가정에 위험도(High/Medium/Low) 레이블링
- 가정이 틀렸을 때 영향 분석

### Step 2: CLARIFY.md 생성

```markdown
# CLARIFY.md — [기능명] 요구사항 명료화

## Context Anchor
| | |
|---|---|
| WHY | [목적] |
| WHO | [대상 사용자] |
| RISK | [주요 위험] |
| SUCCESS | [성공 기준 — 검증 가능한 형태] |
| SCOPE | [포함/제외] |

## 성공 기준 (Goal-Driven 포맷)
1. [기준 1] → verify: [어떻게 확인하는가]
2. [기준 2] → verify: [어떻게 확인하는가]

## 확인된 가정
| 가정 | 위험도 | 틀렸을 때 영향 |
|------|--------|----------------|
| [가정 1] | High | [영향] |

## 범위 결정
- **포함**: [명시적 포함]
- **제외**: [명시적 제외 — YAGNI]
- **MVP 버전**: [최소 버전]

## 인터뷰 요약
[질문/답변 핵심 정리]
```

### Step 3: 완료 안내

```
✅ CS-clarify 완료
📄 CLARIFY.md 생성됨
🚀 다음 단계: /CS-plan "[기능]" --clarify CLARIFY.md
```

---

## CS-clarify v1 노하우

### 1. 인터뷰는 라운드당 1개 질문만 (OMC deep-interview 학습, 2026-04-21)

- **상황**: 여러 질문을 한 번에 던지면 사용자가 일부만 답변하거나 가장 쉬운 것만 답함.
- **발견**: oh-my-claudecode deep-interview: 라운드당 1개 질문, 가장 약한 차원을 공략. 3라운드 후 수렴 판정.
- **교훈**: requirements-interviewer는 라운드당 AskUserQuestion 1번만 호출. 모든 차원이 70% 이상 명확해지면 인터뷰 종료.

### 2. scope-validator는 단순화를 먼저 제안한다 (gstack office-hours 학습, 2026-04-21)

- **상황**: 범위 검토 시 "이게 맞는가?" 보다 "이보다 단순하게 할 수 있는가?"가 더 유용함.
- **발견**: gstack office-hours의 Forcing Questions: "이 기능의 MVP 버전은?", "이것 없이도 목표를 달성할 수 있는가?" — 범위 축소 방향으로 항상 먼저 질문.
- **교훈**: scope-validator 출력에 항상 MVP 대안 포함. 사용자가 풀 버전을 선택하면 이유를 문서화.
