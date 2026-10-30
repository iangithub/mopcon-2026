# Project-A Architecture Rules（PA-ARCH-*）

- **PA-ARCH-001** 這套環境專案若採 Domain 專案，Domain 程式不得依賴 Web/API/DB 實作。
- **PA-ARCH-002** 以本專案實際 `src/` 的組件邊界為準；不得擅自引入無必要的 Application/Infrastructure 層。
- **PA-ARCH-003** 若增加資料庫存取，必須先經 Spec 確立資料持久化需求與依賴方向，不可自行加入 DbContext。
- **PA-ARCH-004** 公開介面或既有行為不相容時必須先取得核准。
