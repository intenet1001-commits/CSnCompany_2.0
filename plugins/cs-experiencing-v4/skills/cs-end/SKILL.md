# /cs-end — CS Session Closing + Plugin Version-up

session-wrap 패턴(team-attention/plugins-for-claude-natives)을 CSnCOMPANY 컨텍스트로 개선.
세션 분석 → 학습 저장 → 플러그인 버전업 → GitHub push를 한 번에 처리한다.

session-wrap과의 차이:
- CS 플러그인 개발 컨텍스트에 특화된 에이전트 프롬프트
- version-scout 에이전트 추가 (session-wrap에 없음)
- 선택지 제시 없이 완전 자동 실행

---

## Phase 1 — 4-Agent 병렬 분석

아래 4개 에이전트를 **단일 메시지에 동시에** 실행한다.

### Agent 1: doc-updater
이번 세션 변경 내용 기준으로 문서 업데이트 필요 여부를 분석한다.
- git diff HEAD~1 또는 git log --oneline -5로 변경 파악
- CLAUDE.md, README.md, README.ko.md 업데이트 항목 추출
- marketplace.json 변경 필요 여부 확인
- 결과를 간결한 bullet list로 반환 (200자 이내)

### Agent 2: learning-extractor
이번 세션의 핵심 학습 내용을 추출한다.
- 새로 발견한 패턴 또는 아키텍처 결정
- 잘 작동한 것 / 작동하지 않은 것
- 다음 세션에서 참고할 TIL
- 결과를 아래 형식으로 반환:
  ```
  ## TIL YYYY-MM-DD
  - ...
  - ...
  ```

### Agent 3: version-scout
marketplace.json에 등록된 모든 활성 플러그인을 분석한다.
- `/Users/gwanli/.claude/plugins/marketplaces/cs-plugins/.claude-plugin/marketplace.json` 읽기
- 각 플러그인 source 경로의 VERSION 파일 확인
- git log --oneline --diff-filter=M -- <plugin-path> 로 변경 여부 확인
- 변경된 플러그인에 대해 bump 타입 추천:
  - 에이전트/로직 변경 → minor
  - 텍스트/문서 수정 → patch
  - 구조 변경 → major
- 결과 형식:
  ```
  plugin-name: 현재버전 → 권장버전 (이유)
  ```

### Agent 4: followup-suggester
다음 세션 우선순위를 정리한다.
- 이번 세션에서 미완성된 작업
- 발견된 개선 포인트
- 다음으로 해야 할 작업 top 3 (구체적으로)
- 결과를 numbered list로 반환

---

## Phase 2 — duplicate-checker (Validation)

Phase 1의 4개 에이전트 결과를 통합한다:
- 중복 내용 제거
- 상충되는 제안 조율
- 최종 실행할 액션 리스트 확정
- version-scout 결과를 그대로 Phase 3에 전달

---

## Phase 3 — Plugin Version-up

duplicate-checker에서 받은 version-scout 결과 기준으로:

각 변경된 플러그인에 대해:
1. `<plugin-path>/VERSION` 파일 읽기
2. 권장 bump 타입으로 버전 증가 (semver: X.Y.Z)
3. VERSION 파일 업데이트
4. `<plugin-path>/.claude-plugin/plugin.json`의 `"version"` 필드 업데이트

변경 없는 플러그인은 건드리지 않는다.

---

## Phase 4 — Learning 저장 + Git Commit & Push

순서대로 실행:

1. `docs/session-learnings/` 디렉토리 확인 (없으면 생성)
2. `docs/session-learnings/YYYY-MM-DD.md` 파일 생성 (learning-extractor 결과)
3. git -C /Users/gwanli/.claude/plugins/marketplaces/cs-plugins add -A
4. git -C /Users/gwanli/.claude/plugins/marketplaces/cs-plugins commit -m "chore: version-up all domains + add session learnings"
5. git -C /Users/gwanli/.claude/plugins/marketplaces/cs-plugins push

---

## 최종 출력 형식

```
✅ cs-end 완료

📚 세션 학습
- [TIL 항목들]

🔼 버전업
- CS-test: v19 → v20 (minor: 에이전트 로직 변경)
- CS-plan: v16 → v17 (patch: 문서 수정)

📋 다음 세션 할 일
1. ...
2. ...
3. ...

🚀 GitHub push 완료
```
