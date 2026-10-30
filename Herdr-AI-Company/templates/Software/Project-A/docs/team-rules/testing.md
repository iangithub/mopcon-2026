# Project-A Testing Rules（PA-TEST-*）

- **PA-TEST-001** 以 .NET 8 SDK 執行 `dotnet build` 與 `dotnet test`；若專案尚未初始化，先由 Manager 授權建立最小可測解決方案。
- **PA-TEST-002** Unit Test 以 xUnit 為預設，必須有有效 Assertions 和關鍵成功／拒絕／邊界情境。
- **PA-TEST-003** 記錄每條命令的 CWD、Exit Code 和測試數量／失敗原因；沒有工具或未跑不得聲稱通過。
- **PA-TEST-004** 測試不可接觸正式服務或秘密資料。
