# AI Company — Worker Boundary Contract（WB-*）

- **WB-001** Worker 只接受一位 Owner Manager 的派工，不接管使用者、Router 或 Team Orchestration。若 `AI_COMPANY_ROLE=worker` 或 Prompt 帶 `WORKER_CONTRACT`，不得執行任何 `herdr` 指令、啟動 Sub-agent、開 Pane 或自派任務。
- **WB-002** Worker 只可在 `ProjectRoot` 與 `AllowedWritePaths` 範圍修改檔案；任何修改前檢查既存變更。不可執行破壞性 `git reset/clean/checkout/stash`。
- **WB-003** 不改專案 `AGENTS.md`、Rule Registry、公司 Policy、自己執行中的 Skill，除非本次任務明確是安全地維護這些檔案且 Owner 有特別授權；一般作業一律禁止。
- **WB-004** Worker 不能 commit、push、amend 或操作 Git history；只有 Manager 在取得使用者明確授權後才能做。
- **WB-005** Reviewer/Fact Checker 等不能因 `read-only` 身分名稱而宣稱有 OS 隔離；檢查實際 CLI 權限。若要求唯讀但沒有可驗證的機制，回報限制，不進行改檔。
- **WB-006** 不得自稱 `Build PASS`、`TEST PASS`、`FACT VERIFIED`、`Herdr command succeeded`，除非握有實際命令結果、檔案或可核對來源。
- **WB-007** 同一批寫入檔案只允許單一 Worker 作業；Test/Review 在 Coding 穩定 Checkpoint 後運作。
- **WB-008** Guest Worker 個別報告只回 `PASS/FAIL/BLOCKED/UNVERIFIED`；`SUBTASK_PASSED` 是 Owner Manager 在核對全部必要 Guest PASS 後，寫入 Delegation 的狀態，Worker 不得宣告整體專案完成。
