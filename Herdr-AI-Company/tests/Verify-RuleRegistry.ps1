# Read-only project Rule Registry verifier; no Herdr calls or file modifications.
param(
  [Parameter(Mandatory=$true)][string]$ProjectRoot
)
$ErrorActionPreference = 'Stop'
$ProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot).TrimEnd([char[]]@('\','/'))
$AgentsFile = Join-Path $ProjectRoot 'AGENTS.md'
if (-not (Test-Path -LiteralPath $AgentsFile)) { throw "Project AGENTS.md missing: $AgentsFile" }
$Body = Get-Content -LiteralPath $AgentsFile -Raw -Encoding utf8
$DeptMatches = [regex]::Matches($Body, '(?m)^Department:\s*(software|writing)\s*$')
if ($DeptMatches.Count -ne 1) { throw 'Expected exactly one Department: software|writing line' }
$Dept = $DeptMatches[0].Groups[1].Value

$Header = [regex]::Match($Body, '(?m)^## Rule Registry\s*$')
if (-not $Header.Success) { throw 'Missing "## Rule Registry" heading' }
$SectionStart = $Header.Index + $Header.Length
$Remaining = $Body.Substring($SectionStart)
$NextHeader = [regex]::Match($Remaining, '(?m)^##\s+')
if ($NextHeader.Success) { $Remaining = $Remaining.Substring(0, $NextHeader.Index) }
$Entries = @{}
$PathSeparator = [System.IO.Path]::DirectorySeparatorChar
foreach ($Line in ($Remaining -split '\r?\n')) {
  $Row = [regex]::Match($Line, '^\|\s*((?:software|writing)\.[a-z-]+)\s*\|\s*([^|]+?)\s*\|\s*$')
  if (-not $Row.Success) { continue }
  $Key = $Row.Groups[1].Value.Trim()
  $Rel = $Row.Groups[2].Value.Trim()
  if ($Entries.ContainsKey($Key)) { throw "Duplicate Rule Registry Key: $Key" }
  if ([System.IO.Path]::IsPathRooted($Rel)) { throw "Absolute Rule path is not allowed: $Key -> $Rel" }
  if ($Rel -match '(^|[\\/])\.\.([\\/]|$)' -or $Rel -match '^[a-zA-Z]+://' -or $Rel -notmatch '\.md$') {
    throw "Invalid Rule Registry path: $Key -> $Rel"
  }
  $Full = [System.IO.Path]::GetFullPath((Join-Path $ProjectRoot $Rel))
  if (-not $Full.StartsWith($ProjectRoot + $PathSeparator, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Rule path escaped project root: $Key -> $Rel"
  }
  if (-not (Test-Path -LiteralPath $Full -PathType Leaf)) { throw "Rule file not found: $Key -> $Full" }
  # 防止專案內檔案或子目錄藉 Junction/Symlink 指向其他 Workspace。
  # 專案根本身視為管理員提供的可信 ProjectRoot；檢查根以下每一層。
  $Cursor = $ProjectRoot
  foreach ($Part in ($Rel -split '[\\/]')) {
    if (-not $Part -or $Part -eq '.') { continue }
    $Cursor = Join-Path $Cursor $Part
    $Item = Get-Item -LiteralPath $Cursor -Force -ErrorAction Stop
    if (($Item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
      throw "Rule path contains Junction/Symlink (reparse point): $Key -> $Cursor"
    }
  }
  $RuleBody = Get-Content -LiteralPath $Full -Raw -Encoding utf8
  if ([string]::IsNullOrWhiteSpace($RuleBody)) { throw "Empty Rule file: $Key -> $Full" }
  $Hash = (Get-FileHash -LiteralPath $Full -Algorithm SHA256).Hash
  $Entries[$Key] = $Full
  Write-Host "PASS $Key -> $Rel SHA256:$Hash"
}

$Required = if ($Dept -eq 'software') {
  @('software.architecture','software.coding','software.testing','software.review','software.security')
} else {
  @('writing.style','writing.editorial','writing.facts','writing.sources','writing.proofreading')
}
# Optional Book-A guest support: if any software rule declared, require ALL five.
if ($Dept -eq 'writing' -and @($Entries.Keys | Where-Object { $_ -like 'software.*' }).Count -gt 0) {
  $Required += @('software.architecture','software.coding','software.testing','software.review','software.security')
}
foreach ($Key in $Required) {
  if (-not $Entries.ContainsKey($Key)) { throw "Missing required Rule Registry key: $Key" }
}
Write-Host "PASS Rule Registry: Department=$Dept; $($Entries.Count) keys."
Write-Host 'NOTICE: This verifies file paths/content only. It does not prove agents actually loaded the Rules or that paths enforce OS ACLs.'
