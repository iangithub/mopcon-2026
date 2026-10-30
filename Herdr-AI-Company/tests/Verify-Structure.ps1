# Read-only AI Company static verification.
# It does NOT invoke Herdr, Codex, Claude, or modify any files.
param([string]$Company = 'D:\AI-Company')
$ErrorActionPreference = 'Stop'
$Failures = [System.Collections.Generic.List[string]]::new()
$RequiredFiles = @(
  'README.md','AGENTS.md','bootstrap\manager-startup.md',
  'config\README.md','config\agent-models.json','scripts\Start-WorkerAgent.ps1','tests\Test-WorkerModelConfig.ps1',
  '.agents\skills\company-router\SKILL.md',
  '.agents\skills\company-router\references\runtime.md',
  '.agents\skills\company-router\references\dispatch-contract.md',
  '.agents\skills\company-router\references\cross-department-policy.md',
  '.agents\skills\company-router\references\cross-department-contract.md',
  '.agents\skills\software-team\SKILL.md',
  '.agents\skills\writing-team\SKILL.md',
  'policies\worker\rule-composition.md',
  'policies\worker\worker-boundary.md',
  'policies\worker\report-contract.md',
  'contracts\README.md','contracts\STATE-MACHINE.md','contracts\worker-requirements.json',
  'contracts\schemas\task-dispatch.schema.json','contracts\schemas\worker-report.schema.json','contracts\schemas\repair-request.schema.json',
  'scripts\Get-ScopeSnapshot.ps1','scripts\Test-AgentContract.ps1','scripts\New-RepairRequest.ps1','scripts\Test-QualityGate.ps1','tests\Run-ContractTests.ps1',
  'docs\CONTRACT-TEST.md',
  'policies\manager\git-commit.md',
  'templates\Software\Project-A\AGENTS.md',
  'templates\Writing\Book-A\AGENTS.md',
  'docs\ARCHITECTURE.md','docs\ACCEPTANCE.md','docs\CROSS-DEPARTMENT-TEST.md',
  'tests\Verify-RuleRegistry.ps1',
  'scripts\README.md','tests\README.md',
  'WORKSHOP.md','docs\FILE-PLACEMENT.md','docs\EXECUTION-FLOW.md'
)
$WorkerSkills = @(
  'software-coding','software-code-review','software-unit-test','software-repo-scout',
  'writing-writer','writing-editor','writing-fact-check','writing-proofreader','writing-researcher'
)
foreach ($Name in $WorkerSkills) { $RequiredFiles += ".agents\skills\$Name\SKILL.md" }
foreach ($Rel in $RequiredFiles) {
  $Full = Join-Path $Company $Rel
  if (-not (Test-Path -LiteralPath $Full -PathType Leaf)) { $Failures.Add("Missing: $Rel") }
}
$SkillRoot = Join-Path $Company '.agents\skills'
$AllowedSkills = @('company-router','software-team','writing-team') + $WorkerSkills
if (Test-Path -LiteralPath $SkillRoot) {
  foreach ($Dir in (Get-ChildItem -LiteralPath $SkillRoot -Directory -Force)) {
    if ($Dir.Name -eq 'herdr') {
      $Failures.Add('Official herdr Skill must be installed globally with npx skills add; it must not be stored in CompanyRoot')
    } elseif ($Dir.Name -notin $AllowedSkills) { $Failures.Add("Unexpected skill directory: $($Dir.Name)") }
  }
  foreach ($Name in $WorkerSkills) {
    $SkillDir = Join-Path $SkillRoot $Name
    $Skill = Join-Path $SkillDir 'SKILL.md'
    if (-not (Test-Path -LiteralPath $Skill)) { continue }
    $Text = Get-Content -LiteralPath $Skill -Raw -Encoding UTF8
    if ($Text -notmatch '(?s)^---\s*\r?\nname:\s*' -or $Text -notmatch 'description:' -or $Text -notmatch 'WORKER_CONTRACT') {
      $Failures.Add("Bad Worker Skill frontmatter or contract: $Name")
    }
    $Refs = [regex]::Matches($Text, 'references/[a-z-]+\.md') | ForEach-Object { $_.Value } | Select-Object -Unique
    if (@($Refs).Count -eq 0) { $Failures.Add("No method references in Worker Skill: $Name") }
    foreach ($Ref in $Refs) {
      $RefFull = Join-Path $SkillDir ($Ref -replace '/', [System.IO.Path]::DirectorySeparatorChar)
      if (-not (Test-Path -LiteralPath $RefFull -PathType Leaf)) { $Failures.Add("Missing method reference: $Name/$Ref") }
    }
  }
}
# This is a static CompanyRoot verifier. Official herdr is installed globally
# via npx skills; verify it separately as described in WORKSHOP.md STEP 3.

foreach ($Proj in @('templates\Software\Project-A','templates\Writing\Book-A')) {
  $ProjRoot = Join-Path $Company $Proj
  try { & (Join-Path $Company 'tests\Verify-RuleRegistry.ps1') -ProjectRoot $ProjRoot }
  catch { $Failures.Add("Rule Registry invalid ($Proj): $($_.Exception.Message)") }
}

$DuplicateDeptRules = @(
  '.agents\skills\software-team\references\rules',
  '.agents\skills\writing-team\references\rules'
)
foreach ($Rel in $DuplicateDeptRules) {
  if (Test-Path -LiteralPath (Join-Path $Company $Rel)) { $Failures.Add("Duplicate department rules must not be active: $Rel") }
}
$Bootstrap = Join-Path $Company 'bootstrap\manager-startup.md'
if (Test-Path -LiteralPath $Bootstrap) {
  $Text = Get-Content -LiteralPath $Bootstrap -Raw -Encoding UTF8
  foreach ($Needle in @('Rule Registry','WORKER_CONTRACT','company-router','AI_COMPANY_ROLE','Test-AgentContract.ps1','repair-request.json')) {
    if (-not $Text.Contains($Needle)) { $Failures.Add("Manager bootstrap missing: $Needle") }
  }
}
$XDept = Join-Path $Company '.agents\skills\company-router\references\cross-department-policy.md'
if (Test-Path -LiteralPath $XDept) {
  $Text = Get-Content -LiteralPath $XDept -Raw -Encoding UTF8
  foreach ($Needle in @('XDEPT-001','XDEPT-006','XDEPT-009')) {
    if (-not $Text.Contains($Needle)) { $Failures.Add("Missing cross-department rule: $Needle") }
  }
}
if ($Failures.Count -gt 0) {
  foreach ($Line in $Failures) { Write-Host "FAIL $Line" }
  throw "$($Failures.Count) static errors"
}
try { & (Join-Path $Company 'tests\Test-WorkerModelConfig.ps1') -Company $Company }
catch { throw "Worker model configuration invalid: $($_.Exception.Message)" }
Write-Host 'PASS AI Company static structure, Worker Skill references, project Rule Registry and model profiles.'
Write-Host 'NOTICE: This does NOT prove Herdr, CLI Skill activation, runtime sandbox, or agent quality.'
