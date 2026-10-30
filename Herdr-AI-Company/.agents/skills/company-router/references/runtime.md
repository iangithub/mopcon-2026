# Herdr Runtime Contract — Pane / Agent 操作（PowerShell 7）

本檔只供 Manager；操作 Herdr 前應載入 STEP 3 全域安裝的官方 `herdr` Skill（由 `npx skills` 管理，不放在 CompanyRoot）。若本機 Herdr CLI 與已安裝 Skill 的命令不一致，應以 `herdr --help` 與本機 CLI 為準。以下 CLI 指令參數依 https://herdr.dev/docs/cli-reference/ ，**仍須在實機檢查版本**。

## 1. 先確認當前身分、Workspace、ProjectRoot

```powershell
if ($env:HERDR_ENV -ne '1' -or $env:AI_COMPANY_ROLE -eq 'worker') { throw 'Not an authorized Herdr Manager' }
$workspaceId = $env:HERDR_WORKSPACE_ID
$managerPane = $env:HERDR_PANE_ID
$companyRoot = 'D:\AI-Company' # 替換成已驗證的 Bootstrap 公司根路徑；Manager 不一定有環境變數
if (-not $workspaceId -or -not $managerPane -or -not (Test-Path (Join-Path $companyRoot 'bootstrap\manager-startup.md'))) { throw 'Missing Herdr identity or invalid CompanyRoot' }
herdr workspace get $workspaceId
herdr pane get $managerPane
herdr pane list --workspace $workspaceId
herdr agent list
```

`AI_COMPANY_ROOT` 在 Manager 根 Pane **不保證存在**；此處 `$companyRoot` 需根據已安裝 Bootstrap 橋接的實際絕對路徑核實（若非 D 槽必須替換），Worker Pane 再以 `--env AI_COMPANY_ROOT=...` 顯式傳入。不要假設跨 CLI 的 Shell 環境變數會自動繼承。

## 2. 以 Workspace ID 派生唯一 Agent 名稱

```powershell
$bytes = [System.Security.Cryptography.SHA256]::HashData([System.Text.Encoding]::UTF8.GetBytes($workspaceId))
$prefix = 'w' + [Convert]::ToHexString($bytes).Substring(0,10).ToLowerInvariant()
$codingName = "$prefix-s-code"   # must match [a-z][a-z0-9_-]{0,31}
$reviewName = "$prefix-s-review"
$testName   = "$prefix-s-test"
```

同個 Workspace 若同時 Owner + Guest 用相同角色，需額外使用不同的合法 role suffix；不得與伺服器現有 Agent 名稱衝突。

## 3. 建空 Shell Worker Pane（先建 Pane，再 agent start）

```powershell
$projectRoot = (Get-Location).Path # 核實這是此 Workspace 的專案根，不是隨意 CWD
$created = herdr pane split $managerPane --direction right --cwd $projectRoot --env AI_COMPANY_ROLE=worker --env "AI_COMPANY_ROOT=$companyRoot" --no-focus | ConvertFrom-Json
$workerPane = $created.result.pane.pane_id
if (-not $workerPane) { throw 'Herdr did not return a pane id' }
herdr pane rename $workerPane 'Coding Agent'
```

後續 Test/Review 可依已建立右側 Worker Pane 用 `pane split <workerPane> --direction down`，從 JSON 取得 ID。只有右側 Pane 多於三個時才考慮第二欄，優先避免破壞 Manager 左側。

Guest 需要時先取得授權並檢查 `examples/<delegation-id>` 目錄；再用 `--cwd $guestCwd` 建 Pane。**CWD 不構成寫入權限邊界**。

## 4. 啟動 CLI（由公司模型設定決定各 Worker Model）

所有 Worker 的 **Kind / Model / Reasoning** 一律由 `config/agent-models.json` 與 `scripts/Start-WorkerAgent.ps1` 載入；**不要手寫 `herdr agent start` 的 `-m`、`--model` 或 `-c model_reasoning_effort`，也不要讓 Worker 沿用 Manager 模型**。Manager 主 Pane 的模型仍由使用者自行選擇。

先用 `herdr pane split` 建好**沒有前景任務的空 Shell Pane**，再以 Workspace-scoped 合法 Agent Name 啟動。例如：

```powershell
$companyRoot = 'D:\AI-Company'
# $codingPane / $testPane / $reviewPane 是前面 split 的 JSON 真正回傳的 Pane IDs
# $codingName / $testName / $reviewName 是本 Workspace 唯一合法的 Agent Names
& "$companyRoot\scripts\Start-WorkerAgent.ps1" -CompanyRoot $companyRoot -WorkerSkill 'software-coding' -AgentName $codingName -PaneId $codingPane
& "$companyRoot\scripts\Start-WorkerAgent.ps1" -CompanyRoot $companyRoot -WorkerSkill 'software-unit-test' -AgentName $testName -PaneId $testPane
& "$companyRoot\scripts\Start-WorkerAgent.ps1" -CompanyRoot $companyRoot -WorkerSkill 'software-code-review' -AgentName $reviewName -PaneId $reviewPane
```

**Writing Team / Guest** 使用相同入口，例如：

```powershell
& "$companyRoot\scripts\Start-WorkerAgent.ps1" -CompanyRoot $companyRoot -WorkerSkill 'writing-writer' -AgentName $writerName -PaneId $writerPane
& "$companyRoot\scripts\Start-WorkerAgent.ps1" -CompanyRoot $companyRoot -WorkerSkill 'software-code-review' -AgentName $guestReviewName -PaneId $guestReviewPane
```

`Start-WorkerAgent.ps1` 會透過 Herdr `agent start ... -- <原生 CLI args>` 傳入模型與推理強度；Codex 同時固定符合角色的 `--sandbox` 與 `--ask-for-approval never`。本工具只**啟動** Agent，不建立 Pane、不調整專案 Rules、不執行 Task Dispatch、也不是獨立 Controller。

正式啟動前先在 PowerShell 7 用 **預覽模式**確認每位 Worker 對應的模型與參數（不啟動 Herdr）：

```powershell
& "$companyRoot\scripts\Start-WorkerAgent.ps1" -CompanyRoot $companyRoot -WorkerSkill software-coding -Preview
& "$companyRoot\scripts\Start-WorkerAgent.ps1" -CompanyRoot $companyRoot -WorkerSkill software-code-review -Preview
```

若使用者已授權可信專案進行 NuGet／套件還原，僅 `workspace-write` Codex Worker 可以在啟動器增加 `-AllowNetwork`，Reviewer 仍禁止聯網。不要在 Reviewer 使用 `workspace-write`；不要使用 `danger-full-access` 或等價權限繞過。Claude Code 在 Native Windows 上的實際檔案權限需另行評估，不能由模型設定推論具備 OS Sandbox。**模型設定變更只對新啟動的 Worker 生效**；重用既有 Pane 前須核對該 Worker 的實際 Model / Reasoning / Sandbox，若不符，等工作完成並安全退出後重新啟動，不能在工作進行中強制關閉。

## 5. 向 Worker 傳入已驗證的 JSON Dispatch 路徑（**不是 Rule 正文**）

先由 Manager 寫好本專案 `.ai-work/runs/<run-id>/dispatch-coding.json`（格式見 `contracts/schemas/task-dispatch.schema.json`），以 `scripts/Get-ScopeSnapshot.ps1` 計算真實 `snapshot.digest`，並通過：

```powershell
$companyRoot = 'D:\AI-Company'
$projectRoot = 'D:\Workspaces\Software\Project-A'
$dispatchFile = Join-Path $projectRoot '.ai-work\runs\RUN-001\dispatch-coding.json'
& "$companyRoot\scripts\Test-AgentContract.ps1" -Type Dispatch -File $dispatchFile -CompanyRoot $companyRoot -ProjectRoot $projectRoot

# 注意：此範例假定已按前段建好 Coding Pane 並啟動對應 Agent。
$prompt = @'
$software-coding
WORKER_CONTRACT: D:\Workspaces\Software\Project-A\.ai-work\runs\RUN-001\dispatch-coding.json
Read the validated JSON, your Skill SOP/references and project Rules. Return a complete worker-report JSON.
Do not run Herdr, spawn other agents, or commit.
'@
herdr agent prompt $codingName $prompt --wait --until idle --until done --until blocked --timeout 180000
herdr agent read $codingName --source recent-unwrapped --lines 160
```

以上路徑和 RUN-001 都是**示例**；正式派工前 Manager 必須建立真正 Dispatch。唯讀 Worker 的完整 JSON 如果被終端截斷，不能靠這 160 行推測出完整契約；請在符合權限的方式取得完整原文後由 Manager 保存。

## 6. Lifecycle 與例外

- `agent prompt --wait` 遇到 `blocked`、`timeout`、`agent_prompt_stalled`，先 `agent get/read`；超時**不代表** Prompt 沒送到，不得盲目重送。
- 重用 Pane 前確認屬同 Workspace、Role、權限、Kind、Model（若有）、Session 與 Task Scope；不安全則在完成後由使用者確認是否退出並另建。
- Worker 能與使用者互動的 UI 不代表可接受產品變更；需求決策仍返回唯一 Manager。
- Read-only Reviewer 不寫 Source、Git Metadata 或 log；若要保存長報告，讓 Manager 將 Worker 的回覆保存到授權報告檔。
