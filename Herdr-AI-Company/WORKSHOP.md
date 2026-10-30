# Herdr AI Company｜從零建立可協作的 AI 團隊

> **安裝與操作手冊（Windows 11／PowerShell 7）**  
> 本手冊就是安裝入口。每個 STEP 都依序提供 **本步目標 → 操作 → 如何確認成功**。請從 STEP 0 開始，不需要先理解所有 Skill 或 Contract。

這套環境讓你在專案目錄啟動 Herdr，先和 **Manager** 討論需求；你授權「好，開始做吧」之後，Manager 根據該專案 `AGENTS.md` 的 `Department` 派遣主責部門。只有需要其他專業時，`company-router` 才調派支援部門。每個 Worker 在獨立 Pane 執行 Codex／Claude CLI，透過自己的 **Skill SOP → references → 專案 Rule** 工作，使用 **標準契約**交接。

支援兩個部門：**Software Team**、**Writing Team**。Herdr 透過既有 CLI 提供 Pane 與 Agent 的操作介面。

**想先理解執行流程？** [docs/EXECUTION-FLOW.md](docs/EXECUTION-FLOW.md) 逐關標出 Manager、Team Skill、Worker Skill、Project Rules、Contract、PowerShell 的負責工作。安裝時仍依本手冊順序操作。

## 步驟總覽

| STEP | 做什麼 | 完成時看見什麼 |
|---|---|---|
| 0 | 安裝必要工具 | `pwsh`、`herdr`、`codex`、`claude` 可執行 |
| 1 | 把公司套件放進固定目錄 | `D:\AI-Company\WORKSHOP.md` 與 `.agents\skills\` 存在 |
| 2 | 對照檔案與目錄 | 清楚公司檔案、使用者設定、專案檔案各在哪裡 |
| 3 | 以官方工具全域安裝 Herdr Skill | Codex／Claude 可使用全域 `herdr` Skill；公司目錄不保存官方副本 |
| 4 | 安裝公司自訂 Skills 到兩個 CLI | 12 個公司 Skill 透過 Junction 共用同一份來源 |
| 5 | 設定 Manager 啟動入口 | Codex／Claude 的全域指令指向公司 Bootstrap |
| 6 | 建立軟體、寫書兩個測試專案 | 各有自己的 `AGENTS.md` 與專案 Rule |
| 7 | 先跑靜態、模型與契約測試 | Rule Registry、模型配置、Contract 正反例測試有結果 |
| 8 | 在 Herdr 開啟專案 Workspace | 每個專案各自有 Root Pane |
| 9 | 驗證 Manager 身分與設定 | 能正確回報 `Department`，尚未建立 Worker |
| 10 | 執行 Software Team | 右側 Coding／Unit Test／Code Review 三個 Pane |
| 11 | 執行 Writing Team 與跨部門支援 | Writing Manager 仍是主責，程式範例由 Software Guest 支援 |
| 12 | 驗證 FAIL → Repair → 再審查 | 契約資料、Finding ID、Snapshot 及 Quality Gate 可核對 |
| 13 | 套用到你自己的正式專案 | 不複製公司 Skill，只新增專案規範 |

## 先看這張圖：誰應該放在哪裡？

```text
D:\
├─ AI-Company\                         ← 公司制度：唯一來源，只安裝一份
│  ├─ WORKSHOP.md                       ← 你現在讀的手冊
│  ├─ README.md                         ← 簡短入口
│  ├─ AGENTS.md                         ← 維護公司設定庫時適用；不代表某專案部門
│  ├─ .agents\skills\                  ← Team Skill + 9 個 Worker Skill + Router
│  │  ├─ company-router\SKILL.md
│  │  ├─ software-team\SKILL.md
│  │  ├─ writing-team\SKILL.md
│  │  ├─ software-coding\SKILL.md
│  │  ├─ software-code-review\SKILL.md
│  │  ├─ software-unit-test\SKILL.md
│  │  ├─ software-repo-scout\SKILL.md
│  │  ├─ writing-writer\SKILL.md
│  │  ├─ writing-editor\SKILL.md
│  │  ├─ writing-fact-check\SKILL.md
│  │  ├─ writing-proofreader\SKILL.md
│  │  └─ writing-researcher\SKILL.md  ← 共 12 個公司自訂 Skills（不含官方 herdr）
│  ├─ bootstrap\manager-startup.md     ← Manager 啟動規則
│  ├─ config\agent-models.json          ← Worker CLI／模型／推理強度，Manager 模型不受影響
│  ├─ contracts\                       ← JSON 契約、Schema、狀態機
│  ├─ policies\                        ← 公司級權限、Rule 組合及交付政策
│  ├─ scripts\                         ← 正式流水線：Snapshot／Contract／Repair／Gate／Worker 啟動
│  ├─ tests\                           ← 安裝檢查／Rule Registry／離線合成測試
│  ├─ templates\                       ← 測試專案範本，STEP 6 才複製出去
│  └─ docs\                            ← 參考文件與完整放置清單
│
└─ Workspaces\                         ← 各專案的實際工作檔案，與公司庫分離
   ├─ Software\Project-A\
   │  ├─ AGENTS.md                    ← Department: software + Rule Registry
   │  ├─ docs\team-rules\*.md         ← 本專案真正的程式規範
   │  └─ src\ / tests\                ← 實作時才依需求建立
   └─ Writing\Book-A\
      ├─ AGENTS.md                    ← Department: writing + Rule Registry
      ├─ docs\team-rules\*.md         ← 本書真正的寫作與程式範例規範
      ├─ drafts\                      ← 草稿
      └─ examples\                    ← 需要時由 Software Guest 產生

C:\Users\<Windows 使用者>\
├─ .codex\AGENTS.md                    ← Manager 啟動橋接，只需加入短指引
├─ .agents\skills\<company-skill>\   ← Junction 指向 D:\AI-Company 的 12 個自訂 Skills
├─ .claude\CLAUDE.md                  ← Manager 啟動橋接，只需加入短指引
└─ .claude\skills\<company-skill>\   ← Junction 指向同一份公司 Skill

官方 herdr Skill：STEP 3 由 npx skills 全域安裝至所選 CLI 的使用者 Skill 位置；
不放在 D:\AI-Company\.agents\skills\，也不參與 STEP 4 的手動 Junction。
```

**每個 Markdown / PowerShell 的明確去處**：請看 [docs/FILE-PLACEMENT.md](docs/FILE-PLACEMENT.md)。要了解工作實際怎麼流過各檔案與檢查關卡，請看 [docs/EXECUTION-FLOW.md](docs/EXECUTION-FLOW.md)。

---

## STEP 0｜準備測試電腦與工具

### 本步目標
安裝 Windows 11 所需的 PowerShell 7.4+、Git、Node.js、Herdr、Codex CLI、Claude Code CLI；有程式測試需求時再安裝 .NET SDK。

### 操作

1. 在 **PowerShell** 安裝 PowerShell 7、Git、Node.js LTS（已安裝者跳過）：

   ```powershell
   winget install --id Microsoft.PowerShell --exact
   winget install --id Git.Git --exact
   winget install --id OpenJS.NodeJS.LTS --exact
   ```

2. **重新開啟 PowerShell 7（pwsh.exe）**，確認：

   ```powershell
   pwsh --version
   git --version
   node --version
   npm --version
   ```

3. 安裝 Herdr。Windows 指令請以 [Herdr 官方安裝說明](https://herdr.dev/docs/install/) 為準；下列是官方 PowerShell 安裝方式，**先確認下載網址與本機執行政策**：

   ```powershell
   powershell -ExecutionPolicy Bypass -c "irm https://herdr.dev/install.ps1 | iex"
   herdr --version
   ```

4. 安裝並登入 Codex CLI：

   ```powershell
   npm install -g @openai/codex
   codex --version
   codex
   ```

   首次啟動依官方提示完成授權，然後退出，回到 PowerShell。

   **設定 Codex 的 Shell 環境繼承（Herdr 整合必要檢查）**：在這套 Windows 環境的實測中，普通 `codex` 啟動後，工具執行環境曾讀不到 Herdr 提供的 `HERDR_ENV`；修改使用者設定後已恢復正常。請在進入 STEP 8 之前完成以下設定：

   ```powershell
   $Config = Join-Path $HOME '.codex\config.toml'
   New-Item -ItemType Directory -Path (Split-Path $Config) -Force | Out-Null
   if (Test-Path -LiteralPath $Config) {
       Copy-Item -LiteralPath $Config -Destination "$Config.bak" -Force
   }
   notepad $Config
   ```

   在 `config.toml` **既有的 `[shell_environment_policy]` 區段**設定 `inherit`；如果沒有該區段，才新增一次：

   ```toml
   [shell_environment_policy]
   inherit = "all"
   ```

   不要覆蓋既有模型、授權、Sandbox 設定，也不要重複建立同名 TOML 區段。儲存後**退出並重新開啟 Codex Session**。此為使用者層級設定，會影響該帳號下的 Codex 工具執行環境；`inherit = "all"` 可能讓子程序繼承包含憑證在內的環境變數，請避免把敏感變數輸出到日誌或傳給不受信任的命令。

   **STEP 8 將在 Herdr Pane 中驗證 `HERDR_ENV`，不用每次輸入 `codex -c ...`。** 這項設定解決了測試機的環境傳遞現象；若其他 Codex 版本仍有問題，請按 `docs/TROUBLESHOOTING.md` 進一步定位，不應直接假設自己不在 Herdr 裡。

5. 安裝並登入 Claude Code（依 [Claude Code 官方安裝](https://code.claude.com/docs/en/setup)）：

   ```powershell
   irm https://claude.ai/install.ps1 | iex
   claude --version
   claude
   ```

6. 如果要真的建立與測試 .NET 程式，再安裝 SDK：

   ```powershell
   winget install --id Microsoft.DotNet.SDK.8 --exact
   dotnet --info
   ```

### 如何確認成功
`pwsh --version` 至少 7.4；`herdr --version`、`codex --version`、`claude --version` 有正常輸出，且兩個 CLI 都完成登入。此處先不必開 Herdr 的 Worker Pane。

> 說明：Herdr 負責 Terminal／Agent 調度，不取代 Codex 或 Claude 的安裝與登入。契約工具使用 PowerShell 7 的 JSON 功能。

---

## STEP 1｜將 AI Company 檔案放到固定目錄

### 本步目標
公司 Skills、Contracts 與 Policies **只保留一份來源**，不複製到每一個專案。

### 操作

1. 將收到的 `AI-Company.zip` 解壓。ZIP 內的第一層資料夾叫 **`AI-Company`**。
2. 在磁碟建立 `D:\AI-Company`，把解壓後 `AI-Company` 內的**全部內容（包含隱藏 `.agents`）**複製到 `D:\AI-Company`。可用檔案總管完成。
3. 或用下列 PowerShell 明確複製（依實際下載位置修改 `$Source`）。此指令**拒絕覆蓋現有公司目錄**：

   ```powershell
   $Source = Join-Path $HOME 'Downloads\AI-Company'
   $Company = 'D:\AI-Company'
   if (-not (Test-Path -LiteralPath (Join-Path $Source 'WORKSHOP.md'))) { throw '找不到解壓來源，請先確認 ZIP 的第一層資料夾' }
   if (Test-Path -LiteralPath $Company) { throw 'D:\AI-Company 已存在；請先檢查、備份或改用乾淨的測試電腦，不直接覆蓋' }
   New-Item -ItemType Directory -Path $Company | Out-Null
   Get-ChildItem -LiteralPath $Source -Force | ForEach-Object {
       Copy-Item -LiteralPath $_.FullName -Destination $Company -Recurse -Force
   }
   ```

4. 檢查幾個重要檔案：

   ```powershell
   Test-Path 'D:\AI-Company\WORKSHOP.md'
   Test-Path 'D:\AI-Company\.agents\skills\software-code-review\SKILL.md'
   Test-Path 'D:\AI-Company\contracts\schemas\worker-report.schema.json'
   Test-Path 'D:\AI-Company\bootstrap\manager-startup.md'
   ```

### 如何確認成功
上述四個檢查都應回傳 `True`。**不要**把 `D:\AI-Company\AGENTS.md` 當成 Project-A 的 `AGENTS.md`；它們用途不同。

> 這份手冊以 `D:` 為範例。若測試機沒有 D 槽，請選擇另一個固定目錄，並將後續 `D:\AI-Company`、`D:\Workspaces` 及共用 Skill 中的路徑設定一致替換。第一次驗證最簡單的方式是依本手冊使用 D 槽。

---

## STEP 2｜確認公司目錄的責任分工

### 本步目標
知道哪些檔案是公司共用、哪些應隨專案而變，不要把所有規範塞進 Manager。

### 操作

| 公司來源位置（均在 `D:\AI-Company\`） | 作用 | 需要手動搬進每個專案嗎？ |
|---|---|---|
| `.agents\skills\company-router\` | **只**處理跨部門支援，不猜 Project Department | 不需要 |
| `.agents\skills\software-team\`、`writing-team\` | 部門排程／關卡／派工 | 不需要 |
| `.agents\skills\software-*\`、`writing-*\` | 個別 Worker 的 SOP，含 `references\` | 不需要 |
| `bootstrap\manager-startup.md` | Manager 啟動規則 | 不需要；在 STEP 5 建立全域橋接 |
| `policies\` | 公司共同安全與工作底線 | 不需要 |
| `contracts\` | 派工、回報、修復 JSON 契約 | 不需要 |
| `scripts\` | 正式任務的快照、契約驗證、修復請求、品質門工具 | 不需要；由 Manager 依 Team Skill 呼叫 |
| `tests\` | 安裝／Rule Registry 檢查、離線合成契約測試 | 不需要；部署或診斷時呼叫 |
| `templates\` | 專案**起始範本**，內有專案 `AGENTS.md` 與 Rule | **需要**，只在建立專案時複製一次 |
| `docs\` | 架構、檔案對照、測試細節 | 不需要 |

### 如何確認成功
你能說出：**Team Skill 管協作；Worker Skill 管 SOP；references 管執行方法；Project Rule 管實際技術／寫作標準；Contract 管交接。**

---

## STEP 3｜透過官方安裝器，全域安裝 Herdr 操作 Skill

### 本步目標
讓 Codex 與 Claude Code 都能使用官方 `herdr` Skill 操作 Pane／Agent；此 Skill 由官方來源獨立更新，**不納入 `D:\AI-Company` 公司自訂 Skill 來源**。

### 操作

1. 在 PowerShell 7 執行 Herdr 官方建議的全域安裝指令：

   ```powershell
   npx skills add herdrdev/herdr --skill herdr -g
   ```

   依安裝器提示選擇 **Codex** 和 **Claude Code**。若要明確指定兩個目標，可改用以下等效指令（**擇一執行即可**）：

   ```powershell
   npx skills add herdrdev/herdr --skill herdr -g -a codex -a claude-code
   ```

2. 檢查全域 Skill 安裝清單：

   ```powershell
   npx skills ls -g
   ```

   確認 `herdr` 已列於 Codex、Claude Code 對應的全域安裝項目。必要時也可以檢查使用者 Skill 位置；實際路徑以安裝器輸出為準：

   ```powershell
   Test-Path (Join-Path $HOME '.agents\skills\herdr\SKILL.md')
   Test-Path (Join-Path $HOME '.claude\skills\herdr\SKILL.md')
   ```

3. 重新啟動 Codex、Claude Code Session，實際確認兩者能辨識 `herdr` Skill。**檔案存在或清單顯示已安裝，不等於 CLI 已成功載入。** Herdr 控制命令必須在 `HERDR_ENV=1` 的 Herdr Pane 內執行。

> 如果原本已在 `D:\AI-Company\.agents\skills\herdr` 建立官方副本，或 `$HOME` 有指向它的同名 Junction，先參考 [同名 Skill 衝突處理](docs/TROUBLESHOOTING.md#官方-herdr-skill-同名衝突處理)，核對連結目標並清除舊入口，再進行全域安裝。**不要直接覆蓋未知來源的使用者 Skill。**
>
> 官方文件：[Herdr Agent Skill](https://herdr.dev/docs/agent-skill/)；`npx skills add` 與 `-g` 的行為依 [Skills CLI 官方文件](https://github.com/vercel-labs/skills/blob/main/docs/commands.md) 為準。

### 如何確認成功
`npx skills ls -g` 可找到全域 `herdr`，而新開的 Codex／Claude Code Session 能辨識該 Skill；**`D:\AI-Company\.agents\skills\herdr` 不應存在**。

---

## STEP 4｜讓 Codex 與 Claude 使用同一份 Skills

### 本步目標
公司自訂的 12 個 Skills 只維護一份，透過 **NTFS Junction** 連到 Codex／Claude Code 使用者目錄。**官方 `herdr` 已於 STEP 3 全域安裝，不要再用 Junction 指向公司目錄。**

### 操作

1. 先確認你的 Codex、Claude 使用者 Skill 目錄：

   ```powershell
   $CodexSkills = Join-Path $HOME '.agents\skills'
   $ClaudeSkills = Join-Path $HOME '.claude\skills'
   New-Item -ItemType Directory -Path $CodexSkills,$ClaudeSkills -Force | Out-Null
   $CodexSkills
   $ClaudeSkills
   ```

2. 先做**一個**可核對的連結範例：

   ```powershell
   $Src = 'D:\AI-Company\.agents\skills\software-code-review'
   $Dst = Join-Path $HOME '.agents\skills\software-code-review'
   if (Test-Path -LiteralPath $Dst) { throw "同名 Skill 已存在，請先人工確認：$Dst" }
   New-Item -ItemType Junction -Path $Dst -Target $Src
   Get-Item -LiteralPath $Dst | Format-List FullName,LinkType,Target
   ```

3. 其餘 Skill 使用**同一個明確清單**建立連結。已存在的同名檔案／連結**只提示，不覆蓋**：

   ```powershell
   $CompanySkills = 'D:\AI-Company\.agents\skills'
   $Names = @(
     'company-router','software-team','writing-team',
     'software-coding','software-code-review','software-unit-test','software-repo-scout',
     'writing-writer','writing-editor','writing-fact-check','writing-proofreader','writing-researcher'
   )
   foreach ($Name in $Names) {
     $Source = Join-Path $CompanySkills $Name
     if (-not (Test-Path -LiteralPath (Join-Path $Source 'SKILL.md'))) { throw "找不到：$Source\SKILL.md" }
     $CodexSkills = Join-Path $HOME '.agents\skills'
     $ClaudeSkills = Join-Path $HOME '.claude\skills'
     foreach ($Base in @($CodexSkills, $ClaudeSkills)) {
       $Target = Join-Path $Base $Name
       if (Get-Item -LiteralPath $Target -Force -ErrorAction SilentlyContinue) {
         Write-Warning "已存在（不覆蓋）：$Target"
       } else {
         New-Item -ItemType Junction -Path $Target -Target $Source | Out-Null
       }
     }
   }
   ```

4. 檢查至少兩個連結：

   ```powershell
   Get-Item (Join-Path $HOME '.agents\skills\software-code-review') | Format-List LinkType,Target
   Get-Item (Join-Path $HOME '.claude\skills\writing-editor') | Format-List LinkType,Target
   ```

5. **重新開啟新的 Codex／Claude CLI Session**，檢查 Codex 能明確叫出 `$software-code-review`、Claude 能明確執行 `/writing-editor`。不要只看檔案存在，就假設 CLI 一定已載入。若 Claude 在 Windows 上無法發現 Junction Skill，依 [Claude 官方 Skills 文件](https://code.claude.com/docs/en/skills) 排查，不要讓 Worker 在缺 Skill 的情況下繼續。

### 如何確認成功
12 個**自訂 Skill** 各有對應的 Junction，`LinkType` 是 `Junction`，`Target` 指向正確公司 Skill；官方 `herdr` 則由 STEP 3 的全域安裝器管理。新開的 CLI 必須能實際辨識自訂 Skills 與官方 `herdr`。

> `D:\AI-Company\.agents\skills\software-code-review\references\` **不用另建 Junction**；它會隨 Skill 資料夾一起讀取。所有 `references/*.md` 都留在該 Skill 內。

---

## STEP 5｜為兩個 CLI 設定 Manager 啟動橋接

### 本步目標
當你在 Herdr Root Pane 開啟 Codex 或 Claude 時，它知道自己是 Manager，並讀取共用 Bootstrap；**不要把整份 Bootstrap 複製成兩份**。

### 操作

1. 開啟（不存在就建立）以下兩個檔案：

   | 工具 | 正確位置 |
   |---|---|
   | Codex CLI | `C:\Users\<你>\.codex\AGENTS.md`（即 `$HOME\.codex\AGENTS.md`） |
   | Claude Code | `C:\Users\<你>\.claude\CLAUDE.md`（即 `$HOME\.claude\CLAUDE.md`） |

2. **在兩個檔案的最後面各附加一次**下列短指引；如果已有個人設定，請保留既有內容並先備份。**不要覆蓋整份全域檔案**。

   ```markdown
   <!-- BEGIN AI-COMPANY MANAGER BOOTSTRAP -->
   When running inside Herdr (HERDR_ENV=1) as the user-facing Manager,
   read and follow D:\AI-Company\bootstrap\manager-startup.md before routing work.
   CompanyRoot: D:\AI-Company
   The project-root AGENTS.md is the only source of Department and Rule Registry.
   In normal project work use the owner department directly.
   Invoke company-router only for cross-department support.
   When AI_COMPANY_ROLE=worker or WORKER_CONTRACT is present,
   do NOT act as Manager, do NOT run Herdr, and follow the assigned Worker Skill.
   Outside Herdr behave as a normal CLI session.
   <!-- END AI-COMPANY MANAGER BOOTSTRAP -->
   ```

3. 確認只加入**一次**，且不是指向已不存在的路徑；存檔後重新啟動 Codex／Claude CLI。

### 如何確認成功
兩個全域檔案各有**唯一**的 `BEGIN AI-COMPANY MANAGER BOOTSTRAP` 標記與正確路徑。`D:\AI-Company\bootstrap\manager-startup.md` 是真正的政策內容，只有一份。

> **注意**：全域橋接只在 `HERDR_ENV=1` 且不是 Worker 時才生效；不應讓你在普通 CLI 中執行的所有任務都自動開 Herdr Pane。這是文字規約而非 OS 強制攔截器，需在 STEP 9 驗證。

---

## STEP 6｜建立各自獨立的專案工作區

### 本步目標
把公司 **templates 裡的測試專案**複製到真正的 Workspace，確認每個專案的主責部門與 Rules 分開。

### 操作

1. 在 PowerShell 7 執行：

   ```powershell
   $Company = 'D:\AI-Company'
   $Workspaces = 'D:\Workspaces'
   $Projects = @(
     @{ Department='Software'; Name='Project-A' },
     @{ Department='Writing';  Name='Book-A' }
   )
   foreach ($Project in $Projects) {
     $Source = Join-Path $Company ("templates\{0}\{1}" -f $Project.Department,$Project.Name)
     $Target = Join-Path $Workspaces ("{0}\{1}" -f $Project.Department,$Project.Name)
     if (Test-Path -LiteralPath $Target) { throw "專案已存在，不覆蓋：$Target" }
     New-Item -ItemType Directory -Path $Target -Force | Out-Null
     Get-ChildItem -LiteralPath $Source -Force | ForEach-Object {
       Copy-Item -LiteralPath $_.FullName -Destination $Target -Recurse -Force
     }
   }
   ```

2. 打開 `D:\Workspaces\Software\Project-A\AGENTS.md`，確認：

   ```text
   Department: software
   ```

   且 `## Rule Registry` 內有 `software.architecture`、`software.coding`、`software.testing`、`software.review`、`software.security` 指向 `docs/team-rules/`。

3. 打開 `D:\Workspaces\Writing\Book-A\AGENTS.md`，確認：

   ```text
   Department: writing
   ```

   且 Writing Rule（style、editorial、facts、sources、proofreading）在 `docs/team-rules/`。Book-A 的 `software.*` 也應指向**這本書**的 `docs/team-rules/code-examples.md`，提供跨部門程式範例的標準。

### 如何確認成功

```powershell
Test-Path 'D:\Workspaces\Software\Project-A\AGENTS.md'
Test-Path 'D:\Workspaces\Software\Project-A\docs\team-rules\code-review.md'
Test-Path 'D:\Workspaces\Writing\Book-A\AGENTS.md'
Test-Path 'D:\Workspaces\Writing\Book-A\docs\team-rules\code-examples.md'
```

全部應為 `True`。

> `Department` 是**專案主責部門**，不會因為 Book-A 需要寫 C# 範例而改成 `software`。每個專案的 Rule Registry 才是 Worker 當次的規範來源。ToDo、特定章節等短期任務不要放進長期 Project Context。

---

## STEP 7｜先做不需要 AI 的設定驗證

### 本步目標
先排除放錯資料夾、找不到 Rule、模型設定不完整、契約格式錯誤，再去測 Herdr Agent 自動派工。

### 設定 Worker 模型

所有 Worker 的 Model／Effort 集中在 **`D:\AI-Company\config\agent-models.json`**，詳細角色對照見 [config/README.md](config/README.md)。例如 Software Team 預設：Coding 使用 `gpt-6-sol`／medium；Code Review 使用 `gpt-6-sol`／high；Unit Test、Repo Scout 使用 `gpt-6-luna`。Manager 使用何種模型，仍由你在主 Pane 的 Codex／Claude 選擇。

1. 用編輯器開啟 `D:\AI-Company\config\agent-models.json`，確認九位 Worker 的 Model／Effort 符合帳號目前可用模型。**只調整 `model` 與 `effort`，不隨意修改 `kind`。**
2. 使用者帳號的 `~/.codex/config.toml` 仍保留 STEP 0 的 `shell_environment_policy.inherit = "all"`，那是 Herdr 環境變數繼承設定，與這份 Worker 模型配置不同。
3. 本 STEP 會先驗證模型設定；Manager 後續會在建立空 Shell Pane 後，**透過 `scripts/Start-WorkerAgent.ps1` 真正啟動各 Worker**。不會只讀 JSON 卻仍使用 CLI 預設模型。
4. **配置變更不會影響已在執行的 Worker**；新 Session 才會套用。若模型無權使用，先修正配置，不默默降級或切換至 Manager 模型。

### 操作

```powershell
$C = 'D:\AI-Company'
$S = 'D:\Workspaces\Software\Project-A'
$W = 'D:\Workspaces\Writing\Book-A'

& "$C\tests\Verify-Structure.ps1" -Company $C
& "$C\tests\Verify-RuleRegistry.ps1" -ProjectRoot $S
& "$C\tests\Verify-RuleRegistry.ps1" -ProjectRoot $W
& "$C\tests\Test-WorkerModelConfig.ps1" -Company $C
& "$C\scripts\Start-WorkerAgent.ps1" -CompanyRoot $C -WorkerSkill software-code-review -Preview
& "$C\tests\Run-ContractTests.ps1" -CompanyRoot $C
```

### 如何確認成功
- `Verify-Structure` 檢查各 Worker 的 `SKILL.md`／`references`／公司契約入口，以及 `scripts/` 與 `tests/` 的分工。
- `Test-WorkerModelConfig` 檢查九位 Worker 的 Model／Effort；`Start-WorkerAgent -Preview` 能顯示 Code Review 的 `read-only`、模型 ID 與 Reasoning Effort，且不啟動任何 Pane。
- 兩份 `Verify-RuleRegistry` 不應有缺 Rule、重複 Key 或越界路徑。
- 合成契約測試應輸出 `PASS ALL SYNTHETIC CONTRACT TESTS`；其中「壞 Finding／假 PASS／錯 Hash／過期 Snapshot」被拒絕才算測試正常。

> 這步是**離線資料契約測試**，不能當作 Herdr + Codex + Claude 已經整合成功。`tests/Run-ContractTests.ps1` 會呼叫 `scripts/` 的正式工具處理合成資料；工作中真正使用的腳本名稱、時機與輸出請見 [docs/EXECUTION-FLOW.md](docs/EXECUTION-FLOW.md)。

---

## STEP 8｜為每個專案建立 Herdr Workspace

### 本步目標
每個專案有自己的 Herdr Workspace 與 Root Pane，不把 Book-A 的內容混進 Project-A。

### 操作

1. 在**一般 PowerShell 終端機（Herdr 外）**，先從 Project-A 專案目錄啟動 Herdr：

   ```powershell
   Set-Location 'D:\Workspaces\Software\Project-A'
   herdr
   ```

   第一次啟動且尚無 Workspace 時，Herdr 會自動建立目前專案的 Workspace。若已有其他 Workspace，請看下一步建立正確的專案 Workspace，**不要以為再次執行 `herdr` 就會切換專案**。

2. 保持 Herdr 畫面開著，另開一個 **PowerShell 7 視窗（Herdr 外）**，先列出現有 Workspace，再只建立尚不存在的那一個：

   ```powershell
   herdr workspace list
   # 如清單中尚未有 Software Project-A，才執行：
   herdr workspace create --cwd 'D:\Workspaces\Software\Project-A' --label 'Software Project-A' --no-focus
   # 如清單中尚未有 Writing Book-A，才執行：
   herdr workspace create --cwd 'D:\Workspaces\Writing\Book-A' --label 'Writing Book-A' --no-focus
   herdr workspace list
   ```

   注意上面的 `workspace create` 是**條件式示範**，不是要你不看結果就全部執行；不應建立重複 Workspace。

3. 回到 Herdr UI，選擇 **Software Project-A** 的 Root Shell Pane，輸入：

   ```powershell
   codex
   ```

   這個 Codex CLI 就是左側 **Manager**。Manager 的模型由本 Pane 的 Codex 設定決定，與 `config/agent-models.json` 無關；**Worker 模型只在 Manager 之後建立獨立 Pane、透過啟動器啟動時生效**。此時不需要自己先開三個 Worker Pane。Book-A 也可使用 Codex Manager；後續 Writer Worker 仍可由 Herdr 啟動 Claude Code。

4. **驗證環境變數確實能進入 Codex 的工具執行環境**：請 Codex **實際執行**下列唯讀 PowerShell（不是只讓它口頭回答自己是不是 Manager）：

   ```powershell
   [pscustomobject]@{
       HERDR_ENV = $env:HERDR_ENV
       HERDR_WORKSPACE_ID = $env:HERDR_WORKSPACE_ID
       HERDR_PANE_ID = $env:HERDR_PANE_ID
   } | ConvertTo-Json
   ```

   正常應至少取得 `HERDR_ENV = "1"`；工作區、Pane ID 應以實際 Herdr 版本與執行環境的輸出為準。`AI_COMPANY_ROLE` 在主 Manager Pane 可以未設定，不應僅因它是 `null` 就判定為一般 CLI。如果 `HERDR_ENV` 在 Herdr Shell 可讀、在 Codex 工具中卻是空值，先檢查 STEP 0 的 `$HOME\.codex\config.toml`，退出並重新啟動 Codex；仍無法取得時參閱故障排除。

### 如何確認成功
Herdr 側邊欄有 Software Project-A 與 Writing Book-A；每個 Workspace 都有自己的 Root Pane。Manager 是開在**正確的專案**內，且 Codex 的工具執行環境能實際讀到 `HERDR_ENV=1`。

> Herdr 是會持續存在的 Session。從另一個資料夾再執行 `herdr` 可能只是附加既有 Session，**不代表自動切換 CWD 與 Workspace**；先確認目前 Workspace。Herdr CLI 以目前安裝版 `herdr --help` 和官方 [CLI Reference](https://herdr.dev/docs/cli-reference/) 為準。

---

## STEP 9｜確認 Manager 正確載入公司制度

### 本步目標
在建立 Worker 之前，先確認 Manager 懂得使用 Department，而且沒有憑任務文字猜部門。

### 操作

在 Project-A 的 Codex Manager 中輸入：

> 請只做環境自檢，不要建立 Pane、不要修改任何檔案。回報目前 Workspace、ProjectRoot、專案 AGENTS.md 的 Department、Rule Registry Keys、CompanyRoot 與 Manager Bootstrap 的絕對路徑，並說明「開始做吧」之前應處於什麼狀態。

切到 Book-A 做相同檢查。

### 如何確認成功
Project-A 回 `software`；Book-A 回 `writing`。Manager 知道 Planning 不開 Worker；不會從提到 C#、寫書等詞自行改變專案 Department。若連公司 Bootstrap 都無法讀到，回 STEP 5 排查。

---

## STEP 10｜Software Team：從討論到三位 Worker

### 本步目標
驗證平常的實際用法：先討論、再說「開始做吧」，右側才建立三個獨立的 Codex CLI Worker Pane。

### 操作

1. 在 Software Project-A Manager 輸入：

   > 我想增加一個簡單、可測試的 .NET 8 功能。先跟我討論功能需求、檔案安排、Unit Test 與驗收條件；在我說開始前不要寫任何程式，也不要建立 Worker Pane。

2. 討論確認後輸入：

   > 好，那開始做吧。

3. 觀察 Herdr 右側，應建立並命名：

   ```text
   左側：Manager
   右側：Coding Agent       → Codex + software-coding Skill
         Unit Test Agent    → Codex + software-unit-test Skill
         Code Review Agent  → Codex + software-code-review Skill
   ```

4. Manager 必須先建立並驗證 `D:\Workspaces\Software\Project-A\.ai-work\runs\<run-id>\dispatch-*.json`，而非把全部 Coding Rule 貼在 Prompt。Coding 會自行讀 `software-coding/SKILL.md`、其 References，以及 Project-A `AGENTS.md`／Rule Registry。其他兩位 Worker 也依自己的 Skill 工作。
5. 完成一個穩定的 Coding Checkpoint 後，Unit Test 真正執行專案指定的 Build/Test；Code Review 在唯讀 Sandbox 內審查原始 Diff 與測試證據。最後由 Manager 判斷 Quality Gate。

### 如何確認成功
你能觀察到三個 Pane、各自的 CLI Agent 與 Skill，並且在 `.ai-work/runs/<run-id>/` 找到有效的 Dispatch／Report。Test 有**實際 Exit Code、Log**，Reviewer 有真實 Finding 或明確無阻擋結論。未執行測試、缺 Rule 或契約無效時，不能算 PASS。

---

## STEP 11｜Writing Team 與跨部門支援

### 本步目標
驗證一般寫作預設由 Writing Team 負責；需要可執行程式範例時，才臨時向 Software Team 借人。

### 操作

1. 在 Book-A 的 Manager 討論：

   > 我想寫一章介紹 HTTP 狀態碼的技術文章。先討論章節架構、讀者程度、引用來源與驗收標準，不要立即寫稿。

   範本的 `drafts/chapter-01.md` 含一段**刻意放錯的 HTTP 404／500 說明**，用於驗證 Fact Checker 是否真的查證來源。這是待審初稿，不是可信知識來源。

2. 定案後：

   > 好，開始寫吧。

   Manager 依 Writing Team Skill 指派適合的 Writer、Editor、Fact Checker、Proofreader；**不需要固定四個 Worker 同時啟動**。

3. 然後追加跨部門需求：

   > 這一章還要一份能執行、能通過 Unit Test 的 C# 程式範例。請由 Software Team 支援，完成後讓 Writing Manager 把經驗證的成果納入書稿。

4. 觀察 `company-router` 是否建立受控 Guest Delegation。Software Guest 應使用**Book-A 的** `docs/team-rules/code-examples.md`，只寫核准的 `examples/<delegation-id>/`，不應跳到 Project-A、修改 Book-A `Department` 或自行改正文稿。

### 如何確認成功
Book-A 的 Department 始終是 `writing`；Writing Manager 是唯一對使用者負責的 Manager。Software Guest 完成測試與審查後，交回可核對的契約與成果；Writing Manager 才進行書稿整合與最終驗收。完整逐步檢核見 [docs/CROSS-DEPARTMENT-TEST.md](docs/CROSS-DEPARTMENT-TEST.md)。

---

## STEP 12｜Contract：刻意讓 Review FAIL，確認能修復

### 本步目標
不要只驗證「Agent 有回話」，而是驗證**標準交接能維持一致**：Review FAIL → Finding ID → Coding 修正 → Test／Review 重跑 → Quality Gate。

### 操作

1. 先完成 STEP 7 的合成契約測試，確認壞資料會被阻擋。
2. 在 Software Team 的真實任務中，安排一個可檢查的審查違規案例。Reviewer 必須在 `worker-report.json` 產出 `status: FAIL`、Blocking Finding（如 `CR-001`）、Rule ID、檔案位置、實際證據、影響及修正要求。
3. Manager **保留 Reviewer 原始報告**，由 `scripts/New-RepairRequest.ps1` 從有效的 FAIL 產生 `repair-request.json`；不要重新作文或改寫 Finding。
4. Coding 依 Finding ID 回報修復結果，接著建立**新的檔案 Snapshot**，重新執行 Test → Review。舊 PASS 不得沿用。
5. 最後使用 `scripts/Test-QualityGate.ps1` 驗證必要 Worker 的 PASS 都指向最新內容。全流程的「Step → Skill／Rule／PowerShell → 產出」請對照 [docs/EXECUTION-FLOW.md](docs/EXECUTION-FLOW.md)。

### 如何確認成功
原始 `CR-001` 在 Repair Request 與修復回報中能完整追蹤；任何被改寫的 Finding、失效 Snapshot、缺少必要 Report 都無法通過驗證器。**精確 PowerShell 指令與負向案例**見 [docs/CONTRACT-TEST.md](docs/CONTRACT-TEST.md)。

---

## STEP 13｜將公司制度套用到你自己的正式專案

### 本步目標
未來新增 C#、Python、Java 專案或新書時，**不必再安裝一套公司 Skills**。

### 操作

1. 在你的正式專案根建立 `AGENTS.md`。依專案屬性加入**唯一一行** `Department: software` 或 `Department: writing`。
2. 在同一份 `AGENTS.md` 增加 `## Rule Registry`（參照 `templates/Software/Project-A/AGENTS.md` 或 `templates/Writing/Book-A/AGENTS.md`）。每個 Key 指向本專案真實存在的 `docs/team-rules/*.md`。
3. 把技術架構、命名、Coding、Testing、Review 或書籍 Style、Fact、Sources 規範放在**本專案**的 `docs/team-rules/`，而不是塞到 Manager Prompt 或共用 Worker Skill 裡。
4. 在 Herdr 為該專案建立 Workspace，從 Root Pane 啟動 Manager。先 Planning，定案後才授權執行。當次任務的 Spec／Brief／Report 放 `.ai-work/runs/<run-id>/`。
5. 對新專案執行：

   ```powershell
   & 'D:\AI-Company\tests\Verify-RuleRegistry.ps1' -ProjectRoot 'D:\你的專案路徑'
   ```

### 如何確認成功
同一個 `software-code-review` 在不同專案**執行相同 SOP**，卻依每個專案自己的 Rule 進行審查；你沒有複製或改寫公司共用 Skill。

---

## 最後驗收：你真正需要確認的六件事

- [ ] 每個專案自己的 `AGENTS.md` 決定主責 Department，Router 不猜。
- [ ] 在說「開始做吧」之前，只有 Manager 討論需求；之後才建立 Worker Pane。
- [ ] Worker 真的使用指定 Skill 與 References，並讀取**當前專案**的 Rule Registry。
- [ ] Manager／Worker 透過可驗證 JSON Contract 交接；Reviewer 原始 Finding 不被改寫。
- [ ] Review FAIL 退回修復；程式、測試或 Rule 一旦改變，舊 PASS 失效。
- [ ] Writing 借 Software Guest 也不變更主責；最終仍由 Writing Manager 驗收。

實測紀錄表見 [docs/ACCEPTANCE.md](docs/ACCEPTANCE.md)；安裝故障排除見 [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)。

**邊界提醒**：這套方案使用 Herdr 官方 CLI 及 Codex／Claude Skills 建立協作，並透過資料驗證器提高交接可靠性；它不是 Herdr 原生提供的公司部門管理功能。Skill／Rule 是模型指令，不能替代 OS Sandbox、檔案 ACL 或真實 Build/Test。本套件的文件與 JSON Schema 可在目前環境檢查，但 Windows Herdr 的端到端調度仍需在測試電腦驗證。
