# Final gate for a single frozen artifact scope. Read-only, deterministic.
# Every required Worker report MUST be valid, PASS, and point at the same CURRENT snapshot.
[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$CompanyRoot,
  [Parameter(Mandatory)][string]$ProjectRoot,
  [Parameter(Mandatory)][string[]]$ReportFiles,
  [Parameter(Mandatory)][string[]]$RequiredWorkerSkills
)
$ErrorActionPreference='Stop'
if($ReportFiles.Count -eq 0 -or $RequiredWorkerSkills.Count -eq 0) {throw 'Specify reports and required skills'}
$done=@{}
$identity=$null
$fp=$null
$scopePaths=$null
foreach($file in $ReportFiles){
 & (Join-Path $CompanyRoot 'scripts/Test-AgentContract.ps1') -Type Report -File $file -CompanyRoot $CompanyRoot -ProjectRoot $ProjectRoot
 $r=Get-Content -LiteralPath $file -Raw -Encoding UTF8|ConvertFrom-Json -AsHashtable
 if($r.status -ne 'PASS'){throw "GATE BLOCKED: $($r.worker_skill) says $($r.status)"}
 $thisId="$($r.run_id)|$($r.task_id)|$($r.owner_department)|$($r.delegation_id)"
 if($null -eq $identity){$identity=$thisId}elseif($identity -cne $thisId){throw 'Reports belong to different run/task/owner/delegation'}
 if($null -eq $fp){$fp=$r.scope.snapshot_digest}elseif($fp -cne $r.scope.snapshot_digest){throw 'Reports refer to different snapshots; rerun all affected checks'}
 $scope=ConvertTo-Json -InputObject @($r.scope.scope_paths) -Compress
 if($null -eq $scopePaths){$scopePaths=$scope}elseif($scopePaths -cne $scope){throw 'Reports use different scope path lists; align all checkpoints and rerun'}
 if($done.ContainsKey($r.worker_skill)){throw "Duplicate Worker Skill report: $($r.worker_skill)"}
 $done[$r.worker_skill]=$true
}
foreach($name in $RequiredWorkerSkills){if(-not $done.ContainsKey($name)){throw "Required Worker Skill has no valid current PASS: $name"}}
Write-Host "GATE PASS - all required reports refer to CURRENT snapshot $fp"
Write-Host 'NOTICE: This is a deterministic contract gate, not proof that an LLM genuinely performed every claimed inspection. Validate source logs and actual tools independently.'
