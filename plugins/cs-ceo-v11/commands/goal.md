---
description: "목표 기반 CEO 오케스트레이터 — 자연어 목표를 받아 공수 추정 후 최적 도메인 자율 배분. /cs-ceo의 alias. (/goal [목표])"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Agent, AskUserQuestion, Task, ToolSearch
---

# /goal [목표]

목표를 말하면 CEO가 공수를 추정하고 CS 시리즈에서 최적 실행 경로를 자율 배분합니다.
`/cs-ceo`와 동일한 CEO 에이전트를 사용합니다.

## 사용법

```
/goal 이 URL에서 버그 찾아줘
/goal 새 결제 기능 설계해줘
/goal 전체 코드 품질 점검해줘
/goal 뭔가 이상한 것 같아 찾아봐줘
/goal with superpowers: 이 기능 어떻게 접근할지 모르겠어
/goal with bkit: 전체 PDCA 사이클로 개발해줘
```

## CEO 자동 파트너 감지

파트너 명시 없이도 맥락에서 자동 감지:
- "잘 모르겠어" / "막막해" → superpowers:brainstorming
- "구글 시트" / "드라이브" → gstack
- "버그" + 복잡한 증상 → omc:deep-dive
- "PDCA로" / "전체 사이클" → bkit:pdca

## 실행 방식

```bash
BASE="$HOME/.claude/plugins/marketplaces/CSnCompany_2-0/plugins"
LATEST_CEO=$(ls -d "$BASE/cs-ceo-v"* 2>/dev/null | sort -V | tail -1)
```

CEO 에이전트 파일: `$LATEST_CEO/agents/ceo.md`
CEO 스킬 파일: `$LATEST_CEO/skills/cs-ceo/SKILL.md`

SKILL.md 프로토콜에 따라 CEO 에이전트를 Task()로 스폰합니다.
