---
name: company-router
description: Herdr AI Company executive dispatcher for genuine cross-department expert subtasks. Respect the exact project AGENTS.md Department as permanent owner, create bounded guest delegations, and return results to the same owner manager. Not a worker skill.
---
# Company Router — 跨部門派遣

**Manager-only**；若 `AI_COMPANY_ROLE=worker` 或有 `WORKER_CONTRACT`，不得使用本 Skill，不得跑 Herdr。

## 決策流程

1. 確認 Herdr Workspace / 根 Pane / `ProjectRoot`。讀根目錄 `AGENTS.md` 唯一 `Department: software|writing`；缺少則先請 Owner 一次性設定，不猜。
2. `planning` 不建 Guest Pane；使用者核准執行，且專業子任務確實需要另一部門交付成果（或明確要求支援），才進入 `guest-support`。在書中談論程式碼不代表需要 Software Guest，交付**可執行、可測試範例**才是具體需求。
3. 讀 [跨部門政策](references/cross-department-policy.md) 與 [Delegation 合約](references/cross-department-contract.md)。交由 Owner Manager 在本專案 `.ai-work/runs/<run-id>/delegations/<id>.md` 保存授權的子任務、範圍、禁改路徑與驗收標準。
4. 確認**同一個專案** `AGENTS.md` 的 `## Rule Registry` 能供 Guest Worker Skills 載入必要 keys。例如 Book-A 的 Software Guest 必須讀 Book-A `software.*`，**不能**拿另一個 Project-A 的 Rules 來代替。
5. Manager 讀 [Runtime](references/runtime.md) 及 [Worker Dispatch Contract](references/dispatch-contract.md)，在**目前專案 Workspace** 建立右側 Worker Pane，並使用 `scripts/Start-WorkerAgent.ps1` 按公司模型配置啟動 Worker，傳入 Owner/Guest/Skill/Task/Scope/Baseline/DelegationId，並以 `$skill` 或 `/skill` 明確指定 Worker Skill。
6. Manager 先以 `contracts/schemas/task-dispatch.schema.json` 建立 Guest Dispatch（Owner 永遠是同一個 Project），依 `scripts/Test-AgentContract.ps1` 驗證後交 Worker；Worker 自行執行 Skill SOP → References → 專案 Rule Registry；不由 Manager 拼接 Rule 正文。Review/Fact 回覆必須是可驗證的 `worker-report.json`。
7. Guest Worker 個別回 `PASS|FAIL|BLOCKED|UNVERIFIED`；Owner Manager 驗證 Guest Gate 的最新 Snapshot 後，才於 XDEPT Delegation 記錄 `SUBTASK_PASSED`，整合成果、驗收原始任務。`Department` 全程不變。

## 不得做的事

- 不從自然語言或資料夾名稱猜 `Department`，不擅改 `AGENTS.md`。
- 不讓 Guest 成為第二位 Manager、不跨 Workspace 寫入、不允許 Worker 再委派其他 Agent。
- 不把 `AllowedWritePaths`、CWD 或 Skill 指令宣稱為 OS ACL。缺少受檢權限，停下回報。
- 不允許 Worker 使用原生 Codex/Claude Sub-agent 再開一層未受控編排；這套環境每個 Pane 一位獨立 CLI Worker。
