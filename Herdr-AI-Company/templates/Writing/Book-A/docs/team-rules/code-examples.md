# Book-A — 可執行程式範例規範（EX-*）

此文件是**寫書專案**自訂的 Software Guest Rules，一份文件對應五個 `software.*` Key，避免重複維護。它不意味每個專案都要採 .NET 或 DDD。

## Architecture（software.architecture）
- **EX-ARCH-001** 範例程式須能獨立放在本書 `examples/<delegation-id>/` 目錄，不依賴 Project-A 程式庫。
- **EX-ARCH-002** 以讀者能獨立執行與理解為主，避免加入無必要的框架層級；如要求多專案架構，由當次 Spec 明定。

## Coding（software.coding）
- **EX-CODE-001** 本書此類  範例使用 .NET 8／C#，命名清楚，無秘密值、無不相關依賴。
- **EX-CODE-002** 程式行為與當次章節 Brief／Spec 一致，既能執行也便於讀者重現。

## Testing（software.testing）
- **EX-TEST-001** 對 .NET 8 範例實際執行 `dotnet build`、`dotnet test`；若尚未生成專案，先取得 Manager 核准建立必要 Solution/Test 專案。
- **EX-TEST-002** 必須有真正的 Unit Test assertions、結果與 Exit Code，沒有 SDK/網路則回 `BLOCKED`，不能聲稱 PASS。

## Review（software.review）
- **EX-REV-001** Reviewer 對本次允許的 `examples/<delegation-id>/` 程式與測試進行唯讀獨立審查；需讀真實 Diff/檔案與 Build/Test 證據。
- **EX-REV-002** Finding 引用 Rule ID、程式位置與證據，影響教學正確性／可編譯性的問題為 Blocking。

## Security（software.security）
- **EX-SEC-001** 禁止硬編碼憑證、資料庫連線或未核准的外部網路存取。
- **EX-SEC-002** 不得碰 Book-A 的 `drafts/**`、`sources/**`、其他 ProjectRoot 或公司政策。CWD 不等於 OS 權限白名單。
