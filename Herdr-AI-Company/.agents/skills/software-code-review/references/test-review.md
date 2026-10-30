# Test Review Method（跨框架）

**標準來源**：`software.testing` 及本次 Spec／驗收條件；不預設 xUnit、pytest、JUnit 等特定工具。

1. 驗收條件 → 測試名稱與位置 → 具體 assertions → 真實執行證據，逐項對應。
2. 檢查成功／拒絕／邊界／重要回歸情境；測試隔離、替身與資料控制是否符合本專案規範。
3. 查看此次執行的命令、CWD、Exit Code、失敗詳細資料；零測試、過期紀錄、空 assertion 不能當完成證據。
4. 如果 Test PASS 但實際驗收條件未覆蓋，仍提出具體 Finding。
5. 讀取測試與報告不應更改追蹤檔案或觸發 Build 寫入；若沒有可用證據，標 `BLOCKED` 而非假通過。
