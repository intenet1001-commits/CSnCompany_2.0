---
name: CS-plan
description: |
  CS-plan 도메인 지식 조회 및 플래닝 실행.
  Use when invoked via /experiencing plan or /CS-plan.
version: 1.0.0
allowed-tools:
  - Read
  - Write
  - Bash
  - Agent
---

# CS-plan - 플래닝 지식 도메인 v1

## 현재 상태

플래닝 학습 경험이 축적 중입니다.
현재 버전(v1)은 템플릿 단계입니다.

## 학습된 플래닝 원칙

1. **Opus로 플랜, Sonnet으로 실행**: 복잡한 작업은 Opus가 구조화된 계획을 세우고 Sonnet 에이전트들이 병렬 실행
2. **역할 경계 명시**: 각 에이전트의 책임 범위를 명확히 정의
3. **단일 응답 블록 병렬성**: Agent Teams에서 진정한 병렬 실행은 단일 응답에서 모든 Task() 호출

## 다음 학습 예정

- /pdca 사이클 실전 경험
- 플러그인 설계 패턴
- 효과적인 Opus 프롬프팅 기법
