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
