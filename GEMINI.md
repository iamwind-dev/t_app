# AGENTS.md

## Current Project Context (Authoritative)
This repository is the current `Together` Flutter app, a Threads-like social feed prototype. It is not an HTTPBot/request-builder app in the current codebase. Any older HTTPBot/request-builder notes in this file are historical context only and must not drive new changes unless the user explicitly asks to pivot the product back to HTTP tooling.

Current product surface:
- Home feed with thread previews, nested reply navigation, scroll-driven header/bottom-bar behavior, and theme selection.
- Search tab with static suggested accounts.
- Activity tab with local filter chips, follow toggles, and thread recommendation navigation.
- Profile tab with profile header, tabbed thread areas, and profile thread list.
- Create-thread bottom sheet with local draft items and composer controls.
- Thread detail and reply branch screens for nested conversations.
- Light/dark/system theme persistence through `SharedPreferences`.

Current implementation shape:
- Entry point: `lib/main.dart`.
- App widget: `TogetherApp`, currently using `MaterialApp` with `home: HomeScreen`.
- State management: `flutter_bloc`; `ThemeModeCubit` and `HomeCubit` are registered manually in `MultiBlocProvider`.
- Navigation: currently direct `Navigator`/`MaterialPageRoute` plus modal bottom sheets. `go_router` is a dependency but is not wired as the active router.
- Data: mostly static/mock data under feature `data/` folders. The only current persistence is theme mode in `lib/core/theme/theme_mode_storage.dart`.
- Core shared code: theme, system UI helpers, widget keys, and `HomeBottomTabBar`.
- Generated code: `lib/generated/**` is produced by Flutter intl/flutter_gen tooling and should not be hand-edited.
- Assets: image/icon/font/l10n assets are registered in `pubspec.yaml`.

Current feature folders:
- `lib/features/home`
- `lib/features/search`
- `lib/features/activity`
- `lib/features/profile`
- `lib/features/post_detail`
- `lib/features/create_thread`

## Conflict Avoidance
- Keep changes scoped to the requested task and the feature being edited.
- Before editing an existing file, read its latest content in the working tree.
- Do not overwrite, delete, or reformat unrelated existing code.
- Do not touch generated desktop plugin registrant files unless the task specifically targets plugin/platform generation. The current working tree may already contain unrelated generated changes under `linux/`, `macos/`, and `windows/`.
- `AGENTS.md` is ignored by git in this repo; still treat it as shared workspace context and avoid broad rewrites that would erase the skill index.
- Preserve `<!-- SKILLS_INDEX_START -->` and everything after it unless the task is explicitly about skill index maintenance.
- Prefer incremental migration over big-bang rewrites. If a future task introduces Clean Architecture, repositories, DI, or routing, add it around the touched feature without forcing unrelated legacy code to move in the same patch.

## Current Architecture Guidance
- Follow the existing feature-first folder layout.
- Keep presentation widgets/screens under each feature's `presentation/` folder.
- Keep mock/static models and mock repositories under feature `data/` folders until a real domain/data migration is requested.
- When replacing mock data with real data, introduce the domain contract, data source, repository implementation, error mapping, and Cubit/Bloc integration for that feature in one coherent slice.
- Do not call Dio, SharedPreferences, or other low-level services directly from widgets when adding real data flows.
- Do not instantiate repositories or network clients ad hoc in widgets; introduce DI only when the task needs it and keep the migration localized.
- Existing models such as `ThreadItemModel`, `User`, `ActivityItemModel`, and `ThreadDraft` are currently used directly by UI. Do not rename or move them casually because many widgets depend on them.

## UI And State Guidance
- Match the current Threads-like mobile UI language: clean feed rows, theme-aware colors, asset-based icons, compact spacing, and bottom tab navigation.
- Use theme/color-scheme helpers or local token files such as `SearchTokens` where they exist.
- Avoid adding new hardcoded product mock data in production paths unless the task is explicitly prototyping UI.
- Keep local UI-only state local when it is temporary interaction state. Promote it to Cubit/Bloc when it becomes shared, persisted, async, or business-relevant.
- Prefer small extracted widgets when a screen grows, but do not split files only for churn.

## Tooling And Verification
- Follow `analysis_options.yaml` and `flutter_lints`.
- Use `fvm flutter ...` when following the README setup; otherwise use the available local Flutter command if FVM is not configured.
- Typical verification after Dart/Flutter edits: `flutter analyze` and targeted `flutter test` when tests exist.
- There is no `test/` directory in the current working tree at the time this file was updated, despite older README text mentioning tests. Add tests only when the task and existing setup justify them.
- Run code generation only when changing generated inputs such as ARB files, assets, `flutter_gen` config, or serializable/freezed models.

## Legacy HTTPBot Draft (Obsolete Unless Explicitly Requested)
The following pre-existing section is retained for continuity, but it does not describe the current app. Treat it as superseded by the authoritative context above.

## Project Overview
This repository contains a Flutter application inspired by HTTPBot: a mobile app for creating, sending, testing, saving, and inspecting HTTP requests.

Primary goals:
- Build a clean, maintainable Flutter codebase
- Use Clean Architecture
- Use BLoC/Cubit for state management
- Keep networking, persistence, and UI concerns separated
- Make generated code production-oriented, not demo-style

---

## Tech Stack
- Flutter
- Dart
- flutter_bloc / bloc
- go_router
- dio
- get_it
- injectable (optional if DI generation is used)
- equatable
- json_serializable / freezed (only if already adopted in repo)

---

## Architecture Rules
Follow **Clean Architecture** strictly.

### Layers
#### 1. Presentation
Contains:
- pages
- widgets
- bloc / cubit / state
- controllers strictly related to UI behavior

Presentation layer:
- must not call Dio directly
- must not contain raw JSON parsing
- must not access local storage directly
- depends only on domain layer abstractions

#### 2. Domain
Contains:
- entities
- repository contracts
- use cases

Domain layer:
- must be pure Dart
- must not depend on Flutter UI packages
- must not depend on Dio or concrete data sources
- defines business rules

#### 3. Data
Contains:
- models
- repository implementations
- remote data sources
- local data sources
- DTO mapping

Data layer:
- implements domain contracts
- handles serialization/deserialization
- handles API response mapping
- handles persistence details

#### 4. Core
Contains shared app-wide utilities:
- constants
- themes
- errors/failures
- network client setup
- interceptors
- environment config
- base result types
- helpers

---

## Expected Folder Structure
Use this structure unless the repo already has a different established pattern.

```text
lib/
  core/
    constants/
    errors/
    network/
    utils/
    services/
    theme/
    router/

  features/
    request_builder/
      data/
        datasources/
        models/
        repositories/
      domain/
        entities/
        repositories/
        usecases/
      presentation/
        blocs/
        cubits/
        pages/
        widgets/

    request_history/
      data/
      domain/
      presentation/

    collections/
      data/
      domain/
      presentation/

    environments/
      data/
      domain/
      presentation/

  injection/
  main.dart
```

If a feature becomes large, keep all code for that feature inside its own folder.

## Feature Boundaries

Every feature should be self-contained.

Examples of features:

- request_builder
- response_viewer
- request_history
- collections
- environments
- authentication
- settings

Do not mix unrelated logic across features unless it belongs in core/.

## State Management Rules

Use BLoC/Cubit.

### When to use Cubit

Use Cubit for:

- simple UI states
- toggles
- filters
- tab index
- lightweight local orchestration

### When to use Bloc

Use Bloc for:

- form submission workflows
- async request pipelines
- complex state transitions
- multi-event flows
- retry / cancel / refresh behavior

### State rules

- states must be immutable
- use Equatable where appropriate
- avoid giant state classes
- split state by feature responsibility
- prefer explicit states over boolean explosion

Bad:

one state with many flags like isLoading, isSuccess, isError, isEmpty, isSubmitted

Better:

sealed-style or clearly separated state classes, or a compact immutable state with well-defined status enum

## Networking Rules

Use dio for HTTP.

All HTTP logic must:
- live in data layer
- be wrapped by data sources or repositories
- return mapped models/entities, not raw Response

Do not:
- call Dio inside widgets
- hardcode URLs inside presentation layer
- scatter headers/auth logic throughout the app

Prefer:
- one configured Dio instance
- interceptors for logging, headers, auth token injection
- centralized timeout configuration
- typed request/response models where reasonable

## Error handling

Convert low-level exceptions into app-level failures.

Examples:

- timeout -> NetworkFailure
- 401 -> UnauthorizedFailure
- 404 -> NotFoundFailure
- invalid response -> ParsingFailure

Never leak raw Dio exceptions into UI.

## Request Builder Requirements

This project is HTTPBot-like, so generated code should preserve these product expectations:

### Request composing

Support as separate concepts:

- method
- base URL / full URL
- path
- query params
- headers
- body
- auth
- timeout

### Body modes

Design body handling so it can support:

- none
- raw text
- JSON
- form-data
- x-www-form-urlencoded

### Auth modes

Design auth handling so it can support:

- none
- bearer token
- basic auth
- api key

### Response handling

Response-related code should make room for:

- status code
- headers
- duration
- response body
- pretty JSON display
- error state
- request metadata

Do not collapse everything into one unstructured map.

## Data Model Rules

Differentiate clearly:

- Entity: domain object used by business logic
- Model/DTO: data-layer object for serialization
- Request payload object: object used to construct API calls

### Mapping

- map models to entities in data layer
- do not use DTOs directly in UI
- keep fromJson / toJson out of domain entities unless repo already uses that pattern consistently

## Persistence Rules

If the app stores history, collections, or environments:

- persistence code belongs in data layer
- storage mechanism may be shared_preferences, hive, isar, sqlite, etc.
- repository abstracts storage from domain/presentation

Stored objects should be versionable and easy to migrate.

## Routing Rules

Use go_router if routing is already based on it.

Routing should be:

- centralized
- typed as much as practical
- feature-aware

Avoid pushing raw navigation logic deep into widgets repeatedly.

Pages should receive only the data they need.

## Dependency Injection Rules

Use get_it consistently.

### Rules

- register repositories behind interfaces
- register use cases explicitly
- register data sources separately
- do not instantiate repositories inside widgets
- do not instantiate Dio ad hoc in features

If using injectable, keep annotations consistent and do not mix manual and generated DI randomly.

## UI Rules

The UI should be clean and developer-tool styled.

Preferred traits:

- clear spacing
- readable hierarchy
- minimal clutter
- consistent input components
- reusable section widgets
- reusable request/response panels

Avoid:

- deeply nested giant build methods
- repeated widget trees across pages
- business logic inside widget builders

Prefer:

- extracting reusable widgets
- feature-specific widgets under each feature
- using const constructors wherever possible
- keeping page widgets focused on composition

## Code Style

Follow analysis_options.yaml
Prefer small focused files
Prefer descriptive names over short names
Keep functions short
Keep widgets small
Avoid unnecessary comments
Add comments only when intent is not obvious
For every new or modified function, add a brief comment or docstring immediately above it explaining the function's purpose and any non-obvious reasoning
Do not introduce dead code
Do not leave TODOs unless explicitly requested

## Naming

### Files

Use snake_case:

request_history_page.dart
send_request_usecase.dart
request_collection_repository_impl.dart

### Classes

Use PascalCase:

RequestHistoryPage
SendRequestUseCase

### Variables and methods

Use camelCase:

buildRequestPayload
loadSavedCollections

## Testing Expectations

When adding or changing code, prefer tests where the repo already supports them.

### Priorities

- unit tests for use cases
- bloc/cubit tests
- repository tests
- widget tests for important flows

### Test rules

- test behavior, not implementation details
- mock repository contracts, not low-level libraries unless needed
- cover success and failure paths

## What Codex Should Do

When making changes:

- inspect nearby files for local patterns
- follow existing architectural conventions
- preserve feature boundaries
- avoid broad refactors unless necessary
- update only what is needed for the task
- ensure imports stay clean
- ensure code compiles logically

If adding a new feature:

- create feature folder in features/
- define domain entities/contracts first
- implement data sources and repository implementation
- add use cases
- add bloc/cubit
- add page/widgets
- wire DI
- wire routing

## What Codex Must Not Do

Do not put API calls directly in UI
Do not bypass repository abstractions
Do not mix unrelated features in one folder
Do not add massive files with multiple responsibilities
Do not introduce new state management libraries
Do not replace architecture without explicit instruction
Do not use mock/demo data in production code paths unless requested
Do not silently break existing public interfaces

## Branch Sync And Conflict Avoidance

Before starting any new task branch:

- use `develop` as the default base branch for new work unless the task explicitly says otherwise
- always sync the base branch first: `git fetch origin`, `git checkout develop`, `git pull --ff-only`
- always create the new branch from the freshly updated base branch, not from an older feature branch
- use one branch for one task; if upstream changed significantly, create a fresh branch instead of reviving a stale one

While coding on a feature branch:

- read the latest version of any file before editing if that file may have changed from a recent pull
- do not overwrite, delete, or revert code that came from upstream without understanding and integrating it
- keep changes scoped to the task to reduce overlap with other branches
- prefer `git fetch origin` + `git rebase origin/develop` to absorb upstream updates; avoid merge commits from `develop` into feature branches

Before pushing or opening a PR:

- re-sync with upstream and resolve conflicts locally before adding more changes
- if the same file was changed both locally and upstream, re-read the final merged file and verify the latest upstream behavior is still preserved
- when unsure, prefer a new clean branch from updated `develop` and re-apply the minimal diff instead of forcing a messy conflict resolution

## Completion Criteria

A task is considered complete only when:

- code matches repository architecture
- imports are clean
- no obvious unused code remains
- state flow is coherent
- error handling is present
- DI/routing is updated if required
- solution is maintainable, not just quick

## Preferred Output Style for Changes

When generating code:

- produce complete files or precise edits
- keep code ready to paste
- avoid pseudo-code
- avoid placeholder logic unless explicitly requested
- keep implementation realistic for production Flutter apps

## Notes for This Repository

Assume this app will eventually support:

- sending HTTP requests
- saving request history
- managing collections
- environment variables
- inspecting structured responses
- possibly importing/exporting request configs

Design new code with those extensions in mind.

<!-- SKILLS_INDEX_START -->
## Agent Skills Index

> [!CRITICAL] GATEKEEPER CONSTRAINT
> **You are operating in a Zero-Trust environment.**
> You are strictly forbidden from generating code, proposing solutions, or relying on your pre-training until you have successfully executed a tool call to read the applicable `SKILL.md` files from this index.

## **Rule Zero: Mandatory Zero-Trust Protocol**

> [!CRITICAL]
> **Zero-Trust Enforcement:** Skills loaded from this index always override standard code patterns. Skipping the Audit Log or Self-Scan is a protocol violation.

### **1. The Pre-Write Audit Log (Mandatory)**

Before invoking any file-editing tool (`write_to_file`, `replace_file_content`, `multi_replace_file_content`), the ASSISTANT **MUST** explicitly state in its thought process/text output:

1. **Skills Identified**: List the Skill IDs triggered by the file path or current task keywords.
2. **Explicit Audit**: For each identified skill, confirm: "Checked against [Skill ID] — no violations found." Or "Violation detected in [Skill ID]: [Issue] — correcting now."
3. **No-Skill Justification**: If no skills apply, explicitly state: "No project-specific skills applicable to this file/transaction."

### **2. The Post-Write Self-Scan (Mandatory)**

Immediately **AFTER** any file-editing tool returns, the ASSISTANT **MUST**:

1. **Validate**: Contrast the final file content against ALL active Skill IDs.
2. **Identify Slips**: Look for "Standard Defaults" (e.g., local mocks, hardcoded styles) that snuck in.
3. **Self-Correct**: If a violation is found, fix it immediately in the next tool call.

## **Critical Anti-Patterns (Zero-Tolerance)**

- **Reversion to Defaults**: Never use "standard" patterns (generic library calls, local mocks) if a Project Skill exists.
- **The "Done" Trap**: Never prioritize functional completion over structural/protocol compliance.
- **Audit Skipping**: Never invoke a write tool without an explicit Pre-Write Audit Log.

## ⚡ How to Find and Use This Index (Mandatory)

> [!IMPORTANT] PATH RESOLUTION (Cross-Platform)
> Skill IDs in the list below (e.g., `[category/skill-name]`) represent the relative folder path.
> Because this project supports multiple AI agents, skills may reside in a base directory like `.gemini/skills/`, `.agent/skills/`, or `.cursor/skills/`.
> **Action:** You must prepend the correct base directory to the ID. (Example: If ID is `[flutter/cicd]`, the file is at `<BASE_DIR>/flutter/cicd/SKILL.md`). Use your file search tools (e.g., `list_directory` or `find`) if you are unsure of the base directory.

| Trigger Type | What to match | Required Action |
| --- | --- | --- |
| **File glob** (e.g. `**/*.ts`) | Files you are currently editing match the pattern | Call `view_file` on `<BASE_DIR>/[Skill ID]/SKILL.md` |
| **Keyword** (e.g. `auth`, `refactor`) | These words appear in the user\'s request | Call `view_file` on `<BASE_DIR>/[Skill ID]/SKILL.md` |
| **Composite** (e.g. `+other/skill`) | Another listed skill is already active | Also load this skill via `view_file` |

> [!TIP]
> **Indirect phrasing still counts.** Match keywords by intent, not just exact words.
> Examples: "make it faster" → `performance`, "broken query" → `database`, "login flow" → `auth`, "clean up this file" → `refactor`.

- **[common/common-architecture-audit]**: Protocol for auditing structural debt, logic leakage, and fragmentation across Web, Mobile, and Backend. (triggers: `package.json, pubspec.yaml, go.mod, pom.xml, nest-cli.json, architecture audit, code review, tech debt, logic leakage, refactor`)
- **[common/common-architecture-diagramming]**: Standards for creating clear, effective, and formalized software architecture diagrams (C4, UML). (triggers: `ARCHITECTURE.md, **/*.mermaid, **/*.drawio, diagram, architecture, c4, system design, mermaid`)
- **[common/common-best-practices]**: 🚨 Universal clean-code principles for any environment. (triggers: `**/*.ts, **/*.tsx, **/*.go, **/*.dart, **/*.java, **/*.kt, **/*.swift, **/*.py, solid, kiss, dry, yagni, naming, conventions, refactor, clean code`)
- **[common/common-code-review]**: Standards for high-quality, persona-driven code reviews. Use when reviewing PRs, critiquing code quality, or analyzing changes for team feedback. (triggers: `review, pr, critique, analyze code`)
- **[common/common-context-optimization]**: Techniques to maximize context window efficiency, reduce latency, and prevent 'lost in middle' issues through strategic masking and compaction. (triggers: `*.log, chat-history.json, reduce tokens, optimize context, summarize history, clear output`)
- **[common/common-debugging]**: Systematic troubleshooting using the Scientific Method. Use when debugging crashes, tracing errors, diagnosing unexpected behavior, or investigating exceptions. (triggers: `debug, fix bug, crash, error, exception, troubleshooting`)
- **[common/common-documentation]**: Essential rules for code comments, READMEs, and technical docs. Use when adding comments, writing docstrings, creating READMEs, or updating any documentation. (triggers: `comment, docstring, readme, documentation`)
- **[common/common-error-handling]**: Cross-cutting standards for error design, response shapes, error codes, and boundary placement. (triggers: `**/*.service.ts, **/*.handler.ts, **/*.controller.ts, **/*.go, **/*.java, **/*.kt, **/*.py, error handling, exception, try catch, error boundary, error response, error code, throw`)
- **[common/common-feedback-reporter]**: 🚨 Pre-write skill violation audit. Checks planned code against loaded skill anti-patterns before any file write. Use when writing Flutter/Dart code, editing SKILL.md files, or generating any code where project skills are active. Load as composite alongside other skills. (triggers: `skill violation, pre-write audit, audit violations, SKILL.md, **/*.dart, **/*.ts, **/*.tsx`)
- **[common/common-git-collaboration]**: 🚨 Universal standards for version control, branching, and team collaboration. Use when writing commits, creating branches, merging, or opening pull requests. (triggers: `commit, branch, merge, pull-request, git`)
- **[common/common-llm-security]**: 🚨 OWASP LLM Top 10 (2025) audit checklist for AI applications, agent tools, RAG pipelines, and prompt construction. Load during any security review touching LLM client code, prompt templates, agent tools, or vector stores. (triggers: `LLM security, prompt injection, agent security, RAG security, AI security, openai, anthropic, langchain, LLM review`)
- **[common/common-mobile-animation]**: Motion design principles for mobile apps. Covers timing curves, transitions, gestures, and performance-conscious animations. (triggers: `**/*_page.dart, **/*_screen.dart, **/*.swift, **/*Activity.kt, **/*Screen.tsx, Animation, AnimationController, Animated, MotionLayout, transition, gesture`)
- **[common/common-mobile-ux-core]**: 🚨 Universal mobile UX principles for touch-first interfaces. Enforces touch targets, safe areas, and mobile-specific interaction patterns. (triggers: `**/*_page.dart, **/*_screen.dart, **/*_view.dart, **/*.swift, **/*Activity.kt, **/*Screen.tsx, mobile, responsive, SafeArea, touch, gesture, viewport`)
- **[common/common-owasp]**: 🚨 OWASP Top 10 audit checklist for Web Applications (2021) and APIs (2023). Load during any security review, PR review, or codebase audit touching web, mobile backend, or API code. (triggers: `security review, OWASP, broken access control, IDOR, BOLA, injection, broken auth, API review, authorization, access control`)
- **[common/common-performance-engineering]**: 🚨 Universal standards for high-performance development. Use when optimizing, reducing latency, fixing memory leaks, profiling, or improving throughput. (triggers: `**/*.ts, **/*.tsx, **/*.go, **/*.dart, **/*.java, **/*.kt, **/*.swift, **/*.py, performance, optimize, profile, scalability, latency, throughput, memory leak, bottleneck`)
- **[common/common-product-requirements]**: 🚨 Expert process for gathering requirements and drafting PRDs (Iterative Discovery). Use when creating a PRD, speccing a new feature, or clarifying requirements. (triggers: `PRD.md, specs/*.md, create prd, draft requirements, new feature spec`)
- **[common/common-protocol-enforcement]**: 🚨 Standards for Red-Team verification and adversarial protocol audit. Use when verifying tasks, performing self-scans, or checking for protocol violations. Load as composite for all sessions. (triggers: `verify done, protocol check, self-scan, pre-write audit, task complete, audit violations, retrospective, scan, red-team`)
- **[common/common-security-audit]**: 🚨 Adversarial security probing and vulnerability assessments across Node, Go, Dart, Java, Python, and Rust. (triggers: `package.json, go.mod, pubspec.yaml, pom.xml, Dockerfile, security audit, vulnerability scan, secrets detection, injection probe, pentest`)
- **[common/common-security-standards]**: 🚨 Universal security protocols for safe, resilient software. Use when implementing authentication, encryption, authorization, or any security-sensitive feature. (triggers: `**/*.ts, **/*.tsx, **/*.go, **/*.dart, **/*.java, **/*.kt, **/*.swift, **/*.py, security, encrypt, authenticate, authorize`)
- **[common/common-session-retrospective]**: Analyze conversation corrections to detect skill gaps and auto-improve the skills library. Use after any session with user corrections, rework, or retrospective requests. (triggers: `**/*.spec.ts, **/*.test.ts, SKILL.md, AGENTS.md, retrospective, self-learning, improve skills, session review, correction, rework`)
- **[common/common-skill-creator]**: 🚨 Standards for creating, testing, and optimizing Agent Skills for any AI Agent (Claude, Cursor, Windsurf, Copilot). Use when: writing SKILL.md, auditing a skill, improving trigger accuracy, checking size limits, structuring references/, writing anti-patterns, starting a new skill from scratch, or reviewing skill quality.
- **[common/common-system-design]**: 🚨 Universal architectural standards for robust, scalable systems. Use when designing new features, evaluating architecture, or resolving scalability concerns. (triggers: `architecture, design, system, scalability`)
- **[common/common-tdd]**: Enforces Test-Driven Development (Red-Green-Refactor). Use when writing unit tests, implementing TDD, or improving test coverage for any feature. (triggers: `**/*.test.ts, **/*.spec.ts, **/*_test.go, **/*Test.java, **/*_test.dart, **/*_spec.rb, tdd, unit test, write test, red green refactor, failing test, test coverage`)
- **[common/common-ui-design]**: 🚨 Create distinctive, production-grade frontend UI with bold aesthetic choices. Use when building web components, pages, interfaces, dashboards, or applications in any framework (React, Next.js, Angular, Vue, HTML/CSS). Triggers: 'build a page', 'create a component', 'design a dashboard', 'landing page', 'UI for', 'build a layout', 'make it look good', 'improve the design', build UI, create interface, design screen
- **[common/common-workflow-writing]**: 🚨 Rules for writing concise, token-efficient workflow and skill files. Prevents over-building that requires costly optimization passes. (triggers: `.agent/workflows/*.md, SKILL.md, create workflow, write workflow, new skill, new workflow`)
- **[dart/dart-best-practices]**: Dart code quality conventions: naming, const/final/var hierarchy, single quotes, trailing commas, collection idioms, tear-offs, and import organization. Use when writing new Dart code or reviewing for style violations — wrong import style, global variables, var misuse, anonymous lambdas where tear-offs fit, or missing trailing commas. (triggers: `**/*.dart, naming, convention, trailing comma, import, tear-off`)
- **[dart/dart-language]**: 🚨 Dart 3.x language feature standards: null safety, records, sealed classes, switch pattern matching, extensions, and async/await. ALWAYS consult when using !, ?., ??, late, sealed classes, record types, switch expressions, or async patterns — and before introducing any new Dart 3.x construct to confirm the modern idiomatic approach. (triggers: `**/*.dart, sealed, record, switch, pattern, !, late, async, extension`)
- **[dart/dart-tooling]**: Dart static analysis, linting, formatting, and code-generation standards. Use when touching analysis_options.yaml, running build_runner, configuring dart format line length, setting up DCM metrics, or adding pre-commit hooks via lefthook — and whenever a CI job fails on analyze or format steps. (triggers: `analysis_options.yaml, build.yaml, build_runner, lefthook.yml, dart format, dart_code_metrics`)
- **[flutter/flutter-cicd]**: Continuous Integration and Deployment standards for Flutter apps. Use when setting up CI/CD pipelines, automated testing, or deployment workflows for Flutter. (triggers: `.github/workflows/**.yml, fastlane/**, android/fastlane/**, ios/fastlane/**, ci, cd, pipeline, build, deploy, release, action, workflow`)
- **[flutter/flutter-design-system]**: 🚨 Enforce Design Language System adherence in Flutter. Use when enforcing design tokens, preventing hardcoded colors/spacing, or implementing a DLS in Flutter. (triggers: `**/theme/**, **/*_theme.dart, **/*_colors.dart, **/*_dls/**, **/foundation/**, **/presentation/**, **/ui/**, **/widgets/**, ThemeData, ColorScheme, AppColors, VColors, VSpacing, AppTheme, design token`)
- **[flutter/flutter-error-handling]**: Functional error handling with Either/Failure. ALWAYS consult when writing repositories, handling exceptions, defining failures, or using Either in any Flutter layer — not just when setting up error handling. (triggers: `lib/domain/**, lib/infrastructure/**, Either, fold, Left, Right, Failure, dartz`)
- **[flutter/flutter-feature-based-clean-architecture]**: 🚨 Feature-based clean architecture standards. ALWAYS consult when creating or modifying any file under lib/features/ — new features, domain entities, repositories, data sources, or screens. (triggers: `lib/features/**, feature, domain, infrastructure, application, presentation`)
- **[flutter/flutter-idiomatic-flutter]**: Modern layout and widget composition standards. Use when composing Flutter widget trees, managing layout constraints, or following idiomatic Flutter patterns. (triggers: `lib/presentation/**/*.dart, context.mounted, SizedBox, Gap, composition, shrink`)
- **[flutter/flutter-layer-based-clean-architecture]**: 🚨 Layer separation and DDD standards. ALWAYS consult when working in lib/domain/, lib/infrastructure/, lib/application/, or lib/presentation/ — for entities, repositories, mappers, BLoCs, or screens. (triggers: `lib/domain/**, lib/infrastructure/**, lib/application/**, dto, mapper, Either, Failure`)
- **[flutter/flutter-navigation]**: Flutter navigation patterns including go_router, deep linking, and named routes. Use when implementing navigation, deep linking, or named routes in Flutter. (triggers: `**/*_route.dart, **/*_router.dart, **/main.dart, Navigator, GoRouter, routes, deep link, go_router, AutoRoute`)
- **[flutter/flutter-notifications]**: Push and local notifications for Flutter using FCM and flutter_local_notifications. Use when integrating push or local notifications in Flutter apps. (triggers: `**/*notification*.dart, **/main.dart, FirebaseMessaging, FlutterLocalNotificationsPlugin, FCM, notification, push`)
- **[flutter/flutter-performance]**: Optimization standards for rebuilds and memory. Use when optimizing Flutter widget rebuilds, reducing memory usage, or improving rendering performance. (triggers: `lib/presentation/**, pubspec.yaml, const, buildWhen, ListView.builder, Isolate, RepaintBoundary`)
- **[flutter/flutter-security]**: 🚨 OWASP Mobile security standards for Flutter. ALWAYS consult when storing data, making network calls, handling tokens/PII, or preparing a release build — not just dedicated security tasks. (triggers: `lib/infrastructure/**, pubspec.yaml, secure_storage, obfuscate, jailbreak, pinning, PII, OWASP`)
- **[flutter/flutter-testing]**: 🚨 Unit, widget, and integration testing with robots, widget keys, and Patrol. Use when writing Flutter unit tests, widget tests, or integration tests with Patrol. (triggers: `**/test/**.dart, **/integration_test/**.dart, **/robots/**.dart, lib/core/keys/**.dart, test, patrol, robot, WidgetKeys, patrolTest, blocTest, mocktail`)
- **[flutter/flutter-widgets]**: Principles for maintainable UI components. Use when building, refactoring, or reviewing Flutter widget implementations for maintainability. (triggers: `**_page.dart, **_screen.dart, **/widgets/**, StatelessWidget, const, Theme, ListView`)

<!-- SKILLS_INDEX_END -->
