# sync-dicts.ps1 —— 一键同步上游雾凇词库
# 用法：双击本文件即可（或在 PowerShell 里运行）
# 作用：拉取上游 rime-ice 的 cn_dicts/，覆盖本地，并提交（不推送）
#
# 为什么脚本里不写中文路径：Windows PowerShell 5.1 读取 UTF-8 无 BOM 的 .ps1
# 时会按本地代码页(GBK)解析，中文会乱码。改用 $PSScriptRoot 自动定位。

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = $PSScriptRoot
Write-Host ""
Write-Host "=== 同步上游雾凇词库 ===" -ForegroundColor Cyan
Write-Host "仓库: $repoRoot"
Write-Host ""

if (-not (Test-Path (Join-Path $repoRoot '.git'))) {
    Write-Host "[x] 当前目录不是 git 仓库" -ForegroundColor Red
    Read-Host "按回车退出"
    exit 1
}

function Get-Git {
    $g = Get-Command git -ErrorAction SilentlyContinue
    if ($g) { return $g.Source }
    foreach ($p in @("$env:ProgramFiles\Git\cmd\git.exe", "${env:ProgramFiles(x86)}\Git\cmd\git.exe")) {
        if (Test-Path $p) { return $p }
    }
    return $null
}
$git = Get-Git
if (-not $git) {
    Write-Host "[x] 找不到 git，请先安装 Git for Windows" -ForegroundColor Red
    Read-Host "按回车退出"
    exit 1
}

# 记录同步前的 HEAD
$before = (& $git -C $repoRoot rev-parse --short HEAD)

Write-Host "[1/3] 拉取上游 main ..." -ForegroundColor Yellow
& $git -C $repoRoot fetch upstream main --depth=1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[x] fetch 失败（网络？upstream 未配置？）" -ForegroundColor Red
    Read-Host "按回车退出"
    exit 1
}

Write-Host "[2/3] 用上游覆盖 cn_dicts/ ..." -ForegroundColor Yellow
& $git -C $repoRoot checkout upstream/main -- cn_dicts/
if ($LASTEXITCODE -ne 0) {
    Write-Host "[x] checkout 失败" -ForegroundColor Red
    Read-Host "按回车退出"
    exit 1
}

Write-Host "[3/3] 检查变更 ..." -ForegroundColor Yellow
$changes = & $git -C $repoRoot status --short -- cn_dicts/
if (-not $changes) {
    Write-Host ""
    Write-Host "[OK] 词库已是最新，无需更新。" -ForegroundColor Green
    Read-Host "按回车退出"
    exit 0
}

Write-Host ""
Write-Host "以下文件有更新：" -ForegroundColor Green
$changes | ForEach-Object { Write-Host "  $_" }
Write-Host ""

& $git -C $repoRoot add cn_dicts/
$msg = "chore: sync cn_dicts with upstream rime-ice"
& $git -C $repoRoot commit -m $msg

$after = (& $git -C $repoRoot rev-parse --short HEAD)
Write-Host ""
Write-Host "=== 完成 ===" -ForegroundColor Cyan
Write-Host "  提交: $before -> $after"
Write-Host "  提醒: 尚未推送。需要推送到 GitHub 请在聊天里说「推」。" -ForegroundColor DarkYellow
Write-Host "  提醒: 词库生效需同步到 Rime 用户目录并重新部署。" -ForegroundColor DarkYellow
Write-Host ""
Read-Host "按回车退出"
