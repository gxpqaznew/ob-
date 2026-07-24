[CmdletBinding()]
param(
    [string]$VaultPath,
    [switch]$Promote,
    [switch]$Overwrite
)

$ErrorActionPreference = 'Stop'
if (-not $VaultPath) { $VaultPath = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path }
$downloadedPath = Join-Path $VaultPath '00-收件箱\已下载'
$cleanedPath = Join-Path $VaultPath '00-收件箱\已清洗'
$researchPath = Join-Path $VaultPath '04-研究'
$taxonomyPath = Join-Path $VaultPath '98-AI-上下文\研究分类.json'
$graphScript = Join-Path $PSScriptRoot '更新知识图谱.ps1'

function Get-FrontmatterBlock {
    param([string]$Text)
    $match = [regex]::Match($Text, '(?s)\A---\s*\r?\n(?<frontmatter>.*?)\r?\n---\s*(?:\r?\n)?')
    if ($match.Success) { return $match }
    return $null
}

function Get-FrontmatterValue {
    param([string]$Frontmatter, [string[]]$Names)
    foreach ($name in $Names) {
        $pattern = '(?mi)^\s*' + [regex]::Escape($name) + '\s*:\s*["'']?(?<value>.*?)["'']?\s*$'
        $match = [regex]::Match($Frontmatter, $pattern)
        if ($match.Success -and $match.Groups['value'].Value.Trim()) {
            return $match.Groups['value'].Value.Trim()
        }
    }
    return $null
}

function ConvertTo-SafeFileName {
    param([string]$Name)
    $safe = $Name
    foreach ($character in [IO.Path]::GetInvalidFileNameChars()) {
        $safe = $safe.Replace([string]$character, '-')
    }
    $safe = ($safe -replace '\s+', ' ').Trim().TrimEnd('.')
    if ($safe.Length -gt 100) { $safe = $safe.Substring(0, 100).Trim() }
    if (-not $safe) { $safe = '未命名研究' }
    return $safe
}

function ConvertTo-YamlString {
    param([string]$Value)
    if ($null -eq $Value) { return '""' }
    return '"' + ($Value.Replace('\', '\\').Replace('"', '\"').Replace("`r", '').Replace("`n", ' ')) + '"'
}

function Format-MarkdownConservatively {
    param([string]$Body)
    $lines = $Body -split "\r?\n"
    $result = [System.Collections.Generic.List[string]]::new()
    $inCodeBlock = $false

    foreach ($originalLine in $lines) {
        $line = $originalLine.TrimEnd()
        if ($line -match '^\s*```') {
            $inCodeBlock = -not $inCodeBlock
            $result.Add($line)
            continue
        }
        if ($inCodeBlock) {
            $result.Add($line)
            continue
        }

        if ($line -match '^\s*\u3010(?<heading>[^\u3011]+)\u3011\s*$') {
            $line = '## ' + ([string]$Matches.heading).Trim()
        }
        elseif ($line -match '^\s*(?<number>[\u4e00\u4e8c\u4e09\u56db\u4e94\u516d\u4e03\u516b\u4e5d\u5341\u767e]+)[\u3001\uff0e.]\s*(?<text>.+)$') {
            $line = '## ' + ([string]$Matches.number) + ([char]0x3001) + ([string]$Matches.text).Trim()
        }
        elseif ($line -match '^\s*(?<number>\d+)[\u3001)]\s*(?<text>.+)$') {
            $line = ([string]$Matches.number) + '. ' + ([string]$Matches.text).Trim()
        }
        elseif ($line -match '^\s*[\u2022\u00b7]\s*(?<text>.+)$') {
            $line = '- ' + ([string]$Matches.text).Trim()
        }

        $isStructure = $line -match '^\s*(#{1,6}\s|[-*+]\s|\d+\.\s|>|```|\|)'
        if (-not $isStructure -and $line.Length -gt 180) {
            $segments = [regex]::Split($line, '(?<=[\u3002\uff01\uff1f!?])(?=\S)')
            foreach ($segment in $segments) {
                if ($segment) { $result.Add($segment) }
            }
        }
        else {
            $result.Add($line)
        }
    }

    $output = [System.Collections.Generic.List[string]]::new()
    for ($index = 0; $index -lt $result.Count; $index++) {
        $line = $result[$index]
        $isHeading = $line -match '^#{1,6}\s'
        if ($isHeading -and $output.Count -gt 0 -and $output[$output.Count - 1] -ne '') {
            $output.Add('')
        }
        $output.Add($line)
        if ($isHeading -and $index + 1 -lt $result.Count -and $result[$index + 1] -ne '') {
            $output.Add('')
        }
    }
    return (($output -join "`n") -replace "`n{3,}", "`n`n").Trim()
}

if (-not (Test-Path -LiteralPath $taxonomyPath)) {
    throw "未找到研究分类配置：$taxonomyPath"
}

$taxonomy = Get-Content -Raw -LiteralPath $taxonomyPath -Encoding utf8 | ConvertFrom-Json
New-Item -ItemType Directory -Path $cleanedPath -Force | Out-Null
$sourceFiles = Get-ChildItem -LiteralPath $downloadedPath -File -Filter '*.md' |
    Where-Object { $_.Name -ne '.gitkeep' }

if (-not $sourceFiles) {
    Write-Output '00-收件箱/已下载 中没有 Markdown 文件。'
    exit 0
}

$processed = 0
$skipped = 0

foreach ($file in $sourceFiles) {
    $raw = Get-Content -Raw -LiteralPath $file.FullName -Encoding utf8
    $frontmatterMatch = Get-FrontmatterBlock -Text $raw
    $frontmatter = if ($frontmatterMatch) { $frontmatterMatch.Groups['frontmatter'].Value } else { '' }
    $body = if ($frontmatterMatch) { $raw.Substring($frontmatterMatch.Length) } else { $raw }

    $title = Get-FrontmatterValue -Frontmatter $frontmatter -Names @('title', 'source_title')
    if (-not $title) {
        $headingMatch = [regex]::Match($body, '(?m)^\s*#\s+(?<title>.+?)\s*$')
        if ($headingMatch.Success) { $title = $headingMatch.Groups['title'].Value.Trim() }
    }
    if (-not $title) { $title = $file.BaseName }

    $sourceUrl = Get-FrontmatterValue -Frontmatter $frontmatter -Names @('source_url', 'url', 'source')
    if (-not $sourceUrl) {
        $urlMatch = [regex]::Match($raw, 'https?://[^\s\)>\]"]+')
        if ($urlMatch.Success) { $sourceUrl = $urlMatch.Value.TrimEnd('.', ',', ';') }
    }
    $author = Get-FrontmatterValue -Frontmatter $frontmatter -Names @('source_author', 'author', 'by')
    $published = Get-FrontmatterValue -Frontmatter $frontmatter -Names @('source_published', 'published', 'date')
    $capturedAt = Get-FrontmatterValue -Frontmatter $frontmatter -Names @('captured_at', 'captured', 'created')
    if (-not $capturedAt) { $capturedAt = $file.CreationTime.ToString('yyyy-MM-dd HH:mm') }

    $category = $taxonomy.defaultCategory
    foreach ($candidate in $taxonomy.categories) {
        foreach ($keyword in $candidate.keywords) {
            if ($keyword -and $raw -match [regex]::Escape([string]$keyword)) {
                $category = [string]$candidate.name
                break
            }
        }
        if ($category -eq [string]$candidate.name -and $candidate.keywords.Count -gt 0) { break }
    }

    $topicMatches = [System.Collections.Generic.List[object]]::new()
    foreach ($topic in $taxonomy.topics) {
        foreach ($keyword in $topic.keywords) {
            if ($keyword -and $raw -match [regex]::Escape([string]$keyword)) {
                $topicMatches.Add($topic)
                break
            }
        }
    }

    $safeTitle = ConvertTo-SafeFileName -Name $title
    $fileDate = $file.CreationTime.ToString('yyyy-MM-dd')
    $destinationRoot = if ($Promote) { Join-Path $researchPath $category } else { $cleanedPath }
    New-Item -ItemType Directory -Path $destinationRoot -Force | Out-Null
    $destination = Join-Path $destinationRoot ($fileDate + ' - ' + $safeTitle + '.md')
    if ((Test-Path -LiteralPath $destination) -and -not $Overwrite) {
        Write-Warning "已跳过现有文件：$destination"
        $skipped++
        continue
    }

    $tagLines = @('  - research')
    foreach ($topic in $topicMatches) { $tagLines += '  - topic/' + $topic.slug }
    $hubLines = @()
    foreach ($topic in $topicMatches) {
        $hubLines += '- [[04-研究/主题中心/' + $topic.hub + '|' + $topic.hub + ']]'
    }
    if (-not $hubLines) { $hubLines = @('- 暂未匹配主题，请手动分拣。') }

    $formattedBody = Format-MarkdownConservatively -Body $body
    $sourceHash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    $relativeSource = $file.FullName.Substring($VaultPath.Length).TrimStart('\').Replace('\', '/')

    $output = @(
        '---'
        'title: ' + (ConvertTo-YamlString $title)
        'type: research'
        'status: cleaned'
        'category: ' + (ConvertTo-YamlString $category)
        'source_url: ' + (ConvertTo-YamlString $sourceUrl)
        'source_author: ' + (ConvertTo-YamlString $author)
        'source_published: ' + (ConvertTo-YamlString $published)
        'captured_at: ' + (ConvertTo-YamlString $capturedAt)
        'cleaned_at: ' + (ConvertTo-YamlString (Get-Date -Format 'yyyy-MM-dd HH:mm'))
        'source_file: ' + (ConvertTo-YamlString $relativeSource)
        'source_sha256: ' + (ConvertTo-YamlString $sourceHash)
        'tags:'
        $tagLines
        '---'
        ''
        '# ' + $title
        ''
        '> [!source]'
        '> **网址：** ' + $(if ($sourceUrl) { $sourceUrl } else { '未检测到' })
        '> **作者：** ' + $(if ($author) { $author } else { '未检测到' })
        '> **发布时间：** ' + $(if ($published) { $published } else { '未检测到' })
        '> **Captured:** ' + $capturedAt
        '> **原始来源：** `' + $relativeSource + '`'
        '> **SHA-256:** `' + $sourceHash + '`'
        ''
        '> [!important] 原文保护'
        '> 原始文件在 `00-收件箱/已下载` 中保持不变。本副本只规范 Markdown 结构和换行，不总结、删除或改写原始内容。'
        ''
        '## 主题中心'
        ''
        $hubLines
        ''
        '## 原始内容'
        ''
        $formattedBody
        ''
    ) -join "`n"

    Set-Content -LiteralPath $destination -Value $output -Encoding utf8
    Write-Output "已创建：$destination"
    $processed++
}

if ($Promote -and (Test-Path -LiteralPath $graphScript)) {
    & $graphScript -VaultPath $VaultPath
}

Write-Output "已处理：$processed；已跳过：$skipped；原始资料变更：0。"
