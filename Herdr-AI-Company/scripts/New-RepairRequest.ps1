# Generate an exact, auditable repair request from a validated FAIL review report.
# NO LLM paraphrase. This only writes an authorized repair-request JSON, never source code.
[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$SourceReport,
  [Parameter(Mandatory)][string]$DispatchFile,
  [Parameter(Mandatory)][string]$CompanyRoot,
  [Parameter(Mandatory)][string]$ProjectRoot,
  [Parameter(Mandatory)][string]$OutFile,
  [Parameter(Mandatory)][ValidateSet('software-coding','writing-writer')][string]$TargetWorkerSkill
)
$ErrorActionPreference='Stop'
$root=[IO.Path]::GetFullPath($ProjectRoot).TrimEnd([char[]]@('\','/'))
$full=[IO.Path]::GetFullPath($OutFile)
$approvedBase=[IO.Path]::GetFullPath((Join-Path $root '.ai-work/runs')).TrimEnd([char[]]@('\','/'))
$cmp=if($IsWindows){[StringComparison]::OrdinalIgnoreCase}else{[StringComparison]::Ordinal}
if(-not $full.StartsWith($approvedBase+[IO.Path]::DirectorySeparatorChar,$cmp)) {throw 'OutFile must be inside ProjectRoot/.ai-work/runs/'}
if(Test-Path -LiteralPath $full){throw 'Refusing to overwrite an existing repair request'}
if(-not (Test-Path -LiteralPath (Split-Path -Parent $full) -PathType Container)) {throw 'Create approved run folder before writing'}
& (Join-Path $CompanyRoot 'scripts/Test-AgentContract.ps1') -Type Report -File $SourceReport -CompanyRoot $CompanyRoot -ProjectRoot $root
& (Join-Path $CompanyRoot 'scripts/Test-AgentContract.ps1') -Type Dispatch -File $DispatchFile -CompanyRoot $CompanyRoot -ProjectRoot $root -SkipCurrentSnapshot
$report=Get-Content -LiteralPath $SourceReport -Raw -Encoding UTF8 | ConvertFrom-Json -AsHashtable
$dispatch=Get-Content -LiteralPath $DispatchFile -Raw -Encoding UTF8 | ConvertFrom-Json -AsHashtable
if($report.status -ne 'FAIL'){throw 'Original reviewer report is not FAIL'}
if($report.run_id -ne $dispatch.run_id -or $report.task_id -ne $dispatch.task_id){throw 'Report/Dispatch task identity mismatch'}
if($report.owner_department -ne $dispatch.owner_department -or $report.delegation_id -ne $dispatch.delegation_id){throw 'Owner or Delegation identity mismatch'}
$findings=@($report.findings | Where-Object { $_.severity -eq 'BLOCKING' })
if($findings.Count -eq 0){throw 'FAIL has no BLOCKING findings to send for repair'}
$sourceFull=[IO.Path]::GetFullPath($SourceReport)
if(-not $sourceFull.StartsWith($root+[IO.Path]::DirectorySeparatorChar,$cmp)){throw 'Source report outside ProjectRoot'}
$relative=[IO.Path]::GetRelativePath($root,$sourceFull).Replace('\','/')
$digest='sha256:'+(Get-FileHash -LiteralPath $sourceFull -Algorithm SHA256).Hash.ToLowerInvariant()
$dispatchFull=[IO.Path]::GetFullPath($DispatchFile)
if(-not $dispatchFull.StartsWith($root+[IO.Path]::DirectorySeparatorChar,$cmp)){throw 'Source dispatch outside ProjectRoot'}
$dispatchRelative=[IO.Path]::GetRelativePath($root,$dispatchFull).Replace('\','/')
$dispatchDigest='sha256:'+(Get-FileHash -LiteralPath $dispatchFull -Algorithm SHA256).Hash.ToLowerInvariant()
$next=[ordered]@{
 contract_version='1.0';message_type='repair_request';run_id=$report.run_id;task_id=$report.task_id
 attempt=([int]$report.attempt+1);project_root=$root
 owner_department=$report.owner_department;assigned_department=$report.assigned_department
 delegation_mode=$report.delegation_mode;delegation_id=$report.delegation_id
 target_worker_skill=$TargetWorkerSkill
 source_dispatch=[ordered]@{path=$dispatchRelative;sha256=$dispatchDigest}
 source_report=[ordered]@{path=$relative;sha256=$digest;status='FAIL';snapshot_digest=$report.scope.snapshot_digest;worker_skill=$report.worker_skill}
 findings=$findings;allowed_write_paths=@($dispatch.allowed_write_paths)
 acceptance_criteria=@($dispatch.acceptance_criteria);handoff_to='owner-manager'
}
if($next.allowed_write_paths.Count -eq 0) {throw 'Original dispatch had no writable paths for a repair task'}
$raw=ConvertTo-Json -InputObject $next -Depth 50
# Validate before write by reading the schema directly; semantic validation is repeated after save.
$schema=Join-Path $CompanyRoot 'contracts/schemas/repair-request.schema.json'
if(-not (Test-Json -Json $raw -SchemaFile $schema -ErrorAction Stop)){throw 'Repair request JSON schema failed'}
[IO.File]::WriteAllText($full,$raw+"`n",[Text.UTF8Encoding]::new($false))
try {
 & (Join-Path $CompanyRoot 'scripts/Test-AgentContract.ps1') -Type Repair -File $full -CompanyRoot $CompanyRoot -ProjectRoot $root
} catch {
 Remove-Item -LiteralPath $full -Force
 throw
}
Write-Host "CREATED exact repair request: $full; copied $($findings.Count) BLOCKING findings"
