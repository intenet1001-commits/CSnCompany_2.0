---
description: "YouTube Shorts 자동화 빌더 — 경쟁사 리서치 → 대본 → ElevenLabs 보이스 → Gemini 비주얼 → CapCut JSON. (/cs-youtube \"주제\" 또는 /cs-youtube --draft [파일/텍스트] \"주제\")"
allowed-tools: Task, Agent, Read, Write, Edit, Bash, WebSearch, WebFetch, AskUserQuestion, ToolSearch
---

# `/cs-youtube [옵션] "주제"`

YouTube Shorts를 원스톱으로 제작합니다.  
경쟁사 리서치 → 대본 → 보이스 → 비주얼 → CapCut JSON까지 자동화합니다.

## 기본 사용법

```
/cs-youtube "ChatGPT로 월 100만원 버는 법"
/cs-youtube "주식 투자 초보 가이드"
/cs-youtube "다이어트 3가지 비법"
```

## 초안 기반 제작 (내가 쓴 글/블로그 활용)

```
# 파일로 초안 제공
/cs-youtube --draft ./my-idea.md "부업 아이디어"
/cs-youtube --draft ./blog-post.txt "건강한 식단"

# 텍스트 직접 입력
/cs-youtube --draft "제가 생각한 건데요, 요즘 AI 툴을 쓰면..." "AI 활용법"
```

## 옵션

```
--draft [파일경로 또는 "텍스트"]   초안 기반 제작 (경쟁사 벤치마킹으로 개선)
--channel [json경로]              채널 프로필 (목소리, 스타일, 톤 설정)
--duration [초]                   목표 영상 길이 (기본: 60)
--lang [언어코드]                  언어 (기본: ko)
```

## 출력 구조

```
shorts-workspace/projects/YYYY-MM-DD_[slug]/
├── 01_research/competitors.json   경쟁사 YouTube + 블로그 분석
├── 02_script/script.md            훅 + 본문 + CTA 대본
├── 03_voice/voice-plan.json       ElevenLabs API 파라미터
├── 04_visuals/visual-plan.json    Gemini 이미지 프롬프트 (씬별)
└── 05_export/project.json         CapCut 임포트용 통합 JSON
```

## 실행 방법

cs-youtube 스킬 파일을 찾아 실행합니다:

```bash
SKILL_PATH=$(find ~/.claude/plugins ~/plugins ./plugins -name "SKILL.md" \
  -path "*/cs-youtube/*" 2>/dev/null | sort -V | tail -1)

if [ -z "$SKILL_PATH" ]; then
  echo "❌ cs-youtube 스킬을 찾을 수 없습니다."
  echo "설치: npx skills add -g intenet1001-commits/CS-youtube"
  exit 1
fi

echo "✅ cs-youtube 스킬 발견: $SKILL_PATH"
```

SKILL.md의 프로토콜을 따라 실행합니다.
