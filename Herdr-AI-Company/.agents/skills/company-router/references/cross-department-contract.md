# Cross-Department Delegation Contract（）

跨部門**只派 Guest 專業任務**，不改 `ProjectRoot/AGENTS.md` 的 Department。正式契約保存在 `.ai-work/runs/<run-id>/delegations/<delegation-id>.md`，由唯一 Owner Manager 建立。

```markdown
# Delegation
- DelegationId:
- ProjectRoot:
- WorkspaceId:
- OwnerDepartment: writing | software
- GuestDepartment: software | writing
- DelegationMode: guest-support
- ApprovedBy: user / derived from approved deliverable and scope
- Task / AcceptanceCriteria:
- AllowedReadPaths:
- AllowedWritePaths:  # explicit subdirectory; NEVER treat cwd as OS ACL
- ForbiddenWritePaths: AGENTS.md, drafts, other workspaces, etc.
- GuestWorkerSkills: software-coding, software-unit-test, software-code-review
- GuestRuleKeys: software.architecture, software.coding, software.testing, software.review, software.security
- RuleRegistry: ProjectRoot/AGENTS.md  # never borrow a different project
- ReturnTo: the same Owner Manager pane
- ExpectedDeliverables: files, test evidence, review report
- Status: PLANNED | RUNNING | BLOCKED | SUBTASK_PASSED | OWNER_ACCEPTED
```

Writing → Software 時，Book-A 必須在自己的 `AGENTS.md` 提供 `software.*` Rule Registry（例如同一份 `docs/team-rules/code-examples.md` 可提供所有相關 keys）；否則 Guest Worker 必須 `BLOCKED`，不可偷套 Project-A 的 DDD/C# 規範。

Manager 給 Guest Worker 的 `WORKER_CONTRACT` 必須包含上述實際契約的讀取路徑、User 授權、子目錄、Task/Acceptance、真正的 CLI 權限及對應 Worker Skill。Guest Skill **自己**讀相關專案 Rule 與共用政策，不能由 Manager 摘述替代。

驗收：Guest **個別 Worker** 回交符合 JSON Schema 的 `PASS|FAIL|BLOCKED|UNVERIFIED` 及實際產物、Build/Test Exit Code、Reviewer Finding。只有 Owner Manager 驗證必要 Guest Gate 和最新 Snapshot 後，才可將 Delegation 設為 `SUBTASK_PASSED`；只有 Owner Manager 能宣告整個專案完成。新增契約詳 `contracts/README.md`。
