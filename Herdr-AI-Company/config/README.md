# Worker 模型與推理強度設定

唯一設定檔：`D:\AI-Company\config\agent-models.json`。**只負責 Worker 的模型與推理強度**；主 Pane 的 Manager 仍由使用者在 Codex／Claude CLI 選擇模型，互不覆蓋。

## 角色的預設配置

| Worker Skill | CLI | Model | Effort | 原則 |
|---|---|---|---|---|
| `software-coding` | Codex | `gpt-6-sol` | `medium` | 日常功能實作，兼顧成本與品質 |
| `software-code-review` | Codex | `gpt-6-sol` | `high` | 獨立審查不應預設使用最低推理 |
| `software-unit-test` | Codex | `gpt-6-luna` | `medium` | 依真實 Build/Test Log 驗證 |
| `software-repo-scout` | Codex | `gpt-6-luna` | `low` | 程式探索與影響範圍整理 |
| `writing-writer` | Claude | `sonnet` | `medium` | 章節初稿 |
| `writing-editor` | Codex | `gpt-6-sol` | `medium` | 內容與結構審稿 |
| `writing-fact-check` | Codex | `gpt-6-sol` | `high` | 事實來源核實 |
| `writing-proofreader` | Codex | `gpt-6-luna` | `medium` | 校稿、格式與用詞 |
| `writing-researcher` | Claude | `sonnet` | `medium` | 文獻／來源研究 |

此表是可調整的起始配置，不代表模型在每個帳號都可用。CLI 供應商可能調整模型識別碼、額度與支援的推理強度；請先用已登入的 CLI 確認，再修改 JSON。`sonnet` 是 Claude Code 模型別名。不同工具的 `effort` 並非可直接比較的性能分數。

## 變更方式

1. 僅修改 `config/agent-models.json` 對應 Worker 的 `model`、`effort`。支援 `low`、`medium`、`high`、`xhigh`（須確認該模型支援）。
2. **不要透過這份模型設定更改 CLI kind、Sandbox 或權限。** 每個角色的 CLI kind 與 Codex Sandbox，由 `scripts/Start-WorkerAgent.ps1` 固定檢查。
3. 在 PowerShell 7 執行唯讀檢查：

   ```powershell
   $C = 'D:\AI-Company'
   & "$C\tests\Test-WorkerModelConfig.ps1" -Company $C
   & "$C\scripts\Start-WorkerAgent.ps1" -CompanyRoot $C -WorkerSkill software-code-review -Preview
   ```

4. 下次由 Manager 建立 Worker Session 時，透過 `scripts/Start-WorkerAgent.ps1` 讀取這份設定，將模型參數交給 `herdr agent start`。
5. **既有執行中的 Worker 不會被熱切換模型。** 若要變更，先等工作完成、保留報告，再於空 Shell Pane 重新啟動。不要為了改模型中斷正在編輯的工作。

## 真正的啟動入口

Manager 使用 `company-router/references/runtime.md` 的流程，建立 Worker 的空 Shell Pane，再呼叫：

```powershell
& 'D:\AI-Company\scripts\Start-WorkerAgent.ps1' -CompanyRoot 'D:\AI-Company' -WorkerSkill 'software-code-review' -AgentName $reviewName -PaneId $reviewPane
```

啟動器會讀 `agent-models.json`、檢查角色、產生 CLI 原生參數，再呼叫 Herdr。Reviewer 的 Codex Sandbox 固定為 `read-only`；Coding／Unit Test 固定為 `workspace-write`。若已確認可信專案需要 NuGet／依賴套件還原，可對 `workspace-write` Codex Worker 額外使用 `-AllowNetwork`；預設**不啟用**，不能對 Reviewer 或 Claude Worker 使用。這個腳本**只啟動一位 Worker**，不建立 Pane、不執行 Skill 任務、不取代 Team Skill 的編排或 Contract／Quality Gate。

如果指定模型在 CLI 中不可用，啟動會失敗並回報，**不應默默改成更貴的模型或降低沙箱限制**。
