---
description: "다른 스킬과 협업해서 목표 달성 — /cs-partnership with [스킬들] [목표]. cs-ceo P-모드의 명시적 진입점. Goal Gate 내장."
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Agent, AskUserQuestion, Task, ToolSearch
---

# /cs-partnership with [스킬들] [목표]

협업할 스킬을 명시하면 CEO가 목표를 확인하고 파트너십 모드로 성과를 냅니다.
`/cs-ceo with [partner]: [목표]`의 전용 진입점입니다. Goal Gate가 내장되어 있습니다.

## 사용법

```
/cs-partnership with gstack 분석 결과를 구글 시트에 정리해줘
/cs-partnership with superpowers 이 기능 어떻게 접근할지 막막해
/cs-partnership with omc,bkit 버그 근본 원인 파악 후 PDCA로 개선
/cs-partnership with cs-clarify,tdd-workflow 요구사항 정리 후 TDD 개발
/cs-partnership with deep-research,gstack 기술 조사 후 시트에 정리
```

## 파트너 지정 형식

- 단일: `with gstack [목표]`
- 복수: `with omc,bkit [목표]` (쉼표로 구분, 공백 없음)
- 어떤 설치된 스킬이든 가능 (Dynamic Resolve 자동 탐색)

## 잘 알려진 파트너

| 파트너 | 언제 쓰나 | CEO P-모드 |
|--------|----------|----------|
| `superpowers` | 어떻게 접근할지 막막할 때 | P-Pre |
| `bkit` | 전체 PDCA 사이클, 품질 게이트 | P-Wraps |
| `omc` | 버그 심층 분석, 리서치 | P-Pre |
| `gstack` | 구글 시트/드라이브 저장·정리 | P-Post |
| `cs-clarify` | 요구사항 불명확, scope 정의 필요 | P-Pre |
| *(기타)* | 자동 탐색 후 타이밍 추론 | 자동 결정 |

## 실행 방식

### Step 1: 최신 CEO 경로 확인

```bash
BASE="$HOME/.claude/plugins/marketplaces/CSnCompany_2-0/plugins"
LATEST_CEO=$(ls -d "$BASE/cs-ceo-v"* 2>/dev/null | sort -V | tail -1)
echo "CEO 경로: $LATEST_CEO"
```

### Step 2: 입력 파싱

유저 입력에서 파트너 목록과 태스크를 추출한다:

- 입력 예: `with gstack,omc 분석 결과를 시트에 저장`
- 파싱 결과: `partners="gstack,omc"`, `task="분석 결과를 시트에 저장"`
- CEO 전달 포맷: `with gstack,omc: 분석 결과를 시트에 저장`

파싱 실패(with 키워드 없음, 목표 없음) → AskUserQuestion으로 재확인:
```
"파트너와 목표를 확인해 주세요.\n예시: with gstack 분석 결과를 시트에 정리해줘"
```

### Step 3: CEO 에이전트 파일 읽기 + 스폰

1. Read 도구로 `$LATEST_CEO/agents/ceo.md` 전체 내용을 읽는다.
2. Task() 도구로 CEO 에이전트를 스폰한다:
   - `description`: "CS-CEO Partnership Mode"
   - `subagent_type`: "cs-ceo:ceo"
   - `prompt`: ceo.md 전체 내용
   - 유저 요청을 `with [파트너]: [태스크]` 형태로 원문 그대로 전달한다.
   - CEO가 **Goal Gate → Partnership Detection → P-모드(Pre/In/Post/Wraps) 자율 결정** 후 실행.

### Step 4: 결과 출력

CEO 에이전트가 반환한 종합 리포트를 그대로 출력한다.
