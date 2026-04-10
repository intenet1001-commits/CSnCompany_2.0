---
name: experiencing
description: |
  경험 지식 저장소 오케스트레이터.
  도메인별 누적 학습 조회, 실행, 버전 관리.
  Use when invoked via /experiencing, or when user says "경험", "학습 실행", "버전업".
version: 1.0.0
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Agent
  - AskUserQuestion
---

# Experiencing - 경험 지식 저장소

## 사용법

```
/experiencing                          # 도메인 목록 + 버전 현황 표시
/experiencing test [URL]               # CS-test 실행 (14-agent 웹 테스트)
/experiencing plan [task]              # CS-plan 실행
/experiencing version-up [domain]     # 도메인 버전 증가
/experiencing status                   # 모든 도메인 VERSION 파일 읽기
```

---

## 실행 프로토콜

### `/experiencing` (인수 없음)

도메인 목록과 현재 버전을 표시:

```bash
BASE="plugins/experiencing-v1/domains"
for domain in CS-test CS-plan; do
  VERSION=$(cat "$BASE/${domain}-v"*/VERSION 2>/dev/null || echo "?")
  echo "📦 $domain | 현재 콘텐츠 버전: $VERSION"
done
```

### `/experiencing test [URL]`

1. `domains/CS-test-v1/VERSION` 읽기 → 현재 버전 확인
2. `domains/CS-test-v1/skills/CS-test/SKILL.md` 프로토콜 실행
3. URL을 대상으로 14-agent 팀 가동

### `/experiencing plan [task]`

1. `domains/CS-plan-v1/VERSION` 읽기
2. `domains/CS-plan-v1/skills/CS-plan/SKILL.md` 프로토콜 실행

### `/experiencing version-up [domain]`

도메인 버전을 증가시키고 새 버전 디렉토리를 준비:

```bash
DOMAIN="[domain]"  # test 또는 plan
BASE_PATH="/Users/gwanli/cs_plugins/plugins/experiencing-v1/domains"

# 현재 버전 읽기
CURRENT_VERSION=$(cat "$BASE_PATH/${DOMAIN}-v1/VERSION" 2>/dev/null || echo "1")
# 실제로는 최신 도메인 디렉토리를 찾아야 함:
LATEST_DIR=$(ls -d "$BASE_PATH/CS-${DOMAIN}-v"* 2>/dev/null | sort -V | tail -1)
CURRENT_VERSION=$(cat "$LATEST_DIR/VERSION" 2>/dev/null || echo "1")
NEXT_VERSION=$((CURRENT_VERSION + 1))

echo "⬆️ CS-${DOMAIN}-v${CURRENT_VERSION} → v${NEXT_VERSION} 준비 중..."
```

새 버전 디렉토리 생성 절차:
1. `cp -r $LATEST_DIR $BASE_PATH/CS-${DOMAIN}-v${NEXT_VERSION}/` (내용 복사)
2. `echo "$NEXT_VERSION" > $BASE_PATH/CS-${DOMAIN}-v${NEXT_VERSION}/VERSION` (버전 파일 갱신)
3. 새 학습 내용을 추가할 수 있도록 사용자에게 안내
4. `plugin.json` patch version 증가

### `/experiencing status`

모든 도메인의 VERSION 파일과 마지막 수정 시간 표시:

```bash
find /Users/gwanli/cs_plugins/plugins/experiencing-v1/domains -name "VERSION" | sort | while read f; do
  DIR=$(dirname "$f")
  VER=$(cat "$f")
  DOMAIN=$(basename "$DIR")
  echo "📋 $DOMAIN: v$VER"
done
```

---

## 버전 철학

- **도메인 디렉토리명** (`CS-test-v1`): 스키마/구조 버전 — 큰 구조 변경 시에만 변경
- **VERSION 파일**: 콘텐츠 버전 — 새 학습이 추가될 때마다 증가
- **plugin.json version**: 전체 플러그인 버전 — semver (major.minor.patch)
