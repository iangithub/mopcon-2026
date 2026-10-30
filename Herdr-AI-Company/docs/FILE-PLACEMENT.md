# 檔案放置對照表｜每個 Markdown 與目錄的正確位置

> 本表使用 `D:\AI-Company` 與 `D:\Workspaces` 兩個根目錄。來源檔案的 `相對路徑`，指 ZIP 第一層 `AI-Company/` 底下的相對位置。**先把這一層的內容完整放到 `D:\AI-Company`；範本專案再依 STEP 6 複製一次到 `D:\Workspaces`。**

## 一、安裝後只應有三種位置

| 位置 | 應放的東西 | 不應放的東西 |
|---|---|---|
| `D:\AI-Company\` | 公司 Skills、References、Contracts、Policies、手冊與 templates | 實際專案的 source code／Book 正文 |
| `D:\Workspaces\Software\...` 或 `D:\Workspaces\Writing\...` | 各專案根 `AGENTS.md`、`docs/team-rules/`、程式／書稿與 `.ai-work` | 公司層共用 Skills 的另一份複製品 |
| `$HOME` 使用者設定 | Codex／Claude 的短 Bootstrap 指引及指向公司來源的 Skill Junction | 大段 Company SOP 或複製多份 Project Rules |

## 二、使用者全域入口（不是 ZIP 內的檔案）

| 建立位置 | 實際操作 |
|---|---|
| `$HOME\.codex\AGENTS.md` | **保留原有內容、只附加** `WORKSHOP.md` STEP 5 的短橋接，指向 `D:\AI-Company\bootstrap\manager-startup.md` |
| `$HOME\.claude\CLAUDE.md` | 同樣只附加一次短橋接，不複製 Bootstrap 正文 |
| `$HOME\.agents\skills\<company-skill>\` | STEP 4 僅為 **12 個公司自訂 Skill** 建立 Junction，指向 `D:\AI-Company\.agents\skills\<company-skill>\` |
| `$HOME\.claude\skills\<company-skill>\` | STEP 4 為相同的 12 個公司 Skill 建立 Junction，指向同一份來源 |
| `herdr` 官方全域 Skill（Codex／Claude 的使用者 Skill 位置） | STEP 3 使用 `npx skills add herdrdev/herdr --skill herdr -g` 安裝；依安裝器指定兩個 CLI，實際位置以安裝清單為準，**不在公司 Skill 目錄內** |

## 三、公司共用 Markdown（原地保留，不需要搬進專案）

這些 Markdown 在解壓後**原地放在 `D:\AI-Company\`**。`Skill` 資料夾及其 `references` 必須一起保留，不能把內部 Reference `.md` 另外散放到 `$HOME`。

| ZIP 第一層下的相對路徑 | 安裝後的完整路徑 | 負責事項 |
|---|---|---|
| `.agents/skills/company-router/SKILL.md` | `D:\AI-Company\.agents\skills\company-router\SKILL.md` | 跨部門 Guest 派遣 SOP |
| `.agents/skills/company-router/references/cross-department-contract.md` | `D:\AI-Company\.agents\skills\company-router\references\cross-department-contract.md` | 該 Skill 內部的方法／調度 Reference；隨 Skill 保留 |
| `.agents/skills/company-router/references/cross-department-policy.md` | `D:\AI-Company\.agents\skills\company-router\references\cross-department-policy.md` | 該 Skill 內部的方法／調度 Reference；隨 Skill 保留 |
| `.agents/skills/company-router/references/dispatch-contract.md` | `D:\AI-Company\.agents\skills\company-router\references\dispatch-contract.md` | 該 Skill 內部的方法／調度 Reference；隨 Skill 保留 |
| `.agents/skills/company-router/references/runtime.md` | `D:\AI-Company\.agents\skills\company-router\references\runtime.md` | 該 Skill 內部的方法／調度 Reference；隨 Skill 保留 |
| `.agents/skills/software-code-review/SKILL.md` | `D:\AI-Company\.agents\skills\software-code-review\SKILL.md` | Worker 專業 SOP；Worker 自己載入專案 Rule |
| `.agents/skills/software-code-review/references/architecture-review.md` | `D:\AI-Company\.agents\skills\software-code-review\references\architecture-review.md` | 該 Skill 內部的方法／調度 Reference；隨 Skill 保留 |
| `.agents/skills/software-code-review/references/code-quality-review.md` | `D:\AI-Company\.agents\skills\software-code-review\references\code-quality-review.md` | 該 Skill 內部的方法／調度 Reference；隨 Skill 保留 |
| `.agents/skills/software-code-review/references/test-review.md` | `D:\AI-Company\.agents\skills\software-code-review\references\test-review.md` | 該 Skill 內部的方法／調度 Reference；隨 Skill 保留 |
| `.agents/skills/software-coding/SKILL.md` | `D:\AI-Company\.agents\skills\software-coding\SKILL.md` | Worker 專業 SOP；Worker 自己載入專案 Rule |
| `.agents/skills/software-coding/references/implementation.md` | `D:\AI-Company\.agents\skills\software-coding\references\implementation.md` | 該 Skill 內部的方法／調度 Reference；隨 Skill 保留 |
| `.agents/skills/software-repo-scout/SKILL.md` | `D:\AI-Company\.agents\skills\software-repo-scout\SKILL.md` | Worker 專業 SOP；Worker 自己載入專案 Rule |
| `.agents/skills/software-repo-scout/references/repo-discovery.md` | `D:\AI-Company\.agents\skills\software-repo-scout\references\repo-discovery.md` | 該 Skill 內部的方法／調度 Reference；隨 Skill 保留 |
| `.agents/skills/software-team/SKILL.md` | `D:\AI-Company\.agents\skills\software-team\SKILL.md` | 部門 Orchestration SOP |
| `.agents/skills/software-unit-test/SKILL.md` | `D:\AI-Company\.agents\skills\software-unit-test\SKILL.md` | Worker 專業 SOP；Worker 自己載入專案 Rule |
| `.agents/skills/software-unit-test/references/test-execution.md` | `D:\AI-Company\.agents\skills\software-unit-test\references\test-execution.md` | 該 Skill 內部的方法／調度 Reference；隨 Skill 保留 |
| `.agents/skills/writing-editor/SKILL.md` | `D:\AI-Company\.agents\skills\writing-editor\SKILL.md` | Worker 專業 SOP；Worker 自己載入專案 Rule |
| `.agents/skills/writing-editor/references/editorial-review.md` | `D:\AI-Company\.agents\skills\writing-editor\references\editorial-review.md` | 該 Skill 內部的方法／調度 Reference；隨 Skill 保留 |
| `.agents/skills/writing-fact-check/SKILL.md` | `D:\AI-Company\.agents\skills\writing-fact-check\SKILL.md` | Worker 專業 SOP；Worker 自己載入專案 Rule |
| `.agents/skills/writing-fact-check/references/claim-verification.md` | `D:\AI-Company\.agents\skills\writing-fact-check\references\claim-verification.md` | 該 Skill 內部的方法／調度 Reference；隨 Skill 保留 |
| `.agents/skills/writing-proofreader/SKILL.md` | `D:\AI-Company\.agents\skills\writing-proofreader\SKILL.md` | Worker 專業 SOP；Worker 自己載入專案 Rule |
| `.agents/skills/writing-proofreader/references/proofreading.md` | `D:\AI-Company\.agents\skills\writing-proofreader\references\proofreading.md` | 該 Skill 內部的方法／調度 Reference；隨 Skill 保留 |
| `.agents/skills/writing-researcher/SKILL.md` | `D:\AI-Company\.agents\skills\writing-researcher\SKILL.md` | Worker 專業 SOP；Worker 自己載入專案 Rule |
| `.agents/skills/writing-researcher/references/research-method.md` | `D:\AI-Company\.agents\skills\writing-researcher\references\research-method.md` | 該 Skill 內部的方法／調度 Reference；隨 Skill 保留 |
| `.agents/skills/writing-team/SKILL.md` | `D:\AI-Company\.agents\skills\writing-team\SKILL.md` | 部門 Orchestration SOP |
| `.agents/skills/writing-writer/SKILL.md` | `D:\AI-Company\.agents\skills\writing-writer\SKILL.md` | Worker 專業 SOP；Worker 自己載入專案 Rule |
| `.agents/skills/writing-writer/references/drafting.md` | `D:\AI-Company\.agents\skills\writing-writer\references\drafting.md` | 該 Skill 內部的方法／調度 Reference；隨 Skill 保留 |
| `AGENTS.md` | `D:\AI-Company\AGENTS.md` | 維護公司共用設定庫時的指令；不是 Project Department |
| `README.md` | `D:\AI-Company\README.md` | 導讀與文件入口 |
| `WORKSHOP.md` | `D:\AI-Company\WORKSHOP.md` | 逐步安裝及操作手冊（主要入口） |
| `docs/FILE-PLACEMENT.md` | `D:\AI-Company\docs\FILE-PLACEMENT.md` | 本文件；列出全部 Markdown、Scripts 及使用者目錄放置位置 |
| `docs/EXECUTION-FLOW.md` | `D:\AI-Company\docs\EXECUTION-FLOW.md` | Software／Writing／Guest 作業流水線；每關的 Skill、Rule、Contract 與指令 |
| `config/README.md` | `D:\AI-Company\config\README.md` | 九位 Worker 的模型、Reasoning 與修改方式 |
| `config/agent-models.json` | `D:\AI-Company\config\agent-models.json` | Worker Model/Kind/Effort 唯一設定來源，Manager 不沿用 |
| `scripts/README.md` | `D:\AI-Company\scripts\README.md` | 正式任務用 PowerShell 工具用途表 |
| `tests/README.md` | `D:\AI-Company\tests\README.md` | 安裝與離線測試工具用途表 |
| `bootstrap/manager-startup.md` | `D:\AI-Company\bootstrap\manager-startup.md` | Manager 的正式啟動規範（僅此一份） |
| `contracts/README.md` | `D:\AI-Company\contracts\README.md` | 公司共用契約與狀態機說明 |
| `contracts/STATE-MACHINE.md` | `D:\AI-Company\contracts\STATE-MACHINE.md` | 公司共用契約與狀態機說明 |
| `docs/ACCEPTANCE.md` | `D:\AI-Company\docs\ACCEPTANCE.md` | 可選讀的參考／診斷／驗收文件 |
| `docs/ARCHITECTURE.md` | `D:\AI-Company\docs\ARCHITECTURE.md` | 可選讀的參考／診斷／驗收文件 |
| `docs/CONTRACT-TEST.md` | `D:\AI-Company\docs\CONTRACT-TEST.md` | 可選讀的參考／診斷／驗收文件 |
| `docs/CROSS-DEPARTMENT-TEST.md` | `D:\AI-Company\docs\CROSS-DEPARTMENT-TEST.md` | 可選讀的參考／診斷／驗收文件 |
| `docs/TROUBLESHOOTING.md` | `D:\AI-Company\docs\TROUBLESHOOTING.md` | 可選讀的參考／診斷／驗收文件 |
| `policies/manager/git-commit.md` | `D:\AI-Company\policies\manager\git-commit.md` | Manager 操作／提交安全政策 |
| `policies/worker/report-contract.md` | `D:\AI-Company\policies\worker\report-contract.md` | Worker 共用權限、Rule 組裝與報告政策 |
| `policies/worker/rule-composition.md` | `D:\AI-Company\policies\worker\rule-composition.md` | Worker 共用權限、Rule 組裝與報告政策 |
| `policies/worker/worker-boundary.md` | `D:\AI-Company\policies\worker\worker-boundary.md` | Worker 共用權限、Rule 組裝與報告政策 |

## 四、測試專案的 Markdown（先在 templates，STEP 6 才複製到 Workspace）

**請整個專案資料夾複製，不要只搬 `AGENTS.md` 或只搬 Rule 檔。** 以下表格顯示每一個 Markdown 來源與實際使用時的位置。

| 公司範本的相對路徑 | STEP 6 後實際專案位置 | 作用 |
|---|---|---|
| `templates/Software/Project-A/AGENTS.md` | `D:\Workspaces\Software\Project-A\AGENTS.md` | 專案主責 `Department`、Rule Registry；各專案維護自己的這一份 |
| `templates/Software/Project-A/README.md` | `D:\Workspaces\Software\Project-A\README.md` | 此專案的基本說明 |
| `templates/Software/Project-A/docs/team-rules/architecture.md` | `D:\Workspaces\Software\Project-A\docs\team-rules\architecture.md` | 本專案實際的工作品質／架構／查核標準（Worker 依 Registry 讀） |
| `templates/Software/Project-A/docs/team-rules/code-review.md` | `D:\Workspaces\Software\Project-A\docs\team-rules\code-review.md` | 本專案實際的工作品質／架構／查核標準（Worker 依 Registry 讀） |
| `templates/Software/Project-A/docs/team-rules/coding.md` | `D:\Workspaces\Software\Project-A\docs\team-rules\coding.md` | 本專案實際的工作品質／架構／查核標準（Worker 依 Registry 讀） |
| `templates/Software/Project-A/docs/team-rules/security.md` | `D:\Workspaces\Software\Project-A\docs\team-rules\security.md` | 本專案實際的工作品質／架構／查核標準（Worker 依 Registry 讀） |
| `templates/Software/Project-A/docs/team-rules/testing.md` | `D:\Workspaces\Software\Project-A\docs\team-rules\testing.md` | 本專案實際的工作品質／架構／查核標準（Worker 依 Registry 讀） |
| `templates/Writing/Book-A/AGENTS.md` | `D:\Workspaces\Writing\Book-A\AGENTS.md` | 專案主責 `Department`、Rule Registry；各專案維護自己的這一份 |
| `templates/Writing/Book-A/docs/team-rules/code-examples.md` | `D:\Workspaces\Writing\Book-A\docs\team-rules\code-examples.md` | 本專案實際的工作品質／架構／查核標準（Worker 依 Registry 讀） |
| `templates/Writing/Book-A/docs/team-rules/editorial.md` | `D:\Workspaces\Writing\Book-A\docs\team-rules\editorial.md` | 本專案實際的工作品質／架構／查核標準（Worker 依 Registry 讀） |
| `templates/Writing/Book-A/docs/team-rules/facts.md` | `D:\Workspaces\Writing\Book-A\docs\team-rules\facts.md` | 本專案實際的工作品質／架構／查核標準（Worker 依 Registry 讀） |
| `templates/Writing/Book-A/docs/team-rules/proofreading.md` | `D:\Workspaces\Writing\Book-A\docs\team-rules\proofreading.md` | 本專案實際的工作品質／架構／查核標準（Worker 依 Registry 讀） |
| `templates/Writing/Book-A/docs/team-rules/sources.md` | `D:\Workspaces\Writing\Book-A\docs\team-rules\sources.md` | 本專案實際的工作品質／架構／查核標準（Worker 依 Registry 讀） |
| `templates/Writing/Book-A/docs/team-rules/style.md` | `D:\Workspaces\Writing\Book-A\docs\team-rules\style.md` | 本專案實際的工作品質／架構／查核標準（Worker 依 Registry 讀） |
| `templates/Writing/Book-A/drafts/chapter-01.md` | `D:\Workspaces\Writing\Book-A\drafts\chapter-01.md` | 測試用書稿；Fact Checker 可用於查核演練 |
| `templates/Writing/Book-A/examples/README.md` | `D:\Workspaces\Writing\Book-A\examples\README.md` | 本書程式範例目錄說明；Guest 修改範圍另由契約限制 |
| `templates/Writing/Book-A/sources/README.md` | `D:\Workspaces\Writing\Book-A\sources\README.md` | 本書來源素材目錄說明 |

## 五、其他檔案／子目錄（整個保留）

| 目錄 | 真正位置 | 包含內容 |
|---|---|---|
| `config\` | `D:\AI-Company\config\` | `agent-models.json`：集中設定九位 Worker 的 Model／Effort |
| `contracts\schemas\` | `D:\AI-Company\contracts\schemas\` | `task-dispatch.schema.json`、`worker-report.schema.json`、`repair-request.schema.json`；保留 JSON Schema 原路徑 |
| `contracts\worker-requirements.json` | `D:\AI-Company\contracts\worker-requirements.json` | 9 位 Worker 必要 Rule/References 列表 |
| `scripts\` | `D:\AI-Company\scripts\` | 四支契約／品質工具與一支 Worker CLI 啟動器；不複製進專案 |
| `tests\` | `D:\AI-Company\tests\` | 原三支安裝／契約回歸測試，另有一支 Worker Model 離線測試 |
| `policies\manager\` | `D:\AI-Company\policies\manager\` | 以 ZIP 原有子目錄為準，勿將內部檔案重新攤平 |
| `policies\worker\` | `D:\AI-Company\policies\worker\` | 以 ZIP 原有子目錄為準，勿將內部檔案重新攤平 |
| `.agents\skills\` | `D:\AI-Company\.agents\skills\` | 以 ZIP 原有子目錄為準，勿將內部檔案重新攤平 |
| `templates\Software\Project-A\` | `D:\AI-Company\templates\Software\Project-A\` | 以 ZIP 原有子目錄為準，勿將內部檔案重新攤平 |
| `templates\Writing\Book-A\` | `D:\AI-Company\templates\Writing\Book-A\` | 以 ZIP 原有子目錄為準，勿將內部檔案重新攤平 |

## 六、PowerShell 檔案的準確位置與用途

| 來源相對路徑 | 安裝後位置 | 使用關卡 |
|---|---|---|
| `scripts/Start-WorkerAgent.ps1` | `D:\AI-Company\scripts\Start-WorkerAgent.ps1` | 根據集中模型配置、角色權限啟動獨立 Herdr Worker；`-Preview` 僅檢查不啟動 |
| `tests/Test-WorkerModelConfig.ps1` | `D:\AI-Company\tests\Test-WorkerModelConfig.ps1` | 離線確認九位 Worker 的模型／參數完整、Reviewer 權限未放寬 |
| `scripts/Get-ScopeSnapshot.ps1` | `D:\AI-Company\scripts\Get-ScopeSnapshot.ps1` | 初始／更新後 Scope Snapshot |
| `scripts/Test-AgentContract.ps1` | `D:\AI-Company\scripts\Test-AgentContract.ps1` | 每份 Dispatch、Report、Repair 的格式及語意驗證 |
| `scripts/New-RepairRequest.ps1` | `D:\AI-Company\scripts\New-RepairRequest.ps1` | Review FAIL → 原始 Finding 轉修復契約 |
| `scripts/Test-QualityGate.ps1` | `D:\AI-Company\scripts\Test-QualityGate.ps1` | 所需 Worker 全部有效 PASS 的最終品質門 |
| `tests/Verify-Structure.ps1` | `D:\AI-Company\tests\Verify-Structure.ps1` | 部署結構驗證 |
| `tests/Verify-RuleRegistry.ps1` | `D:\AI-Company\tests\Verify-RuleRegistry.ps1` | 專案 Rule Registry 驗證 |
| `tests/Run-ContractTests.ps1` | `D:\AI-Company\tests\Run-ContractTests.ps1` | 合成資料正反例回歸測試 |

所有工具的觸發順序與實際命令見 [EXECUTION-FLOW.md](EXECUTION-FLOW.md)，其中 `scripts/` 只在 Team Skill 的對應關卡**被 Manager 明確呼叫**，不是自動觸發的 Hook。

## 七、規範如何被實際載入？

1. Manager 讀**目前專案** `AGENTS.md` 的 `Department`，選擇主責 Team Skill；跨部門才使用 `company-router`。
2. Manager 只傳有效的 `task-dispatch.json` 路徑與指定 Worker Skill，**不複製 Rule 正文**。
3. Worker 在自己的 CLI Session 執行 `SKILL.md` SOP，讀同 Skill 的 `references/`，再讀**目前專案** `AGENTS.md` 的 Rule Registry 和實際 Rule 文件。
4. Worker 依 `contracts/` 回報可驗證的資料；Review FAIL 按原始 Finding ID 修復與重新驗證。

當次 Spec、Brief、Dispatch、Report 與 Snapshot 放在 `<ProjectRoot>\.ai-work\runs\<run-id>\`；這個目錄不是在安裝階段手動複製的公司 Skill。
