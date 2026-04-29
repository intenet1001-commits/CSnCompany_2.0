---
name: cs-youtube
user-invocable: true
description: |
  YouTube Shorts builder. Use when user types "/cs-youtube", "숏폼 만들어", "유튜브 쇼츠",
  "shorts 제작", "쇼츠 만들어", "유튜브 영상 만들어", or wants to create a YouTube Short
  with competitor research, script writing, ElevenLabs voice plan, Gemini visual plan,
  and CapCut JSON export. Supports topic-only mode or draft-based mode (--draft).
version: 1.0.0
allowed-tools:
  - Task
  - Agent
  - Read
  - Write
  - Edit
  - Bash
  - WebSearch
  - WebFetch
  - AskUserQuestion
  - ToolSearch
---

# cs-youtube — YouTube Shorts 자동화 빌더

## 개요

`youtube-director` 에이전트가 4개의 전문 에이전트 팀을 조율하여  
경쟁사 리서치부터 CapCut JSON까지 원스톱으로 YouTube Shorts를 제작합니다.

**지원하는 3가지 입력 모드:**

| 모드 | 예시 | 동작 |
|------|------|------|
| A — 주제만 | `/cs-youtube "ChatGPT 활용법"` | 리서치 → 대본 자동 생성 |
| B — 초안 파일 | `/cs-youtube --draft ./my-draft.md "제목"` | 초안 기반 + 경쟁사 벤치마킹 |
| C — 인라인 초안 | `/cs-youtube --draft "내가 쓴 글..." "제목"` | 텍스트 직접 입력 |

## 사용법

```
/cs-youtube "주제"
/cs-youtube --draft ./draft.md "주제"
/cs-youtube --draft "초안 텍스트..." "주제"
/cs-youtube --channel ./config/channels.json --draft ./draft.md "주제"
/cs-youtube --duration 30 "주제"        # 기본 60초, 30초 버전도 가능
/cs-youtube --lang ko "주제"            # 기본 한국어
```

## 실행 프로토콜

### Step 1: 인자 파싱

입력에서 다음을 추출합니다:

```
TOPIC      = 큰따옴표 안의 텍스트, 또는 옵션 제외 나머지
DRAFT      = --draft [파일경로 또는 "인라인 텍스트"] (없으면 모드 A)
CHANNEL    = --channel [채널 프로필 JSON 경로] (없으면 default)
DURATION   = --duration [초] (없으면 60)
LANG       = --lang [언어코드] (없으면 ko)
```

TOPIC이 없으면 사용자에게 요청 후 중단:
```
❓ 어떤 주제로 YouTube Shorts를 만들까요?
예: /cs-youtube "ChatGPT로 월 100만원 버는 법"
예: /cs-youtube --draft ./my-idea.md "부업 아이디어"
```

### Step 2: 시작 안내 출력

```
🎬 cs-youtube Shorts Builder 시작
📋 주제: [TOPIC]
📝 모드: [A: 자동 리서치 | B/C: 초안 기반]
⏱️  목표 길이: [DURATION]초
🌐 언어: [LANG]

youtube-director가 4개 전문 에이전트를 조율합니다...
├── 🔍 researcher   — 경쟁사 YouTube + 블로그 분석
├── ✍️  scriptwriter — 대본 작성 (훅 + 본문 + CTA)
├── 🎙️  voice-planner — ElevenLabs 보이스 플랜
└── 🖼️  visual-planner — Gemini 비주얼 프롬프트
```

### Step 3: 프로젝트 폴더 생성

```bash
SLUG=$(echo "[TOPIC]" | tr ' ' '_' | head -c 30)
DATE=$(date +%Y-%m-%d)
PROJECT_DIR="shorts-workspace/projects/${DATE}_${SLUG}"
mkdir -p "${PROJECT_DIR}/01_research"
mkdir -p "${PROJECT_DIR}/02_script"
mkdir -p "${PROJECT_DIR}/03_voice/audio"
mkdir -p "${PROJECT_DIR}/04_visuals/images"
mkdir -p "${PROJECT_DIR}/05_export"
```

`00_brief.md`에 입력 정보 저장:
```
# [TOPIC]
- 모드: [모드]
- 생성일: [DATE]
- 목표 길이: [DURATION]초
- 초안: [있음/없음]
```

### Step 4: youtube-director 에이전트 스폰

```
Task(
  subagent_type: "general-purpose",
  name: "youtube-director",
  model: "opus",
  prompt: "당신은 cs-youtube의 youtube-director입니다.
  아래 컨텍스트로 YouTube Shorts 프로젝트를 완성하세요.

  TOPIC: [TOPIC]
  DRAFT: [DRAFT_TEXT 또는 null]
  PROJECT_DIR: [PROJECT_DIR]
  DURATION: [DURATION]
  LANG: [LANG]
  CHANNEL_PROFILE: [채널 프로필 JSON 또는 default]

  youtube-director.md 프로토콜을 따라 4개 에이전트를 조율하고
  05_export/project.json을 완성하세요."
)
```

### Step 5: 완료 후 출력

```
✅ YouTube Shorts 프로젝트 완성!

📁 프로젝트 위치: [PROJECT_DIR]
├── 01_research/competitors.json   — 경쟁사 분석
├── 02_script/script.md            — 최종 대본
├── 03_voice/voice-plan.json       — ElevenLabs 설정
├── 04_visuals/visual-plan.json    — Gemini 비주얼 프롬프트
└── 05_export/project.json         — CapCut 임포트용 JSON ✨

📋 다음 단계:
1. 05_export/project.json 검토
2. ElevenLabs에서 보이스 생성 (voice-plan.json 참고)
3. Gemini에서 이미지 생성 (visual-plan.json 참고)
4. CapCut에서 최종 편집
```

## 에러 처리

- WebSearch 실패 시: 리서치 없이 주제만으로 대본 생성 후 경고 표시
- DRAFT 파일 없음: 에러 메시지 후 모드 A로 전환 여부 확인
- PROJECT_DIR 존재: 타임스탬프 추가하여 새 폴더 생성
