---
name: CS-codebase-review
user-invocable: true
description: |
  5-agent parallel codebase review skill. Use when user types "/CS-codebase-review", "코드베이스 리뷰",
  "전체 코드 리뷰", "codebase review", "코드 전체 분석", or wants a comprehensive parallel review
  covering architecture, quality, security, performance, and maintainability.
version: 1.0.0
---

# Codebase Review Skill

<codebase-review>

## Overview
전체 코드베이스를 5가지 관점에서 병렬 분석하여 종합 리뷰 리포트를 생성합니다.

## Trigger
- `/experiencing review` - 전체 코드베이스 분석
- `/experiencing review [path]` - 특정 경로만 분석
- `/experiencing review --focus [aspect]` - 특정 관점만 분석 (architecture, quality, security, performance, maintainability)

## Execution Protocol

### Phase 1: Codebase Discovery
1. 프로젝트 루트에서 주요 파일/디렉토리 구조 파악
2. 언어/프레임워크 식별 (package.json, requirements.txt, go.mod 등)
3. 분석 범위 결정 (전체 또는 지정된 경로)

### Phase 2: Multi-Agent Parallel Analysis
5개의 전문 에이전트를 **병렬로** 실행하여 각 관점에서 분석합니다.

#### 🏗️ Architecture Agent
분석 항목:
- 디렉토리 구조 및 모듈 구성
- 디자인 패턴 사용 여부 (MVC, MVVM, Clean Architecture 등)
- 의존성 방향 및 순환 참조
- 레이어 분리 (presentation, business, data)
- API 설계 일관성

평가 기준:
- A: 명확한 아키텍처, 일관된 패턴, 낮은 결합도
- B: 대체로 좋으나 일부 개선 필요
- C: 구조적 문제 있음, 리팩토링 권장
- D: 심각한 구조적 결함, 즉시 개선 필요

#### ✨ Quality Agent
분석 항목:
- 코드 중복 (DRY 원칙)
- 함수/클래스 복잡도 (순환 복잡도)
- 네이밍 컨벤션 일관성
- 에러 핸들링 패턴
- 타입 안정성 (TypeScript, 타입 힌트 등)

평가 기준:
- A: 클린 코드, 일관된 스타일, 낮은 복잡도
- B: 대체로 양호, 일부 리팩토링 필요
- C: 중복 및 복잡도 문제, 개선 권장
- D: 심각한 품질 문제, 즉시 개선 필요

#### 🔒 Security Agent
분석 항목:
- OWASP Top 10 취약점
  - Injection (SQL, Command, XSS)
  - Broken Authentication
  - Sensitive Data Exposure
  - Security Misconfiguration
- 하드코딩된 시크릿/API 키
- 의존성 취약점 (outdated packages)
- 입력 검증 및 출력 인코딩
- 권한 및 접근 제어

평가 기준:
- A: 보안 모범 사례 준수
- B: 경미한 보안 이슈
- C: 중요 취약점 발견, 수정 필요
- D: 심각한 보안 취약점, 즉시 조치 필요

#### ⚡ Performance Agent
분석 항목:
- N+1 쿼리 문제
- 불필요한 재렌더링/재계산
- 메모리 누수 가능성
- 비효율적인 알고리즘 (O(n²) 등)
- 캐싱 전략
- 번들 사이즈 (프론트엔드)
- 비동기 처리 패턴

평가 기준:
- A: 최적화된 코드, 효율적인 알고리즘
- B: 대체로 양호, 일부 최적화 가능
- C: 성능 병목 존재, 개선 권장
- D: 심각한 성능 문제, 즉시 최적화 필요

#### 📚 Maintainability Agent
분석 항목:
- 문서화 수준 (README, JSDoc, docstring)
- 테스트 커버리지 및 품질
- 설정 관리 (환경 변수, config 분리)
- 로깅 및 모니터링
- 버전 관리 관행 (커밋 메시지, 브랜치 전략)
- 온보딩 용이성

평가 기준:
- A: 우수한 문서화, 높은 테스트 커버리지
- B: 적절한 문서화, 기본 테스트 존재
- C: 문서화 부족, 테스트 미흡
- D: 문서화 없음, 테스트 부재

### Phase 3: Report Synthesis
모든 에이전트 결과를 종합하여 최종 리포트 생성

## Output Format

```markdown
# 🔍 코드 리뷰 리포트

**프로젝트**: {project_name}
**분석 일시**: {timestamp}
**분석 범위**: {scope}

---

## 📊 Executive Summary

### 전체 등급: {A/B/C/D}

| 관점 | 등급 | 상태 |
|------|------|------|
| 🏗️ Architecture | {grade} | {status_emoji} |
| ✨ Quality | {grade} | {status_emoji} |
| 🔒 Security | {grade} | {status_emoji} |
| ⚡ Performance | {grade} | {status_emoji} |
| 📚 Maintainability | {grade} | {status_emoji} |

### 🎯 주요 발견사항
1. {critical_finding_1}
2. {critical_finding_2}
3. {critical_finding_3}

---

## 🏗️ Architecture Analysis

**등급: {grade}**

### 강점
- {strength_1}
- {strength_2}

### 개선 필요
- {issue_1}
  - 위치: `{file_path}:{line}`
  - 권장: {recommendation}

---

## ✨ Quality Analysis

**등급: {grade}**

### 강점
- {strength_1}

### 개선 필요
- {issue_1}
  - 위치: `{file_path}:{line}`
  - 권장: {recommendation}

---

## 🔒 Security Analysis

**등급: {grade}**

### 발견된 취약점
| 심각도 | 유형 | 위치 | 설명 |
|--------|------|------|------|
| {severity} | {type} | `{location}` | {description} |

### 권장 조치
- {recommendation}

---

## ⚡ Performance Analysis

**등급: {grade}**

### 성능 병목
- {bottleneck_1}
  - 위치: `{file_path}:{line}`
  - 영향: {impact}
  - 권장: {recommendation}

---

## 📚 Maintainability Analysis

**등급: {grade}**

### 문서화 상태
- README: {status}
- API 문서: {status}
- 인라인 주석: {status}

### 테스트 커버리지
- 단위 테스트: {coverage}%
- 통합 테스트: {status}

---

## 🚀 권장 조치사항 (우선순위별)

### 🔴 Critical (즉시 조치)
1. {action_1}

### 🟠 High (1주 내)
1. {action_1}

### 🟡 Medium (1개월 내)
1. {action_1}

### 🟢 Low (향후 고려)
1. {action_1}

---

## 📈 다음 단계

1. {next_step_1}
2. {next_step_2}
3. {next_step_3}
```

## Agent Execution Instructions

각 에이전트는 다음 도구를 활용:
- `Glob`: 파일 패턴 검색
- `Grep`: 코드 패턴 검색
- `Read`: 파일 내용 분석
- `Task` with `Explore`: 코드베이스 탐색

분석 시 주의사항:
1. 실제 코드 예시와 함께 구체적인 피드백 제공
2. 파일 경로와 라인 번호 명시
3. 단순 지적이 아닌 개선 방안 제시
4. 프로젝트 컨텍스트 고려 (프레임워크, 규모 등)

</codebase-review>
