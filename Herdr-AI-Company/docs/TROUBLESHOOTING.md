#  故障排除（先核實再修）

| 現象 | 優先排查 | 正確處理 |
|---|---|---|
| `herdr` 找不到 | `Get-Command herdr`、PATH、Herdr 安裝來源 | 重開 PowerShell 或按官方 Windows 安裝處理 |
| 全域 `herdr` Skill 看不到 | `npx skills ls -g`、是否選取 Codex 與 Claude Code、使用者 Skill 路徑 | 依 STEP 3 重新以官方全域方式安裝，並新開 CLI Session；不要用公司目錄副本充數 |
| `herdr` Skill 同名或 Junction 衝突 | `$HOME\.agents\skills\herdr` 與 `$HOME\.claude\skills\herdr` 的 `LinkType`、`Target` | 先確認是否仍指向公司目錄，依下方「官方 Herdr Skill 同名衝突處理」解除舊入口，**不覆蓋未知 Skill** |
| `codex` / `claude` 找不到 | `Get-Command codex,claude`、版本、登入 | 使用相應 CLI 官方安裝與登入流程 |
| Herdr Pane 已啟動 Codex，但 Codex 工具讀不到 `HERDR_ENV` | 先在 Herdr Shell 檢查 `$env:HERDR_ENV`，再讓 Codex 實際執行唯讀環境檢查；核對 `$HOME\.codex\config.toml` | 依 `WORKSHOP.md` STEP 0 的 `[shell_environment_policy] inherit = "all"` 設定並重啟 Codex；不要因 `AI_COMPANY_ROLE` 未設定就誤判 Manager 身分 |
| 新 Session 看不到 `$software-coding` | `$HOME\.agents\skills\software-coding\SKILL.md` 是否可讀、Junction Target 是否正確 | 檢查安裝位置/名稱，重開 Codex；不要用普通 Prompt 假裝 Skill 已啟用 |
| `/writing-writer` 無法觸發 | `$HOME\.claude\skills\writing-writer`、`/skills`、Claude 版本與 Windows Junction 特性 | 驗證 `/writing-writer` 後才派工；必要時依官方流程改安裝方式並記錄非即時共享缺點 |
| 「開始做吧」但沒開團隊 | 是否新 Manager Session、全域 Bootstrap、Project Department、需求是否定案 | 先只讀自檢，不用猜 Owner；確認 Skill 裝好後再重新測 |
| Worker 想當 Manager | Pane `--env AI_COMPANY_ROLE=worker`、Prompt `WORKER_CONTRACT` | 停止，不允許 Worker 操作 Herdr；在 Root Manager 修正 |
| `AI_COMPANY_ROOT` 未設於 Worker | `herdr pane get`、Pane 建立參數 | Worker 必須 fail closed；Manager 用正確 `--env` 重建合法 Pane |
| Guest 引用 Project-A Rule | WORKER_CONTRACT `ProjectRoot` 是否 Book-A；Book-A Rule Registry 是否有 `software.*` | 停止 Guest，修正為 Book-A Rules，確認 Loaded Rules 是 `EX-*` |
| Review 只回「程式符合規範」 | 是否真觸發 `$software-code-review`、實際讀了 references/Rule/Diff | 判驗收 FAIL，提供可核對的 Skill/Loaded Rules 和 Findings |
| `Rule Registry` 有缺 key | `tests/Verify-RuleRegistry.ps1`、Worker RequiredKeys | 在**專案**補必要 Markdown，不在 Manager Prompt 創造 Rule，必要時 BLOCKED |
| `Department` 缺或重複 | 讀專案根 AGENTS.md | 請專案 Owner 一次性設定，不由 Router 猜測 |
| Worker 全部使用 Manager 的模型 | 檢查 `config/agent-models.json` 與 `scripts/Start-WorkerAgent.ps1` 是否真的被 Manager 使用 | 用 `-Preview` 檢查各 Worker 的原生 CLI 參數；若曾手動啟動 Worker，安全結束後重新由啟動器建立 |
| Worker 指定模型不可使用 | 本機 Codex／Claude 登入、模型支援與帳號額度 | 在 `config/agent-models.json` 改為該 CLI 帳號實際可用的模型，再重新啟動 Worker；不可悄悄改用更貴模型 |
| 改 JSON 後目前 Pane 模型沒變 | 舊 Worker Session 不會熱切換 | 保存當前任務、退出舊 Worker，回到空 Shell 後重新啟動；不要中斷進行中的修改 |
| `agent start` 失敗 | 必須是已有的空 Shell Pane、Agent CLI 已登入／PATH 可用 | 先確認 Pane 終端狀態，不在已跑 Agent 的 Pane 中重啟 |
| `agent_prompt_stalled` / Timeout | 先 `herdr agent get/read` | 超時不代表沒送到，不能盲目重送導致重複寫入 |
| Codex Reviewer 嘗試改檔 | 實際 `--sandbox read-only` 與 Role/Task | 停止驗收；改成真正 Read-only；不靠 Role 文字作隔離保證 |
| Claude Code 原生 Windows 權限 | 官方 Windows Setup／當前版本與允許工具 | 無 OS Sandbox 就不能保證唯讀，僅在非機密測試專案驗證 |
| `.NET` 測試無法執行 | `dotnet --info`、SDK/Package Restore、真實測試命令 | 標 `NOT RUN/BLOCKED`，先修環境，勿虛構 PASS |
| Fact Checker 沒有可訪問來源 | CLI 的真實網路／Web 工具、提供的文件 | 標 `UNVERIFIED`，不編造 Source |
| 同名 Skill 被覆蓋 | User Skills 目錄、Junction Target、既有設定備份 | 停止；先分辨所有者，不覆蓋已安裝的同名 Skill |
| Manager Bridge 已存在 | 全域 AGENTS.md/CLAUDE.md 內的 Marker 與中央路徑 | 人工核對 Bridge 並新開 Session；避免重複或互相衝突的橋接 |

## 官方 Herdr Skill 同名衝突處理

官方 `herdr` 由 `npx skills` **全域**安裝；`D:\AI-Company\.agents\skills\herdr` 不再是安裝位置。若使用者目錄已存在 `herdr`，**先看清楚連結目標**：

```powershell
$OldCompanyHerdr = 'D:\AI-Company\.agents\skills\herdr'
$Paths = @(
  (Join-Path $HOME '.agents\skills\herdr'),
  (Join-Path $HOME '.claude\skills\herdr')
)
foreach ($Path in $Paths) {
  Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue |
    Format-List FullName,LinkType,Target
}
```

只有當 `LinkType` 確實是 `Junction`、且 `Target` **明確指向** `$OldCompanyHerdr` 時，才可對那條舊連結執行 `cmd /c rmdir "<已確認的 Junction 完整路徑>"`；此操作目標是**移除連結本身**，不是刪除來源檔案。來源是一般資料夾、其他連結類型，或路徑不確定時不要執行，先備份並人工處理。

確認舊連結已解除後，執行 `npx skills add herdrdev/herdr --skill herdr -g`，選取 Codex／Claude Code，再用 `npx skills ls -g` 和全新 CLI Session 驗證。`D:\AI-Company\.agents\skills\herdr` 若仍有手動產生的檔案，可在檢查不再被任何入口引用後，**移出**公司 Skill 目錄另行備份；不要在新安裝前盲目刪除或覆蓋。

## Windows Junction 已知風險

Windows 上部分 Claude Code 版本曾出現 Junction 指向的 User Skills 讀得到檔案，但 `/skill` 初次呼叫或選單發現異常；**Link 可讀 ≠ Skill 已生效**。請直接在新 CLI Session 驗證 `/writing-writer`，無法成功就記錄版本，依 Claude 官方 Skills 安裝指引改用支援的方式。不要宣稱這套環境已完全驗證跨工具共用。

## 除錯順序

① 檔案存在 → ② Rule Registry valid → ③ CLI Skill 明確可啟用 → ④ Manager Bootstrap 読取 → ⑤ Pane/Agent 真實建立 → ⑥ Worker Loaded Rules → ⑦ 真實產物/Build/Test/Fact Evidence → ⑧ Owner 簽收。

##  Contract 故障

| 症狀 | 排查方式 | 處理 |
|---|---|---|
| `Test-Json` 無 `-SchemaFile` 或 PS 命令不識別 | `pwsh --version` | 升級 PowerShell 7.4+；目前僅支援 PowerShell 7.4+ 的契約驗證 |
| `CONTRACT INVALID: STALE SNAPSHOT` | 重新 `scripts/Get-ScopeSnapshot.ps1`，查實際 Source/Tests/Rules/Spec | Coding 修改後重跑必要 Test 和 Review；不能硬改 digest 讓舊 PASS 過關 |
| Rule Hash mismatch / missing Reference | 實際 `AGENTS.md Rule Registry`／`contracts/worker-requirements.json` | Worker 必須重讀 Rule 和 Reference、重做檢查；不能由 Manager 假填 SHA |
| Review FAIL 但 Repair Request 驗證失敗 | 原始 Review/Dispatch SHA-256、Blocking Findings | 保留原始回報，從最新且有效的 FAIL 重新執行 `scripts/New-RepairRequest.ps1`，不要自行改 Finding |
| Read-only Reviewer 無法寫 JSON | CLI 真的 Read-only | Worker 回完整純 JSON，Manager 原封不動封存並驗證；不可為保存報告而放寬 Reviewer Sandbox |
| Test-QualityGate 失敗 | 驗證每份報告 status、RunId、TaskId、Snapshot | 必須有同一最新版有效 PASS 的完整 Worker 集合；缺任何一關都不可交付 |
