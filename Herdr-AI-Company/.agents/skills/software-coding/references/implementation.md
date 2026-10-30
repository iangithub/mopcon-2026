# 實作方法：跨技術 Coding

1. 先讀 Spec／已核准 Task 與驗收條件；有規格疑問列出缺口，不自行決定產品行為。
2. 盤點現有專案：實際檔案、依賴關係、既有測試和既存的使用者變更；沒有 Git 時以 Manager 提供的 Baseline 清單為準。
3. 從 `software.architecture` 判斷模組／層級及依賴方向，從 `software.coding` 判斷命名、例外、性能、套件版本和程式風格；從 `software.security` 判斷輸入及敏感資料處理。
4. 選擇最小變更集；不得因為 Skill 範例使用 DDD/C# 就套用到沒有要求的專案。
5. 如果 Test Worker 擁有測試檔案，Coding 只能讀測試，不可同時編輯；若本次沒有分工，依專案 Rule 撰寫必要測試。
6. 自檢時讀取真實命令輸出及退出碼；只回報所做的檢查，不假設尚未執行的檢查會 PASS。
