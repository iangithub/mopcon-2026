# AI Company — Agent Communication Contract（AC-*）

本目錄定義 Herdr 跨 Pane／跨 CLI 的**任務派發、Worker 回報、問題修復與品質驗收**契約。Manager 與 Worker 必須使用相同的 JSON Schema、狀態定義及檔案驗證規則，禁止僅憑自然語言回覆認定任務完成。

契約適用於 Software Team 與 Writing Team；各職務以相同的資料結構交接，但依自身 Worker Skill 和當前專案 Rules 執行專業工作。

## 唯一來源與檔案

| 類型 | 檔案 | 誰建立 | 用途 |
|---|---|---|---|
| 派工 | `schemas/task-dispatch.schema.json` | Owner Manager | What/Who/Scope/Skill/Permission/Acceptance |
| Worker 回報 | `schemas/worker-report.schema.json` | 該 Worker，或唯讀 Worker 原文由 Manager 封存 | Scope/Checks/Findings/Limitations/Rule 證據 |
| 修復請求 | `schemas/repair-request.schema.json` | Manager 由原始 FAIL 回報**原封不動選取 Blocking Finding**產生 | Coding / Writer 修正工作 |
| Worker 規格 | `worker-requirements.json` | AI Company 管理者 | Worker Skill 要讀的 project Rule keys 與 method references 唯一登錄表 |
| 狀態機 | `STATE-MACHINE.md` | AI Company 管理者 | PASS/FAIL/BLOCKED、版本失效及重試規則 |
| Validator | `../scripts/Test-AgentContract.ps1` | PowerShell 7.4+ | Schema + Rule Hash/Registry + Snapshot/Status 驗證 |
| 修復請求產生器 | `../scripts/New-RepairRequest.ps1` | PowerShell 7.4+ | 原始 Finding 雜湊綁定與保留 |
| 最後品質門 | `../scripts/Test-QualityGate.ps1` | PowerShell 7.4+ | 所有必要 PASS 必須相同且為目前 Snapshot |

## AC-001：派工是檔案，不是長篇 Prompt

Manager 將 `task-dispatch.json` 寫到**目前專案** `.ai-work/runs/<run-id>/`（不寫入公司定義庫），經 `Test-AgentContract -Type Dispatch` 驗證後，才把 **絕對路徑**與指定 Worker Skill 交給 Pane。`Task` 與 `AcceptanceCriteria` 必須有已核准內容；Rule 本文不在 Manager Prompt 重述。

Worker 依序讀取：Dispatch → 自己的 `SKILL.md` → `references/*.md` → 公司 `policies/worker/*` → **目前 ProjectRoot `AGENTS.md` Rule Registry** → 專案 Rule 完整正文 → 作業與回報。

## AC-002：標準回報，不改寫 Reviewer

一個 Worker / 一次 attempt / 一個凍結版本，產生一份 `worker-report.json`，包含：

- `status`: `PASS | FAIL | BLOCKED | UNVERIFIED`。`UNVERIFIED` 用於事實查核沒有足夠證據等情況；不能算 PASS。
- `scope`: `project_root`, `scope_paths`, `snapshot_digest`（`scripts/Get-ScopeSnapshot.ps1` 算出之 SHA-256 指紋）；若環境問題導致無法計算，**只有 `BLOCKED` 可以填 `null`**，不得偽造 Hash。
- `method_references`: **實際引用的方法文件**與 SHA-256；`BLOCKED` 若根本無法讀取，允許空陣列但必須說明限制。
- `loaded_rules`: `key`, `path`, `sha256`, `rule_ids`；必須符合本專案 Rule Registry 及 Worker Requirement Catalog。**只有 `BLOCKED`** 可因缺規範而不齊全，且不能被 Gate 接受。
- `checks`: 每項 `PASS / FAIL / BLOCKED / NOT_RUN / NOT_APPLICABLE` 與明確證據。
- `findings`: `id`, `severity`, `rule_key`, `rule_id`, `location`, `evidence`, `impact`, `required_action`。
- `verification`: 真正執行過的命令、CWD、Exit Code 與 Log 路徑；未執行明確記 `NOT_RUN`。
- `fixes`: Coding／Writer 在修復迴圈以原始 Finding ID 回覆 `FIXED` / `UNRESOLVED`。
- `limitations`: 必要脈絡、證據或來源缺失的原因；對 BLOCKED／UNVERIFIED 不可省略。

唯讀 Reviewer／Editor 不能寫工作區檔案，須**回覆完整、原始、可解析的純 JSON 正文**；Manager 只可以逐字封存，不得代填、改寫欄位或結論。若 Herdr `agent read` 只提供截斷片段，該回報不可被驗收為 PASS；需向 Worker 索取完整原文或安全的替代保存途徑，仍須遵守 Sandbox。

## AC-003：FAIL → 原始 Findings → Repair

1. 保留原始 FAIL Review 報告檔，記錄 SHA-256。**不能覆寫或重新命名既有 FAIL 回報來躲過審查**。
2. 以 `scripts/New-RepairRequest.ps1` 從該報告**精確複製** `severity=BLOCKING` 的 Finding Objects（連同原始 Rule ID、檔案位置、原文證據、修正要求及順序）。
3. Repair Contract 包含 `source_dispatch.path + sha256` 與 `source_report.path + sha256 + snapshot_digest`；驗證器發現原文被更改、漏項或重排即拒絕。
4. Coding／Writer 修復後，回覆 `fixes[].finding_id` 對應原始 Finding；使用 `scripts/Test-AgentContract.ps1 -Type Report -RepairFile <repair.json>` 驗證 Finding ID 一致，Manager 重新取得受檢內容 Snapshot，重新測試＋Review（寫書則重新審稿／事實核查）。不能沿用舊 PASS。

## AC-004：Snapshot 與交付

`scripts/Get-ScopeSnapshot.ps1` 對列出的 `scope_paths` 內檔案計算 SHA-256，排序後形成統一指紋；只排除列明的產生目錄（`.git`、`bin`、`obj` 等）。**必須由 Manager 檢查 Scope 是否覆蓋實際變動的 Source、Tests、AGENTS、Rules 與 Spec**；只掃一個無關檔案，雖然技術上可雜湊，也不代表 Review 有效。

每一關 Worker 都使用當次真正的 Snapshot；`scripts/Test-QualityGate.ps1` 必須確認所有必要 Worker Reports **共同指向目前版本**，且全部有效、PASS。只要 Source / Tests / 審查規範 / Spec 有改動，舊 Gate 作廢。檢查期間停止對受檢內容的修改。

**限制**：SHA-256 和 JSON Schema 可驗證資料一致性，不代表模型真的讀懂或檢查正確。Worker 的「已實查」仍須靠 Manager 抽查實際 Diff、測試 Log、來源證據。`AllowedWritePaths` 不是 OS ACL，應另外使用實際沙箱或檔案權限。

## AC-005：Guest 跨部門

Guest Worker 一樣只回報 `PASS/FAIL/BLOCKED/UNVERIFIED`，其 `owner_department` 永遠是本專案 `AGENTS.md` 的 `Department`；`assigned_department` 是支援部門，`delegation_id` 必填。**只有 Owner Manager 經檢查 Guest 的所有必要 Worker PASS 和新鮮 Snapshot，才將原本的 XDEPT Delegation 狀態寫成 `SUBTASK_PASSED`。** Guest Worker 不可宣告整本書／整個專案完成。

## AC-006：防止契約降級

- Schema 只允許 `contract_version: "1.0"`，未知欄位、缺欄位、型別錯誤、未知狀態一律拒絕。
- 驗證程序失敗須停止自動推進，不能把不合法 JSON 換成自然語言 PASS。
- `contract_version` 用於管理 JSON 契約格式的相容性。
- Manager 可以引用 Reviewer 已驗證 Findings，但不能藉著重寫原文降低嚴重程度。

## Quick test

```powershell
$C = 'D:\AI-Company'
pwsh -NoProfile -File "$C\tests\Run-ContractTests.ps1" -CompanyRoot $C
```

這個測試使用**合成資料**；不啟動 Herdr / Codex / Claude，不代表 AI 實際 Review 成功。完整實機驗收見 `docs/CONTRACT-TEST.md`。
