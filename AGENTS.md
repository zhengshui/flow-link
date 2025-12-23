# Repository Guidelines

## Project Structure & Module Organization
- `AppScope/`: app-level configuration and shared resources (`app.json5`, global strings/images).
- `entry/`: main HarmonyOS module with ArkTS UI and abilities; pages live in `entry/src/main/ets/pages/`, entry ability in `entry/src/main/ets/entryability/`.
- `common/`: shared models, services, utilities, and widgets reused across modules (`common/src/main/ets/`).
- Resources: module-level assets in `entry/src/main/resources/` and `common/src/main/resources/`; raw media in `entry/src/main/resources/rawfile/`.
- Tests: `entry/src/test/` (local unit), `entry/src/ohosTest/` (device tests), plus matching locations under `common/`.

## Build, Test, and Development Commands
- `ohpm install`: install or sync dependencies after `oh-package.json5` changes.
- `./hvigorwAssembleHap.sh`: build the HAP; required after any code change (project rule).
- `hvigorw clean`: clean build outputs.
- `hvigorw --stop-daemon`: stop hvigor daemon if builds hang.
- DevEco Studio: `Build > Build HAP(s)` and `Run > Run 'entry'` for local deployment.

## Coding Style & Naming Conventions
- ArkTS strict mode: explicit types for variables/params/returns; avoid `any`.
- Avoid `Map`/`Set`; prefer objects or helper functions.
- Prefer `for` loops over `map/filter/find`; use `indexOf()` over `includes()`.
- Use `null` instead of `undefined`.
- Indentation: 2 spaces; keep struct/component names in PascalCase.
- Naming: pages in `entry/src/main/ets/pages/*Page.ets` (e.g., `DashboardPage.ets`), services in `common/src/main/ets/services/*Service.ets`.

## ArkTS Compliance & Workflow
- All UI uses ArkUI declarative syntax; components must include `@Entry` and `@Component`.
- State management is limited to `@State`, `@Prop`, and `@Link`.
- No dynamic JS features (`eval`, `with`, dynamic imports).
- Every function must declare a return type; keep style close to HarmonyOS official examples.
- On ArkTSCheck errors: fix the type or API issue immediately; do not bypass the type system.

## Testing Guidelines
- Framework: Hypium (`@ohos/hypium` in `oh-package.json5`).
- Naming: `*.test.ets` (see `entry/src/test/` and `entry/src/ohosTest/`).
- Run tests via DevEco Studio for the relevant module (device tests live under `ohosTest`).

## Commit & Pull Request Guidelines
- Commit style in history favors short, lowercase type prefixes: `feat ...`, `fix ...`, `chore ...` (optional colon).
- Keep messages concise and action-oriented (e.g., `feat plan template`).
- PRs should include a clear summary, testing notes (or “not run”), and screenshots for UI changes; link relevant issues when available.

## API & Documentation Updates
- If app changes require backend API updates or new endpoints, document them in `API_DOCUMENTATION.md`.
- Keep API docs in sync with request/response shapes used in `common/src/main/ets/services/`.

## Agent-Specific Notes
- Safe area handling: pages with top/bottom chrome should bind to stored safe-area heights:
  ```ts
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  ```
  Use these to pad layout and avoid content clipping on devices with notches or system bars.
- 你的每一个回答结束后都有执行 ./hvigorwAssembleHap.sh ，看看有没有错误，有错误要修复，知道 ./hvigorwAssembleHap.sh 成功
