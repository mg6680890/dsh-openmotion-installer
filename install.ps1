#Requires -Version 5.1
<#
.SYNOPSIS
  一键安装 OpenMotion 到 DeepSeek Harness（Windows）。

.DESCRIPTION
  从 npm 官方源安装第三方开源软件 OpenMotion（Apache-2.0），并在当前 DSH
  配置档注册插件 dsh-plugin-openmotion-local（MCP + 技能）。
  本脚本不包含 OpenMotion 或 DSH 的任何代码。

.PARAMETER Profile
  DSH 配置档名称，默认 desktop。

.PARAMETER BundleOnly
  只生成本机用的插件 bundle（不安装 OpenMotion 应用）。

.PARAMETER OpenMotionVersion
  npm 上的 @openmotion/app 版本标签，默认 latest。

.EXAMPLE
  .\install.ps1
  .\install.ps1 -Profile desktop
  .\install.ps1 -BundleOnly
#>
[CmdletBinding()]
param(
    [string]$Profile = "desktop",
    [switch]$BundleOnly,
    [string]$OpenMotionVersion = "latest"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$omHome = Join-Path $env:LOCALAPPDATA "openmotion"
$entry  = Join-Path $omHome "dsh-entry.js"

function Write-Step($Message) { Write-Host "==> $Message" -ForegroundColor Cyan }
function Write-Ok($Message)   { Write-Host "    $Message" -ForegroundColor Green }

# 1) 环境检查 ---------------------------------------------------------------
Write-Step "检查 Node.js / npm"
$node = Get-Command node -ErrorAction SilentlyContinue
if (-not $node) { throw "未找到 node。请先安装 Node.js 22.18 或更高版本。" }
$nodeVersion = (& node --version).TrimStart('v')
$nodeMajor = [int]($nodeVersion.Split('.')[0])
if ($nodeMajor -lt 22) { throw "Node 版本过低：$nodeVersion（需要 22.18+）。" }
Write-Ok "node $nodeVersion"

$npx = Get-Command npx -ErrorAction SilentlyContinue
if (-not $npx) { throw "未找到 npx（通常随 npm 一起安装）。" }

# 2) 生成 DSH CLI 入口包装 --------------------------------------------------
#    DSH Desktop 不把 dsh 加入 PATH，且自带 shim 格式与 OpenMotion 安装器不兼容。
#    这里生成一个 JavaScript 入口，由 node 调用 Electron 运行时执行 DSH CLI。
Write-Step "生成 DSH CLI 入口包装：$entry"
New-Item -ItemType Directory -Force -Path $omHome | Out-Null
$template = Join-Path $PSScriptRoot "dsh-entry.js.tmpl"
if (-not (Test-Path -LiteralPath $template)) { throw "缺少模板文件：$template" }
Copy-Item -LiteralPath $template -Destination $entry -Force
Write-Ok "已写入 $entry"

# 3) 仅生成 bundle ----------------------------------------------------------
if ($BundleOnly) {
    $bundleDir = Join-Path $PSScriptRoot "dsh-openmotion"
    $patch = Join-Path $bundleDir "cordis.patch.yml"
    if (-not (Test-Path -LiteralPath $patch)) { throw "缺少 bundle 模板：$patch" }
    $text = Get-Content -LiteralPath $patch -Raw
    $text = $text.Replace('__OPENMOTION_HOME__', $omHome)
    Set-Content -LiteralPath $patch -Value $text -Encoding utf8
    Write-Host ""
    Write-Host "已生成本机 bundle：$bundleDir" -ForegroundColor Green
    Write-Host "注册命令：dsh plugin --profile $Profile add `"$bundleDir`""
    return
}

# 4) 调用官方安装器 --------------------------------------------------------
Write-Step "从 npm 安装 OpenMotion（@openmotion/app@$OpenMotionVersion）并注册插件"
Write-Host "    这一步会下载 OpenMotion 应用与视频组件，请保持网络畅通。"
& $npx.Source --yes --package "@openmotion/app@$OpenMotionVersion" openmotion setup --host deepseek --profile $Profile --dsh $entry
if ($LASTEXITCODE -ne 0) { throw "openmotion setup 失败（退出码 $LASTEXITCODE）。" }

Write-Host ""
Write-Host "安装完成。" -ForegroundColor Green
Write-Host "  1) 在 DSH 的 Plugins 面板确认 dsh-plugin-openmotion-local 已启用。"
Write-Host "  2) 新开会话即可使用 openmotion_* 工具与 OpenMotion 技能。"
Write-Host "  3) 首次导出前，等待浏览器 / 媒体组件准备完成（Studio 会显示进度）。"
Write-Host ""
Write-Host "卸载：.\uninstall.ps1"
