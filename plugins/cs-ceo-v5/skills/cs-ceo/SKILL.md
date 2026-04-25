---
name: cs-ceo
user-invocable: true
description: |
  CS 시리즈 CEO 오케스트레이터. 자연어 요청을 받아 공수 추정 후 CS-test/CS-plan/CS-codebase-review/cs-design/cs-smart-run 중 최적 조합을 자율 선택·배분한다.
  v5.1: Universal Partnership Protocol — "with [어떤스킬이든]:" 구문으로 시스템에 설치된 모든 스킬과 협업 가능.
  v5.2: External Knowledge Gate — 외부 지식이 필요하다고 판단되면 지체 없이 context7-auto-research를 자동 호출하여 학습 후 진행. 학습 결과는 버전업 시 노하우로 영속화.
  설치된 스킬을 자동 탐색하고, 타이밍(Pre/In/Post/Wraps)을 description 기반으로 자동 추론한다.
  Use when user types "/cs-ceo" or "cs-ceo".
version: 1.2.0
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

# CS-CEO — CS 시리즈 총괄 오케스트레이터 (v5 + Partnership Protocol)

## 개요

유저가 `/cs-ceo [자연어 요청]`을 입력하면:
1. **(v5.2 신규) 외부 지식 게이트**: CEO가 라이브러리/프레임워크/최신 동향 등 외부 도움이 필요할 것 같으면 즉시 `/context7-auto-research`를 호출해 공부 후 진행 (Phase -3)
2. CEO가 외부 파트너 스킬 필요 여부 판단 (Phase -2)
3. CEO 에이전트(opus)가 공수를 추정하고
4. 어떤 CS 도메인을 어떤 순서로 실행할지 스스로 결정하고
5. 필요 시 cs-smart-run(Opus 플랜→Sonnet 실행)을 자율 선택한다

유저는 도메인이나 파트너를 지정할 필요 없다. 원하는 것을 말하면 CEO가 판단한다.

### v5.2 External Knowledge Gate — 자동 학습 루프

```
요청 진입
  ↓
[Phase -3] 외부 지식 필요?  ← 라이브러리/최신 변경/모르는 용어/대안 비교/외부 stack trace
  │ Yes → context7-auto-research 설치됨?
  │        ├─ 설치됨    → Skill(context7-auto-research) → 학습 결과를 INPUT으로 보관
  │        └─ 미설치    → AskUserQuestion: [Install / Skip once / Abort]
  │                       └─ Install 선택 시 `npx skills add -g BenedictKing/context7-auto-research` 자동 실행 후 진행
  │ No  → 그대로 진행
  ↓
[Phase -2] 파트너십 탐지 → ... → [Phase 4] 종합 리포트 → [Phase 5-B] 버전업 결정
                                                              │
                                                              └→ 외부 학습이 판단을 바꿨다면 노하우 후보로 적재 → 다음 version-up에서 영속화
```

- 발동 시 알림: `📚 외부 지식 필요 감지: [주제] — context7-auto-research로 학습 후 진행합니다.`
- 미설치 시: 설치 명령(`npx skills add -g BenedictKing/context7-auto-research`)과 함께 Install/Skip/Abort 3지선다 제시 — 사용자가 명시적으로 Skip하지 않는 한 무단으로 외부 학습을 건너뛰지 않는다.

---

## 사용법

### 기본 (기존과 동일)

```
/cs-ceo 이 URL을 테스트해줘
/cs-ceo 새 결제 기능 플랜 짜줘
/cs-ceo 전체 코드베이스 분석해줘
/cs-ceo 이 서비스 뭔가 이상한 것 같아
/cs-ceo 대규모 아키텍처 개편 어떻게 할지 알려줘
```

### 파트너십 명시 (v5 — 어떤 스킬이든 가능)

```
# 잘 알려진 파트너 (Fast-Path)
/cs-ceo with superpowers: 이 기능 어떻게 접근할지 잘 모르겠어
/cs-ceo with bkit: 전체 PDCA 사이클로 개발해줘
/cs-ceo with omc: 이 버그 깊이 파봐줘
/cs-ceo with gstack: 분석 결과를 구글 시트에 저장해줘
/cs-ceo with cs-clarify: 요구사항이 불명확해, 먼저 정리해줘

# 설치된 어떤 스킬이든 (Dynamic Resolve)
/cs-ceo with tdd-workflow: 새 결제 기능 TDD로 개발해줘
/cs-ceo with deep-research: 이 라이브러리 대안 조사해줘
/cs-ceo with stripe-integration: 결제 붙이면서 코드베이스 리뷰해줘
/cs-ceo with systematic-debugging: 이 에러 근본 원인 찾아줘
```

### 멀티 파트너

```
/cs-ceo with superpowers,gstack: 기능 설계 후 결과를 드라이브에 저장해줘
/cs-ceo with omc,bkit: 버그 근본 원인 파악 후 PDCA로 수정해줘
/cs-ceo with cs-clarify,tdd-workflow: 요구사항 정리 후 TDD로 개발해줘
/cs-ceo with deep-research,stripe-integration,gstack: 결제 옵션 조사 → 구현 → 시트 정리
```

---

## 파트너 스킬 가이드

### Fast-Path 파트너 (자동 감지 포함)

| 파트너 키 | 핵심 스킬 | 언제 쓰나 | 자동 감지 트리거 |
|----------|----------|----------|----------------|
| `superpowers` | brainstorming, writing-plans, executing-plans, systematic-debugging | 설계 불명확, 체계적 플랜, 병렬 작업, 디버깅 방법론 | "잘 모르겠어" / "어떻게 접근" / "막막해" |
| `bkit` | pdca, qa-phase | PDCA 전체 사이클, 품질 게이트, 장기 피처 개발 | "PDCA로" / "전체 사이클" / "품질 게이트" |
| `omc` | deep-dive, autoresearch, autopilot | 심층 버그 조사, 리서치, 집중 실행 모드 | "깊이 파봐" / "근본 원인" + 복잡한 증상 |
| `gstack` | gstack | Google Drive/Sheets/Docs/Gmail/Calendar 연동 | "구글 시트" / "드라이브에" / "Gmail" / "캘린더" |
| `cs-clarify` | cs-clarify | 요구사항 모호, scope 정의 필요 | "뭘 만들어야" / "요구사항 불명확" |

### Dynamic Resolve 파트너 (설치된 모든 스킬)

`with [스킬이름]:` 에 **어떤 스킬 이름이든** 넣으면 CEO가 자동으로:
1. 시스템 전체(마켓플레이스 → 캐시 → 유저스킬)에서 해당 SKILL.md 탐색
2. SKILL.md `description`을 읽어 타이밍(Pre/In/Post/Wraps) 자동 추론
3. 적절한 실행 모드로 협업 진행

탐색 순서: CS-plugins 내부 → `~/.claude/plugins/marketplaces` → `~/.claude/plugins/cache` → `~/.claude/skills`

파트너를 명시하지 않아도 CEO가 알려진 패턴은 자동으로 감지해 알린 후 진행한다.

---

## 실행 프로토콜

### Step 1: 최신 CEO 경로 확인

```bash
BASE="$HOME/.claude/plugins/marketplaces/CSnCompany_2-0/plugins"
LATEST_CEO=$(ls -d "$BASE/cs-ceo-v"* 2>/dev/null | sort -V | tail -1)
echo "CEO 경로: $LATEST_CEO"
echo "CEO 버전: $(cat $LATEST_CEO/VERSION)"
```

### Step 2: CEO 에이전트 스폰

```
에이전트 파일: $LATEST_CEO/agents/ceo.md
```

Task() 스폰 시 유저 요청을 원문 그대로 전달 (`with [partner]:` 구문 포함):
```
유저 요청: [원문 그대로]
```

CEO 에이전트 내부 처리:
- Phase -2: 파트너십 탐지 (명시/자동)
- Partnership Registry: 파트너 경로 확보
- Phase -1~0: 컨텍스트 점검 + 도메인/파트너 경로 확인
- Phase 1~5: 공수 추정 → 모드 결정 → 실행 → 리포트

### Step 3: 결과 출력

CEO 에이전트가 반환한 종합 리포트를 그대로 출력한다.

---

## CEO 판단 모드 요약

| 모드 | 조건 | 실행 |
|------|------|------|
| **A** (직접 단독) | 도메인 1개, 명확 | 해당 도메인 직접 실행 |
| **B** (CEO 오케스트레이션) | 도메인 2~3개 | CEO가 순차/병렬 조합 |
| **C** (smart-run 위임) | 복잡/대규모/불확실 | Opus 플랜→Sonnet 실행 |
| **P-Pre** (파트너 선행) | 파트너 결과가 플랜 INPUT | 파트너 → A/B/C |
| **P-In** (파트너 병렬) | 파트너와 독립 병렬 가능 | 파트너 ‖ CS 도메인 동시 |
| **P-Post** (파트너 후처리) | 파트너가 CEO 결과 처리 | A/B/C → 파트너 |
| **P-Wraps** (파트너 감싸기) | bkit:pdca 전체 사이클 | pdca 방법론 안에서 A/B/C |

모드 선택은 CEO가 자율 결정. 유저가 지정하지 않아도 된다.

---

## CEO 노하우

*(버전업마다 이 섹션에 판단 패턴이 축적됩니다)*

### 1. 인프라 진단 태스크는 도메인 에이전트 없이 직접 Bash 실행이 효율적 (2026-04-24)
- **상황**: localhost:9000 점검 + GitHub sync + 폴더 선택 기능 에러 개선 확인 요청
- **판단**: 도메인 에이전트 스폰 없이 직접 Bash 명령으로 진단
- **결과**: 즉시 근본 원인 진단. 효율적이었음.
- **교훈**: 인프라 진단은 CEO 직접 Bash. 도메인 에이전트는 심층 분석에만.

### 2. 코드 변경 검증 요청은 Mode A + 직접 분석 (2026-04-24)
- **상황**: 워크트리 UX 개선 코드 변경 후 6개 항목 검증 요청
- **판단**: Mode A — Bash+Read로 직접 코드 분석
- **결과**: 6개 항목 모두 빠르게 검증 완료.
- **교훈**: "implemented code verify" = 항상 Mode A. Bash grep + Read로 충분.
