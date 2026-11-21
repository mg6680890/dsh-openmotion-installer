#Requires -Version 5.1
<#
.SYNOPSIS
  卸载 dsh-openmotion-installer 注册的 DSH 插件。

.PARAMETER Profile
  DSH 配置档名称，默认 desktop。

.PARAMETER KeepApp
  保留 OpenMotion 应用本体（默认也会提示是否删除）。
#>
[CmdletBinding()]
param(
    [string]$Profile = "desktop",
    [switch]$KeepApp
)

$ErrorActionPreference = "Stop"

$omHome = Join-Path $env:LOCALAPPDATA "openmotion"
$entry  = Join-Path $omHome "dsh-entry.js"

if (-not (Test-Path -LiteralPath $entry)) {
    Write-Host "未找到入口包装 $entry，改用 PATH 中的 dsh（若存在）。" -ForegroundColor Yellow
    $dsh = 'dsh'
} else {
    $dsh = @('node', $entry) -join ' '
}

Write-Host "==> 移除插件 dsh-plugin-openmotion-local（profile: $Profile）" -ForegroundColor Cyan
if ($dsh -eq 'dsh') {
    & dsh plugin --profile $Profile remove dsh-plugin-openmotion-local
} else {
    & node $entry plugin --profile $Profile remove dsh-plugin-openmotion-local
}

if (-not $KeepApp) {
    Write-Host ""
    Write-Host "提示：OpenMotion 应用本体位于 $omHome" -ForegroundColor Yellow
    Write-Host "如需删除，请手动移除该目录（本脚本不自动删除，以免误删你的工程文件）。"
}

Write-Host "完成。" -ForegroundColor Green
