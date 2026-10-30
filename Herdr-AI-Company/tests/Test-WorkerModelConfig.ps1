# Offline smoke test of Worker model profiles and actual Herdr CLI argument generation.
# Does NOT start Herdr or modify existing sessions.
param([string]$Company = 'D:\AI-Company')
$ErrorActionPreference = 'Stop'
$Required = @(
    'software-coding','software-code-review','software-unit-test','software-repo-scout',
    'writing-writer','writing-editor','writing-fact-check','writing-proofreader','writing-researcher'
)
$Launcher = Join-Path $Company 'scripts\Start-WorkerAgent.ps1'
$ConfigPath = Join-Path $Company 'config\agent-models.json'
if (-not (Test-Path -LiteralPath $Launcher)) { throw "Missing launcher: $Launcher" }
$Config = Get-Content -LiteralPath $ConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json
$Defined = @($Config.workers.PSObject.Properties.Name)
if (@($Defined).Count -ne $Required.Count) { throw 'Worker model configuration must contain exactly nine roles' }
foreach ($Worker in $Required) {
    if ($Worker -notin $Defined) { throw "Missing Worker profile: $Worker" }
    $JsonText = & $Launcher -WorkerSkill $Worker -CompanyRoot $Company -Preview
    $PreviewResult = $JsonText | ConvertFrom-Json
    if ($PreviewResult.worker_skill -ne $Worker) { throw "Wrong worker preview: $Worker" }
    if (@($PreviewResult.cli_arguments).Count -lt 4) { throw "Missing native CLI model/effort args: $Worker" }
    if ($PreviewResult.kind -eq 'codex' -and '--sandbox' -notin @($PreviewResult.cli_arguments)) {
        throw "Codex sandbox missing: $Worker"
    }
    if ($PreviewResult.kind -eq 'claude' -and '--effort' -notin @($PreviewResult.cli_arguments)) {
        throw "Claude effort flag missing: $Worker"
    }
    if ($Worker -match '(code-review|repo-scout|writing-editor|writing-fact-check|writing-proofreader)' -and $PreviewResult.kind -eq 'codex' -and $PreviewResult.sandbox -ne 'read-only') {
        throw "Review-style worker lost read-only sandbox: $Worker"
    }
    Write-Host "PASS $Worker => $($PreviewResult.kind) $($PreviewResult.model) / $($PreviewResult.effort)"
}
# A reviewer must never be allowed to opt into the workspace-write network override.
try {
    & $Launcher -WorkerSkill 'software-code-review' -CompanyRoot $Company -AllowNetwork -Preview | Out-Null
    throw 'Reviewer unexpectedly accepted AllowNetwork'
} catch {
    if ($_.Exception.Message -eq 'Reviewer unexpectedly accepted AllowNetwork') { throw }
}
Write-Host 'PASS all nine model profiles, CLI arguments, and reviewer network boundary (offline only).'
