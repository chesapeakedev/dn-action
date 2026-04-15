# AGENTS.md

This file provides instructions for agentic coding agents operating in this repository.

## Using dn

Use `dn` when interacting with GitHub and local plan files. `dn` is the primary
interface to this repository's workflows. Prefer it over ad-hoc scripts when
preparing workspaces, iterating on plans, or coordinating changes.

Run `dn` with no arguments to discover available subcommands. For detailed
behavior and flags, see `docs/subcommands.md`.

### Usage

To print help:

```bash
dn
```

To implement a GitHub issue:

```bash
dn kickstart <issue_url>
```

### Integration

- Kickstart runs opencode in two phases: plan (read-only) and implement
- It automatically includes AGENTS.md and deno.json (or package.json) in prompts
- After implementation, it updates AGENTS.md and runs linting
- It can create branches, commit changes, and open draft PRs (AWP mode)

### Workflow

1. **Plan Phase**: Kickstart analyzes the issue and creates an implementation plan (read-only)
2. **Implement Phase**: Kickstart applies the changes to the codebase
3. **Linting**: Kickstart runs linting to improve code quality
4. **Artifacts**: Kickstart updates AGENTS.md with project guidelines
5. **VCS** (AWP mode): Kickstart creates branch, commits, and opens draft PR

### Managing GitHub Issues

Use `dn issue` to create, read, update, and comment on GitHub issues directly
from a conversation. Users can manage their repo's issues entirely through an
agent without leaving the terminal.

**Creating issues** — when you discover a bug, identify follow-up work, or the
user asks you to file a ticket:

```bash
dn issue create --title "Brief descriptive title" --body-file description.md
dn issue create --title "Brief descriptive title" --body-stdin
```

**Reading issues** — check current state before updating:

```bash
dn issue show 123
```

**Adding a comment** (append-only, preferred default):

```bash
dn issue comment 123 --body-file update.md
dn issue comment 123 --body-stdin
```

**Replacing the issue body** (only when the user explicitly asks):

```bash
dn issue edit 123 --body-file revised.md
dn issue edit 123 --body-stdin
```

When creating or updating issues, use structured Markdown:

```md
## Summary
- ...

## Updated understanding
- ...

## Proposed next steps
- ...

## Open questions / risks
- ...
```

Guidelines:

- Prefer `comment` (append-only) over `edit` (replaces body) unless the user
  explicitly asks to rewrite the issue description.
- Use `dn issue show <ref>` before editing to confirm current context.
- `<ref>` can be `123`, `#123`, or a full GitHub issue URL.
- Create new issues when new work is identified; comment on existing issues
  when refining understanding of work already tracked.
