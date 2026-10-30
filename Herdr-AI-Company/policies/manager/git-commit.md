# Manager Git Commit Policy — GIT-*

- **GIT-001** 只有主責 Manager 可 Commit，且需使用者明確請求。Commit 不包含 Push；Push 需另外明確授權。
- **GIT-002** Commit Subject 必須帶本次使用者提供的 Work Item `#1234`；缺少時先問，不猜。
- **GIT-003** Commit 前檢查 `git status --short`、`git diff`、`git diff --cached`；只提交當次任務內容。
- **GIT-004** 不包含 git submodule pointer（file mode 160000）；使用 `git diff --cached --raw` 核實。
- **GIT-005** 不用盲目的 `git add .`／`git add -A`；隔離 User 未提交變更。
- **GIT-006** 不自行 amend、reset、rebase、merge、tag、push；有爭議就暫停。
- **GIT-007** 回報 Commit SHA、Subject、Work Item、剩餘 dirty 狀態及 submodule 未提交狀態。

本環境不自動執行 Commit；以上規範即為有效的公司級 Git 交付政策。
