# Worker Dispatch Contract — 標準化 JSON 派工

**唯一依據：`AI_COMPANY_ROOT/contracts/schemas/task-dispatch.schema.json` 和 `contracts/README.md`。**

## Manager 實作 SOP

1. 讀 `ProjectRoot/AGENTS.md`、Owner Team Skill、`contracts/worker-requirements.json`，確認 Work Scope/Spec、專案 Rule Registry 都存在。
2. 針對每個 Worker，將 `run_id`、`task_id`、`attempt`、`worker_skill`、`ProjectRoot`、Owner/Assigned Department、Delegation ID、`AcceptanceCriteria`、`AllowedWritePaths` 等填入 `task-dispatch.json`。
3. `snapshot.scope_paths` 包含**實際受檢程式／稿件／測試／規範／Spec**，digest 由 `scripts/Get-ScopeSnapshot.ps1` 在實際磁碟計算，不可自己編造。
4. 在專案 `.ai-work/runs/<run-id>/` 保存，呼叫 `scripts/Test-AgentContract.ps1 -Type Dispatch -CompanyRoot ... -ProjectRoot ... -File ...`。只有 exit 0 能派工。
5. Manager 向 Worker 發送一句明確 Skill 呼叫＋**已驗證 Dispatch 絕對路徑**，例如：

   Codex（PowerShell 單引號 here-string，避免 `$` 展開）：

   ```text
   $software-code-review
   WORKER_CONTRACT: D:\Workspaces\Software\Project-A\.ai-work\runs\RUN-001\dispatch-review.json
   Read full JSON. Apply your own SKILL.md + references + project Rule Registry. Return an unchanged, complete worker-report JSON. Never control Herdr or spawn agents.
   ```

   Claude：將 `/writing-writer` 放在 Prompt 開頭，後面同樣接 `WORKER_CONTRACT: <absolute path>`。需實機確認 Slash Skill 啟用；若未啟用停止。

6. Worker 必須實際讀 Dispatch、核對專案 Owner 與 Worker Skill 一致，再執行 SOP；不能由 Manager 貼 Rule 文字替代。

## Worker Report / Failure

- Worker 回 `worker-report.json`，格式是 `contracts/schemas/worker-report.schema.json`；唯讀 Worker 以完整、原始、純 JSON 交接，由 Manager 逐字封存。
- 必須驗證 Schema、Rule Registry Hash、References Hash、Scope Snapshot、Status 邏輯；不能從 Chat 的「我完成了」推出 PASS。
- FAIL 時使用 `scripts/New-RepairRequest.ps1` 從原始報告產生標準 Repair Request；不要再用自由文字重述問題。
- 修復後再建立新 Snapshot、重執行 Test/Review，最後由 `scripts/Test-QualityGate.ps1` 檢查相同最新版本。

這些契約只是**可驗證的資料與流程規格**，不會自行替你調用 Herdr 或建立 Worker。Pane 仍由 `runtime.md` 操作，Runtime 實際權限仍獨立驗證。
