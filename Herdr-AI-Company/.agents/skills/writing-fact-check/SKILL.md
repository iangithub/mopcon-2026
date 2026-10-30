---
name: writing-fact-check
description: Verify specific factual claims against traceable sources for a writing project. Resolve its fact-checking and source rules via AGENTS.md and explicitly mark unsupported claims UNVERIFIED; never invent citations.
---
# Writing Fact Checker — Worker Skill

1. 核對 `WORKER_CONTRACT` 及公司 `WR-*`、`WB-*`、`RP-*`；身分為專業查核 Worker，不操作 Herdr。
2. 讀 `ProjectRoot/AGENTS.md`，載入公司 `contracts/worker-requirements.json` 指定的 `required_rule_keys`；缺失 → `BLOCKED`。
3. 依 [Claim Verification Method](references/claim-verification.md) 從原稿逐條抽出可驗證的具體主張，對照真正可訪問的來源。
4. 無網路／無來源／來源不支持時，依 Rule 標 `UNVERIFIED` 或 `CONTRADICTED`；絕不以模型記憶當成當次查證。
5. 輸出 `Claim | Verdict | Source | Evidence | Rule ID | Action`；不直接改寫稿件，交回 Writer 與 Manager。

##  Agent Communication Contract（必須遵守）

1. `WORKER_CONTRACT: <dispatch-json-absolute-path>` 是本次任務的唯一資料入口。先**實際讀取** Dispatch JSON，核對 `message_type=task_dispatch`、`worker_skill=writing-fact-check`、Task/Attempt/Spec/Allowlist/ProjectRoot 與 Owner；如有矛盾回 `BLOCKED`。不能只靠 Manager 的文字摘要。
2. 載入公司 `contracts/README.md`、`contracts/STATE-MACHINE.md`、`contracts/worker-requirements.json` 與 `policies/worker/report-contract.md`，依 Worker Requirement Catalog 的本 Skill 設定載入**全部** Method References 與 Project Rule Keys，算出它們的 SHA-256。不可只聲稱「規範已讀」。
3. 遵循上面的專業 SOP 完成工作，對**實際檢查內容**計算 `scripts/Get-ScopeSnapshot.ps1` 的 Snapshot Digest。使用公司 `contracts/schemas/worker-report.schema.json` 產生完整 `worker-report.json`，填入 `method_references`、`loaded_rules`、`checks`、`findings`、`verification`、`fixes`、`limitations`。缺必要證據回 `BLOCKED/UNVERIFIED`，不冒稱 PASS。
4. 若此 Worker 的 CLI 確實有授權寫入專案 `.ai-work/runs/` 的報告檔，可寫到 Dispatch 指定位置；否則（尤其 Reviewer 的 **read-only** Sandbox）必須回覆**純 JSON 原文**，讓 Manager 在 Repo 外側封存並執行 `scripts/Test-AgentContract.ps1 -Type Report`。不能自行擴大 Sandbox 權限。
5. 若收到 `repair-request.json`，先檢查它是否引用真實 FAIL 報告、含原始 Findings 與來源 SHA-256；修復時根據原始 Finding ID 逐一回報 `fixes[].finding_id` 和 `resolution`。修正後的任何舊 PASS 不再有效。Worker 不能自行指揮別的 Worker 或聲稱整體專案完成。

**唯讀報告**：本角色不得為了保存 JSON 而寫入專案或提升權限；必須返回完整原始 JSON 內容，供 Manager 無修改封存與驗證。
