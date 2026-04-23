# CSnCOMPANY — Claude Code 안의 AI 팀

Claude Code용 AI 에이전트 컴퍼니. 각 플러그인은 CEO, 디자이너, 아키텍트, QA, 리뷰어, 배포 담당 등 명확한 역할을 가진 팀 멤버입니다. 아이디어부터 배포까지 함께 움직입니다.

## 팀 구성

| 멤버 | 플러그인 | 슬래시 명령 | 역할 |
|------|----------|------------|------|
| 🧭 **CEO** | `cs-ceo` | `/cs-ceo` | 오케스트레이터 — 공수 추정 후 CS-test / CS-plan / CS-codebase-review / cs-design / cs-smart-run에 자율 배분 |
| 💬 **PM (요구사항 정리)** | `cs-clarify` | `/cs-clarify` | 4-에이전트 소크라테스식 질문 — 숨겨진 가정 발견, 스코프 검증, 과잉 설계 방지 |
| 🏗️ **아키텍트** | `CS-plan` | `/CS-plan "기능"` | 4-에이전트 TDD + Clean Architecture 플래너 — 도메인 분석, 아키텍처 설계, 테스트 전략, 구현 체크리스트 |
| 🎨 **디자이너** | `cs-design` | `/cs-design` | 5-에이전트 병렬 디자인 리뷰 — 비주얼 계층, 인터랙션 품질, 디자인 시스템 일관성, 반응형/접근성, 안티 패턴 탐지 |
| 🎨 **디자인 시스템 가이드** | `cs-design-sample1` | `/cs-design-sample1` | Crextio 스타일 레퍼런스: 웜 크림 팔레트 + 앰버/슬레이트 액센트 — Tailwind/Next.js 대시보드용 |
| 🧪 **QA 엔지니어** | `CS-test` | `/CS-test` | 14-에이전트 웹 테스트 — 보안, SEO, 성능, 접근성, DB, PWA, 터치, 이미지 최적화 |
| 🔍 **코드 리뷰어** | `CS-codebase-review` | `/CS-codebase-review` | 5-에이전트 병렬 리뷰 — Architecture, Quality, Security, Performance, Maintainability |
| 🚢 **DevOps (배포 게이트)** | `cs-ship` | `/cs-ship` | 4-에이전트 PR 전 검증 — 스펙 준수, 커버리지, 커밋 메시지 |
| ⚡ **팀 리더 (Runner)** | `cs-smart-run` | `/cs-smart-run` | 2-phase 오케스트레이터 — Opus로 계획, Sonnet 에이전트로 병렬 실행 |
| 📚 **지식 저장소** | `cs-experiencing` | `/cs-experiencing` | CS-test / CS-plan / CS-codebase-review / cs-design 메타 라우터, 버전별 학습 관리 |
| 🗣️ **언어 코치** | `convo-maker` | `/convo-maker` | 세션 Q&A를 자연스러운 미국식 영어 대화로 변환 (언어 학습용) |

## 일반적인 워크플로우

```
  /cs-clarify → /CS-plan → /cs-design → 구현 → /CS-test
                                                   ↓
                   /CS-codebase-review → /cs-ship → PR
```

또는 CEO에게 맡기세요: `/cs-ceo "대시보드 만들어줘"` — 필요한 멤버를 자동으로 배정합니다.

## 설치 방법

### 방법 1 — Claude Code 원라이너 (권장)

```
/plugin marketplace add intenet1001-commits/CSnCOMPANY
```

이후 원하는 멤버만 선택 설치:

```
/plugin install cs-ceo@cs-plugins
/plugin install cs-clarify@cs-plugins
/plugin install CS-plan@cs-plugins
/plugin install cs-design@cs-plugins
/plugin install cs-design-sample1@cs-plugins
/plugin install CS-test@cs-plugins
/plugin install CS-codebase-review@cs-plugins
/plugin install cs-ship@cs-plugins
/plugin install cs-smart-run@cs-plugins
/plugin install cs-experiencing@cs-plugins
/plugin install convo-maker@cs-plugins
```

### 방법 2 — 수동 설치

```bash
git clone https://github.com/intenet1001-commits/CSnCOMPANY ~/.claude/plugins/marketplaces/cs-plugins
```

`~/.claude/settings.json`에 등록:

```json
{
  "extraKnownMarketplaces": {
    "cs-plugins": {
      "source": {
        "source": "local",
        "path": "~/.claude/plugins/marketplaces/cs-plugins"
      }
    }
  },
  "enabledPlugins": {
    "cs-ceo@cs-plugins": true,
    "cs-clarify@cs-plugins": true,
    "CS-plan@cs-plugins": true,
    "cs-design@cs-plugins": true,
    "cs-design-sample1@cs-plugins": true,
    "CS-test@cs-plugins": true,
    "CS-codebase-review@cs-plugins": true,
    "cs-ship@cs-plugins": true,
    "cs-smart-run@cs-plugins": true,
    "cs-experiencing@cs-plugins": true,
    "convo-maker@cs-plugins": true
  }
}
```

Claude Code를 재시작하면 플러그인이 로드됩니다.

## 아키텍처 — Lead-Agent 패턴

모든 멀티 에이전트 멤버는 **lead-agent 패턴**을 사용합니다. 메인 컨텍스트가 lead 에이전트 1개를 생성하고, lead가 내부적으로 N명의 워커를 오케스트레이션합니다. 워커의 원시 출력이 메인 대화에 누적되지 않습니다.

```
main context
  └─ SKILL.md (얇은 래퍼: 인자 파싱, lead Task 1개 생성)
       └─ lead agent (자체 컨텍스트: N개 워커 오케스트레이션)
            ├─ worker-1 → 결과 파일
            ├─ worker-2 → 결과 파일
            └─ worker-N → 결과 파일
            → 최종 문서 합성 → 메인 컨텍스트로 반환
```

### CS-test (14 에이전트, 2-phase)

```
SKILL → test-lead
  Phase 1: build-validator, page-explorer (순차)
  Phase 2: functional, visual, api-interceptor, perf, security,
           seo, social-share, touch, image, db, error-resilience (병렬)
  → REPORT.md
```

### CS-plan (4 에이전트, 병렬)

```
SKILL → plan-lead
  ├─ domain-analyst    → domain-analysis.md
  ├─ arch-designer     → architecture.md
  ├─ tdd-strategist    → tdd-strategy.md
  └─ checklist-builder → implementation-checklist.md
  → PLAN.md
```

### CS-codebase-review (5 에이전트, 병렬)

```
SKILL → review-lead
  ├─ architecture    → architecture-report.json
  ├─ quality         → quality-report.json
  ├─ security        → security-report.json
  ├─ performance     → performance-report.json
  └─ maintainability → maintainability-report.json
  → REVIEW.md
```

### cs-design (5 에이전트, 병렬)

```
SKILL → design-lead
  ├─ visual-hierarchy     → visual-hierarchy.json
  ├─ interaction-quality  → interaction-quality.json
  ├─ design-system        → design-system.json
  ├─ responsive-a11y      → responsive-a11y.json
  └─ anti-pattern         → anti-pattern.json
  → DESIGN-REVIEW.md
```

## 사용 예시

```
/cs-ceo "사용자 대시보드 만들어줘"
/cs-clarify "결제 연동 추가"
/CS-plan "이메일 + JWT 기반 사용자 인증"
/cs-design https://example.com
/CS-test https://example.com
/CS-codebase-review ./src --focus security
/cs-ship
/cs-smart-run "대시보드에 다크모드 추가"
```

## 라이선스

MIT — 자세한 내용은 [LICENSE](LICENSE) 참조.

## 링크

- [English Documentation](README.md)
- [GitHub Repository](https://github.com/intenet1001-commits/CSnCOMPANY)
