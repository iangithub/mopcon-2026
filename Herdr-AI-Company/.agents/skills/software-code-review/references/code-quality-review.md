# Code Quality Review Method（跨語言）

**標準來源**：`software.coding`、`software.review`、`software.security`；行為來源是本次 Spec/Task。

1. 逐段核對本次 Diff、已批准 Scope 與驗收條件；新增未要求的功能／清理／重構，須標示並確認授權。
2. 按專案 Rule 檢查命名、可讀性、錯誤處理、空值、邊界、資源處置、非同步與相容性；沒有此類功能時標 N/A。
3. 查找具體資安風險時描述信任邊界與 source-to-sink，不靠字串搜尋結果直接判定漏洞。
4. 檢查建置產物與編譯警告時，只接受真實執行的輸出與 Exit Code；不得自行在唯讀工作區進行會修改檔案的 Build。
5. 阻擋項目必須有可重現或明確可推導的風險；純風格建議不能自行升格成阻擋。
