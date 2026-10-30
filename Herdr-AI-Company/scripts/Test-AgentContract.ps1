# AI Company  schema + semantic validation. Does not modify source / call agents / Herdr.
# PS 7.4+ for Test-Json -SchemaFile and SHA256 helpers.
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateSet('Dispatch','Report','Repair')][string]$Type,
    [Parameter(Mandatory)][string]$File,
    [Parameter(Mandatory)][string]$CompanyRoot,
    [Parameter(Mandatory)][string]$ProjectRoot,
    [string]$RepairFile,
    [switch]$SkipCurrentSnapshot
)
$ErrorActionPreference = 'Stop'
$company = [IO.Path]::GetFullPath($CompanyRoot).TrimEnd([char[]]@('\','/'))
$root = [IO.Path]::GetFullPath($ProjectRoot).TrimEnd([char[]]@('\','/'))
$cmp = if ($IsWindows) { [StringComparison]::OrdinalIgnoreCase } else { [StringComparison]::Ordinal }
$sep = [IO.Path]::DirectorySeparatorChar
function Fail([string]$reason) { throw "CONTRACT INVALID [$Type]: $reason" }
function SamePath([string]$a,[string]$b) { return ([IO.Path]::GetFullPath($a).TrimEnd([char[]]@('\','/'))).Equals(([IO.Path]::GetFullPath($b).TrimEnd([char[]]@('\','/'))),$cmp) }
function SafeRel([string]$relative,[string]$base,[bool]$mustExist=$true) {
    if ([string]::IsNullOrWhiteSpace($relative) -or [IO.Path]::IsPathRooted($relative) -or $relative -match '(^|[\\/])\.\.([\\/]|$)' -or $relative -match '^[A-Za-z]+:') { Fail "Unsafe relative path: $relative" }
    $full = [IO.Path]::GetFullPath((Join-Path $base $relative))
    if (-not $full.StartsWith(($base+$sep),$cmp)) { Fail "Path escaped its root: $relative" }
    if ($mustExist -and -not (Test-Path -LiteralPath $full)) { Fail "Path not found: $relative" }
    $cur = $base
    foreach ($part in ($relative -split '[\\/]')) {
        if (-not $part -or $part -eq '.') { continue }
        $cur = Join-Path $cur $part
        if (-not (Test-Path -LiteralPath $cur)) {
            if ($mustExist) { Fail "Missing path segment: $cur" }
            break
        }
        $item = Get-Item -LiteralPath $cur -Force
        if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { Fail "Reparse-point path not supported: $cur" }
    }
    return $full
}
function HashOf([string]$filePath) { return 'sha256:'+(Get-FileHash -LiteralPath $filePath -Algorithm SHA256).Hash.ToLowerInvariant() }
function ProjectDepartment {
    $agents = Join-Path $root 'AGENTS.md'
    if (-not (Test-Path -LiteralPath $agents)) { Fail 'ProjectRoot/AGENTS.md missing' }
    $txt = Get-Content -LiteralPath $agents -Raw -Encoding UTF8
    $matches = [regex]::Matches($txt,'(?m)^Department:\s*(software|writing)\s*$')
    if ($matches.Count -ne 1) { Fail 'Department must appear exactly once' }
    return $matches[0].Groups[1].Value
}
function CheckDepartment([System.Collections.IDictionary]$x) {
    if ((ProjectDepartment) -ne $x.owner_department) { Fail 'Owner Department is inconsistent with actual AGENTS.md' }
    $guest = ($x.owner_department -ne $x.assigned_department)
    if ($guest -ne ($x.delegation_mode -eq 'guest-support')) { Fail 'DelegationMode is inconsistent with Owner/Assigned departments' }
    if ($guest -and [string]::IsNullOrWhiteSpace([string]$x.delegation_id)) { Fail 'Guest task needs DelegationId' }
    if (-not $guest -and $null -ne $x.delegation_id) { Fail 'Owner task must have null DelegationId' }
}
function CheckSnapshot($scopePaths,[string]$digest) {
    if ($SkipCurrentSnapshot) { return }
    $script = Join-Path $company 'scripts/Get-ScopeSnapshot.ps1'
    $json = & $script -ProjectRoot $root -ScopePaths @($scopePaths)
    $current = $json | ConvertFrom-Json -AsHashtable
    if ($current.digest -cne $digest) { Fail "STALE SNAPSHOT: expected $digest, current $($current.digest). Re-run test/review." }
}
if (-not (Test-Path -LiteralPath $File -PathType Leaf)) { Fail "Contract file missing: $File" }
if (-not (Test-Path -LiteralPath $company -PathType Container)) { Fail 'CompanyRoot is invalid' }
$names = @{ Dispatch='task-dispatch'; Report='worker-report'; Repair='repair-request' }
$schema = Join-Path $company ("contracts/schemas/$($names[$Type]).schema.json")
$json = Get-Content -LiteralPath $File -Raw -Encoding UTF8
if (-not (Test-Json -Json $json -SchemaFile $schema -ErrorAction Stop)) { Fail "JSON Schema failed: $schema" }
$x = $json | ConvertFrom-Json -AsHashtable
CheckDepartment $x
if ($Type -eq 'Dispatch') {
    if (-not (SamePath $x.project_root $root)) { Fail 'Dispatch ProjectRoot mismatches actual ProjectRoot' }
    if (-not (SamePath $x.company_root $company)) { Fail 'Dispatch CompanyRoot mismatches actual CompanyRoot' }
    $catalog = (Get-Content -LiteralPath (Join-Path $company 'contracts/worker-requirements.json') -Raw | ConvertFrom-Json -AsHashtable)
    if (-not $catalog.workers.Contains($x.worker_skill)) { Fail "Unknown WorkerSkill: $($x.worker_skill)" }
    $readonly=@('software-code-review','software-repo-scout','writing-editor','writing-fact-check','writing-proofreader')
    if ($x.worker_skill -in $readonly -and @($x.allowed_write_paths).Count -gt 0) { Fail 'Read-only reviewer dispatch cannot contain writable paths' }
    foreach ($p in @($x.spec_paths)+@($x.input_report_paths)) { [void](SafeRel $p $root $true) }
    foreach ($p in @($x.allowed_write_paths)) { [void](SafeRel $p $root $false) }
    foreach ($p in @($x.allowed_read_paths)) { if ($p -ne '.') { [void](SafeRel $p $root $false) } }
    $reportTarget=SafeRel $x.report_path $root $false
    $approvedReports=[IO.Path]::GetFullPath((Join-Path $root ('.ai-work/runs/'+$x.run_id))).TrimEnd([char[]]@('\','/'))
    if (-not $reportTarget.StartsWith(($approvedReports+$sep),$cmp)) { Fail 'Report path must be within this run .ai-work/runs/<run_id>/' }
    foreach ($p in @($x.snapshot.scope_paths)) { [void](SafeRel $p $root $true) }
    CheckSnapshot $x.snapshot.scope_paths $x.snapshot.digest
}
elseif ($Type -eq 'Report') {
    if (-not (SamePath $x.scope.project_root $root)) { Fail 'Report ProjectRoot mismatches actual project' }
    if ($x.status -ne 'BLOCKED') {
        if ($null -eq $x.scope.snapshot_digest) { Fail 'Non-BLOCKED report requires a real snapshot digest' }
        CheckSnapshot $x.scope.scope_paths $x.scope.snapshot_digest
    }
    $catalog = (Get-Content -LiteralPath (Join-Path $company 'contracts/worker-requirements.json') -Raw | ConvertFrom-Json -AsHashtable)
    if (-not $catalog.workers.Contains($x.worker_skill)) { Fail "Unknown WorkerSkill: $($x.worker_skill)" }
    $req = $catalog.workers[$x.worker_skill]
    $agents = Get-Content -LiteralPath (Join-Path $root 'AGENTS.md') -Raw -Encoding UTF8
    $sectionMatch = [regex]::Match($agents,'(?ms)^## Rule Registry\s*\r?\n(.*?)(?=^## |\z)')
    if (-not $sectionMatch.Success) { Fail 'Missing Rule Registry' }
    $registry = @{}
    foreach ($line in ($sectionMatch.Groups[1].Value -split '\r?\n')) {
        $r = [regex]::Match($line,'^\|\s*((?:software|writing)\.[a-z-]+)\s*\|\s*([^|]+?)\s*\|\s*$')
        if (-not $r.Success) { continue }
        $key = $r.Groups[1].Value.Trim()
        if ($registry.ContainsKey($key)) { Fail "Duplicate Rule Key: $key" }
        $registry[$key] = $r.Groups[2].Value.Trim()
    }
    $seenKeys = @{}
    foreach ($rule in $x.loaded_rules) {
        $key = [string]$rule.key
        if ($seenKeys.ContainsKey($key)) { Fail "Duplicate loaded Rule: $key" }
        $seenKeys[$key] = $true
        if (-not $registry.ContainsKey($key)) { Fail "Loaded undeclared Rule Key: $key" }
        if ($registry[$key] -cne $rule.path) { Fail "Rule path disagrees with Registry for $key" }
        $path = SafeRel $rule.path $root $true
        if ((HashOf $path) -cne $rule.sha256) { Fail "Rule SHA-256 mismatch for $key" }
        $body = Get-Content -LiteralPath $path -Raw -Encoding UTF8
        foreach ($rid in $rule.rule_ids) { if (-not $body.Contains($rid)) { Fail "Declared Rule ID $rid not found in $($rule.path)" } }
    }
    if ($x.status -ne 'BLOCKED') {
      foreach ($key in $req.required_rule_keys) { if (-not $seenKeys.ContainsKey($key)) { Fail "Required Rule not loaded: $key" } }
    }
    $seenMethods = @{}
    foreach ($m in $x.method_references) {
        if ($seenMethods.ContainsKey($m.path)) { Fail "Duplicate Method Reference: $($m.path)" }
        $seenMethods[$m.path] = $true
        $base = Join-Path $company ('.agents/skills/' + $x.worker_skill)
        $p = SafeRel $m.path $base $true
        if ((HashOf $p) -cne $m.sha256) { Fail "Method hash mismatch: $($m.path)" }
    }
    if ($x.status -ne 'BLOCKED') {
      foreach ($p in $req.method_references) { if (-not $seenMethods.ContainsKey($p)) { Fail "Required Method Reference missing: $p" } }
    }
    $ids=@{}
    foreach ($f in $x.findings) {
        if ($ids.ContainsKey($f.id)) { Fail "Duplicate Finding ID: $($f.id)" }
        $ids[$f.id]=$true
        if (-not $seenKeys.ContainsKey($f.rule_key)) { Fail "Finding rule key not loaded: $($f.id)" }
        $ruleItem=@($x.loaded_rules | Where-Object { $_.key -eq $f.rule_key })[0]
        if ($f.rule_id -notin $ruleItem.rule_ids) { Fail "Finding references undeclared Rule ID: $($f.id)" }
    }
    if ($RepairFile) {
        & $PSCommandPath -Type Repair -File $RepairFile -CompanyRoot $company -ProjectRoot $root | Out-Null
        $repairJson=Get-Content -LiteralPath $RepairFile -Raw -Encoding UTF8
        $repairSchema=Join-Path $company 'contracts/schemas/repair-request.schema.json'
        if (-not (Test-Json -Json $repairJson -SchemaFile $repairSchema -ErrorAction Stop)) { Fail 'Referenced Repair JSON is invalid' }
        $rp=$repairJson | ConvertFrom-Json -AsHashtable
        if ($x.worker_skill -cne $rp.target_worker_skill -or $x.run_id -cne $rp.run_id -or $x.task_id -cne $rp.task_id -or $x.attempt -ne $rp.attempt) { Fail 'Coding/Writer response does not match Repair attempt and target WorkerSkill' }
        $expectedIds=@($rp.findings | ForEach-Object { $_.id })
        $gotIds=@($x.fixes | ForEach-Object { $_.finding_id })
        if ($expectedIds.Count -ne $gotIds.Count) { Fail 'Repair response must address every original blocking Finding ID' }
        foreach ($expected in $expectedIds) {
          $count=@($gotIds | Where-Object { $_ -ceq $expected }).Count
          if ($count -ne 1) { Fail "Repair response missing or duplicated original Finding ID: $expected" }
        }
        if ($x.status -eq 'PASS' -and @($x.fixes | Where-Object { $_.resolution -ne 'FIXED' }).Count -gt 0) { Fail 'Repair response claims PASS with unresolved Findings' }
    }
    foreach ($v in $x.verification) {
        if ($v.result -eq 'PASS' -and ($v.exit_code -ne 0 -or [string]::IsNullOrWhiteSpace([string]$v.evidence_path))) { Fail 'Verification PASS must have exit 0 and a log path' }
        if ($v.result -eq 'PASS') { [void](SafeRel $v.evidence_path $root $true) }
        if ($v.result -eq 'NOT_RUN' -and $null -ne $v.exit_code) { Fail 'NOT_RUN must not invent an exit code' }
    }
    $verificationFailed=@($x.verification | Where-Object { $_.result -eq 'FAIL' }).Count
    $blocking=@($x.findings | Where-Object { $_.severity -eq 'BLOCKING' }).Count
    $failed=@($x.checks | Where-Object { $_.result -eq 'FAIL' }).Count
    $blocked=@($x.checks | Where-Object { $_.result -eq 'BLOCKED' }).Count
    if ($x.status -eq 'PASS') {
        if ($blocking -gt 0 -or $failed -gt 0 -or $blocked -gt 0 -or $verificationFailed -gt 0) { Fail 'PASS cannot coexist with blocking findings, failed checks or failed verification commands' }
        if (@($x.checks | Where-Object { $_.result -eq 'PASS' }).Count -eq 0) { Fail 'PASS requires at least one positive check' }
        if ($x.worker_skill -eq 'software-unit-test') {
            $passed=@($x.verification | Where-Object { $_.result -eq 'PASS' -and $_.exit_code -eq 0 -and -not [string]::IsNullOrWhiteSpace($_.evidence_path) })
            if ($passed.Count -eq 0) { Fail 'Unit Test PASS requires executed command, exit code 0, evidence path' }
            foreach ($v in $passed) { [void](SafeRel $v.evidence_path $root $true) }
        }
    }
    if ($x.status -eq 'FAIL' -and $blocking -eq 0 -and $failed -eq 0 -and $verificationFailed -eq 0) { Fail 'FAIL without blocking finding or failed check/command' }
    if ($x.status -eq 'BLOCKED' -and @($x.limitations).Count -eq 0 -and $blocked -eq 0) { Fail 'BLOCKED needs a limitation or blocked check' }
    if ($x.status -eq 'UNVERIFIED' -and @($x.limitations).Count -eq 0) { Fail 'UNVERIFIED needs explicit limitations' }
}
else {
    if (-not (SamePath $x.project_root $root)) { Fail 'Repair project root mismatch' }
    if ($x.target_worker_skill -eq 'software-coding' -and $x.assigned_department -ne 'software') { Fail 'Software repair requested from a non-software department' }
    if ($x.target_worker_skill -eq 'writing-writer' -and $x.assigned_department -ne 'writing') { Fail 'Writing repair requested from a non-writing department' }
    $dispatchSource=SafeRel $x.source_dispatch.path $root $true
    if ((HashOf $dispatchSource) -cne $x.source_dispatch.sha256) { Fail 'Original dispatch hash changed' }
    & $PSCommandPath -Type Dispatch -File $dispatchSource -CompanyRoot $company -ProjectRoot $root -SkipCurrentSnapshot | Out-Null
    $oldDispatch=Get-Content -LiteralPath $dispatchSource -Raw -Encoding UTF8 | ConvertFrom-Json -AsHashtable
    $originalWrite=ConvertTo-Json -InputObject @($oldDispatch.allowed_write_paths) -Compress
    $repairWrite=ConvertTo-Json -InputObject @($x.allowed_write_paths) -Compress
    if ($originalWrite -cne $repairWrite) { Fail 'Repair modified original allowed-write paths' }
    $originalCriteria=ConvertTo-Json -InputObject @($oldDispatch.acceptance_criteria) -Compress
    $repairCriteria=ConvertTo-Json -InputObject @($x.acceptance_criteria) -Compress
    if ($originalCriteria -cne $repairCriteria) { Fail 'Repair modified original acceptance criteria' }
    if ($oldDispatch.run_id -ne $x.run_id -or $oldDispatch.task_id -ne $x.task_id) { Fail 'Repair and Dispatch task identity mismatch' }
    $src = SafeRel $x.source_report.path $root $true
    if ((HashOf $src) -cne $x.source_report.sha256) { Fail 'Original review report hash changed' }
    $originalJson=Get-Content -LiteralPath $src -Raw -Encoding UTF8
    $orig=$originalJson | ConvertFrom-Json -AsHashtable
    if ($orig.status -ne 'FAIL' -or $orig.run_id -ne $x.run_id -or $orig.task_id -ne $x.task_id) { Fail 'Repair does not refer to matching FAIL source' }
    if ($orig.scope.snapshot_digest -cne $x.source_report.snapshot_digest) { Fail 'Source report snapshot digest mismatch' }
    if ($orig.worker_skill -cne $x.source_report.worker_skill) { Fail 'Source WorkerSkill mismatch' }
    if ($orig.attempt + 1 -ne $x.attempt) { Fail 'Repair attempt must be source report attempt + 1' }
    $sourceFindings=@($orig.findings | Where-Object { $_.severity -eq 'BLOCKING' })
    if ($sourceFindings.Count -eq 0) { Fail 'No blocking findings to repair' }
    $a=ConvertTo-Json -InputObject $sourceFindings -Depth 30 -Compress
    $b=ConvertTo-Json -InputObject @($x.findings) -Depth 30 -Compress
    if ($a -cne $b) { Fail 'Findings were paraphrased, dropped or reordered; must copy original blocking finding objects' }
}
Write-Host "VALID $Type $($x.task_id) $($x.message_type) $($x.status)"
