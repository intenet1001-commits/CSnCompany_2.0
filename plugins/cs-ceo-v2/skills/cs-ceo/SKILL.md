---
name: cs-ceo
user-invocable: true
description: |
  CS 시리즈 CEO 오케스트레이터. 자연어 요청을 받아 공수 추정 후 CS-test/CS-plan/CS-codebase-review/cs-design/cs-smart-run 중 최적 조합을 자율 선택·배분한다.
  Use when user types "/cs-ceo" or "cs-ceo".
version: 1.0.0
allowed-tools:
  - Task
  - Agent
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
  - ToolSearch
---

# CS-CEO — CS 시리즈 총괄 오케스트레이터

## 개요

유저가 `/cs-ceo [자연어 요청]`을 입력하면:
1. CEO 에이전트(opus)가 공수를 추정하고
2. 어떤 CS 도메인을 어떤 순서로 실행할지 스스로 결정하고
3. 필요 시 cs-smart-run(Opus 플랜→Sonnet 실행)을 자율 선택한다

유저는 도메인을 지정할 필요 없다. 그냥 원하는 것을 말하면 된다.

## 사용법

```
/cs-ceo 이 URL을 테스트해줘
/cs-ceo 새 결제 기능 플랜 짜줘
/cs-ceo 전체 코드베이스 분석해줘
/cs-ceo 이 서비스 뭔가 이상한 것 같아
/cs-ceo 대규모 아키텍처 개편 어떻게 할지 알려줘
```

## 실행 프로토콜

### Step 1: 최신 CEO 경로 확인

```bash
BASE="$HOME/.claude/plugins/marketplaces/cs-plugins/plugins"
LATEST_CEO=$(ls -d "$BASE/cs-ceo-v"* 2>/dev/null | sort -V | tail -1)
echo "CEO 경로: $LATEST_CEO"
echo "CEO 버전: $(cat $LATEST_CEO/VERSION)"
```

### Step 2: CEO 에이전트 스폰

CEO 에이전트 파일을 읽고 Task()로 스폰:

```
에이전트 파일: $LATEST_CEO/agents/ceo.md
```

Task() 스폰 시 유저 요청 전달:
```
유저 요청: [원문 그대로]
```

CEO 에이전트가 내부적으로:
- 공수 추정 (①~⑤)
- 모드 결정 (A/B/C)
- 도메인 실행 오케스트레이션
- 종합 리포트 생성

### Step 3: 결과 출력

CEO 에이전트가 반환한 종합 리포트를 그대로 출력한다.

---

## CEO 판단 모드 요약

| 모드 | 조건 | 실행 |
|------|------|------|
| **A** (직접 단독) | 도메인 1개, 명확 | 해당 도메인 직접 실행 |
| **B** (CEO 오케스트레이션) | 도메인 2~3개 | CEO가 순차/병렬 조합 |
| **C** (smart-run 위임) | 복잡/대규모/불확실 | Opus 플랜→Sonnet 실행 |

모드 선택은 CEO가 자율 결정. 유저가 지정하지 않아도 된다.

---

## CEO 노하우

*(버전업마다 이 섹션에 판단 패턴이 축적됩니다)*

CEO는 각 버전업 시 이번 세션에서 내린 배분 결정을 회고하고 효과적이었던 패턴을 여기에 기록합니다.

### 1. 인프라 진단 태스크는 도메인 에이전트 없이 직접 Bash 실행이 효율적 (2026-04-24)
- **상황**: localhost:9000 점검 + GitHub sync + 폴더 선택 기능 에러 개선 확인 요청
- **판단**: 도메인 에이전트 스폰 없이 직접 Bash 명령으로 진단 (git log, curl, lsof)
- **결과**: git pull 1개 누락 커밋이 근본 원인임을 즉시 진단. 효율적이었음.
- **교훈**: 서버 상태 확인, git sync, 파일 존재 여부 같은 인프라 진단은 CEO가 직접 Bash 실행. 도메인 에이전트는 코드 리뷰/설계/테스트처럼 심층 분석이 필요할 때만 스폰할 것.
