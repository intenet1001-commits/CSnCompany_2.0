# /codebase-review Command

전체 코드베이스를 분석하여 품질, 아키텍처, 보안 등을 종합 검토합니다.

## Usage

```
/codebase-review              # 전체 코드베이스 분석
/codebase-review [path]       # 특정 경로만 분석
/codebase-review --focus [aspect]  # 특정 관점만 분석
```

### Focus Options
- `architecture` - 구조, 패턴, 의존성 분석
- `quality` - 코드 품질, 중복, 복잡도 분석
- `security` - 보안 취약점, 민감정보 분석
- `performance` - 성능 병목, 메모리 분석
- `maintainability` - 문서화, 테스트 커버리지 분석

## Examples

```bash
# 전체 프로젝트 분석
/codebase-review

# src 디렉토리만 분석
/codebase-review src/

# 보안 관점만 집중 분석
/codebase-review --focus security

# 특정 경로의 성능만 분석
/codebase-review src/api --focus performance
```

## Output

5가지 관점(Architecture, Quality, Security, Performance, Maintainability)에서 A/B/C/D 등급으로 평가하고, 구체적인 개선 권장사항을 우선순위별로 제공합니다.

## Skill Reference

이 커맨드는 `skills/codebase-review/SKILL.md`의 프로토콜을 따릅니다.
