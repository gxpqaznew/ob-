[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$Name,
    [string]$VaultPath
)

$ErrorActionPreference = 'Stop'
if (-not $VaultPath) { $VaultPath = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path }
$safeName = $Name.Trim()
foreach ($character in [IO.Path]::GetInvalidFileNameChars()) {
    if ($safeName.Contains([string]$character)) {
        throw "Project name contains an invalid character: $character"
    }
}

$projectsRoot = Join-Path $VaultPath '06-项目'
$projectPath = Join-Path $projectsRoot $safeName
$templatePath = Join-Path $VaultPath '90-模板\项目模板.md'
$statusPath = Join-Path $projectPath '项目状态.md'

if (Test-Path -LiteralPath $projectPath) {
    throw "Project already exists: $projectPath"
}
if (-not (Test-Path -LiteralPath $templatePath)) {
    throw "Project template not found: $templatePath"
}

New-Item -ItemType Directory -Path $projectPath | Out-Null
$content = Get-Content -Raw -LiteralPath $templatePath -Encoding utf8
$content = $content.Replace('<Project Name>', $safeName)
$content = $content.Replace('{{date:YYYY-MM-DD}}', (Get-Date -Format 'yyyy-MM-dd'))
Set-Content -LiteralPath $statusPath -Value $content -Encoding utf8
Write-Output "Created project: $projectPath"
