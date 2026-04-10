# cs-experiencing-v1 - 경험 지식 저장소

이 플러그인은 누적된 학습 경험을 도메인별로 관리합니다.

## 도메인 구성

| 도메인 | 현재 버전 | 내용 |
|--------|-----------|------|
| **CS-test** | v1 | 웹 테스트 (14-agent playwright 팀) |
| **CS-plan** | v1 | TDD+CleanArch 플랜 (4-agent: domain-analyst, arch-designer, tdd-strategist, checklist-builder) |
| **CS-codebase-review** | v1 | 5-관점 병렬 코드 리뷰 (Architecture/Quality/Security/Performance/Maintainability) |

## 사용법

```
/experiencing                                      # 도메인 목록 및 버전 확인
/experiencing test [URL]                           # CS-test 실행 (14개 에이전트로 웹 테스트)
/experiencing plan [task]                          # CS-plan 실행
/experiencing review [path] [--focus aspect]       # CS-codebase-review 실행 (5-관점 코드 리뷰)
/experiencing version-up test                      # CS-test 버전 업그레이드
/experiencing version-up review                    # CS-codebase-review 버전 업그레이드
```

## 버전 관리

각 도메인의 VERSION 파일이 현재 콘텐츠 버전을 나타냅니다.
새 학습이 추가되면 `/experiencing version-up [domain]` 으로 버전 증가.

## 도메인 파일 구조

3개 도메인은 cs-experiencing-v1과 같은 레벨의 plugins/ 디렉토리에 위치합니다:

```
plugins/
├── cs-experiencing-v1/  ← 이 플러그인 (오케스트레이터)
├── CS-test-v1/
│   ├── VERSION          # 현재: 1
│   ├── agents/          # 14개 테스트 에이전트
│   ├── skills/CS-test/SKILL.md
│   └── commands/CS-test.md
├── CS-plan-v1/
│   ├── VERSION          # 현재: 1
│   ├── agents/          # 4개: domain-analyst, arch-designer, tdd-strategist, checklist-builder
│   ├── commands/CS-plan.md
│   ├── knowledge/README.md
│   └── skills/CS-plan/SKILL.md
└── CS-codebase-review-v1/
    ├── VERSION          # 현재: 1
    ├── skills/CS-codebase-review/SKILL.md
    └── commands/CS-codebase-review.md
```
