# 구현 체크리스트: Todo 앱 (추가/삭제/완료 체크)

> 언어: TypeScript | 아키텍처: Clean Architecture (4레이어) | 전략: Inside-Out TDD

---

## 환경 설정

- [ ] Node.js + TypeScript 프로젝트 초기화
  ```bash
  mkdir todo-app && cd todo-app
  npm init -y
  npm install --save-dev typescript ts-node @types/node
  npm install --save-dev jest ts-jest @types/jest
  npm install uuid @types/uuid
  npx tsc --init
  ```
- [ ] Jest 설정 (`jest.config.ts`)
  ```bash
  cat > jest.config.ts << 'EOF'
  export default {
    preset: 'ts-jest',
    testEnvironment: 'node',
    collectCoverageFrom: ['src/**/*.ts'],
    coverageThreshold: { global: { lines: 90 } },
  };
  EOF
  ```
- [ ] `tsconfig.json` 설정 (`strict: true`, `outDir: dist`)
- [ ] 폴더 구조 생성
  ```bash
  mkdir -p src/domain/{entities,value_objects,repositories}
  mkdir -p src/application/{use_cases,dtos}
  mkdir -p src/interface_adapters/{controllers,repositories}
  mkdir -p src/infrastructure/di
  mkdir -p tests/{unit/{domain,application},integration}
  ```
- [ ] `package.json` scripts 설정
  ```json
  "test": "jest",
  "test:watch": "jest --watch",
  "test:coverage": "jest --coverage"
  ```

---

## Phase 1: Value Objects

### TodoId

- [ ] 🔴 RED: `TodoId` — 빈 문자열로 생성 시 에러 테스트 작성 (실패 확인)
- [ ] 🔴 RED: `TodoId` — 정상 값으로 생성 후 `.value` 반환 테스트 작성
- [ ] 🔴 RED: `TodoId` — `.equals()` 동일값/다른값 비교 테스트 작성
- [ ] 🟢 GREEN: `src/domain/value_objects/TodoId.ts` 최소 구현
  ```typescript
  export class TodoId {
    readonly value: string;
    constructor(value: string) {
      if (!value || value.trim().length === 0) throw new Error("TodoId cannot be empty");
      this.value = value;
    }
    equals(other: TodoId): boolean { return this.value === other.value; }
  }
  ```
- [ ] 🔵 RFCT: trim 처리 일관성 확인, 에러 메시지 상수화 검토

### TodoTitle

- [ ] 🔴 RED: `TodoTitle` — 빈 문자열/공백만 입력 시 에러 테스트
- [ ] 🔴 RED: `TodoTitle` — 255자 초과 시 에러 테스트
- [ ] 🔴 RED: `TodoTitle` — 앞뒤 공백 trim 후 저장 테스트
- [ ] 🔴 RED: `TodoTitle` — 정상 값 `.value` 반환 테스트
- [ ] 🟢 GREEN: `src/domain/value_objects/TodoTitle.ts` 최소 구현
- [ ] 🔵 RFCT: 유효성 검사 로직을 별도 private 메서드로 추출

### TodoStatus

- [ ] 🔴 RED: `TodoStatus` — `pending` / `completed` 외 값 시 에러 테스트
- [ ] 🔴 RED: `TodoStatus` — `.isPending()`, `.isCompleted()` 반환값 테스트
- [ ] 🟢 GREEN: `src/domain/value_objects/TodoStatus.ts` 최소 구현 (enum 또는 union type 활용)
- [ ] 🔵 RFCT: `TodoStatus.PENDING`, `TodoStatus.COMPLETED` 정적 팩토리 메서드 검토

---

## Phase 2: Domain Entities

### Todo Entity

- [ ] 🔴 RED: `Todo` — 정상 생성 후 id/title/completed/createdAt 속성 테스트
- [ ] 🔴 RED: `Todo` — 빈 title로 생성 시 에러 테스트
- [ ] 🔴 RED: `Todo` — `complete()` 호출 시 새 인스턴스 반환, `completed: true` 테스트
- [ ] 🔴 RED: `Todo` — `complete()` 호출 시 원본 인스턴스 불변 확인 테스트
- [ ] 🔴 RED: `Todo` — `uncomplete()` 호출 시 `completed: false` 새 인스턴스 반환 테스트
- [ ] 🔴 RED: `Todo` — 이미 완료된 Todo에 `complete()` 호출 시 멱등 처리(동일 상태 반환) 테스트
- [ ] 🟢 GREEN: `src/domain/entities/Todo.ts` 최소 구현
  ```typescript
  export class Todo {
    readonly id: TodoId;
    readonly title: string;
    readonly completed: boolean;
    readonly createdAt: Date;
    constructor(id: TodoId, title: string, completed = false, createdAt = new Date()) { ... }
    complete(): Todo { return new Todo(this.id, this.title, true, this.createdAt); }
    uncomplete(): Todo { return new Todo(this.id, this.title, false, this.createdAt); }
  }
  ```
- [ ] 🔵 RFCT: `TodoTitle` VO를 title 속성에 적용, 불변 패턴 일관성 검토

---

## Phase 3: Repository Interface & InMemory Fake

### ITodoRepository Interface

- [ ] `src/domain/repositories/ITodoRepository.ts` 인터페이스 정의 (테스트 없음 — 순수 타입)
  ```typescript
  export interface ITodoRepository {
    findById(id: TodoId): Promise<Todo | null>;
    findAll(): Promise<Todo[]>;
    save(todo: Todo): Promise<void>;
    delete(id: TodoId): Promise<void>;
  }
  ```

### InMemoryTodoRepository

- [ ] 🔴 RED: `save()` 후 `findById()`로 동일 Todo 조회 테스트
- [ ] 🔴 RED: `findAll()` — 저장된 모든 Todo 반환 테스트
- [ ] 🔴 RED: `delete()` 후 `findById()` null 반환 테스트
- [ ] 🔴 RED: 존재하지 않는 ID `findById()` → null 반환 테스트
- [ ] 🔴 RED: `save()` 동일 id로 두 번 저장 시 마지막 값으로 덮어쓰기 테스트 (update 시나리오)
- [ ] 🟢 GREEN: `src/interface_adapters/repositories/InMemoryTodoRepository.ts` 구현
- [ ] 🔵 RFCT: `Map<string, Todo>` store 타입 명시, async/await 일관성 확인

---

## Phase 4: Use Cases

### AddTodoUseCase

- [ ] 🔴 RED: 정상 title 입력 시 Todo 생성 및 Output DTO 반환 테스트 (Fake Repo 사용)
- [ ] 🔴 RED: 빈 title 입력 시 에러 발생 테스트
- [ ] 🔴 RED: 생성된 Todo가 Repository에 저장됨을 확인하는 테스트
- [ ] 🔴 RED: Output에 `id`, `title`, `completed: false` 포함 테스트
- [ ] 🟢 GREEN: `src/application/use_cases/AddTodoUseCase.ts` 최소 구현
  ```typescript
  async execute(input: AddTodoInput): Promise<AddTodoOutput> {
    const id = new TodoId(uuidv4());
    const todo = new Todo(id, input.title);
    await this.repo.save(todo);
    return { id: todo.id.value, title: todo.title, completed: todo.completed };
  }
  ```
- [ ] 🔵 RFCT: UUID 생성을 `IdGenerator` 인터페이스로 추출하여 테스트 주입 가능하게 개선

### DeleteTodoUseCase

- [ ] 🔴 RED: 존재하는 id 삭제 시 `{ success: true }` 반환 테스트
- [ ] 🔴 RED: 삭제 후 Repository에서 실제로 제거됨 확인 테스트
- [ ] 🔴 RED: 존재하지 않는 id 삭제 시 `NotFoundError` 발생 테스트
- [ ] 🟢 GREEN: `src/application/use_cases/DeleteTodoUseCase.ts` 최소 구현
- [ ] 🔵 RFCT: `NotFoundError` 커스텀 에러 클래스를 `src/domain/errors/` 에 분리

### CompleteTodoUseCase

- [ ] 🔴 RED: 미완료 Todo 완료 처리 시 `{ id, completed: true }` 반환 테스트
- [ ] 🔴 RED: 완료 처리 후 Repository에 완료 상태로 저장됨 확인 테스트
- [ ] 🔴 RED: 존재하지 않는 id 완료 요청 시 `NotFoundError` 발생 테스트
- [ ] 🔴 RED: 이미 완료된 Todo 완료 요청 시 멱등 처리(에러 없이 동일 상태 반환) 테스트
- [ ] 🟢 GREEN: `src/application/use_cases/CompleteTodoUseCase.ts` 최소 구현
- [ ] 🔵 RFCT: 멱등 처리 전략 명확히 주석 또는 도메인 메서드로 표현

### ListTodosUseCase (조회)

- [ ] 🔴 RED: Todo가 없을 때 빈 배열 반환 테스트
- [ ] 🔴 RED: Todo가 있을 때 전체 목록 반환 테스트
- [ ] 🟢 GREEN: `src/application/use_cases/ListTodosUseCase.ts` 최소 구현
- [ ] 🔵 RFCT: 필터(completed/pending) 기능 추가 여부 검토 (현재는 YAGNI)

---

## Phase 5: Repository 실제 구현체 (선택 — DB 연동)

> 현재 설계는 InMemory가 기본. DB 연동이 필요한 경우만 진행.

- [ ] 🔴 RED: `PersistentTodoRepository` — `save()` 후 DB에서 `findById()` 조회 Integration 테스트
- [ ] 🔴 RED: `PersistentTodoRepository` — `delete()` 후 DB에서 조회 null Integration 테스트
- [ ] 🟢 GREEN: `src/interface_adapters/repositories/PersistentTodoRepository.ts` 구현 (SQLite/PostgreSQL)
- [ ] 🔵 RFCT: Connection Pool, 트랜잭션 처리 검토
- [ ] `TODO_STORE=db` 환경변수로 DI 컨테이너에서 구현체 교체 설정

---

## Phase 6: Controllers & API

### TodoController

- [ ] 🔴 RED: `POST /todos` — 정상 body로 201 + 생성된 Todo JSON 반환 Integration 테스트
- [ ] 🔴 RED: `POST /todos` — 빈 title body로 400 에러 응답 테스트
- [ ] 🔴 RED: `DELETE /todos/:id` — 존재하는 id로 200 + `{ success: true }` 테스트
- [ ] 🔴 RED: `DELETE /todos/:id` — 존재하지 않는 id로 404 에러 응답 테스트
- [ ] 🔴 RED: `PATCH /todos/:id/complete` — 정상 완료 처리 200 응답 테스트
- [ ] 🔴 RED: `PATCH /todos/:id/complete` — 존재하지 않는 id로 404 에러 응답 테스트
- [ ] 🔴 RED: `GET /todos` — 전체 목록 200 응답 테스트
- [ ] 🟢 GREEN: `src/interface_adapters/controllers/TodoController.ts` 구현 (Express/Fastify)
- [ ] 🔵 RFCT: 에러 핸들링 미들웨어 분리, `NotFoundError` → 404 매핑 일관성

---

## Phase 7: DI & 통합

### DI Container 설정

- [ ] `src/infrastructure/di/Container.ts` 작성
  ```typescript
  const repository = new InMemoryTodoRepository();
  const addTodo = new AddTodoUseCase(repository);
  const deleteTodo = new DeleteTodoUseCase(repository);
  const completeTodo = new CompleteTodoUseCase(repository);
  const listTodos = new ListTodosUseCase(repository);
  export const controller = new TodoController(addTodo, deleteTodo, completeTodo, listTodos);
  ```
- [ ] `PORT`, `TODO_STORE` 환경변수 설정 문서화 (`README.md` 또는 `.env.example`)

### E2E 테스트

- [ ] 🔴 RED: 서버 기동 후 Todo 추가 → 목록 조회 → 완료 → 삭제 전체 흐름 E2E 테스트
- [ ] 🟢 GREEN: E2E 테스트 통과 확인
- [ ] 🔵 RFCT: 테스트 격리 (각 테스트 전 store 초기화)

---

## 최종 Definition of Done

- [ ] 모든 Unit 테스트 통과 (`npm test`)
- [ ] 모든 Integration/E2E 테스트 통과
- [ ] 핵심 비즈니스 로직 커버리지 ≥ 90% (`npm run test:coverage`)
- [ ] Domain 레이어에 외부 의존성(npm 패키지) 없음 확인
- [ ] `ITodoRepository` 인터페이스가 Domain 레이어에 위치함 확인 (DIP 준수)
- [ ] 각 Use Case가 단일 책임만 가짐 확인 (SRP 준수)
- [ ] `InMemoryTodoRepository`가 `ITodoRepository`를 완전히 대체 가능함 확인 (LSP 준수)
- [ ] `PORT`, `TODO_STORE` 환경변수 문서화 완료
- [ ] `NotFoundError` 커스텀 에러 클래스 정의 및 일관된 HTTP 매핑

---

## 빠른 시작 명령어

```bash
# 전체 테스트 실행
npm test

# 감시 모드 (TDD 사이클 중 사용)
npm run test:watch

# 커버리지 리포트 생성
npm run test:coverage

# 특정 파일만 테스트
npx jest TodoId
npx jest AddTodoUseCase

# TypeScript 빌드 확인
npx tsc --noEmit
```

---

## Red-Green-Refactor 사이클 요약

| Phase | 컴포넌트 | RED | GREEN | RFCT |
|-------|---------|-----|-------|------|
| 1 | Value Objects (TodoId, TodoTitle, TodoStatus) | 9개 | 3개 | 3개 |
| 2 | Todo Entity | 6개 | 1개 | 1개 |
| 3 | InMemoryTodoRepository | 5개 | 1개 | 1개 |
| 4 | Use Cases (Add/Delete/Complete/List) | 14개 | 4개 | 4개 |
| 5 | PersistentRepository (선택) | 2개 | 1개 | 1개 |
| 6 | Controllers & API | 7개 | 1개 | 1개 |
| 7 | E2E | 1개 | 1개 | 1개 |
| **합계** | | **44개 RED** | **12개 GREEN** | **12개 RFCT** |

> **총 체크박스: 약 90개 | Phase: 7개 | Red-Green-Refactor 사이클: 27개**
