---
name: software-code-review
description: Independent read-only review of a task-introduced code change. Load method references for architecture, code quality, and tests, then resolve the current project's actual rules from AGENTS.md Rule Registry. Report evidence-based findings; never fix files or orchestrate agents.
---
# Software Code Review — Worker Skill

**只能在確實具有 Read-only 權限的 Review Worker 中執行。** 不以 Coding 摘要或 Test 全綠代替獨立審查。

1. 讀 `WORKER_CONTRACT` 及公司 `WR-*`、`WB-*`、`RP-*`；檢查實際 Read-only Sandbox 與 `ProjectRoot`，不執行 Herdr/commit，不寫 Source。
2. 讀本專案 `AGENTS.md` 的 Rule Registry，完整載入公司 `contracts/worker-requirements.json` 內本 Skill 的 `required_rule_keys`。Guest 的專案 Owner 可以是 writing，但 Rule 仍須來自**本書專案**。缺 Rule／Spec／基線 → `BLOCKED`。
3. 自行取得實際改動：Git 專案檢查 `git status --porcelain=v1 --untracked-files=all`、`git diff HEAD`（含 staged/unstaged）與未追蹤檔案正文；沒有 Git 則讀 Manager 保存的實際 baseline 清單與授權範圍內的檔案。**不要直接相信 Coding 的修改清單**。
4. 依 [架構審查方法](references/architecture-review.md) 核對模組與資料存取；依 [程式品質審查方法](references/code-quality-review.md) 核對規則、Spec、變更邊界；依 [測試審查方法](references/test-review.md) 讀實際 assertion 與當次測試證據。
5. 對每個 Finding 列規則 Key / ID、檔案位置、實際證據、影響與建議。必要規範違反／Spec 不符是 `BLOCKING`；非必要改善列 `NON-BLOCKING`。
6. 依 `RP-*` 回報 `PASS`／`FAIL`／`BLOCKED`。不修復 Findings；交回 Coding Worker 經 Manager 派工，再重新審查修訂 Diff。

##  Agent Communication Contract（必須遵守）

1. `WORKER_CONTRACT: <dispatch-json-absolute-path>` 是本次任務的唯一資料入口。先**實際讀取** Dispatch JSON，核對 `message_type=task_dispatch`、`worker_skill=software-code-review`、Task/Attempt/Spec/Allowlist/ProjectRoot 與 Owner；如有矛盾回 `BLOCKED`。不能只靠 Manager 的文字摘要。
2. 載入公司 `contracts/README.md`、`contracts/STATE-MACHINE.md`、`contracts/worker-requirements.json` 與 `policies/worker/report-contract.md`，依 Worker Requirement Catalog 的本 Skill 設定載入**全部** Method References 與 Project Rule Keys，算出它們的 SHA-256。不可只聲稱「規範已讀」。
3. 遵循上面的專業 SOP 完成工作，對**實際檢查內容**計算 `scripts/Get-ScopeSnapshot.ps1` 的 Snapshot Digest。使用公司 `contracts/schemas/worker-report.schema.json` 產生完整 `worker-report.json`，填入 `method_references`、`loaded_rules`、`checks`、`findings`、`verification`、`fixes`、`limitations`。缺必要證據回 `BLOCKED/UNVERIFIED`，不冒稱 PASS。
4. 若此 Worker 的 CLI 確實有授權寫入專案 `.ai-work/runs/` 的報告檔，可寫到 Dispatch 指定位置；否則（尤其 Reviewer 的 **read-only** Sandbox）必須回覆**純 JSON 原文**，讓 Manager 在 Repo 外側封存並執行 `scripts/Test-AgentContract.ps1 -Type Report`。不能自行擴大 Sandbox 權限。
5. 若收到 `repair-request.json`，先檢查它是否引用真實 FAIL 報告、含原始 Findings 與來源 SHA-256；修復時根據原始 Finding ID 逐一回報 `fixes[].finding_id` 和 `resolution`。修正後的任何舊 PASS 不再有效。Worker 不能自行指揮別的 Worker 或聲稱整體專案完成。

**唯讀報告**：本角色不得為了保存 JSON 而寫入專案或提升權限；必須返回完整原始 JSON 內容，供 Manager 無修改封存與驗證。
