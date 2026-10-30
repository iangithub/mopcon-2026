# 安裝與回歸測試（tests）

本資料夾只放 **部署檢查、專案 Rule Registry 檢查與離線合成契約測試**。正式執行時的四支契約／驗證工具與一支 Worker 啟動器在 [`scripts/`](../scripts/)。

| 程式 | 用途 | 是否呼叫真實 Herdr／Codex／Claude |
|---|---|---|
| `Test-WorkerModelConfig.ps1` | 離線檢查 9 位 Worker 的模型與 CLI 引數，包含 Codex Reviewer 唯讀設定 | 否 |
| `Verify-Structure.ps1` | 檢查公司 **12 個自訂 Skill**、Reference、Schema、文件與腳本配置；並拒絕公司目錄內的官方 `herdr` 副本 | 否 |
| `Verify-RuleRegistry.ps1` | 檢查指定專案 `AGENTS.md` 中的 Department、Rule 路徑和必填 Key | 否 |
| `Run-ContractTests.ps1` | 使用隔離的合成專案，呼叫 `scripts/` 中的工具測試有效／無效契約 | 否 |

```powershell
$C = 'D:\AI-Company'
& "$C\tests\Verify-Structure.ps1" -Company $C
& "$C\tests\Test-WorkerModelConfig.ps1" -Company $C
& "$C\tests\Verify-RuleRegistry.ps1" -ProjectRoot 'D:\Workspaces\Software\Project-A'
& "$C\tests\Run-ContractTests.ps1" -CompanyRoot $C
```

官方 `herdr` Skill 的全域安裝及實際 CLI 載入請依 [WORKSHOP.md 的 STEP 3](../WORKSHOP.md) 與 `npx skills ls -g` 另外確認；這三支檢查程式不會自行存取使用者全域 Skill。

合成契約測試即使全部 PASS，也**不代表** Worker Skill 已在 Herdr 真實執行；端到端測試見 [docs/ACCEPTANCE.md](../docs/ACCEPTANCE.md)。
