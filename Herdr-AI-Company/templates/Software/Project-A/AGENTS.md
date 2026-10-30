# Software Project Context — Project-A

Department: software

## Project-level conventions (long-lived, not one-off task)

- 本測試專案使用 C# / .NET 8 與 xUnit。這是**此專案**的技術選擇，不是 AI Company 的共用 Skill 強制標準。
- 測試目的：驗證 Coding、Test、Review 三個 Worker 在相同 Rule Registry 下執行不同 SOP。
- `src/` 放實作，`tests/` 放測試；真實 Command 以 `software.testing` 為準。
- 不把某次 ToDo、Calculator 功能或當次 User Story 寫進本檔。任務文件放 `.ai-work/runs/`。

## Rule Registry

| Key | Relative Markdown Path |
| --- | --- |
| software.architecture | docs/team-rules/architecture.md |
| software.coding | docs/team-rules/coding.md |
| software.testing | docs/team-rules/testing.md |
| software.review | docs/team-rules/code-review.md |
| software.security | docs/team-rules/security.md |
