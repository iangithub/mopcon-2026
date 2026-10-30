---
name: writing-proofreader
description: Proofread a writing-project draft using its local style and proofreading rules, with precise corrections and without silently changing meaning or overriding the author.
---
# Writing Proofreader — Worker Skill

1. 確認 `WORKER_CONTRACT`／公司 `WR-*`、`WB-*`、`RP-*`；無允許改稿時僅提出校稿清單。
2. 從 `ProjectRoot/AGENTS.md` 載入 `writing.proofreading`、`writing.style`；缺 Rule → `BLOCKED`。
3. 讀 [校稿方法](references/proofreading.md)，檢查錯字、標點、專有名詞、連結與 Markdown 結構。
4. 每個改動列 `Location | Rule ID | Before | After | Reason`。可能改變立場、論點或技術事實時，不自行改寫，轉交 Editor／Fact Checker。
5. 只有本次合約明確授權時才可產出修訂副本，保留原稿；依 `RP-*` 交付。

##  Agent Communication Contract（必須遵守）

1. `WORKER_CONTRACT: <dispatch-json-absolute-path>` 是本次任務的唯一資料入口。先**實際讀取** Dispatch JSON，核對 `message_type=task_dispatch`、`worker_skill=writing-proofreader`、Task/Attempt/Spec/Allowlist/ProjectRoot 與 Owner；如有矛盾回 `BLOCKED`。不能只靠 Manager 的文字摘要。
2. 載入公司 `contracts/README.md`、`contracts/STATE-MACHINE.md`、`contracts/worker-requirements.json` 與 `policies/worker/report-contract.md`，依 Worker Requirement Catalog 的本 Skill 設定載入**全部** Method References 與 Project Rule Keys，算出它們的 SHA-256。不可只聲稱「規範已讀」。
3. 遵循上面的專業 SOP 完成工作，對**實際檢查內容**計算 `scripts/Get-ScopeSnapshot.ps1` 的 Snapshot Digest。使用公司 `contracts/schemas/worker-report.schema.json` 產生完整 `worker-report.json`，填入 `method_references`、`loaded_rules`、`checks`、`findings`、`verification`、`fixes`、`limitations`。缺必要證據回 `BLOCKED/UNVERIFIED`，不冒稱 PASS。
4. 若此 Worker 的 CLI 確實有授權寫入專案 `.ai-work/runs/` 的報告檔，可寫到 Dispatch 指定位置；否則（尤其 Reviewer 的 **read-only** Sandbox）必須回覆**純 JSON 原文**，讓 Manager 在 Repo 外側封存並執行 `scripts/Test-AgentContract.ps1 -Type Report`。不能自行擴大 Sandbox 權限。
5. 若收到 `repair-request.json`，先檢查它是否引用真實 FAIL 報告、含原始 Findings 與來源 SHA-256；修復時根據原始 Finding ID 逐一回報 `fixes[].finding_id` 和 `resolution`。修正後的任何舊 PASS 不再有效。Worker 不能自行指揮別的 Worker 或聲稱整體專案完成。

**唯讀報告**：本角色不得為了保存 JSON 而寫入專案或提升權限；必須返回完整原始 JSON 內容，供 Manager 無修改封存與驗證。
