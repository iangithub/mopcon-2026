# Project-A Security Rules（PA-SEC-*）

- **PA-SEC-001** 禁止寫入 API Key、Token、Password 或真正的 Connection String。
- **PA-SEC-002** 未受信任輸入不可直接形成 SQL、Shell Command、路徑或 HTML 輸出。
- **PA-SEC-003** 涉及授權／身分驗證時必須由 Spec 明確定義安全邊界。
- **PA-SEC-004** Source Code 預檢不能冒稱 Fortify／SAST 已執行；若需要真實工具掃描，保留實際證據。
