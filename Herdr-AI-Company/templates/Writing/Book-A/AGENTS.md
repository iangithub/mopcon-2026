# Writing Project Context — Book-A

Department: writing

## Project-level conventions (long-lived, not a specific chapter)

- 專案主責是出版編輯部，讀者為臺灣繁體中文的資訊技術學習者；術語首次出現使用中英文對照。
- 文稿保留初稿，修訂輸出獨立版本，不要用 Fact Checker 靜默覆寫原稿。
- 書籍需要**可執行程式範例**時，Writing Manager 可發 Software Guest Delegation，僅能寫核准的 `examples/<delegation-id>/`；專案仍是 `writing`。
- 特定章節要求與示例內容由 `.ai-work/runs/<run-id>/` 的 Brief/Spec 管理，不寫在此處。

## Rule Registry

| Key | Relative Markdown Path |
| --- | --- |
| writing.style | docs/team-rules/style.md |
| writing.editorial | docs/team-rules/editorial.md |
| writing.facts | docs/team-rules/facts.md |
| writing.sources | docs/team-rules/sources.md |
| writing.proofreading | docs/team-rules/proofreading.md |
| software.architecture | docs/team-rules/code-examples.md |
| software.coding | docs/team-rules/code-examples.md |
| software.testing | docs/team-rules/code-examples.md |
| software.review | docs/team-rules/code-examples.md |
| software.security | docs/team-rules/code-examples.md |

> `software.*` 是**本書專案自己的程式範例規範**。它們共用 `code-examples.md` 一份文件，並不代表本書主責 Department 轉成 software；也不可套用另一個 Project-A 的標準。
