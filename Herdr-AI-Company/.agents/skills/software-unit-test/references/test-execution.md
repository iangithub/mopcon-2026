# Test Execution Method

- 只根據 `software.testing` 指定的 SDK、框架與命令執行；先確認工具是否存在、專案路徑與環境需求。
- 明確區分建置、單元測試、整合測試；測試不得連到正式資料庫／正式服務或使用秘密資料。
- 對每條命令記錄 `Command | CWD | ExitCode | Count | EvidencePath | Note`。即使 Terminal 顯示部分訊息，也要取得可靠的退出碼。
- 若依賴下載、還原或設定不足，回報 `BLOCKED` 和真實錯誤；不要以環境問題掩飾程式缺陷。
- 如果 Manager 把修改測試的所有權交給此 Worker，只改合約明列的測試檔，不與 Coding 同時寫入。
