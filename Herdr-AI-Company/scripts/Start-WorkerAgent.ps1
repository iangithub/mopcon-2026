# Starts exactly one existing Herdr Worker Pane with an approved company model profile.
# No panes are created. No Agent is prompted. Team Skills still own the orchestration.
param(
    [Parameter(Mandatory = $true)]
    [string]$WorkerSkill,
    [string]$CompanyRoot = 'D:\AI-Company',
    [string]$AgentName,
    [string]$PaneId,
    [switch]$AllowNetwork,
    [switch]$Preview
)
$ErrorActionPreference = 'Stop'

# Fixed execution boundaries: a model-only configuration must not silently change
# the CLI kind or grant write permissions to an independent reviewer.
$RoleRuntime = @{
    'software-coding'       = @{ Kind = 'codex'; Sandbox = 'workspace-write' }
    'software-code-review'  = @{ Kind = 'codex'; Sandbox = 'read-only' }
    'software-unit-test'    = @{ Kind = 'codex'; Sandbox = 'workspace-write' }
    'software-repo-scout'   = @{ Kind = 'codex'; Sandbox = 'read-only' }
    'writing-writer'        = @{ Kind = 'claude'; Sandbox = $null }
    'writing-editor'        = @{ Kind = 'codex'; Sandbox = 'read-only' }
    'writing-fact-check'    = @{ Kind = 'codex'; Sandbox = 'read-only' }
    'writing-proofreader'   = @{ Kind = 'codex'; Sandbox = 'read-only' }
    'writing-researcher'    = @{ Kind = 'claude'; Sandbox = $null }
}
if (-not $RoleRuntime.ContainsKey($WorkerSkill)) {
    throw "Unknown Worker Skill: $WorkerSkill"
}

$ConfigPath = Join-Path $CompanyRoot 'config\agent-models.json'
if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) {
    throw "Model configuration not found: $ConfigPath"
}
try {
    $AllProfiles = Get-Content -LiteralPath $ConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json -ErrorAction Stop
} catch {
    throw "Invalid model configuration JSON: $($_.Exception.Message)"
}
$WorkerProperty = $AllProfiles.workers.PSObject.Properties[$WorkerSkill]
if ($null -eq $WorkerProperty -or $null -eq $WorkerProperty.Value) {
    throw "Worker profile missing in config: $WorkerSkill"
}
$Profile = $WorkerProperty.Value
$Expected = $RoleRuntime[$WorkerSkill]
$Kind = [string]$Profile.kind
if ($Kind -cne $Expected.Kind) {
    throw "Worker '$WorkerSkill' must use '$($Expected.Kind)' in this environment; model configuration cannot change CLI kind or permission boundaries"
}

$Model = [string]$Profile.model
$Effort = [string]$Profile.effort
if (-not $Model -or $Model -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]{0,127}$') {
    throw "Invalid model for '$WorkerSkill'. Use an explicit CLI-compatible model ID/alias."
}
if ($Effort -notin @('low','medium','high','xhigh')) {
    throw "Invalid effort '$Effort' for '$WorkerSkill'; allowed: low, medium, high, xhigh"
}

$NativeArgs = [System.Collections.Generic.List[string]]::new()
if ($Kind -eq 'codex') {
    $NativeArgs.Add('-m')
    $NativeArgs.Add($Model)
    $NativeArgs.Add('-c')
    $NativeArgs.Add(('model_reasoning_effort="{0}"' -f $Effort))
    $NativeArgs.Add('--sandbox')
    $NativeArgs.Add($Expected.Sandbox)
    $NativeArgs.Add('--ask-for-approval')
    $NativeArgs.Add('never')
    if ($AllowNetwork) {
        if ($Expected.Sandbox -ne 'workspace-write') {
            throw "Network override is only allowed for workspace-write Codex roles: $WorkerSkill"
        }
        $NativeArgs.Add('-c')
        $NativeArgs.Add('sandbox_workspace_write.network_access=true')
    }
} elseif ($Kind -eq 'claude') {
    $NativeArgs.Add('--model')
    $NativeArgs.Add($Model)
    $NativeArgs.Add('--effort')
    $NativeArgs.Add($Effort)
    if ($AllowNetwork) { throw 'AllowNetwork is not implemented for Claude Code by this launcher' }
    # Claude Code's Windows permission/sandbox policy is managed separately;
    # never pretend that CWD or Role instructions enforce a read-only sandbox.
}

if ($Preview) {
    [pscustomobject]@{
        worker_skill = $WorkerSkill
        kind = $Kind
        model = $Model
        effort = $Effort
        sandbox = $Expected.Sandbox
        cli_arguments = @($NativeArgs.ToArray())
    } | ConvertTo-Json -Depth 5
    return
}
if (-not $AgentName -or $AgentName -cnotmatch '^[a-z][a-z0-9_-]{0,31}$') {
    throw 'AgentName is required and must match Herdr agent name constraints'
}
if ([string]::IsNullOrWhiteSpace($PaneId)) {
    throw 'PaneId is required: create a separate available shell pane first'
}
if (-not (Get-Command herdr -ErrorAction SilentlyContinue)) {
    throw 'Herdr CLI not found on PATH'
}

$CommandArguments = [System.Collections.Generic.List[string]]::new()
foreach ($Value in @('agent','start',$AgentName,'--kind',$Kind,'--pane',$PaneId,'--')) {
    $CommandArguments.Add($Value)
}
foreach ($Value in $NativeArgs) { $CommandArguments.Add($Value) }

# Return the original Herdr JSON unchanged so the Manager can capture IDs/state.
$HerdrArgs = $CommandArguments.ToArray()
& herdr @HerdrArgs
if ($LASTEXITCODE -ne 0) {
    throw "Herdr failed to start $WorkerSkill ($Kind / $Model / $Effort), exit code $LASTEXITCODE; check CLI model access, available pane and log-in"
}
