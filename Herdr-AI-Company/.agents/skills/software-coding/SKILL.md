---
name: software-coding
description: Implement an approved software task as a Herdr Worker using a reusable coding SOP; load project-specific architecture, coding and security rules from AGENTS.md Rule Registry, without requiring the Manager to paste those rules. Not an orchestration skill.
---
# Software Coding — Worker Skill

**只供 Coding Worker 執行；Manager 派工時明確要求本 Skill。** 只定義 SOP，不內建 .NET、DDD、Python 或特定 Framework 的技術標準。

1. **Identity & guard**：先確認 `WORKER_CONTRACT`、`AI_COMPANY_ROLE=worker`；禁止 Herdr 控制、其他 Agent 與 Git commit。讀 `AI_COMPANY_ROOT/policies/worker/{rule-composition,worker-boundary,report-contract}.md`，逐條遵守。
2. **Resolve Rule Registry**：讀 `ProjectRoot/AGENTS.md`，核對 `OwnerDepartment`；依公司 `contracts/worker-requirements.json` 本 Skill 的 `required_rule_keys` 與 `WR-*` 精確載入。任何必要 Rule 缺失／衝突 → `BLOCKED`，不自造規範。Guest 在 `Department: writing` 專案也讀本專案自己的三個 key，並讀 Delegation。
3. **Read methods**：讀 [實作方法](references/implementation.md)；依 Spec、既有系統與允許路徑決定最小必要變更。
4. **Implement**：尊重現有架構與使用者未提交修改；實作必要測試（若未由 Test Worker 明確接手），不改不相關檔案。
5. **Self-check**：按專案 Rule 選擇可用編譯／靜態檢查／測試指令；如未執行不得宣稱成功。保留可供獨立 Reviewer 檢查的檔案和證據。
6. **Handoff**：依 `RP-*` 回報實際修改、指令、Rule IDs、來源／缺口；不直接宣布總任務通過。

##  Agent Communication Contract（必須遵守）

1. `WORKER_CONTRACT: <dispatch-json-absolute-path>` 是本次任務的唯一資料入口。先**實際讀取** Dispatch JSON，核對 `message_type=task_dispatch`、`worker_skill=software-coding`、Task/Attempt/Spec/Allowlist/ProjectRoot 與 Owner；如有矛盾回 `BLOCKED`。不能只靠 Manager 的文字摘要。
2. 載入公司 `contracts/README.md`、`contracts/STATE-MACHINE.md`、`contracts/worker-requirements.json` 與 `policies/worker/report-contract.md`，依 Worker Requirement Catalog 的本 Skill 設定載入**全部** Method References 與 Project Rule Keys，算出它們的 SHA-256。不可只聲稱「規範已讀」。
3. 遵循上面的專業 SOP 完成工作，對**實際檢查內容**計算 `scripts/Get-ScopeSnapshot.ps1` 的 Snapshot Digest。使用公司 `contracts/schemas/worker-report.schema.json` 產生完整 `worker-report.json`，填入 `method_references`、`loaded_rules`、`checks`、`findings`、`verification`、`fixes`、`limitations`。缺必要證據回 `BLOCKED/UNVERIFIED`，不冒稱 PASS。
4. 若此 Worker 的 CLI 確實有授權寫入專案 `.ai-work/runs/` 的報告檔，可寫到 Dispatch 指定位置；否則（尤其 Reviewer 的 **read-only** Sandbox）必須回覆**純 JSON 原文**，讓 Manager 在 Repo 外側封存並執行 `scripts/Test-AgentContract.ps1 -Type Report`。不能自行擴大 Sandbox 權限。
5. 若收到 `repair-request.json`，先檢查它是否引用真實 FAIL 報告、含原始 Findings 與來源 SHA-256；修復時根據原始 Finding ID 逐一回報 `fixes[].finding_id` 和 `resolution`。修正後的任何舊 PASS 不再有效。Worker 不能自行指揮別的 Worker 或聲稱整體專案完成。
