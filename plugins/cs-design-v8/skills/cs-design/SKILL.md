---
name: cs-design
user-invocable: true
description: |
  5-agent parallel design review skill. Use when user types "/cs-design", "디자인 리뷰",
  "UI 감사", "design audit", "UX 분석", or wants a comprehensive parallel design review
  covering visual hierarchy, interaction quality, design system consistency,
  responsive accessibility, and anti-pattern detection.
version: 1.0.0
---

# CS-design - 5관점 병렬 디자인 리뷰

## 개요

`design-lead` 에이전트가 5개의 전문 디자인 분석 에이전트 팀을 조율하여 UI/UX 종합 리뷰 리포트를 생성합니다.

**모델**: impeccable(7대 디자인 레퍼런스) + gstack(/plan-design-review 0-10 평점) 결합

main context는 design-lead 하나만 스폰하고, design-lead가 팀 오케스트레이션 전체를 담당합니다.
이 방식으로 main context에 5개 에이전트의 raw output이 누적되지 않아 토큰 효율이 높습니다.

## 사용법

```
/cs-design                              # 현재 디렉토리 전체 디자인 분석
/cs-design [path]                       # 특정 경로 분석
/cs-design --focus visual               # 시각 계층만 분석
/cs-design --focus interaction          # 인터랙션 품질만 분석
/cs-design --focus consistency          # 디자인 시스템 일관성만 분석
/cs-design --focus responsive           # 반응형/접근성만 분석
/cs-design --focus antipatterns         # 안티패턴 탐지만 실행
/cs-design --fix                        # 발견된 안티패턴 자동 수정
```

## 5개 분석 관점

| 관점 | 역할 | 참조 |
|------|------|------|
| **visual-hierarchy** | 폰트 스케일, 색상 대비, 공간 구조 감사 | references/typography.md + color-contrast.md |
| **interaction-quality** | 8대 컴포넌트 상태, focus, loading, error | references/interaction-states.md |
| **design-system-consistency** | 토큰 일관성, 컴포넌트 재사용률, 명명 규칙 | gstack /design-consultation 패턴 |
| **responsive-accessibility** | 모바일 우선, WCAG AA, 4pt 간격 시스템 | references/spacing-layout.md |
| **anti-pattern-detector** | 24개 AI slop 지표, 안티패턴 코드 탐지 | references/anti-patterns.md |

## 실행 프로토콜

### Step 1: 인자 파싱

```
DESIGN_PATH = 지정 경로 (미지정 시 현재 작업 디렉토리)
FOCUS       = --focus [aspect] (선택: visual/interaction/consistency/responsive/antipatterns)
FIX_MODE    = --fix (선택: 안티패턴 자동 수정 활성화)
OUTPUT_DIR  = "design-results"
```

### Step 2: 디자인 컨텍스트 수집 (중요!)

> **impeccable 원칙**: 코드베이스를 읽어도 "누가 사용하는지", "어떤 느낌이어야 하는지"는 알 수 없음.
> 디자인 리뷰는 컨텍스트 없이는 제네릭한 결과만 나옴.

`design-results/design-context.md` 파일이 있으면 읽고 진행.
없으면 다음 3가지 확인:
1. **대상 사용자**: 누가 이 제품을 사용하는가?
2. **핵심 작업**: 사용자가 주로 수행하는 작업은?
3. **브랜드 톤**: 인터페이스가 어떤 느낌이어야 하는가? (3단어로)

컨텍스트 없이도 진행 가능 (안티패턴 탐지는 컨텍스트 불필요).

### Step 3: 시작 안내 출력

```
🎨 CS-design 시작
📂 분석 대상: [DESIGN_PATH]
🎯 분석 범위: [FOCUS 또는 "전체 (5관점)"]
🔧 수정 모드: [FIX_MODE ? "활성화" : "비활성화 (리포트만)"]
📁 결과 저장: [OUTPUT_DIR]/

design-lead 에이전트가 [N]개 분석 에이전트 팀을 조율합니다...
```

### Step 4: design-lead 에이전트 스폰

```
Task(
  subagent_type: "general-purpose",
  name: "design-lead",
  model: "sonnet",
  prompt: "당신은 CS-design의 design-lead입니다. 아래 컨텍스트로 디자인 리뷰를 수행하세요.

DESIGN_PATH: [DESIGN_PATH]
FOCUS: [FOCUS 또는 "none"]
FIX_MODE: [true/false]
OUTPUT_DIR: [OUTPUT_DIR]
DESIGN_CONTEXT: [컨텍스트 내용 또는 "not provided"]

agents/design-lead.md 프로토콜을 따라 분석 에이전트 팀을 오케스트레이션하고 DESIGN-REVIEW.md를 생성하세요."
)
```

design-lead가 5개 에이전트 조율, 결과 수집, DESIGN-REVIEW.md 합성을 모두 처리합니다.

## 에러 처리

- **design-lead 실패**: 에러 메시지와 함께 수동 실행 방법 안내
- **UI 파일 없음**: "CSS/JSX 파일을 찾을 수 없습니다. 경로를 확인해주세요."

---

## CS-design v1 노하우

### 1. 컨텍스트 없이 디자인 리뷰 불가 (impeccable 원칙, 2026-04-13)

- **상황**: 코드베이스를 읽고 즉시 디자인 평가를 시작하면 제네릭한 결과만 나옴.
- **발견**: impeccable의 핵심 원칙: "Code tells you what was built, not who it's for or what it should feel like." 대상 사용자, 작업 목적, 브랜드 톤 없이는 "모든 디자인이 나쁘다"고만 말하게 됨.
- **교훈**: design-context.md 파일 또는 AskUserQuestion으로 3가지 컨텍스트를 먼저 수집. 안티패턴 탐지(references/anti-patterns.md)는 컨텍스트 없이도 실행 가능.

### 2. 스킬 미로드 원인 — installed_plugins.json SHA 불일치 (2026-04-14)

- **상황**: cs-design 플러그인이 enabledPlugins에 활성화되어 있고 캐시 파일도 정상인데 CC가 스킬을 로드하지 않음.
- **발견**: CC는 `installed_plugins.json`의 `gitCommitSha`를 현재 marketplace HEAD와 대조해서 플러그인 유효성을 검증함. marketplace에서 `git pull`로 파일이 업데이트되어도 `installed_plugins.json`의 SHA가 갱신되지 않으면 불일치 발생 → 로드 거부. orphaned 캐시 디렉토리(`.orphaned_at` 파일 포함)도 동반 문제로 나타남.
- **교훈**: 플러그인 스킬 미로드 시 `installed_plugins.json`의 해당 항목 `gitCommitSha`를 `git rev-parse HEAD`로 확인 후 최신 SHA로 교체. orphaned 캐시 디렉토리 삭제 후 CC 재시작.

### 3. 멀티라인 텍스트 표시 — split+넘버링 패턴이 pre-line보다 유연 (2026-04-20)

- **상황**: 사용자가 textarea에 줄바꿈으로 항목을 입력했을 때 카드 UI에서 그대로 렌더링 필요.
- **발견**: `white-space: pre-line`은 줄바꿈만 보존하고 maxLines 제한이나 빈 줄 필터링이 불가능. `split('\n').filter(Boolean)` 후 인덱스 넘버링 방식이 더 유연하며, `maxLines`/`small` prop으로 컨텍스트(카드 요약 vs 히스토리 상세)별 재사용 가능.
- **교훈**: 사용자 입력 멀티라인 표시 시 `PlanLines` 같은 컴포넌트로 추출. 줄 분리 → 빈 줄 제거 → 번호 + 텍스트 렌더링 패턴을 디자인 시스템에 등록할 것.

### 4. next/og Edge Runtime 한글 깨짐 해결법 (2026-04-20)

- **상황**: scrum opengraph-image.tsx에서 한글 텍스트가 깨져 보임
- **발견**: fontFamily: "monospace" 지정 시 Edge Runtime에서 한글 미지원으로 글씨 깨짐. MAU/problems OG 이미지는 fontFamily 미지정으로 문제 없음.
- **교훈**: next/og Edge Runtime 한글 텍스트에 fontFamily 명시 금지(특히 monospace). 한글 필요 시 fetch()로 Noto Sans KR 로드 후 fonts 옵션 전달. MAU/problems 스타일 전체너비 레이아웃이 렌더링 안정적.
