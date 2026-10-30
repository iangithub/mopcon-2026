# 實測：Book-A Writing Owner 請 Software Guest 製作可執行程式範例

**目標：確認同一個 `software-code-review` Skill，在 Book-A 專案中只載入該專案的 `EX-*` Rules，而不引用 Project-A 的 `PA-*` Rules。**

## 前置條件

1. 已依 WORKSHOP.md 安裝官方 Herdr Skill、全部 Worker Skill Junction 與兩個全域 Bridge，並在新 CLI Session 驗證可載入。
2. 透過 `tests/Verify-RuleRegistry.ps1` 確認 Book-A `Department: writing`、`software.*` / `writing.*` keys 都存在，且檔案可讀。
3. 新建或選擇 Book-A 的 Herdr Workspace；Root Pane 的 CWD 應是 Book-A 專案根，Manager 使用 Codex CLI。
4. 已安裝 .NET 8 SDK、NuGet 套件可合法還原。若未滿足，測試仍可觀察調度，但 **Build/Test 未執行不能評為完整 PASS**。

## 對話一：需求討論（不得先開 Pane）

> 我正在撰寫一本 AI Agent 的技術書。先討論如何解釋多代理分工，也需要一個足以讓讀者自己執行的程式範例。現在先討論，不要動工。

期望：Manager 在 Book-A 讀到 `Department: writing`，維持 Planning。可以提出大綱、建議與驗收情境，但不能直接開三個 Software Pane。

## 對話二：定案具體子任務

> 這次範例用 .NET 8 / C#，做一個最小計價計算器（只做整數加總，不接資料庫），要有有效的 Unit Test。請保留 `drafts/` 原稿，不更動 `AGENTS.md`，程式只放在 `examples/example-01/`。Build、Test、Review 結果要能核對。先確認這些驗收條件。

期望：Manager 以已確認內容記錄 Brief/Acceptance、`DelegationId=example-01`、允許路徑與禁止路徑。這只是一個**當次 Task**，不應被寫回 Book-A 的長期 `project-context`／Rule。

## 對話三：開工

> 好，就照剛才定案的內容開始。請由 Writing Manager 調派 Software Guest Coding、Unit Test、Code Review，完成後把實際測試與審查證據交回 Writing Team，最後由 Writing Manager 整合成章節修訂稿。

期望 Manager 產生 `.ai-work/runs/<run-id>/delegations/example-01.md`，包含：

```text
ProjectRoot: D:\Workspaces\Writing\Book-A
OwnerDepartment: writing
AssignedDepartment: software
DelegationMode: guest-support
DelegationId: example-01
AllowedWritePaths: examples/example-01/**
ForbiddenWritePaths: AGENTS.md, drafts/**, sources/**, ../**, other workspaces
GuestWorkerSkills: software-coding, software-unit-test, software-code-review
ReturnTo: original Writing Manager
```

Guest Worker PANE 都位於**Book-A Workspace**；每個 `WORKER_CONTRACT` 指向 Book-A `AGENTS.md`，並設 `AI_COMPANY_ROOT`。允許新建 `examples/example-01/`，但不能直接改稿件。

## 逐步驗收

| 階段 | 必須看的證據 | 不可接受 |
|---|---|---|
| Router | XDEPT Delegation、Owner writing 不變 | 要求改 Department 或換去 Project-A |
| Coding Worker | 明確執行 `$software-coding`、讀其 methods 與 Book-A `code-examples.md`（EX-ARCH/EX-CODE/EX-SEC） | 引用 Project-A `PA-CODE-*` 或只稱「我有遵守 Rule」 |
| Unit Test | 明確執行 `$software-unit-test`，真實 `dotnet build/test`、Exit Code、Assertions | 沒執行就回 PASS |
| Code Review | 明確執行 `$software-code-review`，讀其三個 `references/`，真實 read-only、Code/Test 證據、Book-A `EX-REV-*` | 只相信 Coding 摘要、Reviewer 直接修改程式 |
| Handoff | Guest 各 Worker 的有效 JSON `PASS/FAIL/BLOCKED/UNVERIFIED`、有效 Snapshot、真實 Build/Test/Review；Owner 驗證後 Delegation `SUBTASK_PASSED` | Guest 宣告整本書已完成 |
| Integration | Writing Manager 再派 Writer/Editor、根據範例實證撰寫章節新版 | Software Worker 自己更動原稿或虛構測試結果 |

## 對照實驗：同一 Skill，不同 Rule

1. 在 **Project-A** `software-code-review` 應讀 `PA-ARCH-*`、`PA-CODE-*`、`PA-TEST-*`、`PA-REV-*`、`PA-SEC-*`。
2. 在 **Book-A Guest** 同一 `software-code-review` 應讀 `EX-ARCH-*`、`EX-CODE-*`、`EX-TEST-*`、`EX-REV-*`、`EX-SEC-*`；5 個 registry keys 指向同一份 `code-examples.md`，不用維護五份相同內容。
3. 如果 Book-A `AGENTS.md` 暫時**在新複製的拋棄式測試目錄**移除 `software.review` 一行，Review Skill 必須 `BLOCKED`，不能擅自借用 Project-A 或其他專案的 Rule。
4. 不要直接在實際專案做破壞性移除測試；只在拋棄式複本做。

## 產出驗收紀錄

照 `docs/ACCEPTANCE.md` 的 Test Run Report 模板填寫：Workspace / Pane ID、WorkerSkill、Loaded Rules Key + File + Hash、`dotnet` 退出碼與結果、Reviewer Finding、Guest→Owner Handoff、實際檔案差異。

## 額外 Contract Gate

- 由 Writing Manager 在 Book-A 建立 Guest `task-dispatch.json`，`owner_department=writing`、`assigned_department=software`、`delegation_mode=guest-support` 與唯一 `delegation_id`；驗證器拒絕沒有 Delegation ID 的 Guest。
- Guest 的 `software-coding`、`software-unit-test`、`software-code-review` 均必須讀 Book-A 具備的 `EX-*` Rule，交回標準 `worker-report.json`。Reviewer FAIL 時由 Owner Manager 保留原始 Finding，建立 `repair-request.json`。
- 最後執行 `scripts/Test-QualityGate.ps1` 並確認 Guest 全部必要報告都對應同一**目前** Book-A Snapshot；Writing Manager 而非 Guest Worker 將 Delegation 設為 `SUBTASK_PASSED`。
- 接著進入 Writer、Editor、Fact Checker 的書籍內容查核，並依章節要求做 Writing Gate。**程式範例通過，不等於整章文稿通過**。

完整命令參閱 `docs/CONTRACT-TEST.md`。
