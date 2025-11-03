import dataPreferences from '@ohos.data.preferences';
import preferences from '@ohos.data.preferences';
import { HashMap } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';
import { GlobalContext } from './GlobalContext';
import { BusinessError } from '@kit.BasicServicesKit';

class Storage{
  private name: string = 'app_storage'
  private preferences: dataPreferences.Preferences | null = null
  private listenerKeyMap = new HashMap<string, HashMap<string, Callback<string>>>()

  constructor(name: string) {
    this.name = name;
  }

  initStorage() {
    const context = GlobalContext.getContext().getObject('context') as common.UIAbilityContext
    const options: dataPreferences.Options = { name: this.name }
    this.preferences = dataPreferences.getPreferencesSync(context, options)
    this.preferences?.on('change', (key: string) => {
      const pageMap = this.listenerKeyMap.get(key)
      pageMap?.forEach((callBack: Callback<string>) => {
        callBack(key)
      })
    })
  }

  /**
   * 存储key,value到preference缓存里面
   * @param key
   * @param value
   */
  saveValueSync(key: string, value: preferences.ValueType) {
    try {
      this.preferences?.putSync(key, value)
      // 同步刷新到磁盘
      this.preferences?.flushSync()
      console.log(`[Storage] Saved ${key} successfully`)
    } catch (err) {
      console.error(`[Storage] Failed to save ${key}:`, JSON.stringify(err))
    }
  }

  /**
   * 根据key删除值
   * @param key
   */
  deleteValueSync(key: string) {
    try {
      this.preferences?.deleteSync(key)
      // 同步刷新到磁盘
      this.preferences?.flushSync()
      console.log(`[Storage] Deleted ${key} successfully`)
    } catch (err) {
      console.error(`[Storage] Failed to delete ${key}:`, JSON.stringify(err))
    }
  }

  /**
   * 适用于普通函数获取
   * @param key
   * @param defaultValue
   * @returns string
   */
  getStringValueSync(key: string, defaultValue: string): string {
    if (this.preferences === null) {
      console.warn('StorageUtils: preferences not initialized, returning defaultValue');
      return defaultValue;
    }
    const value = this.preferences.getSync(key, defaultValue);
    return value as string;
  }

  /**
   * 适用于普通函数获取
   * @param key
   * @param defaultValue
   * @returns Array<string>
   */
  getArrayStringValueSync(key: string, defaultValue: Array<string>): Array<string> {
    if (this.preferences === null) {
      console.warn('StorageUtils: preferences not initialized, returning defaultValue');
      return defaultValue;
    }
    const value = this.preferences.getSync(key, defaultValue);
    return value as Array<string>;
  }
}
export const commonStorage = new Storage('common_storage')

export const StorageUtils = commonStorage

export function initDataPreference() {
  commonStorage.initStorage()
}