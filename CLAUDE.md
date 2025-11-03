# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**FitEasy (健身易)** - A HarmonyOS fitness tracking application built with ArkTS.

ArkTS开发文档 https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-dev-guide
ArkTS编程规范 https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-coding-style-guide

- **Bundle Name**: com.shui.fiteasy
- **Version**: 1.0.0
- **Tech Stack**: ArkTS + HarmonyOS 5.0.0+ (API Level 12)
- **SDK**: Compatible SDK 5.0.4(16), Target SDK 6.0.0(20)

## Build & Development Commands

### Build Commands
```bash
# Build HAP (after code changes - REQUIRED by project rules)
./hvigorwAssembleHap.sh

# Clean build
hvigorw clean

# Stop hvigor daemon
hvigorw --stop-daemon
```

### Testing & Dependencies
```bash
# Install dependencies
ohpm install

# Sync dependencies after modifying oh-package.json5
ohpm install
```

### DevEco Studio
- **Build**: Build → Build HAP(s)
- **Run**: Run → Run 'entry'
- **Clean**: Build → Clean Project

## Critical Development Rules

### ArkTS Strict Compilation Rules

**MANDATORY**: Every code modification MUST be followed by running `./hvigorwAssembleHap.sh`. If compilation errors occur, continue fixing until zero errors remain.

1. **Explicit Type Declarations**
   - All variables, parameters, and function return types MUST be explicitly typed
   - NO `any` types or implicit typing allowed
   ```typescript
   // ✅ Correct
   function calculateTotal(items: number[]): number {
     let sum: number = 0;
     return sum;
   }

   // ❌ Wrong
   function calculateTotal(items) {
     let sum = 0;
     return sum;
   }
   ```

2. **Avoid ES6 Collections**
   - Map and Set have limited support - use functions or objects instead
   ```typescript
   // ✅ Correct
   function getDataById(id: number): Data | null {
     if (id === 1) return data1;
     return null;
   }

   // ❌ Wrong
   const dataMap = new Map<number, Data>();
   ```

3. **Use for Loops Instead of Higher-Order Functions**
   ```typescript
   // ✅ Correct
   const results: Type[] = [];
   for (let i: number = 0; i < array.length; i++) {
     if (condition) {
       results.push(array[i]);
     }
   }

   // ❌ Potentially problematic
   const results = array.filter(item => condition);
   ```

4. **Promise Must Have Generic Type**
   ```typescript
   // ✅ Correct
   return new Promise<void>((resolve: () => void) => {
     setTimeout((): void => {
       resolve();
     }, 100);
   });

   // ❌ Wrong
   return new Promise((resolve) => {
     setTimeout(() => resolve(), 100);
   });
   ```

5. **Use null Instead of undefined**
   ```typescript
   // ✅ Correct
   data: null

   // ❌ Avoid
   data: undefined
   ```

6. **String Operations**
   - Use `indexOf()` instead of `includes()`
   - Implement custom functions for `padStart()` / `padEnd()` if needed
   - Prefer template strings for concatenation

7. **Component Decorators**
   - UI components require `@Component` decorator
   - Entry points require `@Entry` decorator
   - State management: `@State`, `@Prop`, `@Link`

## Project Architecture

### Module Structure

```
flow-link/
├── AppScope/              # Global app configuration
│   └── app.json5          # Bundle name, version, icon
├── entry/                 # Main application module
│   ├── src/main/ets/
│   │   ├── entryability/  # App entry point
│   │   ├── home/          # HomePage with 5-tab navigation
│   │   └── pages/         # 5 core pages
│   └── module.json5       # Module manifest, abilities, permissions
├── common/                # Shared utilities module (HSP)
│   └── src/main/ets/
│       ├── common/        # UI components (TbsTitleBar, LoadingView)
│       ├── http/          # HTTP utils and response handling
│       ├── location/      # Location and permission managers
│       ├── manager/       # Constants (RoutePageConst, StorageConst)
│       ├── model/         # Common models (UserInfoModel)
│       ├── utils/         # Utilities (ScreenUtil, StorageUtils)
│       └── widgets/       # Reusable widgets (ShowToast, ConfirmDialog)
└── feature/               # Feature modules
    ├── charge/            # Charging station feature (legacy - to be replaced)
    └── mine/              # User profile feature (legacy - to be replaced)
```

### Core Pages (5-Tab Navigation)

Entry point: `entry/src/main/ets/home/HomePage.ets`

1. **DashboardPage** - Training overview and progress
2. **RecordPage** - Training records list (add/edit/delete)
3. **PlanPage** - Fitness plan templates and custom plans
4. **StatsPage** - Data visualization and trends
5. **ProfilePage** - User settings and preferences

### Navigation & Routing

- **Route Constants**: `common/src/main/ets/manager/RoutePageConst.ets`
- **Router Usage**: Import from `@kit.ArkUI`
```typescript
import { router } from '@kit.ArkUI';
router.pushUrl({ url: RoutePageConst.AppHomePage });
```

### HTTP Layer

- **Base URL**: `https://charging.lusson.xyz` (configured in `common/src/main/ets/http/httpUtils.ets`)
- **Authentication**: Bearer token stored in preferences (`StorageConst.TOKEN`)
- **Auto Token Handling**: 401 responses automatically redirect to login
- **Response Model**: `ResponseResult` with `code`, `message`, `data` fields

### State Management

- **Local Storage**: `StorageUtils` from common module
- **User Info**: Stored with key `StorageConst.USER_INFO`
- **Token**: Stored with key `StorageConst.TOKEN`

## Common Patterns

### Creating New Pages

1. Create `.ets` file in `entry/src/main/ets/pages/`
2. Use `@Entry` and `@Component` decorators
3. Register in `entry/src/main/resources/base/profile/main_pages.json`
4. Add route constant to `RoutePageConst.ets`

### HTTP API Calls

```typescript
import { requestApiCall } from '@tbs/common';
import http from '@ohos.net.http';

const response: ResponseResult = await requestApiCall(
  '/api/endpoint',
  http.RequestMethod.POST,
  { key: 'value' }
);
```

### UI Component Structure

```typescript
@Entry
@Component
struct PageName {
  @State data: DataType = initialValue;

  build() {
    Column() {
      // UI elements
    }
    .width('100%')
    .height('100%')
  }
}
```

## Resource Management

- **Strings**: `entry/src/main/resources/base/element/string.json`
- **Colors**: Define in `color.json` or inline as `#RRGGBB`
- **Images**: `entry/src/main/resources/base/media/`
- **Access**: Use `$r()` function - e.g., `$r('app.string.app_name')`

## Important Files

- **App Config**: `AppScope/app.json5` - Bundle name, version, vendor
- **Module Config**: `entry/src/main/module.json5` - Abilities, permissions, device types
- **Build Profile**: `build-profile.json5` - Signing configs, SDK versions, modules
- **Dependencies**: `oh-package.json5` - OHPM dependencies (@ohos/hypium, @ohos/hamock)
- **Main Pages**: `entry/src/main/resources/base/profile/main_pages.json` - Page routing config

## Development Workflow

1. **Before Coding**: Understand ArkTS restrictions (see ARKTS_FIXES.md)
2. **While Coding**:
   - Use explicit types everywhere
   - Avoid Map/Set, use functions instead
   - Use for loops instead of filter/map/find
3. **After Coding**:
   - Run `./hvigorwAssembleHap.sh`
   - Fix all ArkTSCheck errors
   - Never bypass type system or ignore errors

## Current Status

- **Framework**: ✅ Complete (5-page navigation structure)
- **Features**: 🚧 In Progress (placeholder pages need implementation)
- **Legacy Code**: ⚠️ `feature/charge` and `feature/mine` modules are legacy (from charging app)

## Next Development Phases

1. **Data Layer**: Design models, implement local storage (Preferences/SQLite)
2. **Record Feature**: Add/edit/delete training records
3. **Plan Feature**: Templates and custom plan creation
4. **Visualization**: Integrate charts (ECharts or native)
5. **Settings**: Theme switching, notifications, data export
6. **AI Assistant**: Reserved entry point (future enhancement)
