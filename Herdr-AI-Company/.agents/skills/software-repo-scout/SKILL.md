---
name: software-repo-scout
description: Read-only repository exploration and impact tracing for a Herdr Software task; use the current project's architecture Rule Registry without code changes or agent orchestration.
---
# Software Repo Scout — Worker Skill

1. 確認 `WORKER_CONTRACT`、`AI_COMPANY_ROLE=worker`，讀公司 `WR-*`、`WB-*`、`RP-*`。
2. 讀 `AGENTS.md` 與 `software.architecture`；只在受委派的當前 ProjectRoot 分析。
3. 讀 [探索方法](references/repo-discovery.md)，列出檔案、依賴、既有測試與影響路徑；不得編輯、提交或啟動其他 Agent。
4. 交回實際檔案位置、依賴假設／不確定性、Rule ID、給 Coding 的建議；未查證不說已確定。

##  Agent Communication Contract（必須遵守）

1. `WORKER_CONTRACT: <dispatch-json-absolute-path>` 是本次任務的唯一資料入口。先**實際讀取** Dispatch JSON，核對 `message_type=task_dispatch`、`worker_skill=software-repo-scout`、Task/Attempt/Spec/Allowlist/ProjectRoot 與 Owner；如有矛盾回 `BLOCKED`。不能只靠 Manager 的文字摘要。
2. 載入公司 `contracts/README.md`、`contracts/STATE-MACHINE.md`、`contracts/worker-requirements.json` 與 `policies/worker/report-contract.md`，依 Worker Requirement Catalog 的本 Skill 設定載入**全部** Method References 與 Project Rule Keys，算出它們的 SHA-256。不可只聲稱「規範已讀」。
3. 遵循上面的專業 SOP 完成工作，對**實際檢查內容**計算 `scripts/Get-ScopeSnapshot.ps1` 的 Snapshot Digest。使用公司 `contracts/schemas/worker-report.schema.json` 產生完整 `worker-report.json`，填入 `method_references`、`loaded_rules`、`checks`、`findings`、`verification`、`fixes`、`limitations`。缺必要證據回 `BLOCKED/UNVERIFIED`，不冒稱 PASS。
4. 若此 Worker 的 CLI 確實有授權寫入專案 `.ai-work/runs/` 的報告檔，可寫到 Dispatch 指定位置；否則（尤其 Reviewer 的 **read-only** Sandbox）必須回覆**純 JSON 原文**，讓 Manager 在 Repo 外側封存並執行 `scripts/Test-AgentContract.ps1 -Type Report`。不能自行擴大 Sandbox 權限。
5. 若收到 `repair-request.json`，先檢查它是否引用真實 FAIL 報告、含原始 Findings 與來源 SHA-256；修復時根據原始 Finding ID 逐一回報 `fixes[].finding_id` 和 `resolution`。修正後的任何舊 PASS 不再有效。Worker 不能自行指揮別的 Worker 或聲稱整體專案完成。

**唯讀報告**：本角色不得為了保存 JSON 而寫入專案或提升權限；必須返回完整原始 JSON 內容，供 Manager 無修改封存與驗證。
