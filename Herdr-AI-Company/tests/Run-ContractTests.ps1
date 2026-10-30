# Offline synthetic contract tests. No Herdr/Codex/Claude, no Python, no external network.
# Creates and deletes an isolated temporary workspace; never modifies your real projects.
[CmdletBinding()]
param([string]$CompanyRoot=(Split-Path -Parent $PSScriptRoot),[switch]$KeepFixture)
$ErrorActionPreference='Stop'
$root=Join-Path ([IO.Path]::GetTempPath()) ('AICompanyContract-'+[guid]::NewGuid().ToString('N'))
$project=Join-Path $root 'Project-A'
$run=Join-Path $project '.ai-work/runs/RUN-DEMO-001'
function SaveJson([string]$path,$object){[IO.File]::WriteAllText($path,((ConvertTo-Json -InputObject $object -Depth 60)+"`n"),[Text.UTF8Encoding]::new($false))}
function Hash([string]$p){'sha256:'+(Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash.ToLowerInvariant()}
function Validate([string]$type,[string]$f,[switch]$Skip){ & (Join-Path $CompanyRoot 'scripts/Test-AgentContract.ps1') -Type $type -File $f -CompanyRoot $CompanyRoot -ProjectRoot $project -SkipCurrentSnapshot:$Skip }
function ExpectFailure([scriptblock]$action,[string]$name){
  $didFail=$false
  try { & $action 2>$null | Out-Null } catch { $didFail=$true; Write-Host "EXPECTED FAIL $name: $($_.Exception.Message)" }
  if(-not $didFail){throw "NEGATIVE TEST FAILED: $name incorrectly passed"}
}
try {
  New-Item -ItemType Directory -Path $root -Force | Out-Null
  Copy-Item -LiteralPath (Join-Path $CompanyRoot 'templates/Software/Project-A') -Destination $project -Recurse -Force
  New-Item -ItemType Directory -Path (Join-Path $project 'src'),$run -Force | Out-Null
  Set-Content -LiteralPath (Join-Path $project 'src/Example.cs') -Value 'public class Example { public int X => 1; }' -Encoding UTF8
  $snap=(& (Join-Path $CompanyRoot 'scripts/Get-ScopeSnapshot.ps1') -ProjectRoot $project -ScopePaths @('AGENTS.md','docs/team-rules','src')) | ConvertFrom-Json -AsHashtable
  $catalog=Get-Content -LiteralPath (Join-Path $CompanyRoot 'contracts/worker-requirements.json') -Raw | ConvertFrom-Json -AsHashtable
  $methods=@()
  foreach($rel in $catalog.workers.'software-code-review'.method_references){
    $p=Join-Path $CompanyRoot ('.agents/skills/software-code-review/'+$rel)
    $methods+=@{path=$rel;sha256=(Hash $p)}
  }
  $rules=@()
  $map=@{
   'software.architecture'='architecture.md';'software.coding'='coding.md';'software.review'='code-review.md';
   'software.testing'='testing.md';'software.security'='security.md'
  }
  foreach($key in $catalog.workers.'software-code-review'.required_rule_keys){
    $file='docs/team-rules/'+$map[$key]
    $abs=Join-Path $project $file
    $ids=@([regex]::Matches((Get-Content -LiteralPath $abs -Raw),'PA-[A-Z]+-\d{3}') | ForEach-Object {$_.Value}|Select-Object -Unique)
    $rules+=@{key=$key;path=$file;sha256=(Hash $abs);rule_ids=$ids}
  }
  $finding=@{
    id='CR-001';severity='BLOCKING';rule_key='software.architecture';rule_id='PA-ARCH-003';
    location=@{path='src/Example.cs';line=1;anchor=$null};
    evidence='Synthetic fixture: source code would violate approved boundary if it opened a DbContext';
    impact='Architecture dependency violation';required_action='Avoid directly accessing data layer from application logic'
  }
  $base=@{
    contract_version='1.0';message_type='worker_report';run_id='RUN-DEMO-001';task_id='TASK-DEMO-001';attempt=1;
    owner_department='software';assigned_department='software';delegation_mode='owner-work';delegation_id=$null;
    role='code-review';worker_skill='software-code-review';scope=@{project_root=$project;scope_paths=@('AGENTS.md','docs/team-rules','src');snapshot_digest=$snap.digest};
    method_references=$methods;loaded_rules=$rules;
    checks=@(@{name='architecture-review';result='FAIL';evidence='Synthetic: PA-ARCH-003 check was not satisfied'});
    findings=@($finding);verification=@();fixes=@();limitations=@();artifacts=@();status='FAIL';handoff_to='owner-manager'
  }
  $reviewFail=Join-Path $run 'review-fail.json';SaveJson $reviewFail $base
  Validate Report $reviewFail
  $dispatch=@{
    contract_version='1.0';message_type='task_dispatch';run_id='RUN-DEMO-001';task_id='TASK-DEMO-001';attempt=1;
    project_root=$project;company_root=$CompanyRoot;workspace_id='w1';manager_pane_id='w1:p1';
    owner_department='software';assigned_department='software';delegation_mode='owner-work';delegation_id=$null;
    role='coding';worker_skill='software-coding';task='Repair approved code based on review findings';
    acceptance_criteria=@('Follow project architecture rules');spec_paths=@('AGENTS.md');
    input_report_paths=@();allowed_read_paths=@('src');allowed_write_paths=@('src');
    forbidden_write_paths=@('AGENTS.md','docs/team-rules');snapshot=@{scope_paths=$snap.scope_paths;digest=$snap.digest};
    report_path='.ai-work/runs/RUN-DEMO-001/coding-report.json';handoff_to='owner-manager'
  }
  $dispatchFile=Join-Path $run 'dispatch.json';SaveJson $dispatchFile $dispatch
  Validate Dispatch $dispatchFile
  $repair=Join-Path $run 'repair-request.json'
  & (Join-Path $CompanyRoot 'scripts/New-RepairRequest.ps1') -SourceReport $reviewFail -DispatchFile $dispatchFile -ProjectRoot $project -CompanyRoot $CompanyRoot -OutFile $repair -TargetWorkerSkill software-coding
  Validate Repair $repair
  $r=Get-Content -LiteralPath $repair -Raw|ConvertFrom-Json -AsHashtable
  $r.findings[0].required_action='Manager changed the reviewer original wording'
  $tampered=Join-Path $run 'repair-tampered.json';SaveJson $tampered $r
  ExpectFailure {Validate Repair $tampered} 'manager paraphrased reviewer finding'
  $scopeTampered=Get-Content -LiteralPath $repair -Raw | ConvertFrom-Json -AsHashtable
  $scopeTampered.allowed_write_paths=@('src','docs/team-rules')
  $allowPath=Join-Path $run 'repair-writepath-tampered.json';SaveJson $allowPath $scopeTampered
  ExpectFailure {Validate Repair $allowPath} 'repair request widened original allowed-write scope'
  $blocked=$base.Clone()
  $blocked.status='BLOCKED';$blocked.scope=@{project_root=$project;scope_paths=@('AGENTS.md');snapshot_digest=$null}
  $blocked.findings=@();$blocked.loaded_rules=@();$blocked.method_references=@()
  $blocked.checks=@(@{name='load-required-rule';result='BLOCKED';evidence='Missing required Rule prevents review'})
  $blocked.limitations=@('Rule missing or inaccessible; review was not performed')
  $blockedFile=Join-Path $run 'review-blocked.json';SaveJson $blockedFile $blocked
  Validate Report $blockedFile
  ExpectFailure {& (Join-Path $CompanyRoot 'scripts/Test-QualityGate.ps1') -CompanyRoot $CompanyRoot -ProjectRoot $project -ReportFiles @($blockedFile) -RequiredWorkerSkills @('software-code-review') } 'BLOCKED report cannot pass quality gate'
  $passing=$base.Clone()
  $passing.status='PASS';$passing.findings=@();$passing.checks=@(@{name='architecture-review';result='PASS';evidence='Synthetic fixture; architecture inspected against PA-ARCH-003'})
  $reviewPass=Join-Path $run 'review-pass.json';SaveJson $reviewPass $passing
  Validate Report $reviewPass
  & (Join-Path $CompanyRoot 'scripts/Test-QualityGate.ps1') -CompanyRoot $CompanyRoot -ProjectRoot $project -ReportFiles @($reviewPass) -RequiredWorkerSkills @('software-code-review')
  $fakePass=$base.Clone();$fakePass.status='PASS'
  $fakePath=Join-Path $run 'false-pass.json';SaveJson $fakePath $fakePass
  ExpectFailure {Validate Report $fakePath} 'review PASS with blocking findings'
  $ruleCorrupt=$base.Clone();$ruleCorrupt.loaded_rules=@($base.loaded_rules|ForEach-Object{$_.Clone()});$ruleCorrupt.loaded_rules[0].sha256='sha256:'+('0'*64)
  $rulePath=Join-Path $run 'rule-hash-corrupt.json';SaveJson $rulePath $ruleCorrupt
  ExpectFailure {Validate Report $rulePath} 'incorrect Rule hash'
  Add-Content -LiteralPath (Join-Path $project 'src/Example.cs') -Value '// Content changed after review'
  ExpectFailure {Validate Report $reviewPass} 'stale review PASS after source modification'
  Write-Host 'PASS ALL SYNTHETIC CONTRACT TESTS: valid FAIL/PASS, exact repair, tampering rejected, false PASS rejected, valid BLOCKED rejected by gate, Rule hash rejected, stale snapshot rejected.'
} finally {
  if($KeepFixture){Write-Host "KEPT FIXTURE: $project"}
  else { if(Test-Path -LiteralPath $root){Remove-Item -LiteralPath $root -Recurse -Force} }
}
