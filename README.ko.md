# CS Plugins - Claude Code 플러그인 컬렉션

웹 애플리케이션 테스트, 자동화, 문서 생성을 위한 Claude Code 플러그인 모음입니다.

## 제공 플러그인

### playwright-test

5개의 전문 에이전트를 활용한 멀티 에이전트 Playwright 테스트 자동화:

| 에이전트 | 역할 |
|----------|------|
| **Explorer** | 페이지 탐색, DOM 분석, 셀렉터 추출 |
| **Functional** | 페이지 로드, 버튼 클릭, 폼 유효성 테스트 |
| **Visual** | 반응형 스크린샷, 접근성 검사 (axe-core) |
| **API** | XHR/Fetch 캡처, 상태 코드 검증 |
| **Performance** | Core Web Vitals, 로드 시간 측정 |

### report-writer

구조화된 형식의 전문 한국어 비즈니스 보고서 작성:

| 기능 | 설명 |
|------|------|
| **계층적 번호 체계** | I. → 1. → • → (1) → - 다단계 구조 |
| **한국어 타이포그래피** | 나눔명조 폰트 및 적절한 서식 |
| **python-docx 호환** | 프로그래밍 방식으로 .docx 파일 생성 |
| **접기/펼치기 섹션** | Word 2016+ 확장/축소 지원 |
| **표 서식** | 헤더, 내용, 제목 스타일링 |

## 설치 방법

> ⚠️ **중요**: Claude Code가 마켓플레이스로 인식하려면 반드시 `~/.claude/plugins/marketplaces/cs_plugins` 경로에 설치해야 합니다.

### 한 줄 설치 (권장)

```bash
git clone https://github.com/intenet1001-commits/cs_plugins ~/.claude/plugins/marketplaces/cs_plugins
```

### 또는 설치 스크립트 사용

```bash
curl -fsSL https://raw.githubusercontent.com/intenet1001-commits/cs_plugins/main/install.sh | bash
```

### 문제 해결

**잘못된 위치에 클론했나요?** 올바른 경로로 이동하세요:

```bash
mv ~/cs_plugins ~/.claude/plugins/marketplaces/cs_plugins
```

## 사용법

설치 후 다음과 같이 스킬을 트리거할 수 있습니다:

**playwright-test:**
- "Playwright 테스트 실행해줘"
- "이 프로젝트 E2E 테스트해줘"
- "웹앱 성능 테스트"

**report-writer:**
- "보고서 작성해줘"
- "전략 보고서 만들어줘"
- "DOCX 문서 생성해줘"

## 빠른 시작

1. **설치** (위의 [설치 방법](#설치-방법) 참조)
2. **Claude Code 재시작**하여 새 플러그인 로드
3. **스킬 사용**: `"Playwright 테스트 실행해줘"` 또는 `"보고서 작성해줘"`

## 아키텍처

```
┌─────────────────────────────────────────────────────────────┐
│                    Test Coordinator                          │
├─────────────────────────────────────────────────────────────┤
│  Phase 1: Explorer 먼저 실행 (페이지 맵 생성)                   │
│                                                              │
│  Phase 2: 나머지 4개 에이전트 병렬 실행                         │
│           ┌──────────┬──────────┬──────────┬──────────┐      │
│           │Functional│  Visual  │   API    │Performance│      │
│           └──────────┴──────────┴──────────┴──────────┘      │
│                                                              │
│  Phase 3: 결과 집계 및 통합 리포트 생성                         │
└─────────────────────────────────────────────────────────────┘
```

## 환경 변수

| 변수 | 기본값 | 설명 |
|------|--------|------|
| `TEST_URL` | `http://localhost:9005` | 테스트 대상 URL |
| `HEADLESS` | `true` | 브라우저 숨김 여부 |
| `SLOW_MO` | `0` | 동작 지연 시간 (ms) |
| `DEVTOOLS` | `false` | 개발자 도구 열기 |

## 결과 파일

테스트 실행 후 다음 위치에 결과가 생성됩니다:

```
tests/
├── results/
│   ├── REPORT.md               # 통합 마크다운 리포트
│   ├── page-map.json           # 페이지 구조 맵
│   ├── functional-tests.json   # 기능 테스트 결과
│   ├── visual-tests.json       # 시각 테스트 결과
│   ├── api-tests.json          # API 테스트 결과
│   └── performance-report.json # 성능 리포트
└── screenshots/                # 반응형 스크린샷
```

## 라이선스

MIT License - 자세한 내용은 [LICENSE](LICENSE)를 참조하세요.

## 기여

이슈와 풀 리퀘스트를 환영합니다!

## 링크

- [English Documentation](README.md)
- [GitHub Repository](https://github.com/intenet1001-commits/cs_plugins)
