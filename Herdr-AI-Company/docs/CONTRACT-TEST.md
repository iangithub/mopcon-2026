#  實測：Contract-Driven Agent Orchestration

**目標**：驗證「Review FAIL → 原始 Finding ID 交 Coding → 修正 → Test / Review 重跑 → Gate PASS」，且 Manager 沒有重寫 Reviewer 的原始意見。這份文件不是自動讓 LLM 跑完的腳本；Herdr 的 Pane／Agent 仍由 Manager 透過官方 `herdr` Skill 操作。

## 0. 前提與安全

- Windows 11 + PowerShell **7.4+**（`pwsh --version`）、Herdr、Codex CLI／Claude Code，依根 WORKSHOP.md 安裝。
- `D:\AI-Company` 是 CompanyRoot；`D:\Workspaces\Software\Project-A` 是 ProjectRoot；換路徑請在所有指令同步替換。
- 本測試不接真實服務、不涉及機密、禁止自動 Git Commit 或 Push。當前專案 `AGENTS.md` 明確 `Department: software`。
- **Schema／Hash／Snapshot 驗證不保證模型確實履行專業審查**；仍須用實際 Build/Test Log、Source Diff、CLI 權限和 Reviewer 原始 JSON 交叉核對。

## 1. 先跑無 CLI 的合成契約測試

```powershell
$C = 'D:\AI-Company'
& "$C\tests\Verify-Structure.ps1" -Company $C
& "$C\tests\Run-ContractTests.ps1" -CompanyRoot $C
```

預期 `PASS ALL SYNTHETIC CONTRACT TESTS`，至少涵蓋：

| Case | 預期 |
|---|---|
| JSON Schema 有效，真實 Rule/Reference Hash 和 Snapshot 正確 | VALID |
| Reviewer 回 FAIL 並帶 `CR-001` Blocking Finding | VALID FAIL（不是 Gate PASS） |
| `New-RepairRequest` 保留原始 Finding Object 與來源 SHA-256 | VALID Repair |
| Manager 偷改 `required_action` | INVALID Repair |
| 必要 Rule 無法讀取，Worker 回 `BLOCKED`、沒有偽造 Hash | VALID BLOCKED，但 Gate 拒絕 |
| Reviewer 有 Blocking Finding 卻宣稱 PASS | INVALID Report |
| Rule SHA-256 是假的 | INVALID Report |
| Review PASS 後 Source 多一行 | INVALID：STALE SNAPSHOT |

`tests/Run-ContractTests.ps1` 只在系統暫存資料夾建立隔離模擬專案，結束自動刪除。若要保留比對，可加 `-KeepFixture`；請勿把測試結果誤認為真實 Agent 審查。

## 2. 手動在 Herdr 實測一個真正的 Software 任務

1. 開啟 `Project-A` Workspace 的根 Pane，使用 Codex Manager，口頭討論一個**可建置、可測試的最小功能**，確認 Spec／驗收與受影響路徑；尚未說「開始」前不建 Worker。
2. 說：「好，開始做吧。請依  `software-team` 的 Contract-Driven SOP，所有派工先產生並驗證 JSON Dispatch，不要用自由文字替代契約。」
3. Manager 檢查 Repo baseline（含未追蹤檔）、完整 Rule Registry。建立 `.ai-work/runs/<run-id>/` 與 Spec／Task，並向 Herdr 新增右側 Coding、Unit Test、Code Review Pane。
4. Manager 用 `scripts/Get-ScopeSnapshot.ps1` 計算當前已存在檔案的 `digest`，在 `dispatch-coding.json` 引用。若新 `src/` 尚不存在，**初始 Scope 不要填不存在的目錄**；Coding 新建檔案後，將它補入後續範圍。
5. Manager 先在磁碟保存 JSON Dispatch，再跑 `scripts/Test-AgentContract.ps1 -Type Dispatch`，成功才用 `herdr agent prompt` 送 `$software-coding` 和 Dispatch JSON 絕對路徑。
6. Coding Worker 自行讀 `software-coding/SKILL.md`、方法 References、`AGENTS.md` 專案 Rules。Coding 完成後回原始 `worker-report.json`。由 Manager 驗證，不能只看 CLI 顯示 DONE。
7. Manager 在 Coding **穩定 checkpoint** 後計算新 Snapshot：範圍必須包括所有 Source/Tests、AGENTS、Rule、當次已核准 Spec。用此 Snapshot 建 `dispatch-test.json`，啟動 Test Worker，必須有真實的命令 Exit Code 與 Test Log。
8. Test PASS 後，建立 `dispatch-review.json`，指向同一版 Snapshot、Test Report，讓 Reviewer 獨立檢查原始程式、Diff（含 untracked）、Spec、Test Evidence。**審查期間 Coding 不得改受檢內容**。
9. Review Worker 用 `--sandbox read-only`，回覆完整、可解析 JSON。Manager **只能原文封存**到 `review-01.json`；若 `agent read` 截斷則不算通過。
10. Manager 驗證 Review 的 JSON Schema、Rule Hash、References Hash、Snapshot 與 `PASS/FAIL/BLOCKED`。如果 Review FAIL 進入第 3 節；PASS 則用第 4 節驗收。

### 常用指令（不要假裝這些會自動開 Pane）

```powershell
$C = 'D:\AI-Company'
$P = 'D:\Workspaces\Software\Project-A'
$Run = 'RUN-001' # 換成實際已建立的 RunId
$D = Join-Path $P ".ai-work\runs\$Run"

# 受檢檔案凍結後；以下 scope 是例子，須對應真實存在的檔案／Spec
& "$C\scripts\Get-ScopeSnapshot.ps1" -ProjectRoot $P -ScopePaths @('AGENTS.md','docs/team-rules','src','tests')

# 先有此 JSON 檔案，再進行驗證
& "$C\scripts\Test-AgentContract.ps1" -Type Dispatch -File "$D\dispatch-review.json" -CompanyRoot $C -ProjectRoot $P
& "$C\scripts\Test-AgentContract.ps1" -Type Report -File "$D\review-01.json" -CompanyRoot $C -ProjectRoot $P
```

注意：范例 `tests` 只有實際存在時才能放入 Scope。Scope 中預設會排除 `.git`、`.ai-work`、`bin`、`obj` 等明列產生目錄；此規則需在專案有特殊檔案時人工審核。

## 3. Review FAIL：保留原始 Findings，不讓 LLM 自由改寫

假設 Review 回 `FAIL`，`findings[0].id` 為 `CR-001`、規則 `PA-ARCH-003`。

```powershell
# 1. 必須保存 Review 原始純 JSON 正文成 review-01.json
# 2. 建立本輪原始 Dispatch，帶有效的可寫範圍（例如 src、tests）
& "$C\scripts\New-RepairRequest.ps1" `
  -SourceReport "$D\review-01.json" `
  -DispatchFile "$D\dispatch-coding.json" `
  -CompanyRoot $C -ProjectRoot $P `
  -OutFile "$D\repair-02.json" `
  -TargetWorkerSkill software-coding

# 3. 再次驗證
& "$C\scripts\Test-AgentContract.ps1" -Type Repair -File "$D\repair-02.json" -CompanyRoot $C -ProjectRoot $P
```

Manager 發送給 Coding Pane 的工作指令只需包含 `$software-coding`、新任務 Dispatch 路徑與 `repair-02.json` 路徑，**不要自己重述或重寫 `CR-001`**。Coding 必須讀原始 Finding，修正並在下一輪報告 `fixes[].finding_id = "CR-001"`。Manager 驗證修復回報時，額外傳入 `-RepairFile "$D\repair-02.json"`，驗證器會拒絕缺少／錯置的 Finding ID 或未解決卻宣稱 PASS。

修正後新 Snapshot → Test → Review；過去的 PASS 與 FAIL 報告保留，但不可再當成新版的驗收證據。同一阻擋問題重複無法修復，最多 3 輪後停止並報 `BLOCKED`。

## 4. 最終 Gate：看證據，不猜字句

假設三個報告都已通過契約驗證且各指向相同最新 Snapshot：

```powershell
& "$C\scripts\Test-QualityGate.ps1" `
  -CompanyRoot $C -ProjectRoot $P `
  -ReportFiles @("$D\coding-final.json","$D\test-final.json","$D\review-final.json") `
  -RequiredWorkerSkills @('software-coding','software-unit-test','software-code-review')
```

預期 `GATE PASS`；任何一個 FAIL、UNKNOWN Skill、Rule Hash 錯誤、版本過期，皆不可進入最終交付。Manager **仍要**檢查真實 Exit Code、測試 Log 與 Code Review 發現是否合理。

## 5. Writing Team / 跨部門

- 寫書的 `writing-writer` → `writing-editor`／`writing-fact-check`／`writing-proofreader` 也使用同一份 `worker-report.schema.json`。
- Editor 的 Blocking Findings 交回 `writing-writer`，使用相同 `repair-request.schema.json`，目標 Skill 改 `writing-writer`。修訂後稿件 Snapshot 變動 → 全部必要審稿重跑。
- 若 Book-A 需要可執行 C# 範例，Guest Software Worker 的 `owner_department = writing`、`assigned_department = software`、`delegation_mode = guest-support`、`delegation_id` 必填；Rule Registry 一律是 Book-A。
- Guest 全部必要 Gate 成功後，由 **Writing Manager** 將 Delegation 標記 `SUBTASK_PASSED`，才整合書稿；Guest Worker 不可直接宣告此狀態。

## 6. 不能以此宣稱的事

- 這套環境的 PowerShell Validator 是**資料契約驗證**，不是強制 LLM 遵從 Prompt 的防火牆。
- SHA-256 是變動偵測，不是數位簽章／防惡意竄改保證。
- 檢查 Snapshot Scope 的完整性仍需 Manager 和 Git Diff 比對；沒被列入 Scope 的檔案不能得到保護。
- 沒有在 Windows 實機執行 Herdr / Codex / Claude 前，不能宣稱端到端自動調度已通過。
