# 環境驗收（靜態 ≠ 實機；請填寫實測證據）

## A. 安裝與身分

- [ ] Herdr、Codex、Claude CLI 可執行且登入完成；記錄版本。
- [ ] `D:\AI-Company\.agents\skills\` 僅有 3 個 Manager/Team/Router Skills + 9 個 Worker Skills（共 12 個自訂 Skills），沒有官方 `herdr` 副本。
- [ ] `npx skills ls -g` 顯示官方 `herdr` 已全域安裝至 Codex／Claude，且新 CLI Session 可辨識。
- [ ] Codex/Claude 的 12 個自訂 Skill Junction 實際指向同一份公司來源；新 CLI Session 能**明確觸發** `$software-coding` 和 `/writing-writer`（官方 `herdr` 不計入這 12 個 Junction）。
- [ ] Codex `~/.codex/AGENTS.md`、Claude `~/.claude/CLAUDE.md` 均含唯一且正確的 Manager Bootstrap 橋接（不重複衝突）。
- [ ] Worker Pane 具有 `AI_COMPANY_ROLE=worker` + `AI_COMPANY_ROOT`；Worker 不操作 Herdr 或再開 Sub-agent。
- [ ] `tests/Test-WorkerModelConfig.ps1` 能離線驗證九位 Worker 的模型配置；`Start-WorkerAgent.ps1 -Preview` 顯示明確的 CLI Model/Effort/Sandbox。
- [ ] 真正新建立的 Coding／Test／Review Pane 使用 `config/agent-models.json` 指定的模型與推理強度，而不是沿用 Manager 模型；Reviewer 仍是唯讀。

## B. Project Ownership 與 Planning

- [ ] Project-A 僅 `Department: software`，Book-A 僅 `Department: writing`。
- [ ] 缺 Department 或重複 Department 時停止派工，不能猜。
- [ ] 未授權「開始做」前不建立 Worker Pane。
- [ ] 一般任務直接使用 Owner Team，不讓 Router 每次猜部門。

## C. Worker Skill + Rule Composition（**本環境核心**）

- [ ] Software Coding Worker 真正使用 `software-coding/SKILL.md`，並讀其 `references/implementation.md`。
- [ ] Code Reviewer 真正使用 `software-code-review/SKILL.md` 與 3 個專業方法 References；真實 read-only，不改檔。
- [ ] Unit Test Worker 真正使用 `software-unit-test/SKILL.md`、`references/test-execution.md`、專案指定命令。
- [ ] Writing Writer、Editor、Fact Checker、Proofreader（必要角色）確實使用各自 Worker Skill，不只是普通 Prompt。
- [ ] Project-A 的 Code Review `Loaded Rules` 有本專案 `PA-*` Rules，**不得混入** Book-A 或其他專案的 Rule。
- [ ] Book-A Guest 同一 Code Review Skill 載入 Book-A `code-examples.md` 的 `EX-*`，**不是** Project-A `PA-*`。
- [ ] 每個 Worker 交 `Key / Project-relative File / Rule IDs / SHA256 or N/A / Applied`，Manager 依真實檔案抽查，不能只接受 Worker 自稱。
- [ ] 缺 key、重複 key、Rule 路徑不存在、越界／衝突：Worker `BLOCKED`，**不得自動用別人的 Rule 代替**。

## D. Software / Writing 正常流程

- [ ] Software Owner 在討論後「好，開始做吧」產出三個核心 Worker Pane，依 Coding → Test → Review 順序交接。
- [ ] `dotnet build` / `dotnet test` 真正執行，有 CWD、Exit Code、Log、Test Assertions；沒跑就不能 PASS。
- [ ] Reviewer 獨立讀任務 Diff、未追蹤檔、實際 Code 與 Test Evidence，不只看 Coding 摘要。
- [ ] Writing Owner 根據任務決定 Writer/Editor/Fact Checker/Proofreader 人選，不無端啟全隊。
- [ ] Fact Checker 可追溯來源不足時回 `UNVERIFIED`，不虛構已查網頁／引文。

## E. 跨部門 Guest Support

- [ ] Book-A 在整個 Run 期間仍是 `Department: writing`，沒有切到 Project-A Workspace。
- [ ] 有 XDEPT-* Delegation 契約、Owner/Guest 部門、明確白名單、Acceptance、ReturnTo。
- [ ] Guest Pane 仍屬 Book-A Workspace；Worker 不更動 `AGENTS.md` 或原稿。
- [ ] Guest 個別 Worker 產出 `PASS/FAIL/BLOCKED/UNVERIFIED`、真實 Build/Test/Review 證據；Writing Manager 驗證後才將 Delegation 標成 `SUBTASK_PASSED`，並負責最終書籍驗收。
- [ ] Manager 實際查變更清單，沒有把 CWD、Prompt Allowlist 當成 OS ACL。

## F. 風險與錯誤處理

- [ ] `agent_prompt_stalled` / `timeout` 時先讀 Agent，不盲目重發。
- [ ] 不自動 Commit/Push，不清空既存 User 變更。
- [ ] Native Windows Claude 權限能力有實際記錄；若沒有受檢 OS Sandbox，不能聲稱有隔離。
- [ ] 新舊 Skill 同名或 Windows Junction 不支援時，停下修正，不讓無 SOP Agent 代替完成。

## Test Run Report（每次 Run 複製一份）

```markdown
# AI Company  — Test Run
- Date:
- OS / Herdr / Codex / Claude / SDK versions:
- CompanyRoot:
- ProjectRoot / WorkspaceId / ManagerPane:
- AGENTS.md Department / Rule Registry file:
- User goal / approved Task / acceptance:
- Owner Team / Guest Support / DelegationId:
- WorkerRole | AgentName | CLI kind | PaneId | Actual sandbox:
- WorkerSkill | Skill loaded evidence | Method refs loaded:
- Loaded Rules: Key | File | Rule IDs | SHA256/N/A:
- Git/non-Git baseline / actual changed files:
- Build/Test commands | CWD | ExitCodes | Test count | Log path:
- Reviewer Findings + Rule IDs + evidence:
- Fact Checker Sources + VERDICT (if any):
- Guest Handoff and Owner acceptance:
- Static check: PASS / FAIL
- End-to-end result: PASS | FAIL | PARTIAL | BLOCKED | NOT RUN
- Outstanding issue and reproducing steps:
```

**ZIP 格式／靜態 PASS 不代表 Herdr Worker 真正照 Skill 執行**。必須有實際 Agent Prompt/Read、檔案、Rule 載入及命令結果，才能判端到端成功。

## 新增：Contract-Driven End-to-End（必要）

- [ ] `pwsh -NoProfile -File tests/Run-ContractTests.ps1` 的**合成**契約測試通過；負向案例有正常被拒絕，而不是被意外忽略。
- [ ] Manager 每位 Worker 都產生獨立且有效 `task-dispatch.json`，Schema、Owner Department、AllowedPaths、Spec、Scope Digest 實際驗證通過。
- [ ] `software-coding`、`software-unit-test`、`software-code-review` Worker 真正載入自己 Skill 和 Reference；`worker-report.json` 通過 Schema、Rule Registry 與 SHA-256 驗證。
- [ ] Code Review FAIL 時**原始** `worker-report.json` 被保存，`scripts/New-RepairRequest.ps1` 複製相同 `finding.id`／證據／修正要求，並綁定原始 Review + Dispatch SHA-256。
- [ ] 刻意篡改 Repair `required_action` 或 AllowedWritePaths，驗證器拒絕。
- [ ] 修復後有新 Snapshot；Test + Review 都重跑，舊 PASS 不能跨版本沿用。
- [ ] `scripts/Test-QualityGate.ps1` 在全部必要 Worker PASS 且 Snapshot 相同、為當前版本時通過；若插入一行新程式碼就拒絕。
- [ ] Writing Editor / Fact Checker 也使用相同契約；重要主張查無來源時回 `UNVERIFIED`，不得當作 PASS。
- [ ] 正式 Review 期間沒有並行更動 Source/Tests/Rules/Spec；Review 以實際 CLI Read-only Sandbox 執行，不靠 Prompt 聲稱唯讀。
- [ ] Manager 未修改任何 Reviewer 原始 Findings，也沒有自行撰寫 PASS 結論。

詳細的步驟與指令見 `docs/CONTRACT-TEST.md`。以上檢查**尚未在 Windows 上實測**時，不能勾選端到端成功。
