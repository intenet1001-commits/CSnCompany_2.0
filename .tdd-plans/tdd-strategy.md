# TDD 전략: Todo 앱 (추가/삭제/완료 체크)

## 개요

Todo 앱의 핵심 기능(추가, 삭제, 완료 체크)을 TDD Red-Green-Refactor 사이클로 구현합니다.
도메인 중심 설계(Clean Architecture)를 기반으로, Value Object → Entity → Use Case → API 순서로 Bottom-Up TDD를 적용합니다.
각 레이어는 독립적으로 테스트 가능하며, Repository는 InMemory Fake 구현체를 사용합니다.

---

## 테스트 피라미드 분포

- Unit: 22개 / Integration: 6개 / E2E: 2개
- **총 30개**

---

## Mock/Fake 전략

| 의존성 | 전략 | 이유 |
|---|---|---|
| TodoRepository | Fake (InMemoryTodoRepository) | 상태 보존이 필요한 CRUD, Map 기반으로 빠르고 결정론적 |
| IdGenerator | Stub | 고정 UUID 반환 — 테스트 예측 가능성 확보 |
| Clock/Date | Stub | 생성일시 고정 — 시간 의존성 제거 |
| EventPublisher (선택) | Mock | 이벤트 발행 횟수 및 타입 검증 시 사용 |
| 순수 도메인 로직 | Mock 금지 | VO/Entity 내부 로직은 직접 호출 |

---

## 테스트 케이스 목록 (TDD 실행 순서)

---

### Phase 1: Value Object 테스트

#### 1-1. TodoId

**TC-01: 유효한 UUID로 TodoId 생성 성공**
- GIVEN: 유효한 UUID 문자열 `"550e8400-e29b-41d4-a716-446655440000"`
- WHEN: `new TodoId(value)` 호출
- THEN: `todoId.value === "550e8400-e29b-41d4-a716-446655440000"`

**TC-02: 빈 문자열로 TodoId 생성 시 예외**
- GIVEN: 빈 문자열 `""`
- WHEN: `new TodoId("")` 호출
- THEN: `InvalidTodoIdError` 발생

**TC-03: 잘못된 형식으로 TodoId 생성 시 예외**
- GIVEN: UUID 형식이 아닌 문자열 `"not-a-uuid"`
- WHEN: `new TodoId("not-a-uuid")` 호출
- THEN: `InvalidTodoIdError` 발생

**TC-04: 동일한 값의 TodoId는 동등(equality)**
- GIVEN: 동일한 UUID로 생성된 두 TodoId
- WHEN: `id1.equals(id2)` 호출
- THEN: `true` 반환

---

#### 1-2. TodoTitle

**TC-05: 유효한 제목으로 TodoTitle 생성 성공**
- GIVEN: 문자열 `"우유 사기"`
- WHEN: `new TodoTitle("우유 사기")` 호출
- THEN: `title.value === "우유 사기"`

**TC-06: 빈 제목으로 TodoTitle 생성 시 예외**
- GIVEN: 빈 문자열 `""`
- WHEN: `new TodoTitle("")` 호출
- THEN: `EmptyTitleError` 발생

**TC-07: 100자 초과 제목으로 TodoTitle 생성 시 예외**
- GIVEN: 101자 문자열
- WHEN: `new TodoTitle(101자 문자열)` 호출
- THEN: `TitleTooLongError` 발생

**TC-08: 공백만 있는 제목은 빈 제목으로 처리**
- GIVEN: `"   "` (공백만 있는 문자열)
- WHEN: `new TodoTitle("   ")` 호출
- THEN: `EmptyTitleError` 발생

---

### Phase 2: Entity / Aggregate 테스트

#### 2-1. Todo Entity 생성

**TC-09: 유효한 인자로 Todo 생성 성공**
- GIVEN: 유효한 `TodoId`, `TodoTitle`, `createdAt: Date`
- WHEN: `Todo.create(id, title, createdAt)` 호출
- THEN: `todo.id`, `todo.title` 정상 설정, `todo.isCompleted === false`

**TC-10: 새로 생성된 Todo는 미완료 상태**
- GIVEN: `Todo.create(...)` 호출 직후
- WHEN: `todo.isCompleted` 확인
- THEN: `false`

---

#### 2-2. Todo 완료 체크 (complete)

**TC-11: 미완료 Todo를 완료 처리 성공**
- GIVEN: `isCompleted === false`인 Todo
- WHEN: `todo.complete()` 호출
- THEN: `todo.isCompleted === true`

**TC-12: 이미 완료된 Todo를 다시 완료 처리 시 예외**
- GIVEN: `isCompleted === true`인 Todo
- WHEN: `todo.complete()` 호출
- THEN: `AlreadyCompletedError` 발생

---

#### 2-3. Todo 완료 취소 (uncomplete)

**TC-13: 완료된 Todo를 미완료로 되돌리기 성공**
- GIVEN: `isCompleted === true`인 Todo
- WHEN: `todo.uncomplete()` 호출
- THEN: `todo.isCompleted === false`

**TC-14: 이미 미완료인 Todo를 uncomplete 시 예외**
- GIVEN: `isCompleted === false`인 Todo
- WHEN: `todo.uncomplete()` 호출
- THEN: `NotCompletedError` 발생

---

### Phase 3: Domain Service 테스트

이번 Todo 앱은 단일 Aggregate이므로 별도의 Domain Service 없이 Use Case에서 처리합니다.
(복수 Aggregate 간 협력이 없음)

---

### Phase 4: Use Case 테스트

모든 Use Case는 `InMemoryTodoRepository` (Fake)와 `StubIdGenerator`를 주입받습니다.

#### 4-1. AddTodoUseCase

**TC-15: 유효한 제목으로 Todo 추가 성공**
- GIVEN: 빈 InMemoryRepository, `StubIdGenerator` (고정 UUID 반환)
- WHEN: `addTodo({ title: "우유 사기" })` 호출
- THEN: Repository에 Todo 1개 저장됨, 반환된 Todo의 `id`, `title`, `isCompleted === false` 확인

**TC-16: 빈 제목으로 Todo 추가 시 예외 — Repository 저장 없음**
- GIVEN: 빈 InMemoryRepository
- WHEN: `addTodo({ title: "" })` 호출
- THEN: `EmptyTitleError` 발생, Repository는 여전히 비어 있음

**TC-17: 100자 초과 제목으로 Todo 추가 시 예외**
- GIVEN: 빈 InMemoryRepository
- WHEN: `addTodo({ title: 101자 문자열 })` 호출
- THEN: `TitleTooLongError` 발생

---

#### 4-2. DeleteTodoUseCase

**TC-18: 존재하는 Todo 삭제 성공**
- GIVEN: Repository에 Todo 1개 존재
- WHEN: `deleteTodo({ id: 해당 id })` 호출
- THEN: Repository에서 해당 Todo 제거됨, 조회 시 `null`

**TC-19: 존재하지 않는 id로 삭제 시 예외**
- GIVEN: 빈 Repository
- WHEN: `deleteTodo({ id: "없는-uuid" })` 호출
- THEN: `TodoNotFoundError` 발생

---

#### 4-3. ToggleTodoUseCase (완료 체크)

**TC-20: 미완료 Todo 완료 처리 성공**
- GIVEN: Repository에 `isCompleted === false`인 Todo 존재
- WHEN: `toggleTodo({ id: 해당 id })` 호출
- THEN: Repository의 Todo `isCompleted === true`로 업데이트됨

**TC-21: 완료된 Todo 완료 취소 성공**
- GIVEN: Repository에 `isCompleted === true`인 Todo 존재
- WHEN: `toggleTodo({ id: 해당 id })` 호출
- THEN: Repository의 Todo `isCompleted === false`로 업데이트됨

**TC-22: 존재하지 않는 id로 toggle 시 예외**
- GIVEN: 빈 Repository
- WHEN: `toggleTodo({ id: "없는-uuid" })` 호출
- THEN: `TodoNotFoundError` 발생

---

### Phase 5: Integration 테스트

API 레이어 테스트. 실제 HTTP 요청/응답 검증. InMemory DB 사용.

**TC-23: POST /todos — 201 Created, body에 생성된 Todo 반환**
- GIVEN: 서버 기동, 빈 저장소
- WHEN: `POST /todos { "title": "우유 사기" }` 요청
- THEN: HTTP 201, body `{ id, title: "우유 사기", isCompleted: false }`

**TC-24: POST /todos — 빈 title 시 400 Bad Request**
- GIVEN: 서버 기동
- WHEN: `POST /todos { "title": "" }` 요청
- THEN: HTTP 400, body에 에러 메시지 포함

**TC-25: DELETE /todos/:id — 204 No Content**
- GIVEN: Todo 1개 존재
- WHEN: `DELETE /todos/:id` 요청
- THEN: HTTP 204, 해당 Todo 삭제됨

**TC-26: DELETE /todos/:id — 존재하지 않는 id 시 404 Not Found**
- GIVEN: 빈 저장소
- WHEN: `DELETE /todos/없는-uuid` 요청
- THEN: HTTP 404

**TC-27: PATCH /todos/:id/toggle — 200 OK, 완료 상태 토글됨**
- GIVEN: `isCompleted === false`인 Todo 존재
- WHEN: `PATCH /todos/:id/toggle` 요청
- THEN: HTTP 200, body `{ ..., isCompleted: true }`

**TC-28: PATCH /todos/:id/toggle — 존재하지 않는 id 시 404**
- GIVEN: 빈 저장소
- WHEN: `PATCH /todos/없는-uuid/toggle` 요청
- THEN: HTTP 404

---

### Phase 6: E2E 테스트

**TC-29: 전체 흐름 — Todo 추가 후 완료 처리**
- GIVEN: 빈 앱 실행
- WHEN: Todo 추가 → 완료 토글 순서로 작업
- THEN: 최종 상태 `isCompleted === true` 확인

**TC-30: 전체 흐름 — Todo 추가 후 삭제**
- GIVEN: 빈 앱 실행
- WHEN: Todo 추가 → 삭제 순서로 작업
- THEN: 저장소에서 해당 Todo 없음 확인

---

## 엣지 케이스 목록

| 케이스 | 설명 | 예상 동작 |
|---|---|---|
| 공백만 있는 제목 | `"   "` 입력 | trim() 후 빈 문자열로 처리 → EmptyTitleError |
| 정확히 100자 제목 | 경계값 — 최대 허용 | 생성 성공 |
| 101자 제목 | 경계값 초과 | TitleTooLongError |
| 이미 완료된 Todo 재완료 | complete() 중복 호출 | AlreadyCompletedError |
| 미완료 Todo uncomplete | uncomplete() 잘못 호출 | NotCompletedError |
| 없는 ID로 삭제 | 존재하지 않는 UUID | TodoNotFoundError |
| 없는 ID로 토글 | 존재하지 않는 UUID | TodoNotFoundError |
| 동시 완료 토글 | 동일 Todo에 동시 두 요청 (낙관적 락) | 두 번째 요청 충돌 처리 (선택적) |
| 특수문자 포함 제목 | `"<script>alert(1)</script>"` | 저장은 허용, 출력 시 이스케이프 |
| 숫자/이모지 제목 | `"123 🎉"` | 생성 성공 |

---

## 테스트 데이터 전략

| 타입 | 유효한 예시 | 유효하지 않은 예시 |
|---|---|---|
| TodoId (UUID) | `"550e8400-e29b-41d4-a716-446655440000"` | `""`, `"not-uuid"`, `"123"` |
| TodoTitle (1~100자) | `"우유 사기"`, `"a"`, `"a".repeat(100)` | `""`, `"   "`, `"a".repeat(101)` |
| isCompleted | `false`, `true` | `null`, `undefined`, `"true"` (문자열) |
| createdAt | `new Date("2026-02-22T00:00:00Z")` | `null`, 미래 날짜 (선택적 제한) |

### Fake 구현 예시 (InMemoryTodoRepository)

```typescript
class InMemoryTodoRepository implements TodoRepository {
  private store: Map<string, Todo> = new Map();

  async save(todo: Todo): Promise<void> {
    this.store.set(todo.id.value, todo);
  }

  async findById(id: TodoId): Promise<Todo | null> {
    return this.store.get(id.value) ?? null;
  }

  async delete(id: TodoId): Promise<void> {
    this.store.delete(id.value);
  }

  async findAll(): Promise<Todo[]> {
    return Array.from(this.store.values());
  }
}
```

### StubIdGenerator 예시

```typescript
class StubIdGenerator implements IdGenerator {
  constructor(private fixedId: string = "550e8400-e29b-41d4-a716-446655440000") {}

  generate(): TodoId {
    return new TodoId(this.fixedId);
  }
}
```
