# 도메인 분석: 간단한 Todo 앱

## 개요
Todo 앱은 사용자가 할 일 항목을 생성, 삭제, 완료 처리할 수 있는 단순한 태스크 관리 도메인이다. 핵심 도메인은 "Todo(할 일 항목)의 생명주기 관리"이며, 단일 Aggregate(Todo)로 충분히 표현된다.

## 액터 (Actors)
| 액터 | 역할 | 주요 유스케이스 |
|------|------|----------------|
| User (사용자) | 시스템의 유일한 사용자. Todo를 생성·관리한다. | Todo 추가, Todo 삭제, Todo 완료 체크/해제 |

## 유스케이스 목록

1. **Todo 추가 (AddTodo)**
   - 선행조건: 사용자가 제목(title)을 입력한다.
   - 주요 흐름: 사용자가 제목을 입력 → 시스템이 고유 ID를 부여하고 미완료 상태로 Todo를 생성 → TodoAdded 이벤트 발행
   - 예외 흐름: 제목이 빈 문자열이거나 공백만인 경우 생성 거부

2. **Todo 삭제 (RemoveTodo)**
   - 선행조건: 삭제할 Todo가 존재해야 한다.
   - 주요 흐름: 사용자가 특정 Todo 삭제 요청 → 시스템이 해당 Todo를 저장소에서 제거 → TodoRemoved 이벤트 발행
   - 예외 흐름: 존재하지 않는 ID로 삭제 요청 시 Not Found 오류

3. **Todo 완료 체크 (CompleteTodo)**
   - 선행조건: 완료 처리할 Todo가 존재하며 현재 미완료 상태이어야 한다.
   - 주요 흐름: 사용자가 특정 Todo를 완료로 표시 → 상태가 완료(completed)로 변경 → TodoCompleted 이벤트 발행
   - 예외 흐름: 이미 완료된 Todo에 완료 요청 시 멱등 처리(무시 또는 경고)

4. **Todo 완료 해제 (UncompleteTodo)**
   - 선행조건: 완료 해제할 Todo가 존재하며 현재 완료 상태이어야 한다.
   - 주요 흐름: 사용자가 특정 Todo를 미완료로 되돌림 → 상태가 미완료(pending)로 변경 → TodoUncompleted 이벤트 발행
   - 예외 흐름: 이미 미완료인 Todo에 해제 요청 시 멱등 처리

5. **Todo 목록 조회 (ListTodos)**
   - 선행조건: 없음
   - 주요 흐름: 사용자가 목록 조회 요청 → 시스템이 전체 Todo 목록 반환
   - 예외 흐름: 없음 (빈 목록 반환)

## 도메인 모델

### Aggregate: Todo
**Root Entity: Todo**
- ID: TodoId (UUID 또는 순차 정수, Value Object)
- 속성:
  - id: TodoId
  - title: TodoTitle (Value Object)
  - status: TodoStatus (Value Object, pending | completed)
  - createdAt: DateTime
- 불변식:
  - title은 1자 이상 255자 이하의 비공백 문자열이어야 한다.
  - status는 pending 또는 completed만 허용된다.
  - id는 생성 후 변경 불가.

**Value Objects**
- `TodoId(value: string | number)`: 비어있지 않아야 하며, 고유성은 저장소가 보장
- `TodoTitle(value: string)`: 1자 이상, 255자 이하, 앞뒤 공백 trim 후 검증
- `TodoStatus(value: 'pending' | 'completed')`: 열거형, 두 값만 허용

**Domain Events**
- `TodoAdded`: Todo가 생성될 때 발행 - 페이로드: `{ todoId, title, createdAt }`
- `TodoRemoved`: Todo가 삭제될 때 발행 - 페이로드: `{ todoId }`
- `TodoCompleted`: Todo가 완료 상태로 전환될 때 발행 - 페이로드: `{ todoId, completedAt }`
- `TodoUncompleted`: Todo가 미완료 상태로 되돌아갈 때 발행 - 페이로드: `{ todoId }`

**Repository Interface**
```
interface TodoRepository {
  findById(id: TodoId): Todo | null
  findAll(): Todo[]
  save(todo: Todo): void       // 추가 및 업데이트
  remove(id: TodoId): void
}
```

## 도메인 서비스

이 도메인에서는 단일 Aggregate(Todo)로 모든 로직이 충분히 표현되므로 별도의 Domain Service는 필요하지 않다.

- (선택적) **TodoFilter**: 완료/미완료 상태로 목록을 필터링하는 순수 함수 수준의 로직. 복잡성이 낮아 Application Service 또는 Repository Query로 처리 가능.

## 유비쿼터스 언어
| 용어 | 의미 |
|------|------|
| Todo | 사용자가 완료해야 할 단일 할 일 항목 |
| TodoId | Todo를 유일하게 식별하는 값 |
| TodoTitle | Todo의 제목. 비어있을 수 없음 |
| TodoStatus | Todo의 현재 상태. `pending`(미완료) 또는 `completed`(완료) |
| Add (추가) | 새로운 Todo를 시스템에 등록하는 행위 |
| Remove (삭제) | 기존 Todo를 시스템에서 영구 제거하는 행위 |
| Complete (완료 체크) | Todo 상태를 `completed`로 전환하는 행위 |
| Uncomplete (완료 해제) | Todo 상태를 `pending`으로 되돌리는 행위 |
| Pending | 아직 완료되지 않은 상태 |
| Completed | 사용자가 완료로 표시한 상태 |
