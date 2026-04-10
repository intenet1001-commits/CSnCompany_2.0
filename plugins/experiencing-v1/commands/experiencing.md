---
description: "경험 지식 저장소 - 도메인별 학습 조회/실행/버전업 (/experiencing [test|plan|version-up|status])"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Agent, AskUserQuestion
---

# /experiencing [subcommand] [args]

누적된 경험 지식을 도메인별로 관리하고 실행합니다.

## 서브커맨드

| 커맨드 | 설명 |
|--------|------|
| `/experiencing` | 도메인 목록 + 버전 현황 |
| `/experiencing test [URL]` | CS-test v1 실행 (14-agent 웹 테스트) |
| `/experiencing plan [task]` | CS-plan v1 실행 |
| `/experiencing version-up test` | CS-test 버전 증가 → 새 버전 디렉토리 생성 |
| `/experiencing version-up plan` | CS-plan 버전 증가 |
| `/experiencing status` | 모든 도메인 버전 현황 |

## 도메인 현황

| 도메인 | 버전 | 내용 |
|--------|------|------|
| CS-test | v1 | playwright 14-agent 웹 테스트 팀 |
| CS-plan | v1 | 플래닝 학습 (준비 중) |

## 실행 흐름

`skills/experiencing/SKILL.md` 참고
