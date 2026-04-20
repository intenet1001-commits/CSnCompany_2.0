---
name: CS-plan
user-invocable: true
description: |
  TDD + Clean Architecture coding plan generator. Use when user types "/CS-plan", "코딩 플랜",
  "플랜 생성", "TDD 플랜", "clean architecture plan", or wants to generate an implementation plan
  using TDD and Clean Architecture with 4 specialized agents (domain-analyst, arch-designer,
  tdd-strategist, checklist-builder).
version: 1.0.0
---

# CS-plan - TDD + Clean Architecture 코딩 플랜 생성

## 개요

`plan-lead` 에이전트가 4개의 전문 Claude AI 에이전트 팀을 조율하여 TDD + Clean Architecture 기반의 즉시 실행 가능한 코딩 플랜을 생성합니다.

main context는 plan-lead 하나만 스폰하고, plan-lead가 팀 오케스트레이션 전체를 담당합니다.
이 방식으로 main context에 4개 에이전트의 raw output이 누적되지 않아 토큰 효율이 높습니다.

## 사용법

```
/CS-plan "기능 설명"
/CS-plan --lang typescript "기능 설명"
/CS-plan --output docs/plans "기능 설명"
/CS-plan --lang python --output src/plans "기능 설명"
```

## 실행 프로토콜

### Step 1: 인자 파싱

입력값에서 다음을 추출합니다:

```
FEATURE  = 큰따옴표 안의 텍스트, 또는 옵션 제외 나머지 텍스트
LANG     = --lang [언어] (미지정 시 "미지정 (plan-lead가 코드베이스에서 추론)")
OUTPUT   = --output [경로] (미지정 시 ".tdd-plans")
```

기능 설명이 없으면 사용자에게 요청 후 중단:
```
❓ 플랜을 생성할 기능을 설명해주세요.
예: /CS-plan "사용자 인증 시스템 (이메일+비밀번호, JWT)"
```

### Step 2: 시작 안내 출력

```
🚀 CS-plan TDD Clean Planner 시작
📋 기능: [FEATURE]
🌐 언어: [LANG 또는 "자동 감지"]
📁 출력: [OUTPUT]/

plan-lead 에이전트가 4개 전문 에이전트 팀을 조율합니다...
```

### Step 3: plan-lead 에이전트 스폰

다음과 같이 plan-lead를 단일 Task로 스폰합니다:

```
Task(
  subagent_type: "general-purpose",
  name: "plan-lead",
  model: "sonnet",
  prompt: "당신은 CS-plan의 plan-lead입니다. 아래 컨텍스트로 플랜을 생성하세요.

FEATURE: [FEATURE]
LANG: [LANG]
OUTPUT_DIR: [OUTPUT]

plan-lead.md 프로토콜을 따라 4개 에이전트 팀을 오케스트레이션하고 PLAN.md를 생성하세요."
)
```

plan-lead가 4개 에이전트 조율, 파일 생성, PLAN.md 합성을 모두 처리합니다.
plan-lead 완료 후 완료 결과를 사용자에게 전달합니다.

## 에러 처리

- **기능 설명 없음**: 사용자에게 입력 요청 후 중단
- **plan-lead 실패**: 에러 메시지와 함께 수동 실행 방법 안내

## CS-plan v1 노하우

- **토큰 효율**: plan-lead가 하위 에이전트 결과를 자체 context에서 처리 → main context 오염 없음
- **언어 미지정 시**: plan-lead가 코드베이스 컨텍스트에서 자동 추론
- **VERSION 파일**: 새 학습이 추가될 때마다 `/experiencing version-up plan` 으로 버전 증가

### 2. PLAN.md에 디자인 시스템 영향도 섹션 추가 (gstack /plan-design-review 학습, 2026-04-13)

- **상황**: 현재 PLAN.md는 TDD + 아키텍처 중심. UI 컴포넌트가 포함된 기능에서 디자인 영향이 누락됨.
- **발견**: gstack `/plan-design-review`는 각 디자인 차원(타이포그래피, 색상, 공간, 인터랙션, 반응형)을 0-10으로 평가 후 플랜을 수정. 코딩 전에 디자인 문제를 잡는 것이 훨씬 저렴.
- **교훈**: plan-lead가 PLAN.md 생성 시 "## 디자인 시스템 영향도" 섹션 추가. 기능이 UI 컴포넌트를 포함하면 영향받는 디자인 토큰, 컴포넌트 상태, 반응형 분기점 명시.

### 3. 범위 과대 설계 방지를 위한 강제 질문 (gstack /office-hours 학습, 2026-04-13)

- **상황**: plan-lead가 기능 설명을 받으면 즉시 full plan을 생성. 과대 설계 위험 있음.
- **발견**: gstack `/office-hours`는 "이 기능이 정말 필요한가?", "더 단순한 대안은?" 같은 forcing questions를 먼저 던져 범위를 검증함. 이를 통해 불필요한 복잡성을 사전에 제거.
- **교훈**: plan-lead 프로토콜에 Step 0 추가: 기능 설명 수신 직후 1개의 반론 질문 생성 (예: "이 기능의 MVP 버전은 무엇인가요?"). 사용자가 답변 후 플랜 생성 진행.

### 4. 빌드 검증 시 pre-existing 에러와 신규 에러 구분 (2026-04-17)

- **상황**: subagent가 `bun run build` 실행 시 rollup native 모듈 에러 발생
- **발견**: 에러가 이번 변경과 무관한 기존 환경 문제였음. subagent가 `DONE_WITH_CONCERNS`로 보고하여 혼동 없이 진행 가능했음.
- **교훈**: 빌드 검증 실패 시 git diff로 변경 범위 확인 후 pre-existing 에러 여부 판단. subagent는 `DONE_WITH_CONCERNS`로 명확히 구분하여 보고해야 함.

### 5. Karpathy 원칙 — Think Before Planning + Goal-Driven Step 포맷 (2026-04-20)

- **상황**: plan-lead가 요청을 받으면 바로 구현 플랜을 생성. 암묵적 가정이나 해석이 여러 가지인 경우 하나를 선택하고 진행해 나중에 재작업이 발생.
- **발견**: Karpathy의 "Think Before Coding" 원칙: 가정이 여러 개이면 모두 명시하고 하나를 선택하지 말 것. "Goal-Driven Execution"은 각 플랜 스텝에 `→ verify: [검증 조건]`을 붙여 완료 기준을 선언적으로 정의. LLM은 명확한 성공 기준이 있으면 자율 루프 품질이 급등함.
- **교훈**: PLAN.md 각 스텝을 `1. [작업] → verify: [검증 조건]` 포맷으로 작성. 가정이 복수인 경우 모두 명시 후 AskUserQuestion으로 선택 확인. 암묵적 선택 금지.

### 6. bkit Context Anchor — 크로스 세션 플랜 연속성 (2026-04-20)

- **상황**: 세션이 끊기거나 새 세션에서 plan을 이어받을 때 WHY/WHO/SCOPE 맥락이 사라져 arch-designer나 tdd-strategist가 재질문하거나 틀린 방향으로 진행.
- **발견**: bkit의 Context Anchor 패턴: WHY(목적)/WHO(대상)/RISK(주요 위험)/SUCCESS(성공 기준)/SCOPE(범위) 5항목 테이블을 PLAN.md 상단에 삽입. 새 세션에서 이 테이블만 읽어도 전체 맥락 복원 가능.
- **교훈**: plan-lead가 PLAN.md 생성 시 최상단에 Context Anchor 테이블 필수 추가. 다운스트림 에이전트(arch-designer, tdd-strategist)가 이 테이블을 먼저 읽도록 프로토콜 업데이트.

### 7. OMC Handoff Document — 에이전트 간 결정 컨텍스트 전달 (2026-04-21)

- **상황**: plan-lead가 4개 에이전트를 병렬 실행하지만 domain-analyst 결과가 arch-designer에게 전달되지 않아 아키텍처가 도메인 제약을 무시하는 경우 발생.
- **발견**: oh-my-claudecode의 Handoff Document 패턴: 각 단계가 종료 전 `.omc/handoffs/{stage}.md`를 작성하면 다음 에이전트가 이를 먼저 읽고 시작. 컨텍스트 압축이 발생해도 결정이 생존함.
- **교훈**: domain-analyst가 분석 완료 후 `PLAN-domain.md` 핸드오프 파일 생성. arch-designer가 이 파일을 첫 번째 입력으로 읽도록 프로토콜 업데이트. 병렬이 아닌 domain-analyst → (arch-designer + tdd-strategist) 순서로 전환.

### 8. kimoring Pre-PR Gate — 플랜 완료 후 구현 검증 루프 (2026-04-21)

- **상황**: CS-plan이 PLAN.md를 생성하면 플랜 단계 종료. 구현이 플랜대로 됐는지 확인하는 게이트가 없어 플랜 품질이 실제 결과와 단절됨.
- **발견**: kimoring의 `/verify-implementation`: 구현 완료 후 verify-* 스킬들을 동적으로 발견하여 순차 실행하는 메타 오케스트레이터. 결과가 기준 미달이면 자동 수정 제안.
- **교훈**: CS-plan에 `plan-verifier` 에이전트 추가 아이디어 — 구현 완료 신호 수신 시 PLAN.md vs 실제 구현 diff를 3-Way 체크(계획된 파일 ↔ 생성된 파일 ↔ 테스트 통과 여부). 이 역할은 신규 CS-ship 도메인이 담당.
