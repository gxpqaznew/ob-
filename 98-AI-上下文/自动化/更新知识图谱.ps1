[CmdletBinding()]
param(
    [string]$VaultPath
)

$ErrorActionPreference = 'Stop'
if (-not $VaultPath) { $VaultPath = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path }
$researchPath = Join-Path $VaultPath '04-研究'
$hubPath = Join-Path $researchPath '主题中心'
$taxonomyPath = Join-Path $VaultPath '98-AI-上下文\研究分类.json'

function Set-AutoIndex {
    param([string]$Path, [string[]]$Lines)
    $content = Get-Content -Raw -LiteralPath $Path -Encoding utf8
    $replacement = "<!-- AUTO-INDEX:START -->`n" + ($Lines -join "`n") + "`n<!-- AUTO-INDEX:END -->"
    if ($content -match '(?s)<!-- AUTO-INDEX:START -->.*?<!-- AUTO-INDEX:END -->') {
        $content = [regex]::Replace(
            $content,
            '(?s)<!-- AUTO-INDEX:START -->.*?<!-- AUTO-INDEX:END -->',
            [System.Text.RegularExpressions.MatchEvaluator]{ param($match) $replacement }
        )
        Set-Content -LiteralPath $Path -Value $content -Encoding utf8
    }
}

$taxonomy = Get-Content -Raw -LiteralPath $taxonomyPath -Encoding utf8 | ConvertFrom-Json
$notes = Get-ChildItem -LiteralPath $researchPath -Recurse -File -Filter '*.md' |
    Where-Object {
        $_.DirectoryName -ne $hubPath -and
        $_.Name -notin @('研究索引.md', '通用研究.md')
    }

foreach ($topic in $taxonomy.topics) {
    $tag = 'topic/' + $topic.slug
    $matching = foreach ($note in $notes) {
        $content = Get-Content -Raw -LiteralPath $note.FullName -Encoding utf8
        if ($content -match '(?i)(^|[\s\["''])' + [regex]::Escape($tag) + '([\s\]"'']|$)') {
            $relative = $note.FullName.Substring($VaultPath.Length).TrimStart('\')
            $wikilink = [IO.Path]::ChangeExtension($relative, $null).Replace('\', '/')
            '- [[' + $wikilink + '|' + $note.BaseName + ']]'
        }
    }

    $hubFile = Join-Path $hubPath ($topic.hub + '.md')
    if ($matching.Count -ge 2 -and -not (Test-Path -LiteralPath $hubFile)) {
        $hubContent = @(
            '---'
            'type: topic-hub'
            'topic: "' + $topic.hub.Replace(' Hub', '') + '"'
            'status: generated'
            'tags:'
            '  - topic/' + $topic.slug
            '  - system/topic-hub'
            '---'
            ''
            '# ' + $topic.hub
            ''
            '## 范围'
            ''
            '根据研究笔记中重复出现的主题标签自动生成。'
            ''
            '## 研究笔记'
            ''
            '<!-- AUTO-INDEX:START -->'
            '<!-- AUTO-INDEX:END -->'
            ''
        ) -join "`n"
        Set-Content -LiteralPath $hubFile -Value $hubContent -Encoding utf8
    }
    if (Test-Path -LiteralPath $hubFile) {
        $lines = if ($matching) { @($matching | Sort-Object -Unique) } else { @() }
        Set-AutoIndex -Path $hubFile -Lines $lines
    }
}

Write-Output "知识图谱已根据 $($notes.Count) 篇研究笔记更新。"
