[CmdletBinding()]
param(
    [string]$VaultPath = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
)

$ErrorActionPreference = 'Stop'
$generatedAt = Get-Date
$reportPath = Join-Path $VaultPath '98-AI-Context\Knowledge Base Audit Report.md'
$researchRoot = Join-Path $VaultPath '04-Research'
$gitMetadataPath = Join-Path $VaultPath '.git'

function Get-RelativePath {
    param([string]$Path)
    return $Path.Substring($VaultPath.Length).TrimStart('\').Replace('\', '/')
}

function Get-NormalizedContentHash {
    param([string]$Path)
    $content = Get-Content -Raw -LiteralPath $Path -Encoding utf8
    $content = [regex]::Replace($content, '(?s)\A---\s*\r?\n.*?\r?\n---\s*', '')
    $content = ($content -replace '\s+', ' ').Trim()
    $bytes = [Text.Encoding]::UTF8.GetBytes($content)
    $algorithm = [Security.Cryptography.SHA256]::Create()
    try {
        $hashBytes = $algorithm.ComputeHash($bytes)
        return (($hashBytes | ForEach-Object { $_.ToString('x2') }) -join '')
    }
    finally {
        $algorithm.Dispose()
    }
}

function Format-ListSection {
    param([object[]]$Items, [string]$EmptyMessage = 'None.')
    if (-not $Items -or $Items.Count -eq 0) { return @("- $EmptyMessage") }
    return @($Items | ForEach-Object { '- `' + $_ + '`' })
}

$allFiles = @(Get-ChildItem -LiteralPath $VaultPath -Recurse -File -Force |
    Where-Object { -not $_.FullName.StartsWith($gitMetadataPath, [StringComparison]::OrdinalIgnoreCase) })
$markdownFiles = @($allFiles | Where-Object { $_.Extension -eq '.md' })
$directories = @(Get-ChildItem -LiteralPath $VaultPath -Recurse -Directory -Force |
    Where-Object { -not $_.FullName.StartsWith($gitMetadataPath, [StringComparison]::OrdinalIgnoreCase) })
$researchFiles = @($markdownFiles | Where-Object {
    $_.FullName.StartsWith($researchRoot, [StringComparison]::OrdinalIgnoreCase) -and
    $_.DirectoryName -notlike '*\Topic-Hubs' -and
    $_.Name -notin @('Research Index.md', 'General Research.md')
})

$junkPatterns = @(
    '^\.DS_Store$',
    '^Thumbs\.db$',
    '^desktop\.ini$',
    '\.(tmp|temp|swp|bak)$',
    '^~\$'
)
$junkFiles = @($allFiles | Where-Object {
    $name = $_.Name
    $junkPatterns | Where-Object { $name -match $_ } | Select-Object -First 1
} | ForEach-Object { Get-RelativePath $_.FullName })

$structurallyEmptyDirectories = @($directories | Where-Object {
    $meaningfulChildren = @(Get-ChildItem -LiteralPath $_.FullName -Force |
        Where-Object { $_.Name -ne '.gitkeep' })
    $meaningfulChildren.Count -eq 0
} | ForEach-Object { Get-RelativePath $_.FullName })

$abnormalNames = @($allFiles | Where-Object {
    $_.Name.Length -gt 120 -or
    $_.BaseName -match '^(Untitled|New Note|\u672a\u547d\u540d)$' -or
    $_.BaseName -match '\s{2,}' -or
    $_.BaseName.EndsWith('.') -or
    $_.BaseName.EndsWith(' ')
} | ForEach-Object { Get-RelativePath $_.FullName })

$contentHashRecords = foreach ($file in $markdownFiles) {
    if ($file.Length -gt 0) {
        [pscustomobject]@{
            Hash = Get-NormalizedContentHash -Path $file.FullName
            Path = Get-RelativePath $file.FullName
        }
    }
}
$duplicateGroups = @($contentHashRecords | Group-Object Hash | Where-Object { $_.Count -gt 1 })
$duplicateLines = @()
foreach ($group in $duplicateGroups) {
    $duplicateLines += ($group.Group.Path -join ' <-> ')
}

$noteLookup = @{}
foreach ($file in $markdownFiles) {
    $relativeWithoutExtension = [IO.Path]::ChangeExtension((Get-RelativePath $file.FullName), $null)
    foreach ($key in @($file.BaseName, $relativeWithoutExtension)) {
        $normalizedKey = $key.Replace('\', '/').ToLowerInvariant()
        if (-not $noteLookup.ContainsKey($normalizedKey)) {
            $noteLookup[$normalizedKey] = [System.Collections.Generic.List[string]]::new()
        }
        $noteLookup[$normalizedKey].Add((Get-RelativePath $file.FullName))
    }
}

$incomingCounts = @{}
$brokenLinks = [System.Collections.Generic.List[string]]::new()
$topicCounts = @{}
foreach ($file in $markdownFiles) {
    $content = Get-Content -Raw -LiteralPath $file.FullName -Encoding utf8
    $sourceRelative = Get-RelativePath $file.FullName
    $isArchived = $sourceRelative.StartsWith('99-Archive/', [StringComparison]::OrdinalIgnoreCase)
    foreach ($match in [regex]::Matches($content, '\[\[(?<target>[^\]|#]+)(?:#[^\]|]+)?(?:\|[^\]]+)?\]\]')) {
        $target = $match.Groups['target'].Value.Trim().Replace('\', '/')
        $targetKey = $target.ToLowerInvariant()
        if ($targetKey.EndsWith('.md')) {
            $targetKey = $targetKey.Substring(0, $targetKey.Length - 3)
        }
        $resolved = $null
        if ($noteLookup.ContainsKey($targetKey)) {
            $resolved = $noteLookup[$targetKey]
        }
        else {
            $baseKey = [IO.Path]::GetFileName($targetKey)
            if ($noteLookup.ContainsKey($baseKey)) { $resolved = $noteLookup[$baseKey] }
        }
        if ($resolved) {
            foreach ($resolvedPath in $resolved) {
                if (-not $incomingCounts.ContainsKey($resolvedPath)) { $incomingCounts[$resolvedPath] = 0 }
                $incomingCounts[$resolvedPath]++
            }
        }
        elseif (-not $isArchived) {
            $brokenLinks.Add((Get-RelativePath $file.FullName) + ' -> ' + $target)
        }
    }
    foreach ($match in [regex]::Matches($content, '(?mi)^\s*-\s+(?<tag>topic/[a-z0-9][a-z0-9_-]*)\s*$')) {
        $tag = $match.Groups['tag'].Value.ToLowerInvariant()
        if (-not $topicCounts.ContainsKey($tag)) { $topicCounts[$tag] = 0 }
        $topicCounts[$tag]++
    }
}

$orphanFiles = @($markdownFiles | Where-Object {
    $relative = Get-RelativePath $_.FullName
    -not $relative.StartsWith('99-Archive/', [StringComparison]::OrdinalIgnoreCase) -and
    -not $incomingCounts.ContainsKey($relative) -and
    $_.BaseName -notmatch '(Index|Hub|Template|Home|Report)$' -and
    $_.Name -notin @('AGENTS.md')
} | ForEach-Object { Get-RelativePath $_.FullName })

$classificationConflicts = [System.Collections.Generic.List[string]]::new()
foreach ($file in $researchFiles) {
    $relativeResearch = $file.FullName.Substring($researchRoot.Length).TrimStart('\')
    $expectedCategory = $relativeResearch.Split('\')[0]
    $content = Get-Content -Raw -LiteralPath $file.FullName -Encoding utf8
    $match = [regex]::Match($content, '(?mi)^\s*category\s*:\s*["'']?(?<category>.*?)["'']?\s*$')
    if (-not $match.Success) {
        $classificationConflicts.Add((Get-RelativePath $file.FullName) + ' -> missing category')
    }
    elseif ($match.Groups['category'].Value.Trim() -ne $expectedCategory) {
        $classificationConflicts.Add(
            (Get-RelativePath $file.FullName) + ' -> folder=' + $expectedCategory +
            ', property=' + $match.Groups['category'].Value.Trim()
        )
    }
}

$score = 100
$score -= [Math]::Min(20, $junkFiles.Count * 5)
$score -= [Math]::Min(15, $duplicateGroups.Count * 5)
$score -= [Math]::Min(20, $classificationConflicts.Count * 5)
$score -= [Math]::Min(15, $abnormalNames.Count * 3)
$score -= [Math]::Min(20, (@($brokenLinks | Sort-Object -Unique).Count * 2))
$score -= [Math]::Min(10, $orphanFiles.Count)
$score = [Math]::Max(0, $score)

$topicLines = if ($topicCounts.Count -eq 0) {
    @('- No research-derived topic frequencies yet.')
}
else {
    @($topicCounts.GetEnumerator() |
        Sort-Object Value -Descending |
        ForEach-Object { '- `' + $_.Key + '`: ' + $_.Value })
}

$report = @(
    '---'
    'type: audit-report'
    'status: complete'
    'generated_at: "' + $generatedAt.ToString('yyyy-MM-dd HH:mm:ss') + '"'
    'score: ' + $score
    'tags:'
    '  - system/audit'
    '---'
    ''
    '# Knowledge Base Audit Report'
    ''
    '> Generated: ' + $generatedAt.ToString('yyyy-MM-dd HH:mm:ss')
    ''
    '## Score'
    ''
    '**' + $score + '/100**'
    ''
    '## Inventory'
    ''
    '- Directories: ' + $directories.Count
    '- Files: ' + $allFiles.Count
    '- Markdown notes: ' + $markdownFiles.Count
    '- Research notes excluding indexes and hubs: ' + $researchFiles.Count
    ''
    '## Duplicate content'
    ''
    (Format-ListSection -Items $duplicateLines)
    ''
    '## Classification conflicts'
    ''
    (Format-ListSection -Items @($classificationConflicts))
    ''
    '## Abnormal filenames'
    ''
    (Format-ListSection -Items $abnormalNames)
    ''
    '## Structurally empty directories'
    ''
    '> Directories containing only `.gitkeep` are listed so intentional placeholders remain visible.'
    ''
    (Format-ListSection -Items $structurallyEmptyDirectories)
    ''
    '## Junk files'
    ''
    (Format-ListSection -Items $junkFiles)
    ''
    '## Orphan notes'
    ''
    '> Approximation based on incoming wikilinks; archives, indexes, hubs, templates, home pages, reports, and AGENTS files are excluded.'
    ''
    (Format-ListSection -Items $orphanFiles)
    ''
    '## Broken internal links'
    ''
    (Format-ListSection -Items @($brokenLinks | Sort-Object -Unique))
    ''
    '## Topic frequency'
    ''
    $topicLines
    ''
    '## Recommended action'
    ''
    $(if ($researchFiles.Count -eq 0) {
        '- Import real research material before creating domain-specific taxonomies or additional Topic Hubs.'
    } else {
        '- Resolve conflicts and broken links, then review high-frequency topics for new or merged Topic Hubs.'
    })
) -join "`n"

Set-Content -LiteralPath $reportPath -Value $report -Encoding utf8
Write-Output "Audit report written: $reportPath"
Write-Output "Score: $score/100"
