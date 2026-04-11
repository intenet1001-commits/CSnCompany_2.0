# 아키텍처 설계: Todo 앱 (추가/삭제/완료 체크)

## 개요

Clean Architecture 4레이어를 적용하여 Todo 앱의 핵심 비즈니스 로직(Domain, Application)을 프레임워크 및 인프라로부터 완전히 분리한다. 의존성은 항상 안쪽(더 추상적) 레이어를 향하며, Domain 레이어는 어떤 외부 의존성도 갖지 않는다.

3개 유스케이스(AddTodo, DeleteTodo, CompleteTodo)를 각각 독립 클래스로 분리하여 SRP를 지키고, Repository 인터페이스를 Domain에 두어 DIP를 실현한다.

---

## 디렉토리 구조

```
src/
├── domain/
│   ├── entities/
│   │   └── Todo.ts              # Todo 엔티티
│   ├── value_objects/
│   │   └── TodoId.ts            # TodoId VO
│   └── repositories/
│       └── ITodoRepository.ts   # Repository 인터페이스 (Port)
│
├── application/
│   ├── use_cases/
│   │   ├── AddTodoUseCase.ts
│   │   ├── DeleteTodoUseCase.ts
│   │   └── CompleteTodoUseCase.ts
│   └── dtos/
│       ├── AddTodoInput.ts
│       ├── AddTodoOutput.ts
│       ├── DeleteTodoInput.ts
│       ├── DeleteTodoOutput.ts
│       ├── CompleteTodoInput.ts
│       └── CompleteTodoOutput.ts
│
├── interface_adapters/
│   ├── controllers/
│   │   └── TodoController.ts    # HTTP/CLI 진입점
│   └── repositories/
│       └── InMemoryTodoRepository.ts  # Repository 구현체
│
└── infrastructure/
    └── di/
        └── Container.ts         # DI 바인딩
```

---

## Domain Layer

### Todo 엔티티

```typescript
class Todo {
  readonly id: TodoId;
  readonly title: string;
  readonly completed: boolean;
  readonly createdAt: Date;

  constructor(id: TodoId, title: string, completed = false, createdAt = new Date()) {
    if (!title || title.trim().length === 0) throw new Error("Title cannot be empty");
    this.id = id;
    this.title = title.trim();
    this.completed = completed;
    this.createdAt = createdAt;
  }

  complete(): Todo {
    return new Todo(this.id, this.title, true, this.createdAt);
  }
}
```

### TodoId Value Object

```typescript
class TodoId {
  readonly value: string;

  constructor(value: string) {
    if (!value || value.trim().length === 0) throw new Error("TodoId cannot be empty");
    this.value = value;
  }

  equals(other: TodoId): boolean {
    return this.value === other.value;
  }
}
```

### Repository Interface (Port)

```typescript
interface ITodoRepository {
  findById(id: TodoId): Promise<Todo | null>;
  findAll(): Promise<Todo[]>;
  save(todo: Todo): Promise<void>;
  delete(id: TodoId): Promise<void>;
}
```

---

## Application Layer

### 유스케이스 목록

| 유스케이스 | Input DTO | Output DTO | 사용 Repository | 발행 Event |
|---|---|---|---|---|
| AddTodoUseCase | AddTodoInput { title: string } | AddTodoOutput { id: string, title: string, completed: boolean } | save() | - |
| DeleteTodoUseCase | DeleteTodoInput { id: string } | DeleteTodoOutput { success: boolean } | findById(), delete() | - |
| CompleteTodoUseCase | CompleteTodoInput { id: string } | CompleteTodoOutput { id: string, completed: boolean } | findById(), save() | - |

### AddTodoUseCase 로직 흐름

```
1. Input 유효성 확인 (title 비어있으면 예외)
2. TodoId 생성 (UUID)
3. Todo 엔티티 생성
4. repository.save(todo)
5. AddTodoOutput 반환
```

### DeleteTodoUseCase 로직 흐름

```
1. TodoId VO 생성
2. repository.findById(id) → 없으면 NotFoundError
3. repository.delete(id)
4. DeleteTodoOutput { success: true } 반환
```

### CompleteTodoUseCase 로직 흐름

```
1. TodoId VO 생성
2. repository.findById(id) → 없으면 NotFoundError
3. todo.complete() → 새 Todo(불변 객체)
4. repository.save(completedTodo)
5. CompleteTodoOutput { id, completed: true } 반환
```

---

## Interface Adapters Layer

### Controller 엔드포인트 (REST 기준)

| Method | Path | 호출 Use Case |
|---|---|---|
| POST | /todos | AddTodoUseCase |
| DELETE | /todos/:id | DeleteTodoUseCase |
| PATCH | /todos/:id/complete | CompleteTodoUseCase |
| GET | /todos | (조회 전용, Use Case 생략 가능) |

- Controller는 HTTP Request → Input DTO 변환 후 Use Case 호출
- Use Case Output DTO → HTTP Response 변환 책임

### InMemoryTodoRepository

```typescript
class InMemoryTodoRepository implements ITodoRepository {
  private store: Map<string, Todo> = new Map();

  async findById(id: TodoId): Promise<Todo | null> {
    return this.store.get(id.value) ?? null;
  }

  async findAll(): Promise<Todo[]> {
    return Array.from(this.store.values());
  }

  async save(todo: Todo): Promise<void> {
    this.store.set(todo.id.value, todo);
  }

  async delete(id: TodoId): Promise<void> {
    this.store.delete(id.value);
  }
}
```

- 향후 `PersistentTodoRepository`(DB)로 교체 시 이 클래스만 교체하면 됨 (LSP)

---

## Infrastructure Layer

### DI 바인딩

```typescript
// Container.ts
const repository = new InMemoryTodoRepository();

const addTodo = new AddTodoUseCase(repository);
const deleteTodo = new DeleteTodoUseCase(repository);
const completeTodo = new CompleteTodoUseCase(repository);

const controller = new TodoController(addTodo, deleteTodo, completeTodo);
```

### 환경변수 목록

| 변수 | 기본값 | 설명 |
|---|---|---|
| PORT | 3000 | HTTP 서버 포트 |
| TODO_STORE | memory | 저장소 타입 (memory / db) |

---

## 아키텍처 결정사항 (ADR)

| 결정 | 선택 | 이유 |
|---|---|---|
| 저장소 초기 구현 | InMemoryRepository | YAGNI - 현재 요구사항에 DB 불필요, 인터페이스 교체 용이 |
| Todo 불변 객체 | 새 인스턴스 반환 | 부수 효과 제거, 테스트 용이성 증가 |
| 이벤트 발행 | 생략 | 현재 3개 유스케이스 간 연동 없음, YAGNI |
| UUID 생성 위치 | Application Use Case | Domain은 생성 로직 불필요, Use Case가 ID 생성 책임 |
| DTO 분리 | Input/Output 별도 클래스 | ISP - Use Case마다 필요한 데이터만 노출 |

---

## SOLID 체크리스트

| 원칙 | 준수 여부 | 근거 |
|---|---|---|
| SRP | O | 각 Use Case 클래스는 단일 유스케이스만 담당. Controller는 HTTP 변환만 담당 |
| OCP | O | 새 기능(예: ListTodos) 추가 시 새 Use Case 클래스 추가만 필요. 기존 코드 수정 없음 |
| LSP | O | InMemoryTodoRepository는 ITodoRepository 완전 대체 가능. 테스트/운영 환경 교체 가능 |
| ISP | O | 각 Use Case에 별도 Input/Output DTO. Repository 인터페이스는 최소 메서드만 포함 |
| DIP | O | Use Case는 ITodoRepository(추상)에만 의존. 구현체(InMemory)는 Infrastructure에 위치 |

---

## 의존성 그래프

```
Infrastructure → Interface Adapters → Application → Domain
                                           ↑
                                    (인터페이스만)
                                      Domain에 정의된
                                    ITodoRepository
```

- Domain: 외부 의존 없음
- Application: Domain만 import
- Interface Adapters: Application + Domain import
- Infrastructure: 모든 레이어 import (DI 조립)
