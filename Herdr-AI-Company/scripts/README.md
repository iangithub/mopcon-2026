# 正式作業工具（scripts）

以下四支驗證／交接工具與一支啟動器是 **Manager 依 Team Skill 在任務流水線中呼叫的工具**。它們不是 Herdr Agent、Skill，也不會自行建立 Pane。腳本不會自動執行；Manager 必須依對應關卡明確呼叫並檢查失敗狀態。

| 程式 | 使用階段 | 作用 | 是否修改應用原始碼 |
|---|---|---|---|
| `scripts/Start-WorkerAgent.ps1` | Worker Pane 建立後，Task Dispatch 前 | 讀取 `config/agent-models.json`，固定角色 Kind 與 Codex Sandbox，傳入獨立 Model/Effort 並啟動 Herdr Agent；`-Preview` 不啟動 | 否 |
| `scripts/Get-ScopeSnapshot.ps1` | Dispatch 前、Coding Checkpoint、修復後 | 計算指定受檢檔案清單的 SHA-256 指紋；可選擇寫入 Snapshot 檔 | 否 |
| `scripts/Test-AgentContract.ps1` | Dispatch／Report／Repair 交接 | 檢查 JSON Schema、Rule／Method Hash、Snapshot 與相關契約約束 | 否 |
| `scripts/New-RepairRequest.ps1` | Review FAIL | 從原始 Blocking Findings 產生標準修復請求，保留原文及來源 Hash | 否；只寫新 Repair JSON |
| `scripts/Test-QualityGate.ps1` | 必要 Worker 回報齊全後 | 確認指定必要 Worker 均有有效 PASS，指向相同最新 Snapshot | 否 |

執行範例與完整關卡對照請讀 [docs/EXECUTION-FLOW.md](../docs/EXECUTION-FLOW.md)，契約規格請讀 [contracts/README.md](../contracts/README.md)。

**限制**：JSON、Hash 與 Gate 驗證是資料一致性檢查，不能單獨證明 LLM 實際執行了測試或專業審查；仍需要真實 Log、Diff 和來源證據。`RequiredWorkerSkills` 由 Team Skill 的必要角色決定，Manager 不應為了讓 Gate 通過而任意刪減。
