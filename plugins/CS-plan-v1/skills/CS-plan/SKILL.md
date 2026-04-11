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
