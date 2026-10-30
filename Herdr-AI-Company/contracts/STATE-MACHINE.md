# Agent Communication State Machine（ST-*）

```text
PLANNING --使用者明確開工--> APPROVED
APPROVED --建立 dispatch, 驗證成功--> DISPATCHED
DISPATCHED --> IMPLEMENTING --> CHECKPOINT
CHECKPOINT --建立新 snapshot--> VERIFYING
VERIFYING --Test PASS / 有實際 Log--> REVIEWING
VERIFYING --Test FAIL --> REPAIR_PENDING
REVIEWING --Review FAIL + 原始 Findings --> REPAIR_PENDING
REVIEWING --Review BLOCKED/UNVERIFIED --> BLOCKED
REPAIR_PENDING --建立 repair-request --> REPAIRING
REPAIRING --Coding/Writer 修復 --> CHECKPOINT (必須新 snapshot)
REVIEWING --所有必要 PASS、同一最新 snapshot--> OWNER_ACCEPTANCE
OWNER_ACCEPTANCE --> DONE / GUEST_SUBTASK_PASSED
```

- **ST-001** Worker `PASS` 只代表該角色對某個受檢快照 PASS；不是整個專案完成。
- **ST-002** Test/Review 的 `FAIL` 必須有具體失敗證據；Review 的 `BLOCKING` Finding 必須進入 Repair Request 並保留 ID。
- **ST-003** `BLOCKED` 是停止等待資訊／環境，不能被 Manager 解讀成「非重要問題」。
- **ST-004** `UNVERIFIED` 不是 PASS，尤其來源未查證時不得製造結論。
- **ST-005** Manager 至多安排 3 輪修復；同一問題反覆失敗，停止，讓使用者判斷。
- **ST-006** 任何 Snapshot 變動，之前引用該 Snapshot 的 Test／Review PASS 立即失效，需重新執行必要關卡。
- **ST-007** Review 期間凍結受檢內容，包括規範、Spec、測試與程式／稿件；若變動則該輪審查無效。
- **ST-008** Reviewer、Fact Checker 的內容應保留原文；Manager 不能自己改出 PASS 或修改 Findings。
- **ST-009** Guest 的 `SUBTASK_PASSED` 是 Owner Manager 核准的 Delegation 層級狀態，不是 Worker Report 的 status。
- **ST-010** 舊 Review 報告必須保留作為稽核與下一輪追蹤資料；新的 PASS 不能覆蓋舊 FAIL。

### Software Gate

`software-coding PASS` + `software-unit-test PASS` + `software-code-review PASS`，每份報告有效且同一當前 Snapshot，才能進入 Owner 驗收。

### Writing Gate（依任務組合）

由 Writing Team 在派工前宣告必需的 Writer／Editor／Fact Checker／Proofreader；所有實際要求的 Role 都必須回報 `PASS` 且基於相同最新版稿件。Fact Checker 無來源只能 `UNVERIFIED`，重要主張不得被 Writer 導入「已核實」稿件。
