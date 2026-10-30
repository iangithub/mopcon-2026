# Cross-Department Policy — XDEPT-*（公司共用）

| ID | 必要政策 |
|---|---|
| **XDEPT-001** | 專案根 AGENTS.md 的 Department 是永久主責；一次委派不得改變。 |
| **XDEPT-002** | 支援以專業成果為依據，不以 Code/Book 等關鍵字猜主責或任意調派。 |
| **XDEPT-003** | Guest 派遣前必須有 Delegation ID、可驗收子任務、Owner、讀寫範圍、禁止路徑及返回對象。 |
| **XDEPT-004** | Guest 不修改 AGENTS.md、原手稿、Production Code 或別的 Workspace，除非 Owner 對特定位置有明確授權。 |
| **XDEPT-005** | Guest 是 Worker，不得執行任何 Herdr 編排或啟動 Sub-agent；只有原 Owner Manager 可派工。 |
| **XDEPT-006** | Guest 回報實際產出、專案 `Rule Registry` 的 Loaded Rules（Key/File/ID/Hash）、命令/來源與 Review Findings；沒有證據不能 PASS。 |
| **XDEPT-007** | Guest Worker 分別回標準 JSON `PASS/FAIL/BLOCKED/UNVERIFIED`；只有原 Owner Manager 驗證 Guest Gate 後可將 Delegation 標成 `SUBTASK_PASSED`。 |
| **XDEPT-008** | Guest 成果進入 Owner 的主要產物前，需核對真正檔案差異與白名單、隔離既有使用者變更。 |
| **XDEPT-009** | CWD、Skill、Prompt Allowlist **都不是 OS ACL**；任何未經驗證的隔離不能宣稱安全完成。 |
| **XDEPT-010** | Worker CLI / Skill / 權限、Workspace、Rule Registry 不符合時停止，不默默重用或提升權限。 |

**Rule 分層**：本檔是公司跨部門政策；Worker Skill 自行讀 `ProjectRoot/AGENTS.md` 登錄的 `software.*` 或 `writing.*` Rule。**公司政策不應複製專案專屬的 DDD、C# 或編輯風格 Rule**。

##  Guest 契約品質門

- XDEPT Guest 個別 Worker 仍使用 `contracts/schemas/{task-dispatch,worker-report}.schema.json`，完整保留 OwnerDepartment（AGENTS.md）與 AssignedDepartment（Guest）。
- 唯一 Owner Manager 必須驗證 Guest Report、原始 Review Findings 與同一最新 Scope Digest，再把 Delegation 標為 `SUBTASK_PASSED`；不以 Worker 自稱成功當成跨部門驗收。
