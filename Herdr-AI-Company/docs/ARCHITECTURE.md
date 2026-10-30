# Architecture — Manager / Team / Worker Skill / Project Rules

每個作業階段對應的文件、指令及輸出請見 [EXECUTION-FLOW.md](EXECUTION-FLOW.md)。

## 決策（ADR-001 ~ ADR-004）

**ADR-001 — Project Ownership**：專案根 `AGENTS.md` 唯一 `Department` 決定 Owner；Router 不能猜或改。一般任務交 Owner Team。

**ADR-002 — Cross-department Dispatch**：只有當本次交付需要另一部門的專業成果，或使用者明確指定時才用 Router；Guest 不改 Owner、不切其他 Workspace。

**ADR-003 — Composable Worker Skills（本環境核心）**：Manager 只送 `WORKER_CONTRACT`（Who/What/Acceptance/Scope）與 **Skill 名稱**；各 Worker 執行自有 `SKILL.md` SOP，讀 `references/*.md` **方法**，再根據目前專案 `AGENTS.md/Rule Registry` 載入真正技術／寫作 **Rule**。不由 Manager 拼接 Rule 正文。

**ADR-004 — Evidence / Boundary**：Worker 回 Loaded Rules（Key/File/ID/SHA256）與真實查證證據；Sandbox/OS ACL 必須獨立保證，Skill 只是協作規範。

## 組織關係

```text
Herdr Workspace (ProjectRoot/AGENTS.md: Department: writing)
|
+-- Root Pane: Writing Manager (user-facing, owns final acceptance)
|     +-- writing-team / SKILL.md              [Team Orchestration]
|     +-- company-router / SKILL.md            [only guest dispatch]
|     +-- .ai-work/runs/<run>/                  [Spec, worker contracts, evidence]
|
+-- Worker Pane: Writer / Claude CLI
|     +-- writing-writer / SKILL.md            [SOP]
|          +-- references/drafting.md         [METHOD]
|          +-- ProjectRoot/AGENTS.md          [Rule Registry]
|          +-- docs/team-rules/style.md       [PROJECT RULE]
|          +-- docs/team-rules/editorial.md   [PROJECT RULE]
|
+-- Guest Worker Pane: Software Coding / Codex CLI
      +-- software-coding / SKILL.md          [same SOP as ordinary Software project]
           +-- references/implementation.md  [METHOD]
           +-- Book-A/AGENTS.md              [same ProjectRoot, owner writing]
           +-- Book-A/docs/team-rules/code-examples.md [PROJECT RULE]

# No second manager, no external Project-A rules imported
```

## 目錄職責與來源位置

| 資源 | 位址 | 作用 | 是否應複製到其他地方 |
|---|---|---|---|
| Official Herdr Skill | STEP 3 透過 `npx skills add herdrdev/herdr --skill herdr -g` 安裝至使用者全域 | Herdr Pane／Agent CLI 操作方式 | **不屬於公司自訂 Skills**；由官方安裝器管理 |
| Company Bootstrap | `bootstrap/manager-startup.md` | Manager 入口 | **否**，全域指令只放橋接 |
| Router Skill | `.agents/skills/company-router/` | Cross-dept dispatch | **否** |
| Team Skill | `.agents/skills/{software-team,writing-team}/` | Worker 組隊與依賴順序 | **否** |
| Worker Skill | `.agents/skills/{software-coding,...}/` | SOP + 方法 References | **否** |
| Company Worker Policies | `policies/worker/` | 安全、Rule 載入、報告格式 | **否** |
| Project AGENTS.md | `<ProjectRoot>/AGENTS.md` | Owner + Rule Registry | **專案唯一** |
| Project Rules | `<ProjectRoot>/docs/team-rules/*.md` | 技術／語言／編輯標準 | **專案唯一** |
| Run Task/Spec | `<ProjectRoot>/.ai-work/runs/<run>/` | 當次需求與證據 | 每次新 Run |

## Rule Resolution / Fail-closed

Worker 在 `WORKER_CONTRACT` 讀到 `ProjectRoot`，完整載入公司 `policies/worker/rule-composition.md`（WR-*）。依其 Worker Skill 的 RequiredKeys，在當前 ProjectRoot `AGENTS.md` 的 Rule Registry 逐項找路徑。缺失／重複／越界／矛盾 → BLOCKED；不得借用其他專案的 Rule，也不得自行補造規範。**Task Spec 定義當次功能；Project Rules 定義當前專案的品質與架構標準。**

## 有限 Scope 與安全

標記 `AllowedWritePaths`、指定 CWD 及 `AI_COMPANY_ROLE=worker` 有助於減少誤操作，但不是 OS 防護。Windows Native Claude 的權限模型需要實機確認。Code Review 的唯讀性由 Codex CLI 真的使用 read-only sandbox；所有結果都要比對實際檔案及證據。

## Worker Skill 的組成與載入

- **`SKILL.md`**：定義職務的固定 SOP、輸入、輸出與必要交接條件。
- **`references/*.md`**：記錄該職務的審查或實作方法，不內嵌特定專案的技術標準。
- **專案 `AGENTS.md` / `docs/team-rules/*.md`**：由 Rule Registry 宣告目前專案實際適用的標準，Worker 必須自行讀取。

`Project-A` 與 `Book-A` 是獨立的安裝驗收專案。其示例規範不得成為公司共通預設，也不得被其他專案的 Worker 擅自套用。

## ADR-006 — Worker Model Selection

`config/agent-models.json` 是九位 Worker 的 Model 與 Reasoning/Effort 唯一設定入口；`scripts/Start-WorkerAgent.ps1` 在每次建立新 CLI Session 時實際套用。Team Skill 管編制與工作順序，Worker Skill 管 SOP，Project Rule 管專業標準；模型配置不應混入這些文件。Manager 的模型由使用者在主 Pane 自行選取。CLI Kind 與安全權限不允許單靠修改模型 JSON 放寬；配置不影響執行中的 Session。

## ADR-005 — Contract-Driven Orchestration

跨 Pane／跨 CLI 的任務交接採用以下三種可驗證 JSON 契約，所有結果均由對應 Schema 與驗證工具檢查：

```text
User -> Manager (Owner from ProjectRoot/AGENTS.md)
        |
        +-- Team Skill (Software or Writing SOP)
        |
        +-- task-dispatch.json -- Test-AgentContract --> Herdr Worker Pane
        |                                      |
        |                                      +-- Worker Skill SOP + Methods
        |                                      +-- Project Rule Registry
        |                                      +-- worker-report.json (raw)
        |                                                 |
        |                             Test-AgentContract + snapshot hash
        |                                                 |
        +-- FAIL -> repair-request.json (original findings pinned) -> Coding/Writer
        |                                                 |
        +-- Fix -> New Snapshot -> Test/Review/Editor check (fresh reports)
        |
        +-- Test-QualityGate (all required PASS, same current version)
        |
        +-- Owner final acceptance / XDEPT SUBTASK_PASSED
```

**責任界線**：Manager 管協調／派工／最後驗收；Worker Skill 管 SOP；`references/` 管執行方法；`ProjectRoot/AGENTS.md` 和 Project Rule 管專業判定；`contracts/` 管通訊格式和狀態轉移；Herdr 管 Pane／CLI Session，**不替你做 Rule 或資料契約驗證**。

**版本失效防護**：Snapshot 由已核准 Scope 中各檔 SHA-256 組合，含 Source/Tests/Rules/Spec；舊 PASS 必須匹配目前 Snapshot 才可被品質門接受。`bin/obj/.git` 等產生資料夾預設忽略，範圍完整性仍需 Git Diff／原始稿件獨立核對。

**安全限制**：PowerShell Validator 與 JSON Schema 不能防止惡意 Agent 修改檔案；Herdr Pane CWD 與 AllowedPaths 不是 OS ACL，必須搭配真實沙箱／人工授權。Read-only Reviewer 不得為輸出 JSON 自行要求寫權限。沒有 Herdr 實機測試前，不宣稱已自動調度成功。
