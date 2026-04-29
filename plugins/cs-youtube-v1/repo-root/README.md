# CS-youtube — AI YouTube Shorts Builder

Claude Code 스킬로 YouTube Shorts를 원스톱 자동화합니다.

## 파이프라인

```
주제 또는 초안 입력
   ↓
🔍 경쟁사 리서처   — YouTube 고조회수 영상 5개 + 블로그 3개 분석
   ↓
✍️  대본 작성자     — 훅(3초) + 본문 + CTA 60초 대본
   ↓ (병렬)
🎙️  ElevenLabs 플래너 — 세그먼트별 보이스 설정
🖼️  Gemini 비주얼 플래너 — 씬별 이미지 프롬프트
   ↓
📦 CapCut JSON     — 타임라인, 자막, 음악 통합 export
```

## 설치

```bash
# 1. 이 레포 클론
git clone https://github.com/intenet1001-commits/CS-youtube.git
cd CS-youtube

# 2. Claude Code 플러그인 설치
npx skills add ./plugins/cs-youtube-v1

# 3. API 키 설정
cp .env.example .env
# .env 파일에 ELEVENLABS_API_KEY, GEMINI_API_KEY 입력
```

## 사용법

```bash
# 주제만으로 시작
/cs-youtube "ChatGPT로 월 100만원 버는 법"

# 내가 쓴 초안으로 시작 (경쟁사 벤치마킹으로 개선)
/cs-youtube --draft ./my-idea.md "부업 아이디어"

# 텍스트 직접 붙여넣기
/cs-youtube --draft "제가 생각한 건데요..." "AI 활용법"

# 채널 프로필 + 30초 버전
/cs-youtube --channel ./config/channels/my-channel.json --duration 30 "주제"
```

## 출력 구조

```
shorts-workspace/projects/2026-04-29_ChatGPT활용법/
├── 00_brief.md              입력 정보 요약
├── 01_research/
│   └── competitors.json     경쟁사 YouTube + 블로그 분석
├── 02_script/
│   ├── script.md            최종 대본 (마크다운)
│   └── segments.json        씬별 세그먼트
├── 03_voice/
│   ├── voice-plan.json      ElevenLabs API 설정
│   └── audio/               생성된 mp3 파일 (직접 생성)
├── 04_visuals/
│   ├── visual-plan.json     Gemini 이미지 프롬프트
│   └── images/              생성된 이미지 (직접 생성)
└── 05_export/
    └── project.json         CapCut 임포트용 통합 JSON ✨
```

## API 설정

### ElevenLabs (보이스)
1. https://elevenlabs.io 가입
2. Profile → API Keys에서 키 복사
3. `.env`의 `ELEVENLABS_API_KEY` 입력

### Google Gemini (비주얼)
1. https://aistudio.google.com/apikey 접속
2. API 키 생성
3. `.env`의 `GEMINI_API_KEY` 입력

## CapCut 최종 편집 워크플로

1. `05_export/project.json` 검토
2. `voice-plan.json` 기반으로 ElevenLabs에서 오디오 생성 → `03_voice/audio/`
3. `visual-plan.json` 기반으로 Gemini에서 이미지 생성 → `04_visuals/images/`
4. CapCut 새 프로젝트 → 9:16 비율 설정
5. 이미지/오디오 순서대로 임포트
6. `capcut_timeline` 설정 참고하여 편집
7. 자막 자동 생성 + 스타일 적용

## 채널 프로필 설정

```bash
cp plugins/cs-youtube-v1/templates/channel-profile.json config/channels/my-channel.json
# config/channels/my-channel.json 편집 (목소리 ID, 비주얼 스타일 등)
```

## 라이선스

MIT
