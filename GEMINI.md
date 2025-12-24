# GEMINI.md - Context & Guidelines for FitEasy (flow-link)

This file provides context, architectural insights, and strict operational guidelines for AI agents working on the "FitEasy" (健身易) HarmonyOS project.

## 1. Project Overview
**FitEasy** is a fitness and training tracking application built for **HarmonyOS** using **ArkTS**. It allows users to manage workout plans, log training sessions, view statistics, and handle user authentication.

### Key Technologies
*   **Platform:** HarmonyOS (API Version 5.0.0+) / OpenHarmony
*   **Language:** ArkTS (TypeScript with ArkUI extensions)
*   **UI Framework:** ArkUI (Declarative Paradigm)
*   **Build System:** Hvigor
*   **Package Manager:** ohpm
*   **Testing:** Hypium

## 2. Architecture & Directory Structure

The project follows a modular structure:

*   **`AppScope/`**: Global application configuration (`app.json5`) and resources.
*   **`entry/`**: The main application entry module.
    *   `src/main/ets/pages/`: UI Pages (e.g., `LoginPage.ets`, `DashboardPage.ets`).
    *   `src/main/ets/entryability/`: Lifecycle entry point (`EntryAbility`).
*   **`common/`**: A shared library module (`@tbs/common`) used by `entry`.
    *   `src/main/ets/model/`: Data models (e.g., `UserInfoModel.ets`, `ExerciseModel.ets`).
    *   `src/main/ets/services/`: API communication logic (e.g., `AuthApiService.ets`, `PlanApiService.ets`).
    *   `src/main/ets/utils/`: Utilities (e.g., `StorageUtils.ets`, `GlobalContext.ets`).
    *   `src/main/ets/widgets/`: Reusable UI components (e.g., `ShowToast.ets`).

## 3. Build & Operational Mandates (CRITICAL)

### The "Build-Check" Rule
**Every time you modify code**, you **MUST** run the build script to verify that your changes compile correctly. Do not assume your code is correct without verification.

**Command:**
```bash
./hvigorwAssembleHap.sh
```
*If this script fails, your primary task is to fix the build error immediately.*

### Setup Commands
*   **Install Dependencies:** `ohpm install` (Run this if `oh-package.json5` changes).
*   **Clean Build:** `hvigorw clean`

## 4. Development Conventions

### UI & Navigation
*   **Navigation Pattern:** The app uses the `Navigation` component with `NavPathStack`.
*   **Pages:** Most screens are implemented as `NavDestination` wrapped in a `@Component` struct.
    *   *Example:* See `entry/src/main/ets/pages/LoginPage.ets`.
*   **Safe Area:** Respect system bars (notches, navigation bars).
    *   Use stored properties: `@StorageProp('topRectHeight')` and `@StorageProp('bottomRectHeight')`.
    *   Apply padding/margin to avoid content clipping.

### Data & Networking
*   **API Specs:** Refer strictly to **`API_DOCUMENTATION.md`** for endpoint definitions, request/response bodies, and enums.
*   **Services:** Encapsulate HTTP requests in `*ApiService.ets` classes within the `common` module.
*   **Models:** Use strict typing for all data interfaces. Define classes in `common/src/main/ets/model/`.

### State Management
*   **Persistence:** Use `StorageUtils` (wrapping `preferences`) for saving tokens and user info.
*   **Global State:** Use `AppStorage` for app-wide state (e.g., `isLoggedIn`, safe area insets).
*   **Local State:** Use `@State` for component-internal logic.

## 5. Coding Style (ArkTS)
*   **Strict Typing:** Explicitly type all variables, parameters, and return values. Avoid `any`.
*   **Null Safety:** Prefer `null` over `undefined` for nullable types where possible.
*   **Formatting:** 2-space indentation. PascalCase for structs/classes, camelCase for methods/variables.
*   **UI Syntax:** declarative component chaining (e.g., `.width('100%').height(50)`).

## 6. Relevant Documentation Files
*   **`README.md`**: Basic project intro.
*   **`API_DOCUMENTATION.md`**: **Definitive source** for backend API contracts.
*   **`AGENTS.md`**: Additional specific instructions for AI behavior (READ THIS).

## 7. 需要增加删除修改接口的时候
*   **`API_DOCUMENTATION.md`**: 需要修改这个文档，涉及到接口的变化，这样好给后端同步接口；