# dsh-openmotion-installer

把开源视频创作工作台 **OpenMotion** 以插件形式接入 **DeepSeek Harness（DSH）** 的一键安装包（Windows）。

> 本仓库只是**安装器 / 配置包**，不含 OpenMotion 或 DSH 的任何代码。
> 安装时会从 npm 官方源下载 OpenMotion 应用，并在**你自己的** DSH 配置档里注册插件。
> 许可与合规说明见下方 [许可与合规](#许可与合规)。

---

## 它能做什么

- 通过官方 `@openmotion/app` 安装 OpenMotion 应用（视频剪辑 / 动效 / 模板复刻 / MP4 导出）。
- 自动在 DSH 里注册插件：`dsh-plugin-openmotion-local`
  - MCP 服务 `openmotion`（模板库、工程、素材、剪辑、导出等工具）
  - OpenMotion 技能包（openmotion-director / production / template-to-video 等 7 个技能）
- 自动处理 **DSH Desktop 没有全局 `dsh` 命令**的问题（生成一个入口包装脚本给安装器识别）。

已在本机实测（Windows 11 x64，DSH Desktop 0.2.2-rc.3）：本地图片 + 本地视频导入 → 时间轴剪辑 → 渲染导出 MP4（H.264 / 1920×1080 / 30fps / 15s）成功。

---

## 前提条件

| 项目 | 要求 |
|---|---|
| 系统 | Windows 11 及以上（x64）。仅 Windows 版本。 |
| Node.js | 22.18 及以上（含 npm / npx） |
| DSH | 已安装 DeepSeek Harness Desktop，且至少启动过一次（存在 profile） |
| 网络 | 能访问 npm 官方源与 OpenMotion 的组件下载源 |

检查 Node：

```powershell
node --version   # 需要 v22.18+
npm --version
```

---

## 一键安装（推荐）

在仓库目录打开 PowerShell：

```powershell
.\install.ps1
```

指定其他 profile（默认 `desktop`）：

```powershell
.\install.ps1 -Profile desktop
```

脚本会依次：检查环境 → 生成 DSH CLI 入口包装 → 调用官方 `openmotion setup --host deepseek` 完成应用安装与插件注册。

完成后：

1. 在 DSH 的 **Plugins** 面板确认 `dsh-plugin-openmotion-local` 已启用；
2. 建议**新开一个会话**，即可看到 `openmotion_*` 工具与 OpenMotion 技能；
3. 首次使用视频导出前，等待 OpenMotion 的浏览器 / 媒体组件准备完成（Studio 会显示进度）。

---

## 手动安装（可选，给已装好 OpenMotion 的人）

如果你已经在本机装好 OpenMotion，可单独安装 DSH 插件 bundle：

```powershell
# 生成插件配置（脚本会把本机路径填进模板）
.\install.ps1 -BundleOnly

# 或者直接注册 bundle 目录（需把模板中的 __OPENMOTION_HOME__ 换成本机路径）
dsh plugin --profile desktop add .\dsh-openmotion
```

> 手动 bundle 目前只包含 MCP 注册；技能包由官方 `openmotion setup` 生成的 bundle 提供，因此**推荐使用一键安装**。

---

## 卸载

```powershell
.\uninstall.ps1
```

或手动移除：

```powershell
dsh plugin --profile desktop remove dsh-plugin-openmotion-local
```

OpenMotion 应用本体（可选）删除目录：`%LOCALAPPDATA%\openmotion`。

---

## 常见问题

**Q：安装器报 `HOST_CLI_NOT_FOUND` / `HOST_CLI_UNSUPPORTED_SHIM`？**
A：DSH Desktop 未把 `dsh` 加入 PATH，且其自带 shim 格式与安装器不兼容。本包会自动生成 `dsh-entry.js` 作为入口包装（见 `%LOCALAPPDATA%\openmotion\dsh-entry.js`）。若仍失败，请以管理员身份重跑。

**Q：组件下载很慢或失败（`EBUSY` / `checking`）？**
A：Windows 杀软（如火绒、Defender）可能锁住新解压的 `chrome-headless-shell.exe` / `ffprobe.exe`。请把 `%LOCALAPPDATA%\openmotion` 加入杀软信任区，然后重跑 `openmotion prepare`。

**Q：`openmotion_open_preview` 报参数错误？**
A：DSH 宿主未自动打开模板库时，工具会报 `workspace page opening ...`。可直接在浏览器打开安装日志里的 `previewUrl`（形如 `http://localhost:4173/?templates=1&embed=1`）。

**Q：导出任务一直 queued？**
A：确认组件状态：`npx --yes --package "@openmotion/app@latest" openmotion prepare`。若仍异常，重启 DSH 与 OpenMotion 后端后再试。

---

## 许可与合规

- **本仓库代码**：MIT License（见 [LICENSE](LICENSE)）。
- **OpenMotion**：第三方开源软件，**Apache License 2.0**，版权归其各自权利人。本仓库**不包含、不转发、不改授权**其任何代码或资产；安装器仅从 npm 公共源拉取官方包 `@openmotion/app`。
- **DeepSeek Harness**：归 DeepSeek 所有，遵循其自身许可。
- 本项目的名称与内容不代表 OpenMotion 或 DeepSeek 官方，亦未获得其背书。

使用本安装器即表示你同意自行承担安装第三方软件的风险，并遵守上述软件的许可条款。

---

## 仓库结构

```
dsh-openmotion-installer/
├── install.ps1            # 一键安装（Windows）
├── uninstall.ps1          # 卸载
├── dsh-entry.js.tmpl      # DSH CLI 入口包装模板（由脚本生成到本机目录）
├── dsh-openmotion/        # 可选的手动 bundle
│   ├── package.json
│   ├── cordis.patch.yml   # 含 __OPENMOTION_HOME__ 占位符
│   ├── locale/{en,zh}.json
│   ├── icon.svg
│   └── docs/DETAIL.md
├── LICENSE
└── README.md
```
