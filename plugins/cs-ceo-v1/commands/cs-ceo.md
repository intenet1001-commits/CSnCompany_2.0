---
description: "CS 시리즈 CEO — 자연어 요청을 받아 공수 추정 후 최적 도메인 자율 배분 (/cs-ceo [요청])"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Agent, AskUserQuestion, Task, ToolSearch
---

# /cs-ceo [요청]

CS 시리즈 총괄 CEO입니다. 자연어로 요청하면 CEO가 공수를 추정하고 어떤 도메인을 어떤 순서로 실행할지 스스로 판단합니다.

## 사용법

```
/cs-ceo 이 URL을 테스트해줘
/cs-ceo 새 결제 기능 설계해줘
/cs-ceo 전체 코드베이스 분석해줘
/cs-ceo 뭔가 이상한 것 같아 찾아봐줘
```

## 실행 방식

최신 cs-ceo SKILL.md를 읽어 CEO 에이전트를 스폰합니다:

```bash
BASE="$HOME/.claude/plugins/marketplaces/cs-plugins/plugins"
LATEST_CEO=$(ls -d "$BASE/cs-ceo-v"* 2>/dev/null | sort -V | tail -1)
```

CEO 에이전트 파일: `$LATEST_CEO/agents/ceo.md`
CEO 스킬 파일: `$LATEST_CEO/skills/cs-ceo/SKILL.md`

SKILL.md 프로토콜에 따라 CEO 에이전트를 Task()로 스폰합니다.
