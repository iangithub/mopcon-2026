# AI Company — Worker Rule Composition Contract（WR-*）

本檔是所有 Worker Skill 共用的**規範組裝流程**，而不是 C#／Python／Writing 的專業標準。由每個 Worker 自行載入，不由 Manager 拼接完整 Rule。引用來源：`AI_COMPANY_ROOT\policies\worker\rule-composition.md`。

## WR-001：先判斷來源，不臆測專案

1. 先讀 Worker Prompt 的 `WORKER_CONTRACT`；確認 `ProjectRoot`（絕對路徑）、`OwnerDepartment`、`AssignedDepartment`、`WorkerSkill`、`Task`、`AcceptanceCriteria`、讀寫白名單、DelegationMode、輸出位置。
2. 從 `ProjectRoot\AGENTS.md` **實際讀取**唯一一行 `Department: software` 或 `Department: writing`；其值必須等於 `OwnerDepartment`。不以 CWD 或使用者最近提及技術猜測部門。
3. `AI_COMPANY_ROOT` 環境變數必須存在並指向本公司政策根；讀本檔和 `policies/worker/worker-boundary.md`。若環境變數／檔案無法讀取：停止專業動作，回報 `BLOCKED`。
4. 技術型工作即使發生在寫書專案中，也只讀**本書專案根**的 `AGENTS.md`；不能偷換另一個 Software 專案的規範。跨部門必須有有效的 `DelegationId` 及契約檔。

## WR-002：從 Rule Registry 精確載入

專案根 `AGENTS.md` 的 `## Rule Registry` 中，以 Markdown 表格登錄 `Key | Relative Markdown Path`，例如：

| Key | Relative Markdown Path |
| --- | --- |
| software.coding | docs/team-rules/coding.md |
| software.testing | docs/team-rules/testing.md |

Worker Skill 明確列出自己的 `RequiredKeys`。對**每一個 key**：

1. 只接受表格中**唯一、精確匹配**的 key；重複 key、空值、找不到檔案、讀到非 `.md`：回報 `BLOCKED`，不可自行改用其他文件。
2. 路徑必須是 `ProjectRoot` 內的相對路徑，不接受以 `..` 越界、絕對路徑、URL 或其他 Workspace。也應檢查符號連結／Junction 導向是否跳出專案；檢查不確定即停止。
3. 讀取檔案**完整正文**，記錄使用的相對路徑、檔案雜湊 SHA-256（若工具可用）、Rule IDs 與適用條款；不只讀檔名或讓 Manager 口述內容。
4. 若有合法例外，必須已在專案規範或批准的本次 Spec 中明示；不可自行創造例外或把「建議」變成強制標準。

## WR-003：規範優先與衝突處理

1. CLI 實際 sandbox / OS 權限、公司安全底線和 Worker 身分界線優先，**Task / Project 不得放寬**。
2. Worker Skill 的 SOP 與方法 Reference 確定**怎麼做**；Project Rule 才確定**該依什麼技術／編輯標準判斷**。
3. Project Rule 可提供專案特有細節或更嚴格要求，但不得與上層安全底線衝突。
4. 當次 Spec／Task 只定義交付範圍、驗收情境和許可變更，不能偷偷覆寫長期架構或安全規範。
5. 若規則彼此矛盾或同等級無法調和，標 `BLOCKED` 並列出兩份文件、規則編號與衝突內容，交回 Manager 判斷；不得挑對自己容易的一條。

## WR-004：有效規範組合應可稽核

Worker 最後必須附 `Loaded Rules` 表格：`Key | File | Rule IDs | SHA256 / N/A | Applied / N/A`。另列 `Method References Loaded` 和 `Actual Runtime Permissions`。
**只要 RequiredKeys 有缺或未真正讀取，不能回報 PASS。** Manager 需抽查 Worker 報告及專案實際檔案，Rule 載入成功不等於產物合格。

## WR-005：權限不是 Skill 保證

`AllowedWritePaths` 是任務契約，不是作業系統 ACL；CWD、Skill、Prompt 均非強制 sandbox。實際授權不足、權限太寬或工具要求 Sandbox escalation 時，不偷偷放寬，回報 Manager。跨部門 Guest 不改 `Department`，也不直接修改 Owner 禁止的文件。
