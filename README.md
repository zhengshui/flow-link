**鸿蒙（HarmonyOS）工程 README.md 模板**

**1. 项目简介**
**项目名称**：HarmonyOS示例应用**功能概述**：展示基础ArkTS开发能力，包含页面跳转、组件使用及资源管理功能。  
**技术栈**：HarmonyOS 5.0.0+、ArkTS、声明式UI范式

---

**2. 环境要求**
- **开发工具**：DevEco Studio 4.0 Beta2+（支持ArkTS开发）
- **SDK版本**：API Version 5.0.0(12) 或更高
- **设备类型**：支持Phone、Tablet、Car等设备

---

**3. 工程目录结构**
```
├── AppScope                  # 全局配置及资源
│   ├── resources            # 全局资源（字符串、图片、样式等）
│   └── app.json5            # 应用级配置（名称、版本、权限等）
│
├── entry                    # 主模块代码目录
│   ├── src/main/ets
│   │   ├── entryability     # 应用入口逻辑（如EntryAbility.ets）
│   │   ├── pages            # 页面组件（如Index.ets）
│   │   └── model            # 数据模型层（可选）
│   │
│   ├── resources           # 模块级资源文件
│   └── module.json5        # 模块清单（声明Ability、权限等）
│
├── oh_modules              # 三方库依赖（自动生成）
├── build-profile.json5     # 构建配置（签名、产品目标）
└── oh-package.json5        # 依赖管理文件（声明三方库版本）
```

---

#### 4. 快速开始
1. **克隆仓库**：
   ```bash
   git clone [项目仓库地址]
   ```
2. **安装依赖**：
   ```bash
   ohpm install
   ```
3. **配置设备**：  
   在DevEco Studio中连接真机或启动模拟器。
4. **运行项目**：  
   点击 `Run > Run 'entry'` 编译并部署应用。

---

**5. 关键配置说明**
**app.json5（全局配置）**：
```json
{
  "app": {
    "bundleName": "com.example.demo",
    "version": { "code": 1, "name": "1.0.0" },
    "deviceTypes": ["phone", "tablet"]
  }
}
```

**module.json5（模块配置）**：
```json
{
  "module": {
    "name": "entry",
    "abilities": [{
      "name": "EntryAbility",
      "srcEntry": "./ets/entryability/EntryAbility.ets"
    }]
  }
}
```

---

**6. 构建与发布**
- **编译HAP**：通过 `Build > Build HAP(s)` 生成部署包。
- **发布HAR包**（如需共享模块）：
  ```bash
  ohpm publish [HAR文件路径]
  ```
  *需提前配置ohpm私钥和发布码（参考OpenHarmony三方库中心仓指南）。*

---

#### 7. 贡献指南
- **代码规范**：遵循ArkTS编程规范（小驼峰命名、2空格缩进）。
- **提交说明**：关联Issue编号，描述修改内容。
- **测试要求**：新增功能需包含单元测试用例。

---

#### 8. 许可证
```text
MIT License
Copyright (c) 2025 [Your Name]
（需在根目录添加LICENSE文件）
```

---

**备注**：
- 资源文件遵循就近原则，模块内资源会覆盖全局同名资源。
- 修改 `oh-package.json5` 后需执行 `ohpm install` 同步依赖。