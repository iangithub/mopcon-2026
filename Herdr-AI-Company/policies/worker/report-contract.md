# AI Company — Worker Report Contract（RP-*）

本檔是 Worker 回報契約的共用入口；**唯一資料 Schema 與狀態判定定義位於 `AI_COMPANY_ROOT/contracts/`**。Worker 必須先讀：

- `contracts/README.md`：AC-* 派工／報告／修復與 Rule 來源約定。
- `contracts/STATE-MACHINE.md`：ST-* PASS/FAIL/BLOCKED 和失效條件。
- `contracts/schemas/worker-report.schema.json`：精確 JSON 報告格式。
- `contracts/worker-requirements.json`：各 Worker 必須讀的 Rule Keys、Method References。

- **RP-001** 不能以其他 Agent 的摘要代替實查 Diff、檔案、Build/Test Log 或一手來源。
- **RP-002** 無必要 Rule、Spec、真實測試證據、來源或受檢權限時不可回 PASS；對應 `BLOCKED` 或 `UNVERIFIED`。
- **RP-003** 必須產生原始、完整、可解析的 `worker-report.json`；程式／稿件交付不代表自動 Git Commit。
- **RP-004** Code Reviewer／Editor 的 FAIL Finding 不准由 Manager 改寫；傳給 Coding/Writer 時使用 `repair-request` 契約保留原始物件與來源雜湊。
- **RP-005** 每份報告綁定 `scope.snapshot_digest`；修復後以前的 PASS 不再有效，需重新驗證。
- **RP-006** 唯讀 Worker 以回覆純 JSON 原文交接；Manager 僅能逐字封存及驗證，不能變更欄位。長回覆截斷則是 `BLOCKED`，不得補字猜測。
- **RP-007** 在 Manager 真正執行 `scripts/Test-AgentContract.ps1` 與品質門檢驗通過前，Worker 的 `status: PASS` 僅是待驗收主張。
