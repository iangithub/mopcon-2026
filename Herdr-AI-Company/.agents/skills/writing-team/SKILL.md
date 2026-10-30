---
name: writing-team
description: Manager-only Herdr Writing Team orchestration with contract-driven Writer, Editor, Fact Checker, Proofreader and Researcher workers; reusable professional Skills, project-scoped editorial Rules, immutable findings and version-bound review gates.
---
# Writing Team — Contract-Driven Orchestration

**Manager-only**；Worker 不可啟用本 Skill、`herdr` 或 Sub-agents。先讀公司 Bootstrap、`contracts/README.md`、`contracts/STATE-MACHINE.md`、`company-router/references/runtime.md` 及本專案 `AGENTS.md`。

## 主責與支援

- `owner-work`：Department=writing，本 Manager 負責章節交付與最後驗收。
- `guest-support`：Department=software 且有正式 XDEPT Delegation，只修訂准許的技術文件；Owner 仍是 Software Manager。
- 寫書需要可執行範例時，在同一書籍 Workspace 使用 Company Router 指派 Software Guest；Guest 個別回 JSON PASS/FAIL，Owner 驗證後才記錄 SUBTASK_PASSED。

## Worker Catalog

| Worker | CLI kind（建議） | Worker Skill | 用途 |
|---|---|---|---|
| Writer | claude | `writing-writer` | 初稿、依 Finding ID 修訂 |
| Editor | codex/read-only | `writing-editor` | 架構、讀者適切性、論證 |
| Fact Checker | codex/read-only + 已驗證來源能力 | `writing-fact-check` | 主張查核，無來源即 UNVERIFIED |
| Proofreader | codex/read-only | `writing-proofreader` | 錯字、格式、用詞一致性 |
| Researcher | claude（按需） | `writing-researcher` | 來源研究，不能編造引證 |

Rule/Reference 的唯一配置表位於公司 `contracts/worker-requirements.json`，專案的詳細編輯規範位於本專案 `AGENTS.md` 所登錄的 Rule 檔案。各 Worker 的模型與推理強度從 `config/agent-models.json` 取得，由 Manager 在建立空 Shell Pane 後透過 `scripts/Start-WorkerAgent.ps1` 實際啟動，不繼承 Manager 的模型設定。

## SOP

1. **Planning**：討論章節 Brief、受眾、Outline、驗收條件，使用者尚未授權時不開 Worker。
2. **Dispatch**：建立 `.ai-work/runs/<run-id>/`，記錄原稿基線；用 JSON Schema `task-dispatch` 為每位必需 Worker 分別存檔，呼叫 `scripts/Test-AgentContract.ps1` 驗證；讀寫邊界要具體。
3. **Draft**：使用 `scripts/Start-WorkerAgent.ps1 -WorkerSkill writing-writer` 以公司模型配置在 Writer 的空 Shell Pane 啟動 CLI，然後 Writer 啟用 `/writing-writer`（需在 CLI 實機驗證），自行讀 SOP/References/本專案 Rules。Writer 可以在授權範圍產稿，不得未經允許覆蓋原稿。
4. **Frozen Snapshot**：以目前稿件、Brief/Spec、Rule 檔案產生新的 `scope.snapshot_digest`，在審稿期間不修改這些內容。
5. **Independent Reviews**：Editor/Fact Checker/Proofreader 各用自己的 Skill、不同 Pane，產出遵守 JSON Schema 的 `worker-report`；Read-only Worker 回純 JSON 原文，Manager 原封不動保存。Fact Checker 沒來源不能自稱 VERIFIED。
6. **Review FAIL**：將 Editor/Proofreader/Fact Checker 的 **Blocking Findings** 透過 `scripts/New-RepairRequest.ps1` 產生 `repair-request.json`，交給 Writer；不得用 Manager 改寫 Findings。Writer 的下一輪 Report 以 `fixes[].finding_id` 回報修復證據。
7. **Recheck**：修訂後全部涉及同一稿件的舊 PASS 失效，建立新 Snapshot，重跑必要審稿／查核／校稿；直到都 PASS 或明確 BLOCKED，最多三輪。
8. **Gate & Acceptance**：`scripts/Test-QualityGate.ps1` 對當次宣告必要的 Workers 檢查有效 PASS、同一最新 Snapshot。Owner Manager 才能整合定稿與使用者報告。若存在需要核實的關鍵主張，`UNVERIFIED` 不可視為已核實。

## 安全與界線

- 不同 Worker 不可同時修改相同稿件；Editor/Fact Checker/Proofreader 預設只讀。
- 真正的來源檢索、引用與進行中的 Session 必須可核對；Skill 不等於 OS Sandbox。
- 不跨專案套 Rule、不自動 Commit/Push、不變更 AGENTS.md Department。
