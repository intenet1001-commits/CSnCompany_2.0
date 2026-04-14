---
name: experiencing
user-invocable: false
description: |
  경험 지식 저장소 오케스트레이터.
  도메인별 누적 학습 조회, 실행, 버전 관리.
  Use when invoked via /cs-experiencing, or when user says "경험", "학습 실행", "버전업".
version: 3.0.0
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Agent
  - AskUserQuestion
---

# Experiencing - 경험 지식 저장소

## 도메인 위치

4개 도메인은 cs-experiencing-v3과 같은 레벨의 plugins/ 디렉토리에 위치합니다:

```
plugins/
├── cs-experiencing-v3/   ← 이 플러그인 (오케스트레이터)
├── CS-test-v4/           ← 14-agent 웹 테스트 도메인
├── CS-plan-v4/           ← TDD+CleanArch 4-agent 플랜 도메인
├── CS-codebase-review-v4/ ← 5-agent 코드 리뷰 도메인
└── cs-design-v1/         ← 5-agent 디자인 리뷰 도메인 (신규)
```

마켓플레이스 절대 경로: `~/.claude/plugins/marketplaces/cs-plugins/plugins/`

## 사용법

```
/cs-experiencing                                          # 도메인 목록 + 버전 현황 표시
/cs-experiencing test [URL]                               # CS-test 실행 (14-agent 웹 테스트)
/cs-experiencing plan [task]                              # CS-plan 실행
/cs-experiencing review [path] [--focus aspect]           # CS-codebase-review 실행 (5-관점 코드 리뷰)
/cs-experiencing design [path] [--focus aspect] [--fix]  # CS-design 실행 (5-관점 디자인 리뷰)
/cs-experiencing update                                   # 4개 스킬 모두 버전업 (version-up all 단축키)
/cs-experiencing version-up [domain]                      # 도메인 버전 증가 (test/plan/review/design)
/cs-experiencing version-up all                           # 4개 도메인 한번에 버전 증가
/cs-experiencing status                                   # 모든 도메인 VERSION 파일 읽기
```

---

## 실행 프로토콜

### `/experiencing` (인수 없음)

도메인 목록과 현재 버전을 표시:

```bash
BASE="$HOME/.claude/plugins/marketplaces/cs-plugins/plugins"
for domain in CS-test CS-plan CS-codebase-review; do
  VERSION=$(cat "$BASE/${domain}-v"*/VERSION 2>/dev/null || echo "?")
  echo "📦 $domain | 현재 콘텐츠 버전: $VERSION"
done
```

### `/cs-experiencing test [URL]`

1. 최신 CS-test 도메인 경로 찾기:
   ```bash
   BASE="$HOME/.claude/plugins/marketplaces/cs-plugins/plugins"
   LATEST_TEST=$(ls -d "$BASE/CS-test-v"* 2>/dev/null | sort -V | tail -1)
   ```
2. `$LATEST_TEST/VERSION` 읽기 → 현재 버전 확인
3. `$LATEST_TEST/skills/CS-test/SKILL.md` 프로토콜 실행
4. URL을 대상으로 14-agent 팀 가동

### `/cs-experiencing plan [task]`

1. 최신 CS-plan 도메인 경로 찾기:
   ```bash
   BASE="$HOME/.claude/plugins/marketplaces/cs-plugins/plugins"
   LATEST_PLAN=$(ls -d "$BASE/CS-plan-v"* 2>/dev/null | sort -V | tail -1)
   ```
2. `$LATEST_PLAN/VERSION` 읽기 → 현재 버전 확인
3. `$LATEST_PLAN/skills/CS-plan/SKILL.md` 프로토콜 실행

### `/cs-experiencing review [path] [--focus aspect]`

1. 최신 CS-codebase-review 도메인 경로 찾기:
   ```bash
   BASE="$HOME/.claude/plugins/marketplaces/cs-plugins/plugins"
   LATEST_REVIEW=$(ls -d "$BASE/CS-codebase-review-v"* 2>/dev/null | sort -V | tail -1)
   ```
2. `$LATEST_REVIEW/VERSION` 읽기 → 현재 버전 확인
3. `$LATEST_REVIEW/skills/CS-codebase-review/SKILL.md` 프로토콜 실행
3. 인수 파싱:
   - `[path]` 없음 → 현재 작업 디렉토리 전체 분석
   - `[path]` 있음 → 해당 경로만 분석
   - `--focus [aspect]` 있음 → 해당 관점만 집중 분석 (architecture/quality/security/performance/maintainability)
4. 5개 에이전트(Architecture/Quality/Security/Performance/Maintainability)를 병렬 실행
5. 결과 종합 → 등급(A/B/C/D) + 우선순위별 권장 조치사항 리포트 출력

### `/cs-experiencing update`

`version-up all`의 단축 명령어. 3개 도메인(CS-test, CS-plan, CS-codebase-review)을 순차적으로 버전업합니다.

아래 `version-up all` 프로토콜과 동일하게 실행.

---

### `/cs-experiencing design [path] [--focus aspect] [--fix]`

1. 최신 CS-design 도메인 경로 찾기:
   ```bash
   BASE="$HOME/.claude/plugins/marketplaces/cs-plugins/plugins"
   LATEST_DESIGN=$(ls -d "$BASE/cs-design-v"* 2>/dev/null | sort -V | tail -1)
   ```
2. `$LATEST_DESIGN/VERSION` 읽기 → 현재 버전 확인
3. `$LATEST_DESIGN/skills/cs-design/SKILL.md` 프로토콜 실행
4. 인수 파싱:
   - `[path]` 없음 → 현재 작업 디렉토리
   - `--focus [aspect]` 있음 → 해당 관점만 집중 분석 (visual/interaction/consistency/responsive/antipatterns)
   - `--fix` 있음 → 발견된 안티패턴 자동 수정 활성화
5. design-lead 에이전트를 스폰하여 5개 에이전트(visual-hierarchy/interaction-quality/design-system-consistency/responsive-accessibility/anti-pattern-detector) 병렬 실행
6. 결과 종합 → 관점별 점수(0-10) + 등급(A~F) + 우선순위별 수정사항 DESIGN-REVIEW.md 출력

---

### `/cs-experiencing version-up [domain|all]`

**정책: 직전 버전 + 현재 버전 2개만 유지. 더 오래된 버전은 자동 삭제.**

**`all` 키워드**: `test` → `plan` → `review` → `design` 4개 도메인 순차 처리.

**각 도메인마다 아래 순서로 실행:**

---

#### STEP 1: 학습 캡처 (AI 자동 추출 우선)

**AI가 먼저 세션 컨텍스트를 분석해서 핵심 노하우를 추출한다. 발견 시 제안 → 사용자 확인. 없으면 직접 질문.**

**1-A. AI 자동 분석**

현재 세션 대화에서 해당 도메인과 관련된 다음 항목을 탐색:
- 예상과 달랐던 동작 (버그, 엣지케이스, 특이 동작)
- 문제 해결 과정에서 발견한 패턴 또는 원인
- 반복 적용 가능한 팁, 설정, 명령어
- 공식 문서/가정과 실제 동작의 차이

**1-B. 발견사항이 있으면 → 제안 후 확인**

AskUserQuestion으로:
```
💡 CS-[DOMAIN] — AI가 분석한 이번 세션 핵심 학습:

"[AI가 추출한 학습 제목]: [구체적 발견 내용 1-2줄]"

이대로 저장할까요?
```
옵션:
- "저장" → 그대로 SKILL.md에 추가
- "직접 수정" → Other 선택 후 수정 내용 입력
- "스킵" → 학습 없이 버전만 증가

**1-C. 발견사항이 없으면 → 직접 질문 (기존 방식)**

```
📝 CS-[DOMAIN] 이번 세션에서 새로 발견한 내용을 입력해주세요.
(없으면 Enter로 스킵)

예시:
- touch-action CSS 미설정 시 swipe 핸들러가 호출되지 않음
- plan-lead의 PLAN.md 출력이 실제 구현 가이드로 충분히 작동함
```

#### STEP 2: 학습 내용 SKILL.md에 추가 (입력이 있을 경우)

1. 최신 도메인 디렉토리의 SKILL.md 읽기
2. 마지막 노하우 번호 파악 (예: `### 15.` → 다음은 `### 16.`)
3. 오늘 날짜 확인: `date +%Y-%m-%d`
4. Edit 도구로 SKILL.md 노하우 섹션 끝에 추가:

```markdown
### [N]. [학습 제목] ([YYYY-MM-DD])

- **상황**: [어떤 작업 중에 발견했는지]
- **발견**: [구체적으로 무엇을 배웠는지]
- **교훈**: [다음에 어떻게 적용할지]
```

#### STEP 3: 버전 디렉토리 생성

```bash
BASE_PATH="$HOME/.claude/plugins/marketplaces/cs-plugins/plugins"
ALL_DIRS=($(ls -d "$BASE_PATH/CS-${DOMAIN}-v"* 2>/dev/null | sort -V))
LATEST_DIR="${ALL_DIRS[-1]}"
CURRENT_VERSION=$(cat "$LATEST_DIR/VERSION" 2>/dev/null || echo "1")
NEXT_VERSION=$((CURRENT_VERSION + 1))
NEW_DIR="$BASE_PATH/CS-${DOMAIN}-v${NEXT_VERSION}"

cp -r "$LATEST_DIR" "$NEW_DIR"
echo "$NEXT_VERSION" > "$NEW_DIR/VERSION"
```

#### STEP 4: marketplace.json 업데이트

파일: `~/.claude/plugins/marketplaces/cs-plugins/.claude-plugin/marketplace.json`

Edit 도구로:
- `"./plugins/CS-[DOMAIN]-v[CURRENT]"` → `"./plugins/CS-[DOMAIN]-v[NEXT]"`

#### STEP 5: 오래된 버전 정리

```bash
TOTAL=${#ALL_DIRS[@]}
DELETE_COUNT=$((TOTAL - 1))
if [ $DELETE_COUNT -gt 0 ]; then
  for dir in "${ALL_DIRS[@]:0:$DELETE_COUNT}"; do
    echo "🗑️ 삭제: $(basename $dir)"
    rm -rf "$dir"
  done
fi
```

#### STEP 6: 완료 안내

```
✅ CS-[DOMAIN] 버전업 완료
📦 현재 버전: CS-[DOMAIN]-v[NEXT] (VERSION=[NEXT])
📦 보관 버전: CS-[DOMAIN]-v[CURRENT] (직전)
🗑️ 삭제됨: [삭제된 버전들]
📝 학습 추가: "[제목]" (노하우 #[N])   ← 입력 있을 경우
📝 학습 스킵                           ← 입력 없을 경우
```

---

**`all` 완료 후 종합 안내:**
```
✅ 전체 버전업 완료
📦 CS-test: v[N] → v[N+1]  (학습 추가/스킵)
📦 CS-plan: v[N] → v[N+1]  (학습 추가/스킵)
📦 CS-codebase-review: v[N] → v[N+1]  (학습 추가/스킵)
📦 cs-design: v[N] → v[N+1]  (학습 추가/스킵)
```

### `/cs-experiencing status`

모든 도메인의 VERSION 파일 표시:

```bash
BASE="$HOME/.claude/plugins/marketplaces/cs-plugins/plugins"
for PATTERN in "CS-test-v" "CS-plan-v" "CS-codebase-review-v" "cs-design-v"; do
  LATEST=$(ls -d "$BASE/${PATTERN}"* 2>/dev/null | sort -V | tail -1)
  if [ -n "$LATEST" ]; then
    VER=$(cat "$LATEST/VERSION" 2>/dev/null || echo "?")
    DOMAIN=$(basename "$LATEST")
    echo "📋 $DOMAIN: v$VER"
  fi
done
```

---

## 버전 철학

- **도메인 디렉토리명** (`CS-test-v2`): 스키마/구조 버전 — 큰 구조 변경 시에만 변경
- **VERSION 파일**: 콘텐츠 버전 — 새 학습이 추가될 때마다 증가
- **plugin.json version**: 전체 플러그인 버전 — semver (major.minor.patch)

---

## experiencing 노하우

### 1. version-up은 학습 캡처 + 디렉토리 복사 두 단계여야 한다 (2026-04-11)

- **상황**: 초기 version-up이 디렉토리 복사 + VERSION 번호 증가만 수행
- **발견**: 단순 cp는 파일 내용이 동일하므로 "경험 저장소"가 아니라 "버전 스냅샷"에 불과함. 새 VERSION 디렉토리에 이번 세션에서 배운 내용이 없으면 버전 증가의 의미가 없다.
- **교훈**: version-up 실행 시 반드시 AskUserQuestion으로 학습 내용을 받아 SKILL.md 노하우 섹션에 추가한 뒤 cp 실행. 학습 없이 버전만 올리는 것은 의미 없음.

### 2. `all` 키워드로 3개 도메인 한번에 버전업 (2026-04-11)

- **상황**: 도메인별로 version-up을 3번 따로 실행해야 했음
- **발견**: `test` → `plan` → `review` 순서로 순차 처리하면 한 번의 명령으로 모두 처리 가능
- **교훈**: `/cs-experiencing version-up all` 지원으로 워크플로우 간소화. 각 도메인마다 학습 캡처 인터랙션이 뜨므로 3번의 입력 기회가 생김.

### 3. AI 자동 학습 추출 — 수동 입력보다 먼저 시도 (2026-04-14)

- **상황**: version-up 시 항상 수동으로 학습 내용을 입력해야 했음. 세션이 길면 무엇을 배웠는지 직접 요약하기 번거로움.
- **발견**: AI가 세션 컨텍스트를 먼저 분석하면 핵심 발견사항(버그 원인, 해결 패턴, 예상 외 동작 등)을 자동 추출 가능. 사용자는 제안을 확인만 하면 됨.
- **교훈**: STEP 1을 "AI 분석 → 제안 → 확인" 순서로 바꾸면 마찰 최소화. 발견사항이 없을 때만 기존 수동 입력 fallback.
