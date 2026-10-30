# Architecture Review Method（通用方法，不是技術規範）

**標準來源**：Project `AGENTS.md` 的 `software.architecture` Rule；必要時讀其指向的架構圖、Project Context 與本次 Spec。未指定 DDD 或 Layered Architecture 時**不要強加 DDD**。

1. 從改動相關的模組宣告、依賴與呼叫關係建立受影響的依賴圖；按**本專案**已定架構查驗。
2. 檢查新增責任是否放在專案規範所要求的邊界；不要預設存在 Controller、Application、Domain 或 Repository。
3. 如果涉及資料存取，沿實際呼叫鏈檢查授權、交易／一致性及 I/O 邊界；只有專案規範禁止的直接 DB 存取才可依該條 Rule 判違規。
4. 涉及公開介面或資料格式時，核對相容性與核准的例外。
5. 審查結論需引用實際檔案、符號與專案 Rule ID，而非空泛的「不符合最佳實務」。
