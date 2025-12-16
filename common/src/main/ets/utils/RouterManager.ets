/**
 * Navigation 路由管理器
 * 使用 AppStorage 全局管理 NavPathStack，实现跨组件的路由操作
 */

const NAV_PATH_STACK_KEY: string = 'NavPathStack';

/**
 * 路由参数接口
 */
export interface NavRouteParams {
  actionId?: string;
  recordId?: string;
  selectedDate?: string;
  copyFromRecord?: boolean;
}

/**
 * 路由管理器类
 * 提供全局路由操作方法
 */
export class RouterManager {
  /**
   * 初始化路由栈（在 Navigation 组件中调用）
   */
  static initNavPathStack(pathStack: NavPathStack): void {
    AppStorage.setOrCreate<NavPathStack>(NAV_PATH_STACK_KEY, pathStack);
  }

  /**
   * 获取路由栈
   */
  static getNavPathStack(): NavPathStack | undefined {
    return AppStorage.get<NavPathStack>(NAV_PATH_STACK_KEY);
  }

  /**
   * 跳转到指定页面
   * @param pageName 页面名称（对应 route_map.json 中的 name）
   * @param params 可选参数
   */
  static pushPath(pageName: string, params?: NavRouteParams): void {
    const pathStack: NavPathStack | undefined = RouterManager.getNavPathStack();
    if (pathStack !== undefined) {
      pathStack.pushPathByName(pageName, params);
    } else {
      console.error('[RouterManager] NavPathStack not initialized');
    }
  }

  /**
   * 返回上一页
   */
  static pop(): void {
    const pathStack: NavPathStack | undefined = RouterManager.getNavPathStack();
    if (pathStack !== undefined) {
      pathStack.pop();
    } else {
      console.error('[RouterManager] NavPathStack not initialized');
    }
  }

  /**
   * 返回到指定页面
   */
  static popToName(pageName: string): void {
    const pathStack: NavPathStack | undefined = RouterManager.getNavPathStack();
    if (pathStack !== undefined) {
      pathStack.popToName(pageName);
    } else {
      console.error('[RouterManager] NavPathStack not initialized');
    }
  }

  /**
   * 清空路由栈（返回首页）
   */
  static clear(): void {
    const pathStack: NavPathStack | undefined = RouterManager.getNavPathStack();
    if (pathStack !== undefined) {
      pathStack.clear();
    } else {
      console.error('[RouterManager] NavPathStack not initialized');
    }
  }

  /**
   * 替换当前页面
   */
  static replacePath(pageName: string, params?: NavRouteParams): void {
    const pathStack: NavPathStack | undefined = RouterManager.getNavPathStack();
    if (pathStack !== undefined) {
      pathStack.replacePathByName(pageName, params);
    } else {
      console.error('[RouterManager] NavPathStack not initialized');
    }
  }

  /**
   * 获取路由栈大小
   */
  static size(): number {
    const pathStack: NavPathStack | undefined = RouterManager.getNavPathStack();
    if (pathStack !== undefined) {
      return pathStack.size();
    }
    return 0;
  }
}

/**
 * 路由常量 - 页面名称
 */
export class NavRoutes {
  static readonly LOGIN: string = 'LoginPage';
  static readonly REGISTER: string = 'RegisterPage';
  static readonly PROFILE_EDIT: string = 'ProfileEditPage';
  static readonly THEME_SETTINGS: string = 'ThemeSettingsPage';
  static readonly REMINDER_SETTINGS: string = 'ReminderSettingsPage';
  static readonly ABOUT: string = 'AboutPage';
  static readonly FEEDBACK: string = 'FeedbackPage';
  static readonly EXERCISE_DETAIL: string = 'ExerciseDetailPage';
  static readonly TRAINING_SESSION: string = 'TrainingSessionPage';
  static readonly ACTION_SELECT: string = 'ActionSelectPage';
  static readonly ADD_TRAINING: string = 'AddTrainingPage';
}

