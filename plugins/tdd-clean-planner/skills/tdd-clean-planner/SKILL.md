# TDD Clean Planner - AI Agent Teams 기반 코딩 플랜 생성

## 개요

4개의 전문 Claude AI 에이전트가 팀을 구성하여 TDD + Clean Architecture 기반의 즉시 실행 가능한 코딩 플랜을 생성합니다.

## 사용법

```
/tdd-plan "기능 설명"
/tdd-plan --lang typescript "기능 설명"
/tdd-plan --output docs/plans "기능 설명"
/tdd-plan --lang python --output src/plans "기능 설명"
```

## 에이전트 팀 구성

| 에이전트 | 역할 | 출력 파일 |
|----------|------|----------|
| **plan-lead** (당신) | 팀 리더 - 오케스트레이션 및 PLAN.md 합성 | `PLAN.md` |
| **domain-analyst** | DDD 도메인 분석 | `domain-analysis.md` |
| **arch-designer** | Clean Architecture 설계 | `architecture.md` |
| **tdd-strategist** | TDD 테스트 전략 | `tdd-strategy.md` |
| **checklist-builder** | 구현 체크리스트 | `implementation-checklist.md` |

## 실행 프로토콜

이 스킬이 실행되면, 당신(실행 에이전트)이 **plan-lead 역할**을 수행합니다. 아래 프로토콜을 정확히 따르세요.

### Phase 0: 인자 파싱 및 준비

1. **인자 파싱**: 입력값에서 다음을 추출합니다.

```
기능 설명: 큰따옴표 안의 텍스트, 또는 옵션 제외 나머지 텍스트
--lang [언어]: 구현 언어 (미지정 시 "미지정 (에이전트가 컨텍스트에서 추론)")
--output [경로]: 출력 디렉토리 (미지정 시 ".tdd-plans")
```

예시:
- `/tdd-plan "장바구니 도메인"` → 기능="장바구니 도메인", 언어=미지정, 출력=".tdd-plans"
- `/tdd-plan --lang typescript "인증"` → 기능="인증", 언어="typescript", 출력=".tdd-plans"
- `/tdd-plan --output docs/plans "결제"` → 기능="결제", 언어=미지정, 출력="docs/plans"

2. **기능 설명 검증**: 기능 설명이 없으면 사용자에게 요청합니다:
```
❓ 플랜을 생성할 기능을 설명해주세요.
예: /tdd-plan "사용자 인증 시스템 (이메일+비밀번호, JWT)"
```

3. **출력 디렉토리 생성**:
```bash
mkdir -p [OUTPUT_DIR]
```

4. **시작 안내 출력**:
```
🚀 TDD Clean Planner 시작
📋 기능: [기능 설명]
🌐 언어: [언어 또는 "자동 감지"]
📁 출력: [OUTPUT_DIR]/

4개 전문 에이전트가 병렬로 플랜을 생성합니다...
```

### Phase 1: 팀 생성 및 태스크 등록

1. **팀 생성**:

```
TeamCreate(team_name: "tdd-clean-planner", description: "TDD + Clean Architecture 코딩 플랜 생성 팀")
```

2. **4개 태스크 생성** (한 번에):

```
TaskCreate(
  subject: "DDD 도메인 분석",
  description: "기능 '[기능 설명]'에 대한 DDD 기반 도메인 모델 분석. Aggregate, Entity, Value Object, Domain Event, Repository Interface 식별. [OUTPUT_DIR]/domain-analysis.md 생성.",
  activeForm: "도메인 분석 중"
)
→ domainTaskId 저장

TaskCreate(
  subject: "Clean Architecture 설계",
  description: "기능 '[기능 설명]'에 대한 Clean Architecture 4레이어 설계. 레이어 구조, 인터페이스, 의존성 관계 설계. [OUTPUT_DIR]/architecture.md 생성.",
  activeForm: "아키텍처 설계 중"
)
→ archTaskId 저장

TaskCreate(
  subject: "TDD 테스트 전략 수립",
  description: "기능 '[기능 설명]'에 대한 TDD 테스트 케이스 전략. Red-Green-Refactor 순서, Given/When/Then 시나리오, Mock 전략 설계. [OUTPUT_DIR]/tdd-strategy.md 생성.",
  activeForm: "TDD 전략 수립 중"
)
→ tddTaskId 저장

TaskCreate(
  subject: "구현 체크리스트 생성",
  description: "기능 '[기능 설명]'에 대한 Inside-Out 구현 체크리스트. 레이어별 Red-Green-Refactor 체크박스, Definition of Done. [OUTPUT_DIR]/implementation-checklist.md 생성.",
  activeForm: "체크리스트 생성 중"
)
→ checklistTaskId 저장
```

### Phase 2: 4개 에이전트 병렬 스폰

**반드시 하나의 응답에서 4개의 Task 호출을 동시에 실행합니다.**

#### domain-analyst 스폰

```
Task(
  subagent_type: "general-purpose",
  name: "domain-analyst",
  team_name: "tdd-clean-planner",
  model: "sonnet",
  prompt: "당신은 domain-analyst 에이전트입니다. DDD(Domain-Driven Design) 전술 패턴 전문가로서 주어진 기능을 분석합니다.

## 임무

**기능 설명**: [기능 설명]
**언어**: [언어]
**출력 디렉토리**: [OUTPUT_DIR]
**담당 태스크 ID**: [domainTaskId]

## DDD 전술 패턴 지식

### Aggregate
비즈니스 일관성 경계. Aggregate Root를 통해서만 외부 접근. 트랜잭션 경계 = Aggregate 경계. 작게 유지.

### Entity
고유 ID를 가진 객체. 생명주기 동안 변경 가능. ID로 동등성 비교.

### Value Object
식별자 없이 속성으로 정의. 불변(Immutable). 모든 속성으로 동등성 비교. 예: Money, Email, Address.

### Domain Event
도메인에서 발생한 의미 있는 사건. 과거 시제 명명 (UserRegistered, OrderPlaced). Aggregate 상태 변경 시 발행.

### Repository Interface
Aggregate 영속성 추상화. 도메인 레이어에 인터페이스 정의. 컬렉션처럼 동작.

### Domain Service
특정 Entity/VO에 속하지 않는 도메인 로직. 상태 없음(Stateless). 복수 Aggregate 조율 시 사용.

### Bounded Context
도메인 모델이 일관되게 적용되는 명시적 경계. 독립적 유비쿼터스 언어.

## 수행 단계

1. **액터 및 유스케이스 식별**: 시스템과 상호작용하는 주체, 달성 목표
2. **Aggregate 설계**: Root Entity, Child Entity, Value Object, Domain Event
3. **Repository Interface 정의**: 저장/조회/삭제 메서드
4. **Domain Service 식별**: 엔티티에 속하지 않는 도메인 로직
5. **유비쿼터스 언어 용어집**: 핵심 도메인 용어 정의

## 출력 파일 형식

`[OUTPUT_DIR]/domain-analysis.md`를 다음 구조로 작성하세요:

```markdown
# 도메인 분석: [기능명]

## 개요
[기능 요약 및 핵심 도메인 설명]

## 액터 (Actors)
| 액터 | 역할 | 주요 유스케이스 |
|------|------|--------------|
| ... | ... | ... |

## 유스케이스 목록
1. **[유스케이스명]** - [설명]
   - 선행조건: [조건]
   - 주요 흐름: [단계]
   - 예외 흐름: [예외 케이스]

## 도메인 모델

### Aggregate: [이름]
**Root Entity: [이름]**
- ID: [타입]
- 속성: [속성 목록]
- 불변식: [비즈니스 규칙]

**Value Objects**
- [VO명]([속성]): [검증 규칙]

**Domain Events**
- [이벤트명]: [발생 시점] - 페이로드: [데이터]

**Repository Interface**
- findById, save, [도메인 특화 메서드]

## 도메인 서비스
- [서비스명]: [역할]

## 유비쿼터스 언어
| 용어 | 의미 |
|------|------|
| ... | ... |
```

## 완료 보고

파일 작성 후:
1. TaskUpdate(taskId: '[domainTaskId]', status: 'completed') 호출
2. SendMessage(type: 'message', recipient: 'plan-lead', content: '도메인 분석 완료. Aggregate [N]개, 유스케이스 [N]개, VO [N]개, Domain Event [N]개 식별.', summary: '도메인 분석 완료') 전송
3. shutdown_request 수신 시 즉시 approve: true로 응답"
)
```

#### arch-designer 스폰

```
Task(
  subagent_type: "general-purpose",
  name: "arch-designer",
  team_name: "tdd-clean-planner",
  model: "sonnet",
  prompt: "당신은 arch-designer 에이전트입니다. Clean Architecture와 SOLID 원칙 전문가로서 주어진 기능의 아키텍처를 설계합니다.

## 임무

**기능 설명**: [기능 설명]
**언어**: [언어]
**출력 디렉토리**: [OUTPUT_DIR]
**담당 태스크 ID**: [archTaskId]

## Clean Architecture 지식

### 4레이어 구조 (의존성: 안쪽 방향만)
1. Domain: Entities, VO, Repository Interfaces → 외부 의존성 없음
2. Application: Use Case Interactors, Input/Output DTOs, Ports
3. Interface Adapters: Controllers, Repository Impls, External Adapters
4. Infrastructure: Framework 설정, DB, DI Container

### 의존성 규칙
- 의존성은 항상 안쪽(더 추상적) 레이어를 향한다
- Domain은 아무것도 import하지 않는다
- Use Case는 도메인만 알고 프레임워크를 모른다
- Port(인터페이스)는 도메인/유스케이스에 정의, Adapter(구현)는 외부에 위치

### SOLID 적용
- SRP: 각 Use Case 클래스는 하나의 유스케이스만 담당
- OCP: 새 기능 = 새 Use Case 클래스 추가 (기존 코드 수정 최소)
- LSP: Repository 구현체 교체 가능 (InMemory ↔ DB)
- ISP: Use Case별 별도 Input/Output Port 인터페이스
- DIP: Use Case → Repository Interface (도메인) ← Repository Impl (인프라)

### KISS / DRY / YAGNI
- 현재 요구사항에 맞는 최소한의 설계
- 중복 로직은 Domain Service 또는 공통 VO로 추출
- 필요하지 않은 확장점은 설계하지 않음

## 수행 단계

1. 유스케이스 목록 파악 및 레이어별 컴포넌트 설계
2. 디렉토리 구조 및 파일 배치 설계
3. 핵심 인터페이스 정의 (언어 무관 형태)
4. 의존성 그래프 검증 (규칙 위반 없는지)
5. 주요 아키텍처 결정사항 (ADR) 정리

## 출력 파일 형식

`[OUTPUT_DIR]/architecture.md`를 다음 구조로 작성하세요:

```markdown
# 아키텍처 설계: [기능명]

## 개요
[Clean Architecture 적용 전략]

## 디렉토리 구조
[레이어별 파일 트리]

## Domain Layer
[Entity, VO, Repository Interface 코드 스케치]

## Application Layer
| 유스케이스 | Input DTO | Output DTO | 사용 Repository | 발행 Event |
|-----------|-----------|-----------|----------------|-----------|

[각 Use Case 상세 로직 흐름]

## Interface Adapters Layer
[Controller 엔드포인트 목록, Repository 구현 전략]

## Infrastructure Layer
[DI 바인딩, 환경변수 목록]

## 아키텍처 결정사항 (ADR)
| 결정 | 선택 | 이유 |
|------|------|------|

## SOLID 체크리스트
[각 원칙 준수 여부]
```

## 완료 보고

파일 작성 후:
1. TaskUpdate(taskId: '[archTaskId]', status: 'completed') 호출
2. SendMessage(type: 'message', recipient: 'plan-lead', content: '아키텍처 설계 완료. [N]개 유스케이스 인터랙터, [N]개 포트 인터페이스, [N]개 어댑터 설계.', summary: '아키텍처 설계 완료') 전송
3. shutdown_request 수신 시 즉시 approve: true로 응답"
)
```

#### tdd-strategist 스폰

```
Task(
  subagent_type: "general-purpose",
  name: "tdd-strategist",
  team_name: "tdd-clean-planner",
  model: "sonnet",
  prompt: "당신은 tdd-strategist 에이전트입니다. TDD(Test-Driven Development) 전문가로서 주어진 기능의 테스트 전략을 설계합니다.

## 임무

**기능 설명**: [기능 설명]
**언어**: [언어]
**출력 디렉토리**: [OUTPUT_DIR]
**담당 태스크 ID**: [tddTaskId]

## TDD 핵심 지식

### Red-Green-Refactor 사이클
- RED: 실패하는 테스트 작성 (구현 없음)
- GREEN: 테스트 통과하는 최소한의 구현
- REFACTOR: 중복 제거, 코드 품질 개선 (테스트 통과 유지)
- Baby Steps: 한 번에 하나의 테스트만 통과시킴

### Given/When/Then 패턴
- GIVEN: 초기 상태/전제조건 설정
- WHEN: 테스트할 행동/동작 수행
- THEN: 예상 결과 확인
- 테스트명: [메서드]_[시나리오]_[예상결과]

### 테스트 피라미드 (Bottom-Up 순서)
1. Value Object Unit Tests (외부 의존성 없음)
2. Entity/Aggregate Unit Tests
3. Domain Service Unit Tests (Repository Fake 사용)
4. Use Case Unit Tests (Repository Fake + Service Mocks)
5. Repository Integration Tests (실제 DB)
6. Controller/API Integration Tests

### Mock 전략
- **Fake 우선**: InMemoryRepository (Map 기반) - 테스트 더블 중 최선
- **Mock**: 부수효과 검증 (이메일 발송 횟수 등)
- **Stub**: 고정 반환값이 필요한 경우
- Mock하지 말 것: 순수 도메인 로직, 단순 변환, VO/Entity 내부

### FIRST 원칙
Fast, Independent, Repeatable, Self-validating, Timely

## 수행 단계

1. 기능에서 핵심 도메인 개념, 비즈니스 규칙, 엣지 케이스 파악
2. 레이어별 테스트 케이스 목록 작성 (TDD 실행 순서대로)
3. 각 테스트에 Given/When/Then 작성
4. Mock/Fake 전략 결정
5. 엣지 케이스 및 테스트 데이터 정의

## 출력 파일 형식

`[OUTPUT_DIR]/tdd-strategy.md`를 다음 구조로 작성하세요:

```markdown
# TDD 전략: [기능명]

## 개요
[TDD 접근 전략]

## 테스트 피라미드 분포
- Unit: [N]개 / Integration: [N]개 / E2E: [N]개

## Mock/Fake 전략
| 의존성 | 전략 | 이유 |

## 테스트 케이스 목록 (TDD 실행 순서)

### Phase 1: Value Object 테스트
[각 VO의 생성 성공/실패, 동등성 케이스 + Given/When/Then]

### Phase 2: Entity/Aggregate 테스트
[생성, 상태변경, 불변식 위반 케이스 + Given/When/Then]

### Phase 3: Domain Service 테스트 (해당 시)
[복합 로직 케이스]

### Phase 4: Use Case 테스트
[Happy Path, 비즈니스 규칙 위반, 인프라 오류 케이스 + Given/When/Then]

### Phase 5: Integration 테스트
[API 엔드포인트별 요청/응답 케이스]

## 엣지 케이스 목록
| 케이스 | 설명 | 예상 동작 |

## 테스트 데이터 전략
| 타입 | 유효한 예시 | 유효하지 않은 예시 |
```

## 완료 보고

파일 작성 후:
1. TaskUpdate(taskId: '[tddTaskId]', status: 'completed') 호출
2. SendMessage(type: 'message', recipient: 'plan-lead', content: 'TDD 전략 완료. Unit 테스트 [N]개, Integration 테스트 [N]개 설계. [N]개 Phase, 엣지 케이스 [N]개 식별.', summary: 'TDD 전략 완료') 전송
3. shutdown_request 수신 시 즉시 approve: true로 응답"
)
```

#### checklist-builder 스폰

```
Task(
  subagent_type: "general-purpose",
  name: "checklist-builder",
  team_name: "tdd-clean-planner",
  model: "sonnet",
  prompt: "당신은 checklist-builder 에이전트입니다. TDD + Clean Architecture 구현 체크리스트 전문가로서 즉시 실행 가능한 체크리스트를 생성합니다.

## 임무

**기능 설명**: [기능 설명]
**언어**: [언어]
**출력 디렉토리**: [OUTPUT_DIR]
**담당 태스크 ID**: [checklistTaskId]

## Inside-Out 구현 전략

Clean Architecture + TDD에서 권장하는 구현 순서:
```
1. Value Objects (외부 의존성 없음 → 즉시 테스트 가능)
2. Domain Entities/Aggregates (VO에만 의존)
3. Repository Interface 정의 + InMemory Fake 구현
4. Domain Services (Fake Repository로 테스트)
5. Use Case Interactors (Fake Repository + Service Mocks)
6. Repository 실제 구현 (DB 연동, Integration 테스트)
7. Controllers/Adapters (API Integration 테스트)
8. Infrastructure/DI 설정 (전체 통합)
```

## Red-Green-Refactor 체크박스 패턴

각 구현 단위마다:
```
- [ ] 🔴 RED: [테스트명] 테스트 작성 (실패 확인)
- [ ] 🟢 GREEN: [구현 방향] 최소 구현
- [ ] 🔵 RFCT: [개선 포인트] 리팩토링
```

## Definition of Done

기능 완료 기준:
- 모든 Unit/Integration 테스트 통과
- 핵심 비즈니스 로직 커버리지 ≥ 90%
- 의존성 규칙 준수 (도메인 → 외부 의존 없음)
- 환경변수/설정 문서화

## 수행 단계

1. 기능 분석 → 구현 컴포넌트 목록 작성
2. 의존 관계 파악 → 구현 순서 결정
3. 환경 설정 체크리스트 작성
4. 레이어별 Red-Green-Refactor 체크박스 생성
5. Definition of Done 및 빠른 시작 명령어 작성

## 출력 파일 형식

`[OUTPUT_DIR]/implementation-checklist.md`를 다음 구조로 작성하세요:

```markdown
# 구현 체크리스트: [기능명]

## 환경 설정
- [ ] 프로젝트 초기화
- [ ] 테스트 프레임워크 설치
- [ ] 폴더 구조 생성 (bash 명령어 포함)

---

## Phase 1: Value Objects
### [VO명]
- [ ] 🔴 RED: [테스트명] 테스트 작성
- [ ] 🟢 GREEN: 최소 구현
- [ ] 🔵 RFCT: 리팩토링
[반복...]

## Phase 2: Domain Entities
[동일 패턴]

## Phase 3: Repository Interface & Fake
[동일 패턴]

## Phase 4: Use Cases
[동일 패턴, Happy Path + 예외 케이스별]

## Phase 5: Repository 구현체 (DB 연동)
[Integration 테스트 포함]

## Phase 6: Controllers & API
[엔드포인트별 체크리스트]

## Phase 7: DI & 통합
[DI 설정, E2E 테스트]

---

## 최종 Definition of Done
- [ ] 모든 테스트 통과
- [ ] 커버리지 ≥ 90%
[기타 항목...]

## 빠른 시작 명령어
[언어별 테스트 실행 명령어]
```

## 완료 보고

파일 작성 후:
1. TaskUpdate(taskId: '[checklistTaskId]', status: 'completed') 호출
2. SendMessage(type: 'message', recipient: 'plan-lead', content: '구현 체크리스트 완료. 총 [N]개 체크박스, [N]개 Phase, Red-Green-Refactor 사이클 [N]개.', summary: '구현 체크리스트 완료') 전송
3. shutdown_request 수신 시 즉시 approve: true로 응답"
)
```

### Phase 3: 결과 취합 및 PLAN.md 생성

4개 에이전트의 완료 메시지를 모두 수신한 후:

1. **4개 결과 파일 읽기**:
   - `[OUTPUT_DIR]/domain-analysis.md`
   - `[OUTPUT_DIR]/architecture.md`
   - `[OUTPUT_DIR]/tdd-strategy.md`
   - `[OUTPUT_DIR]/implementation-checklist.md`

2. **PLAN.md 합성**: 아래 형식으로 `[OUTPUT_DIR]/PLAN.md`를 작성합니다.

```markdown
# TDD Clean Planner: [기능명]

> 생성일: [YYYY-MM-DD]
> 언어: [언어]
> 생성 도구: tdd-clean-planner AI Agent Teams

---

## 빠른 시작 가이드

이 플랜의 권장 실행 순서:

1. **도메인 이해** → `domain-analysis.md` 전체 읽기
2. **아키텍처 파악** → `architecture.md`의 디렉토리 구조 확인
3. **환경 설정** → `implementation-checklist.md`의 "환경 설정" 섹션 실행
4. **TDD 시작** → `implementation-checklist.md`의 Phase 1부터 순서대로 진행
5. **테스트 참조** → `tdd-strategy.md`에서 각 테스트의 Given/When/Then 확인

---

## 1. 도메인 개요

### 핵심 도메인 개념
[domain-analysis.md의 Aggregate, VO, Event 핵심 요약]

### 주요 유스케이스
[유스케이스 목록 요약]

### 핵심 비즈니스 규칙
[불변식 및 도메인 규칙 요약]

---

## 2. 아키텍처 요약

### 레이어 구조
[architecture.md의 디렉토리 트리]

### 핵심 인터페이스
[주요 Repository Interface, Use Case Input/Output DTO 요약]

### 의존성 흐름
```
[Controller] → [UseCase] → [DomainEntity]
                    ↓
             [RepositoryInterface] ← [RepositoryImpl]
```

---

## 3. TDD 실행 로드맵

### 테스트 케이스 수
- Unit 테스트: [N]개
- Integration 테스트: [N]개
- 예상 소요 시간: [N]시간 (경험치)

### 첫 번째 테스트 (시작 지점)
[tdd-strategy.md의 Phase 1 첫 번째 테스트 케이스 표시]

```
// 첫 번째 RED 테스트 예시
describe('[VO명]', () => {
  it('[테스트명]', () => {
    // Given
    [Given 설정]
    // When
    [동작]
    // Then
    [검증]
  })
})
```

---

## 4. 구현 진행 상황 트래커

| Phase | 내용 | 상태 |
|-------|------|------|
| 환경 설정 | 프로젝트 초기화, 테스트 프레임워크 | ⬜ 대기 |
| Phase 1 | Value Objects | ⬜ 대기 |
| Phase 2 | Domain Entities | ⬜ 대기 |
| Phase 3 | Repository Interface & Fake | ⬜ 대기 |
| Phase 4 | Use Cases | ⬜ 대기 |
| Phase 5 | Repository 구현체 | ⬜ 대기 |
| Phase 6 | Controllers & API | ⬜ 대기 |
| Phase 7 | DI & 통합 | ⬜ 대기 |

> 각 Phase 완료 시 ⬜ → ✅로 변경하세요.

---

## 5. 참고 파일

| 파일 | 내용 | 활용 시점 |
|------|------|---------|
| `domain-analysis.md` | DDD 도메인 모델, 유스케이스, 유비쿼터스 언어 | 개발 전반 참고 |
| `architecture.md` | Clean Architecture 레이어 구조, 인터페이스 명세 | 파일 생성 시 참고 |
| `tdd-strategy.md` | 테스트 케이스 목록, Given/When/Then | 각 테스트 작성 시 |
| `implementation-checklist.md` | 레이어별 Red-Green-Refactor 체크박스 | 구현 진행 트래커 |

---

*이 플랜은 tdd-clean-planner AI Agent Teams에 의해 자동 생성되었습니다.*
```

3. **팀 종료**:

```
SendMessage(type: "shutdown_request", recipient: "domain-analyst", content: "플랜 생성 완료, 종료 요청")
SendMessage(type: "shutdown_request", recipient: "arch-designer", content: "플랜 생성 완료, 종료 요청")
SendMessage(type: "shutdown_request", recipient: "tdd-strategist", content: "플랜 생성 완료, 종료 요청")
SendMessage(type: "shutdown_request", recipient: "checklist-builder", content: "플랜 생성 완료, 종료 요청")
```

모든 에이전트가 `shutdown_response(approve: true)`로 응답하면 `TeamDelete` 호출.

4. **완료 안내 출력**:

```
✅ TDD Clean Plan 생성 완료!

📁 생성된 파일 ([OUTPUT_DIR]/)
├── domain-analysis.md      ← 도메인 모델, 유스케이스, 유비쿼터스 언어
├── architecture.md         ← Clean Architecture 레이어 구조 + 인터페이스
├── tdd-strategy.md         ← 테스트 케이스 순서 + Given/When/Then
├── implementation-checklist.md  ← 레이어별 Red-Green-Refactor 체크박스
└── PLAN.md                 ← 종합 플랜 (빠른 시작 가이드)

🚀 시작하기:
   cat [OUTPUT_DIR]/PLAN.md
   # 또는
   open [OUTPUT_DIR]/PLAN.md
```

## 에러 처리

- **기능 설명 없음**: 사용자에게 기능 설명 입력 요청 후 중단
- **에이전트 실패**: 해당 섹션을 "⚠️ 생성 실패 - 수동 작성 필요"로 표시하고 나머지로 PLAN.md 생성
- **출력 디렉토리 생성 실패**: 권한 오류 메시지와 함께 중단

## 출력 파일

```
[OUTPUT_DIR]/                     (기본: .tdd-plans/)
├── domain-analysis.md            # 도메인 엔티티, 유스케이스, 경계
├── architecture.md               # Clean Architecture 레이어 구조
├── tdd-strategy.md               # 테스트 케이스 순서 + Given/When/Then
├── implementation-checklist.md   # 레이어별 Red-Green-Refactor 체크박스
└── PLAN.md                       # 종합 플랜 (빠른 시작 가이드 포함)
```
