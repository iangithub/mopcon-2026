# AI Company  - calculate a deterministic content fingerprint for the explicitly reviewed file scope.
# Read-only by default. -OutFile is optional and never necessary for verification.
# Requires PowerShell 7.4+. Does NOT call Herdr or any agent.
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ProjectRoot,
    [Parameter(Mandatory)][string[]]$ScopePaths,
    [string]$OutFile
)
$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath($ProjectRoot).TrimEnd([char[]]@('\','/'))
if (-not (Test-Path -LiteralPath $root -PathType Container)) { throw "Project root missing: $root" }
$compare = if ($IsWindows) { [StringComparison]::OrdinalIgnoreCase } else { [StringComparison]::Ordinal }
$sep = [IO.Path]::DirectorySeparatorChar
$skip = @('.git','.ai-work','bin','obj','node_modules','.venv','__pycache__','TestResults','.cache','dist')
$seen = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
$all = [System.Collections.Generic.List[object]]::new()
function Assert-SafeScope([string]$Relative) {
    if ([string]::IsNullOrWhiteSpace($Relative)) { throw 'Empty scope path' }
    if ([IO.Path]::IsPathRooted($Relative) -or $Relative -match '(^|[\\/])\.\.([\\/]|$)' -or $Relative -match '^[A-Za-z]+:') {
        throw "Unsafe scope path: $Relative"
    }
    $resolved = [IO.Path]::GetFullPath((Join-Path $root $Relative))
    if (-not $resolved.StartsWith(($root + $sep), $compare)) { throw "Scope path escaped project: $Relative" }
    if (-not (Test-Path -LiteralPath $resolved)) { throw "Scope path missing: $Relative" }
    $cursor = $root
    foreach ($part in ($Relative -split '[\\/]')) {
        if (-not $part -or $part -eq '.') { continue }
        $cursor = Join-Path $cursor $part
        $entry = Get-Item -LiteralPath $cursor -Force
        if (($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { throw "Scope contains a link/reparse point: $cursor" }
    }
    return $resolved
}
foreach ($path in $ScopePaths) {
    $full = Assert-SafeScope $path
    $items = @(Get-Item -LiteralPath $full -Force)
    $explicitFile = -not $items[0].PSIsContainer
    if (-not $explicitFile) {
        $items = @(Get-ChildItem -LiteralPath $full -Recurse -Force -File)
    }
    foreach ($item in $items) {
        if ($item.PSIsContainer) { continue }
        $relative = [IO.Path]::GetRelativePath($root, $item.FullName).Replace('\','/')
        $parts = @($relative -split '/')
        # An explicitly named Spec file inside .ai-work can be hashed;
        # recursive directory scans still omit generated/cache folders.
        if (-not $explicitFile -and @($parts | Where-Object { $_ -in $skip }).Count -gt 0) { continue }
        # Reject ANY reparse point in an included path, even inside recursive directories.
        $cursor = $root
        foreach ($part in $parts) {
            $cursor = Join-Path $cursor $part
            $entry = Get-Item -LiteralPath $cursor -Force
            if (($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { throw "Linked file in snapshot: $cursor" }
        }
        if (-not $seen.Add($relative)) { continue }
        $hash = (Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
        $all.Add([pscustomobject]@{ path=$relative; sha256=('sha256:' + $hash) })
    }
}
if ($all.Count -eq 0) { throw 'No files in explicit snapshot scope; refusing empty fingerprint' }
$entries = @($all | ForEach-Object { "$($_.path)|$($_.sha256)" })
[Array]::Sort($entries, [StringComparer]::Ordinal)
$payload = [string]::Join("`n", $entries) + "`n"
$hashBytes = [Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($payload))
$fingerprint = 'sha256:' + [Convert]::ToHexString($hashBytes).ToLowerInvariant()
$files = @($all | Sort-Object path)
$result = [ordered]@{
    snapshot_version = '1.0'; project_root = $root
    scope_paths = @($ScopePaths); digest = $fingerprint; files = $files
    excluded_generated_directories = @($skip)
}
$json = ConvertTo-Json -InputObject $result -Depth 20
if ($OutFile) {
    if (Test-Path -LiteralPath $OutFile) { throw "Snapshot output already exists: $OutFile" }
    $dest = [IO.Path]::GetFullPath($OutFile)
    $parent = Split-Path -Parent $dest
    if (-not (Test-Path -LiteralPath $parent)) { throw "Create approved output folder first: $parent" }
    [IO.File]::WriteAllText($dest, $json + "`n", [Text.UTF8Encoding]::new($false))
}
$json
