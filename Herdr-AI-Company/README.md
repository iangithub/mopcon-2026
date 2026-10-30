# Herdr AI Company

一套使用 **Herdr + Codex CLI + Claude Code CLI** 建立的 AI 團隊協作環境。包含 Software Team 與 Writing Team，使用專案 `AGENTS.md` 固定主責部門，僅在必要時透過 `company-router` 進行跨部門支援。

**第一次安裝，請直接從 [WORKSHOP.md](WORKSHOP.md) 的 STEP 0 開始。** 它是唯一的部署手冊，每個 STEP 都包含目標、實際命令和成功判斷，不必先讀完整架構文件。

## 主要文件在哪裡？

| 我要做的事 | 請讀 |
|---|---|
| 從空白 Windows 電腦安裝到第一次開工 | [WORKSHOP.md](WORKSHOP.md) |
| 確認每一個 `.md`、`.ps1` 與資料夾應放哪裡 | [docs/FILE-PLACEMENT.md](docs/FILE-PLACEMENT.md) |
| **看懂作業流水線：每個節點由哪些 Skill、Rule、指令負責** | **[docs/EXECUTION-FLOW.md](docs/EXECUTION-FLOW.md)** |
| 理解 Manager／Team／Worker／Rule 的關係 | [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) |
| **設定不同 Worker 的模型與 Reasoning Effort** | **[config/README.md](config/README.md)** |
| 驗證跨部門支援 | [docs/CROSS-DEPARTMENT-TEST.md](docs/CROSS-DEPARTMENT-TEST.md) |
| 驗證 PASS／FAIL／BLOCKED 與修復交接 | [docs/CONTRACT-TEST.md](docs/CONTRACT-TEST.md) |
| 記錄實機驗收結果 | [docs/ACCEPTANCE.md](docs/ACCEPTANCE.md) |
| 安裝或 Skill 載入發生問題 | [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) |

## 三個最重要的界線

- **公司共用規範：** `D:\AI-Company\`，只維護一份。
- **實際專案：** `D:\Workspaces\...`，各專案維護自己的 `AGENTS.md` 與 `docs/team-rules/`。
- **CLI 使用者入口：** 公司自訂的 12 個 Skill 經 `$HOME\.agents\skills\`、`$HOME\.claude\skills\` 的 Junction 共用；`$HOME\.codex\AGENTS.md`、`$HOME\.claude\CLAUDE.md` 提供 Manager 啟動短橋接。
- **Herdr 官方 Skill：** 依 STEP 3 使用 `npx skills add herdrdev/herdr --skill herdr -g` 全域安裝至 Codex／Claude，獨立於公司自訂 Skill。

部署不會修改任何既有正式專案。建議先用手冊內的兩個測試專案驗證。尚未完成目標 Windows 機上的實機整合驗收。
