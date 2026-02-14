# ADR 0001: Core Tech Choices

- Context: PROJECT GTG를 서버 없이 로컬-only로 빠르게 출시해야 하며, 솔로 개발 환경에서 유지보수성과 버그 표면적을 최소화해야 한다.
- Decision: Flutter stable + Riverpod(no codegen) + go_router + JSON 파일 저장(path_provider 기반)으로 MVP를 구현한다.
- Alternatives considered: (1) Hive/Isar 로컬 DB (2) Provider 기반 상태관리 (3) 복잡한 Clean Architecture/DI 프레임워크.
- Consequences: 구현/디버깅이 단순해지고 테스트가 쉬워진다. 대규모 데이터/동기화 요구가 생기면 저장소 계층을 DB로 교체한다.
- Revisit trigger: 데이터가 커져 성능/쿼리 요구가 생기거나, 다중 디바이스 동기화가 필요해질 때.
