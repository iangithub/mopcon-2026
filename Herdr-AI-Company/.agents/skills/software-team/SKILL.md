---
name: software-team
description: Manager-only Herdr Software Team orchestration with independent Worker Skills, project-scoped Rule Registry, JSON dispatch/report/repair contracts, frozen-snapshot verification and fail-closed gates. Supports owner and bounded guest mode.
---
# Software Team — Contract-Driven Orchestration

**Manager-only**。如果 `AI_COMPANY_ROLE=worker` 或帶 `WORKER_CONTRACT`，嚴禁執行本 Skill、`herdr` 或再開 Sub-agents。

## 必讀政策

1. 公司 `bootstrap/manager-startup.md`、`contracts/README.md`、`contracts/STATE-MACHINE.md`、`contracts/worker-requirements.json`。
2. `company-router/references/runtime.md`、`dispatch-contract.md`、`ProjectRoot/AGENTS.md`。
3. 公司 `policies/manager/git-commit.md` 與 Worker 執行邊界。技術 Rule 不由 Manager 轉述；由各 Worker Skill 根據本專案 Rule Registry 自行載入。

## 團隊與權限

| Pane | Worker Skill | Kind | 沙箱 | 工作 |
|---|---|---|---|---|
| Coding | `software-coding` | codex | workspace-write | 實作、修復、Self-check |
| Unit Test | `software-unit-test` | codex | workspace-write，預設只驗證 | 真正 Build/Test/Log |
| Code Review | `software-code-review` | codex | read-only | 獨立檢查實際 Diff、規範與測試證據 |
| Repo Scout（選用） | `software-repo-scout` | codex | read-only | 影響分析，不實作 |

Worker 的模型與推理強度以 `config/agent-models.json` 為唯一來源；Manager 使用 `scripts/Start-WorkerAgent.ps1` 在已建立的空 Shell Pane 啟動 Worker，固定角色的 CLI Kind 與 Sandbox。Manager 自己的模型仍由主 Pane 設定；權限必須由實際 CLI Sandbox 實現。

## Owner / Guest

- **owner-work**：`ProjectRoot/AGENTS.md` 的 `Department: software`；最後驗收由本 Manager 負責。
- **guest-support**：`Department: writing`，Writing Manager 核准 XDEPT Delegation；Software Guest 只負責受限程式範例，不變更 Owner、Rule Registry 或其他 Workspace。
- Guest 仍載入當前 Book-A 的 `software.*` Rule（不能借用別的軟體專案）。

## 工作 SOP（不得略過契約驗證）

1. **Planning**：只有需求討論，不開 Worker；使用者授權開工且 Spec/Acceptance 清楚後，記錄 Task、RunId、Baselines（包括 Git untracked）與 Paths。
2. **Dispatch**：在專案 `.ai-work/runs/<run-id>/` 保存各 Worker 的 `task-dispatch.json`。使用 `scripts/Get-ScopeSnapshot.ps1` 得到真正初始 Scope Digest，呼叫 `scripts/Test-AgentContract.ps1 -Type Dispatch`，失敗不派工。
3. **Worker Activation**：使用 Herdr 建三個右側空 Shell Pane；對每個角色呼叫 `scripts/Start-WorkerAgent.ps1 -WorkerSkill <role> -AgentName <name> -PaneId <id>`，由 `config/agent-models.json` 決定模型與推理強度，並實際執行 Herdr `agent start`。Prompt 明確指定 `$software-coding`／`$software-unit-test`／`$software-code-review` **和 Dispatch JSON 絕對路徑**，不是把 Rule 本文塞給 Worker。
4. **Coding Checkpoint**：Coding 先完成穩定檔案版本，回報 `worker-report.json`（Scope 是完成版）；不得在 Reviewer 工作時繼續修改受檢檔案。
5. **Test**：Manager 以完成版的**實際 Source/Tests/Rules/Spec**計算新 Snapshot，在新的 Dispatch 中指定；Test Worker 真正執行專案規範指定命令，回報 Exit Code／Log；用 Validator 驗證 Test 報告，缺真實證據不可算 PASS。
6. **Review**：Review Worker 完整讀程式與 Diff／Untracked、Spec、Test Log，使用 `software-code-review` Skill。Read-only Sandbox 下回覆**完整原始 JSON**；Manager 只能原封不動封存，驗證 Schema/Rule/Method Hash/Snapshot/Status。
7. **FAIL 修復**：若 Test FAIL → Coding 修正；若 Review FAIL → 保留原報告，執行 `scripts/New-RepairRequest.ps1` 精確複製原始 Blocking Findings，Coding 在下一輪 `fixes[].finding_id` 回報修復狀態。重新 Snapshot → Test → Review；不得沿用舊 PASS。最多三輪，超過停止為 BLOCKED。
8. **Quality Gate**：以 `scripts/Test-QualityGate.ps1` 檢查 Coding + Test + Review 全部為有效 PASS，**共同指向目前 Snapshot**；若任一檔案、Rule、Spec 變動，即重新驗證。
9. **Owner Acceptance**：owner-work 由 Software Manager 最終核對交付；guest-support 只把 Guest Gate 結論交回同一 Writing Manager，由 Owner 將 Delegation 標為 `SUBTASK_PASSED`，不可代替整本書驗收。

## 不可妥協

- Reviewer 不得修改 Source，Manager 不得改 Reviewer 原始 Findings 或代填 PASS。
- `BLOCKED`、`UNVERIFIED`、壞 JSON、失效 Snapshot、Rule 失配，全部停止自動推進。
- 所有 Worker 不可 Commit/Push；只有 Manager 在使用者明確授權後依 Git Commit Policy 執行。
- CWD、AllowedWritePaths、Skill 與 JSON Schema **不是 OS ACL**；未能確認沙箱範圍時須提出實際限制。
