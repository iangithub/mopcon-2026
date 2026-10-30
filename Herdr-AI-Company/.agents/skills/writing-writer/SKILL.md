---
name: writing-writer
description: Draft and revise writing-project content using a reusable writing SOP and the specific project's style/editorial rules from AGENTS.md Rule Registry; preserve original drafts and distinguish verified facts from claims needing review.
---
# Writing Writer — Worker Skill

1. 核對 `WORKER_CONTRACT`、Owner Department、Allowlist，載入公司 `WR-*`、`WB-*`、`RP-*`。
2. 由專案根 `AGENTS.md` Rule Registry 完整載入公司 `contracts/worker-requirements.json` 指定的 `required_rule_keys`；缺少 → `BLOCKED`。Guest 必須有有效 Delegation。
3. 讀 [寫作方法](references/drafting.md) 及當次 Brief／讀者定位／章節結構。
4. 撰寫或改寫到**授權的新檔案**；不直接覆蓋原稿，除非本次合約明確允許；未查證的數字、標準或引用標記 `待查證`。
5. 依 `RP-*` 回報正文位置、已載入 Rule、待核實主張與仍需 Editor/Fact Checker 的項目；不得自行宣告整本書完成。

##  Agent Communication Contract（必須遵守）

1. `WORKER_CONTRACT: <dispatch-json-absolute-path>` 是本次任務的唯一資料入口。先**實際讀取** Dispatch JSON，核對 `message_type=task_dispatch`、`worker_skill=writing-writer`、Task/Attempt/Spec/Allowlist/ProjectRoot 與 Owner；如有矛盾回 `BLOCKED`。不能只靠 Manager 的文字摘要。
2. 載入公司 `contracts/README.md`、`contracts/STATE-MACHINE.md`、`contracts/worker-requirements.json` 與 `policies/worker/report-contract.md`，依 Worker Requirement Catalog 的本 Skill 設定載入**全部** Method References 與 Project Rule Keys，算出它們的 SHA-256。不可只聲稱「規範已讀」。
3. 遵循上面的專業 SOP 完成工作，對**實際檢查內容**計算 `scripts/Get-ScopeSnapshot.ps1` 的 Snapshot Digest。使用公司 `contracts/schemas/worker-report.schema.json` 產生完整 `worker-report.json`，填入 `method_references`、`loaded_rules`、`checks`、`findings`、`verification`、`fixes`、`limitations`。缺必要證據回 `BLOCKED/UNVERIFIED`，不冒稱 PASS。
4. 若此 Worker 的 CLI 確實有授權寫入專案 `.ai-work/runs/` 的報告檔，可寫到 Dispatch 指定位置；否則（尤其 Reviewer 的 **read-only** Sandbox）必須回覆**純 JSON 原文**，讓 Manager 在 Repo 外側封存並執行 `scripts/Test-AgentContract.ps1 -Type Report`。不能自行擴大 Sandbox 權限。
5. 若收到 `repair-request.json`，先檢查它是否引用真實 FAIL 報告、含原始 Findings 與來源 SHA-256；修復時根據原始 Finding ID 逐一回報 `fixes[].finding_id` 和 `resolution`。修正後的任何舊 PASS 不再有效。Worker 不能自行指揮別的 Worker 或聲稱整體專案完成。
