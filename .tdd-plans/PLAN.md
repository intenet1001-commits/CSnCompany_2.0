# TDD Clean Planner: 간단한 Todo 앱 (추가/삭제/완료 체크)

> 생성일: 2026-02-22
> 언어: TypeScript (에이전트 추론)
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

| 구성요소 | 이름 | 설명 |
|----------|------|------|
| **Aggregate** | `Todo` | 할 일 항목의 생명주기 관리 (1개) |
| **Value Objects** | `TodoId`, `TodoTitle`, `TodoStatus` | 불변 값 객체 (3개) |
| **Domain Events** | `TodoAdded`, `TodoRemoved`, `TodoCompleted`, `TodoUncompleted` | 상태 변경 이벤트 (4개) |
| **Repository** | `ITodoRepository` | `findById`, `findAll`, `save`, `remove` |

### 주요 유스케이스

1. **AddTodo** — 제목 입력 → Todo 생성 (빈 제목 거부)
2. **RemoveTodo** — ID로 삭제 (없는 ID → NotFoundError)
3. **CompleteTodo** — 완료 체크 (이미 완료 시 멱등 처리)
4. **UncompleteTodo** — 완료 해제
5. **ListTodos** — 전체 목록 조회

### 핵심 비즈니스 규칙

- `TodoTitle`: 1자 이상 255자 이하, 공백만 있는 경우 거부 (trim 후 검증)
- `TodoId`: 생성 후 변경 불가
- `TodoStatus`: `pending` | `completed` 두 값만 허용
- 완료/미완료 전환은 **멱등 처리** (이미 같은 상태면 에러 없이 동일 상태 반환)

---

## 2. 아키텍처 요약

### 레이어 구조

```
src/
├── domain/
│   ├── entities/
│   │   └── Todo.ts                    # Aggregate Root
│   ├── value_objects/
│   │   ├── TodoId.ts
│   │   ├── TodoTitle.ts
│   │   └── TodoStatus.ts
│   └── repositories/
│       └── ITodoRepository.ts         # Port (인터페이스)
│
├── application/
│   ├── use_cases/
│   │   ├── AddTodoUseCase.ts
│   │   ├── DeleteTodoUseCase.ts
│   │   ├── CompleteTodoUseCase.ts
│   │   └── ListTodosUseCase.ts
│   └── dtos/
│       └── (Input/Output DTO 파일들)
│
├── interface_adapters/
│   ├── controllers/
│   │   └── TodoController.ts
│   └── repositories/
│       └── InMemoryTodoRepository.ts  # Fake (테스트 + 초기 구현)
│
└── infrastructure/
    └── di/
        └── Container.ts               # DI 바인딩
```

### 핵심 인터페이스

```typescript
// Domain Layer (Port)
interface ITodoRepository {
  findById(id: TodoId): Promise<Todo | null>;
  findAll(): Promise<Todo[]>;
  save(todo: Todo): Promise<void>;
  delete(id: TodoId): Promise<void>;
}

// Application Layer (Use Case I/O)
// AddTodo:    { title: string }  →  { id, title, completed: false }
// DeleteTodo: { id: string }     →  { success: boolean }
// CompleteTodo: { id: string }   →  { id, completed: true }
```

### 의존성 흐름

```
[TodoController] → [AddTodoUseCase]    → [Todo Entity]
                   [DeleteTodoUseCase]       ↑
                   [CompleteTodoUseCase] [ITodoRepository] ← [InMemoryTodoRepository]
                                         (Domain Port)        (Interface Adapter)
```

- **Domain**: 외부 의존 없음
- **Application**: Domain만 import
- **Interface Adapters**: Application + Domain import
- **Infrastructure**: 모든 레이어 import (DI 조립)

---

## 3. TDD 실행 로드맵

### 테스트 케이스 수

- Unit 테스트: **22개**
- Integration 테스트: **6개**
- E2E 테스트: **2개**
- **총 30개** | 엣지 케이스: 10개

### 구현 순서 (Inside-Out)

```
Phase 1 → Value Objects (TodoId, TodoTitle, TodoStatus)  ← 여기서 시작
Phase 2 → Todo Entity / Aggregate
Phase 3 → Repository Interface + InMemory Fake
Phase 4 → Use Cases (Add / Delete / Complete / List)
Phase 5 → Repository 실제 구현체 (선택 — DB 연동)
Phase 6 → Controllers & API
Phase 7 → DI & 통합
```

### 첫 번째 테스트 (시작 지점)

**TC-01: TodoId — 유효한 UUID로 생성 성공**

```typescript
// tests/unit/domain/TodoId.test.ts
describe('TodoId', () => {
  it('유효한_UUID_생성_성공', () => {
    // Given
    const uuid = "550e8400-e29b-41d4-a716-446655440000";
    // When
    const todoId = new TodoId(uuid);
    // Then
    expect(todoId.value).toBe(uuid);
  });

  it('빈_문자열_생성_실패', () => {
    // Given
    const empty = "";
    // When & Then
    expect(() => new TodoId(empty)).toThrow();
  });

  it('동일한_값의_TodoId는_동등', () => {
    // Given
    const id1 = new TodoId("550e8400-e29b-41d4-a716-446655440000");
    const id2 = new TodoId("550e8400-e29b-41d4-a716-446655440000");
    // When & Then
    expect(id1.equals(id2)).toBe(true);
  });
});
```

---

## 4. 구현 진행 상황 트래커

| Phase | 내용 | 항목 수 | 상태 |
|-------|------|---------|------|
| 환경 설정 | 프로젝트 초기화, Jest, 폴더 구조 | 5 | ⬜ 대기 |
| Phase 1 | Value Objects (TodoId, TodoTitle, TodoStatus) | RED 9 / GREEN 3 / RFCT 3 | ⬜ 대기 |
| Phase 2 | Todo Entity | RED 6 / GREEN 1 / RFCT 1 | ⬜ 대기 |
| Phase 3 | Repository Interface & Fake | RED 5 / GREEN 1 / RFCT 1 | ⬜ 대기 |
| Phase 4 | Use Cases (Add/Delete/Complete/List) | RED 14 / GREEN 4 / RFCT 4 | ⬜ 대기 |
| Phase 5 | Repository 구현체 (선택) | RED 2 / GREEN 1 / RFCT 1 | ⬜ 대기 |
| Phase 6 | Controllers & API | RED 7 / GREEN 1 / RFCT 1 | ⬜ 대기 |
| Phase 7 | DI & 통합 | RED 1 / GREEN 1 / RFCT 1 | ⬜ 대기 |

> 총 체크박스: **약 90개** | RGR 사이클: **27개**
> 각 Phase 완료 시 ⬜ → ✅로 변경하세요.

---

## 5. 참고 파일

| 파일 | 내용 | 활용 시점 |
|------|------|---------|
| `domain-analysis.md` | DDD 도메인 모델, 유스케이스 5개, 유비쿼터스 언어 | 개발 전반 참고 |
| `architecture.md` | Clean Architecture 4레이어 구조, 인터페이스 명세, SOLID 체크리스트 | 파일 생성 시 참고 |
| `tdd-strategy.md` | 테스트 케이스 30개, Given/When/Then, Mock/Fake 전략 | 각 테스트 작성 시 |
| `implementation-checklist.md` | 레이어별 Red-Green-Refactor 체크박스 90개, 빠른 시작 명령어 | 구현 진행 트래커 |

---

*이 플랜은 tdd-clean-planner AI Agent Teams에 의해 자동 생성되었습니다.*
