# Projeto Flutter — CLAUDE.md

App Flutter com arquitetura **MVVM + Command pattern**. Este arquivo é contrato: respeite antes de qualquer "criatividade".

---

## Stack

- **Flutter** 3.35+ · **Dart** 3.9+
- **State:** `ChangeNotifier` (vanilla)
- **DI:** `provider`
- **Navegação:** `go_router`
- **HTTP:** `dio`
- **Serialização:** `json_serializable`
- **Lints:** `flutter_lints`
- **Mocks:** `mockito` + `build_runner`
- **Plataformas:** Android, iOS, Web

---

## Fluxo de dependências (direção única)

```
View → ViewModel → Command0/Command1 → Action privada → Repository → dio
```

- View nunca conhece `Repository` ou `dio`.
- ViewModel nunca importa de `lib/data/` (só interfaces de `lib/domain/`).
- Erro nunca atravessa camada via `throw` — Repository captura e retorna `Result.error(AppException)`.

---

## Camadas

- `lib/config/` — env, constantes, feature flags
- `lib/features/<feat>/` — `<feat>_providers.dart` + `view/` + `view_model/` + `widgets/` (sem pasta `commands/`)
- `lib/domain/` — Models, entidades, interfaces de Repository
- `lib/data/` — Implementações de Repository, services, DTOs, mapeadores
- `lib/core/` — infra compartilhada:
  - `result/`, `command/` — tipos base (**leia os arquivos antes de usar**)
  - `exceptions/` — `AppException` + HTTP/rede/desconhecidas tipadas
  - `errors/` — mapeador `DioException` → `AppException`
  - `network/` — factory do `Dio`, interceptadores
  - `routing/` — `app_router.dart`, `routes.dart`
  - `theme/`

---

## Tipos base (em `lib/core/`)

- **`Result<T>`** — sealed: `Ok<T>` (value) ou `Failure<T>` (error: Exception). Factories `Result.ok(v)` / `Result.error(e)`.
- **`Command0<T>` / `Command1<T, A>`** — `ChangeNotifier`, não re-entrantes. Expõem `running`, `error`, `completed`, `result`, `clearResult()`. `execute()` retorna `Future<void>`.
- **`AppException`** — base de toda exceção. Nunca `Exception` genérica.

**Nunca subclassear `Command`.** Instanciar `Command0`/`Command1` passando uma action privada.

---

## ViewModel

- Extende `ChangeNotifier`. Dependências via construtor nomeado (`required`).
- **Possui** Commands como `late final`, instanciados no construtor com action privada.
- Action privada retorna `Future<Result<T>>` — nunca `throw`.
- **`dispose()` obrigatório** fazendo `dispose` de todas as Commands.
- Não duplicar `running`/`error` quando a Command já expõe.

---

## View

- `ListenableBuilder(listenable: vm.command, ...)` para reagir a uma Command.
- `Consumer<ViewModel>` para múltiplos campos do ViewModel.
- `context.read` em callbacks; `context.watch` em `build` (raro).
- **Nunca `setState`** — estado vive em ViewModel/Command.

---

## Repository

- Retorna `Future<Result<T>>`. Nunca throw para fora.
- Captura `DioException` e mapeia para `AppException` via `lib/core/errors/`.
- Converte DTO → Model antes de retornar `Ok`.
- Interface em `domain/`, implementação em `data/`.

---

## DI (provider) — escopos

Use o escopo **mais estreito possível**:

| Escopo | Uso | Onde |
|---|---|---|
| **Rota** | ViewModel de 1 tela só | `ChangeNotifierProvider` dentro do `GoRoute.builder` |
| **Feature** | ViewModel compartilhado entre rotas da feature | `<feature>Providers()` em `<feature>_providers.dart` |
| **Global** | Repository, Service, Dio, AppConfig | `main.dart` (globais + spread dos providers de feature) |

- Cada feature exporta `List<SingleChildWidget> <feature>Providers()`.
- `main.dart` faz `...authProviders()`, `...homeProviders()`, etc.
- **`ChangeNotifierProvider` para ChangeNotifier** — `Provider` puro não dispara listeners nem chama `dispose`.
- `Repository` nunca instanciado em Widget/ViewModel.

---

## Navegação (go_router)

- `createRouter(...)` em `lib/core/routing/app_router.dart` recebe dependências por parâmetro (sem singleton).
- `refreshListenable` + `redirect` central para guards de auth.
- `AppRoutes` em `lib/core/routing/routes.dart` — **toda rota passa por constante**.
- `context.go(AppRoutes.xxx)` / `context.push(AppRoutes.xxx)`. Nunca `Navigator.push(MaterialPageRoute(...))`.
- `pathParameters` para valores simples; `extra` para objetos.

---

## Testes (pirâmide completa)

Toda feature nova: **unit** (Repository + ViewModel), **widget** (Screen), **integration** (fluxo crítico).

- Mocks com `mockito` + `build_runner`.
- Nunca mockar `Command0`/`Command1` ou `ViewModel` — instância real.
- Testar estados observáveis após `execute`, não detalhes internos.

---

## Convenções

- `snake_case` arquivos · `PascalCase` tipos · `camelCase` membros.
- `const` sempre que possível. `final` por padrão.
- `package:logging`, nunca `print`.
- Sem `dynamic` exceto fronteira JSON.
- Dartdoc em classes públicas de `domain/` e `core/`.
- Sealed class para tipos-soma.
- **GitHub Flow:** branch curta a partir de `main` atualizada, merge via PR. `main` sempre deployable.
- **Conventional Commits** em português, < 72 chars. Branches: `feat/<slug>`, `fix/<slug>`, `chore/<slug>`.

---

## Comandos

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format lib test
flutter analyze
flutter test
flutter test integration_test/
```

---

## Antes de responder

1. **Ao iniciar feature/fix/chore novo:** atualizar `main`, criar branch (`feat/<slug>` / `fix/<slug>` / `chore/<slug>`), só então editar arquivos.
2. Leia os arquivos — use `Glob`/`Read`, não assuma estrutura.
3. Verifique se já existe algo equivalente (ViewModel, Repository, Exception). Reuso > duplicação.
4. Pergunte antes de adicionar dependência em `pubspec.yaml`.
5. Mudança em > 3 arquivos: proponha plano antes de codificar.

---

## NÃO fazer

- ❌ Subclassear `Command` — use `Command0`/`Command1`.
- ❌ Esquecer `dispose()` das Commands no ViewModel.
- ❌ `setState` em Widget.
- ❌ Lógica de negócio em Widget.
- ❌ View acessando `Repository`/`dio`.
- ❌ `throw` atravessando camadas.
- ❌ `Exception` genérica — use `AppException`.
- ❌ Instanciar `Repository` em Widget/ViewModel.
- ❌ Provider de feature registrado direto em `main.dart` — use `<feature>Providers()`.
- ❌ `Provider<X>` para ChangeNotifier — use `ChangeNotifierProvider<X>`.
- ❌ `Navigator.push(MaterialPageRoute(...))`.
- ❌ String literal de rota — use `AppRoutes.xxx`.
- ❌ Duplicar `running`/`error` no ViewModel.
- ❌ Desabilitar botão manualmente — `Command` já impede re-entrada.
- ❌ Commit sem prefixo Conventional.
- ❌ Commit direto em `main` — sempre via PR de branch.
- ❌ PR sem teste.
- ❌ Adicionar package sem me avisar.
