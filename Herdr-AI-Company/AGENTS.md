# AI Company — 共用 Repository 指令

- 本 Repository 是全公司的 **Single Source of Truth**，不是業務專案；不在此設 `Department`。
- 專案根 `AGENTS.md` 決定主責與 `## Rule Registry`；同一 Worker Skill 可用於 C#／Python 或寫書中的程式範例，技術標準一律由**目前專案的 Rule** 提供。
- Manager 使用 `software-team`、`writing-team` 編排工作，`company-router` 只負責跨部門 Guest Dispatch；Worker 依 `software-coding`、`software-code-review`、`software-unit-test`、`writing-writer`、`writing-editor` 等專業 Skill 自行讀 References + Rule Registry。
- 公司級安全底線：`policies/worker/`、`policies/manager/`；這些不得被專案 Task 降低。
- Rule 正文不可複製到 Team/Manager Prompt；Manager 只交契約、專案根、Task/Spec、驗收條件及 Worker Skill，Worker 報 Loaded Rules 與實查證據。
- 不允許自動跨 Workspace、變更 Project Owner、碰使用者未核准檔案、無授權 Commit/Push；Skill/Prompt 不是 OS Sandbox。
- 可用部門為 `software` 與 `writing`，正式驗收要求見 `docs/ACCEPTANCE.md`。

- **Agent Contract 唯一來源**：`contracts/` 的 JSON Schema、`worker-requirements.json` 與狀態機；Manager 建立 `task-dispatch.json`，Worker 回 `worker-report.json`，Review FAIL 產生 `repair-request.json`，三者都要透過 `scripts/Test-AgentContract.ps1` 驗證。
- Review / Test PASS 綁定 `scope.snapshot_digest`，修復後舊結果自動失效；唯讀 Reviewer 的原始回覆僅封存、不改寫。
