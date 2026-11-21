# OpenMotion 连接（DSH 插件）

把开源视频创作工作台 **OpenMotion** 接入 **DeepSeek Harness**：在对话里直接浏览模板库、创建工程、导入本地图片与视频、剪辑时间轴并导出 MP4。

## 功能

- MCP 服务 `openmotion`：模板发现、工程创建/编辑、素材导入、预览、导出。
- 技能包（由 OpenMotion 官方安装器提供）：`openmotion-director`、`openmotion-production`、`openmotion-template-to-video`、`openmotion-recreate` 等。

## 依赖

- DeepSeek Harness Desktop（Windows 11 x64）与 Node.js 22.18+。
- OpenMotion 应用本体：由安装脚本从 npm 官方源下载（`@openmotion/app`）。

## 安装

推荐使用本仓库的 `install.ps1`（会自动完成应用安装与插件注册）。手动注册本 bundle 前，请先在本机安装好 OpenMotion，并把 `cordis.patch.yml` 中的 `__OPENMOTION_HOME__` 替换为本机 OpenMotion 主目录。

## 卸载

移除 DSH 插件 `dsh-openmotion-local`（或你注册时使用的名称），并可删除 `%LOCALAPPDATA%\openmotion`。

## 许可

- 本仓库代码：MIT。
- OpenMotion：Apache License 2.0（第三方，版权归其权利人）。
- DeepSeek Harness：遵循其自身许可。
- 本插件不包含任何第三方代码或资产，亦不代表官方背书。
