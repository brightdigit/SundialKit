# Task Master AI - Agent Integration Guide

## SundialKit v2.0.0 Requirements

**Swift 6.1+ Required**: SundialKit v2.0.0 requires Swift 6.1+ for Swift Testing framework adoption. Support for Swift 5.9, 5.10, and 6.0 has been dropped. All CI/CD pipelines updated to test Swift 6.1, 6.2, and nightly builds only.

## Essential Commands

### Core Workflow Commands

```bash
# Project Setup
task-master init                                    # Initialize Task Master in current project
task-master parse-prd .taskmaster/docs/prd.txt      # Generate tasks from PRD document
task-master models --setup                        # Configure AI models interactively

# Daily Development Workflow
task-master list                                   # Show all tasks with status
task-master next                                   # Get next available task to work on
task-master show <id>                             # View detailed task information (e.g., task-master show 1.2)
task-master set-status --id=<id> --status=done    # Mark task complete

# Task Management
task-master add-task --prompt="description" --research        # Add new task with AI assistance
task-master expand --id=<id> --research --force              # Break task into subtasks
task-master update-task --id=<id> --prompt="changes"         # Update specific task
task-master update --from=<id> --prompt="changes"            # Update multiple tasks from ID onwards
task-master update-subtask --id=<id> --prompt="notes"        # Add implementation notes to subtask

# Analysis & Planning
task-master analyze-complexity --research          # Analyze task complexity
task-master complexity-report                      # View complexity analysis
task-master expand --all --research               # Expand all eligible tasks

# Dependencies & Organization
task-master add-dependency --id=<id> --depends-on=<id>       # Add task dependency
task-master move --from=<id> --to=<id>                       # Reorganize task hierarchy
task-master validate-dependencies                            # Check for dependency issues
task-master generate                                         # Update task markdown files (usually auto-called)
```

## Key Files & Project Structure

### Core Files

- `.taskmaster/tasks/tasks.json` - Main task data file (auto-managed)
- `.taskmaster/config.json` - AI model configuration (use `task-master models` to modify)
- `.taskmaster/docs/prd.txt` - Product Requirements Document for parsing
- `.taskmaster/tasks/*.txt` - Individual task files (auto-generated from tasks.json)
- `.env` - API keys for CLI usage

### Claude Code Integration Files

- `CLAUDE.md` - Auto-loaded context for Claude Code (this file)
- `.claude/settings.json` - Claude Code tool allowlist and preferences
- `.claude/commands/` - Custom slash commands for repeated workflows
- `.mcp.json` - MCP server configuration (project-specific)

### Directory Structure

```
project/
├── .taskmaster/
│   ├── tasks/              # Task files directory
│   │   ├── tasks.json      # Main task database
│   │   ├── task-1.md      # Individual task files
│   │   └── task-2.md
│   ├── docs/              # Documentation directory
│   │   ├── prd.txt        # Product requirements
│   ├── reports/           # Analysis reports directory
│   │   └── task-complexity-report.json
│   ├── templates/         # Template files
│   │   └── example_prd.txt  # Example PRD template
│   └── config.json        # AI models & settings
├── .claude/
│   ├── settings.json      # Claude Code configuration
│   └── commands/         # Custom slash commands
├── .env                  # API keys
├── .mcp.json            # MCP configuration
└── CLAUDE.md            # This file - auto-loaded by Claude Code
```

## MCP Integration

Task Master provides an MCP server that Claude Code can connect to. Configure in `.mcp.json`:

```json
{
  "mcpServers": {
    "task-master-ai": {
      "command": "npx",
      "args": ["-y", "--package=task-master-ai", "task-master-ai"],
      "env": {
        "ANTHROPIC_API_KEY": "your_key_here",
        "PERPLEXITY_API_KEY": "your_key_here",
        "OPENAI_API_KEY": "OPENAI_API_KEY_HERE",
        "GOOGLE_API_KEY": "GOOGLE_API_KEY_HERE",
        "XAI_API_KEY": "XAI_API_KEY_HERE",
        "OPENROUTER_API_KEY": "OPENROUTER_API_KEY_HERE",
        "MISTRAL_API_KEY": "MISTRAL_API_KEY_HERE",
        "AZURE_OPENAI_API_KEY": "AZURE_OPENAI_API_KEY_HERE",
        "OLLAMA_API_KEY": "OLLAMA_API_KEY_HERE"
      }
    }
  }
}
```

### Essential MCP Tools

```javascript
help; // = shows available taskmaster commands
// Project setup
initialize_project; // = task-master init
parse_prd; // = task-master parse-prd

// Daily workflow
get_tasks; // = task-master list
next_task; // = task-master next
get_task; // = task-master show <id>
set_task_status; // = task-master set-status

// Task management
add_task; // = task-master add-task
expand_task; // = task-master expand
update_task; // = task-master update-task
update_subtask; // = task-master update-subtask
update; // = task-master update

// Analysis
analyze_project_complexity; // = task-master analyze-complexity
complexity_report; // = task-master complexity-report
```

## Claude Code Workflow Integration

### Standard Development Workflow

#### 1. Project Initialization

```bash
# Initialize Task Master
task-master init

# Create or obtain PRD, then parse it
task-master parse-prd .taskmaster/docs/prd.txt

# Analyze complexity and expand tasks
task-master analyze-complexity --research
task-master expand --all --research
```

If tasks already exist, another PRD can be parsed (with new information only!) using parse-prd with --append flag. This will add the generated tasks to the existing list of tasks..

#### 2. Daily Development Loop

```bash
# Start each session
task-master next                           # Find next available task
task-master show <id>                     # Review task details

# During implementation, check in code context into the tasks and subtasks
task-master update-subtask --id=<id> --prompt="implementation notes..."

# Complete tasks
task-master set-status --id=<id> --status=done
```

#### 3. Multi-Claude Workflows

For complex projects, use multiple Claude Code sessions:

```bash
# Terminal 1: Main implementation
cd project && claude

# Terminal 2: Testing and validation
cd project-test-worktree && claude

# Terminal 3: Documentation updates
cd project-docs-worktree && claude
```

### Custom Slash Commands

Create `.claude/commands/taskmaster-next.md`:

```markdown
Find the next available Task Master task and show its details.

Steps:

1. Run `task-master next` to get the next task
2. If a task is available, run `task-master show <id>` for full details
3. Provide a summary of what needs to be implemented
4. Suggest the first implementation step
```

Create `.claude/commands/taskmaster-complete.md`:

```markdown
Complete a Task Master task: $ARGUMENTS

Steps:

1. Review the current task with `task-master show $ARGUMENTS`
2. Verify all implementation is complete
3. Run any tests related to this task
4. Mark as complete: `task-master set-status --id=$ARGUMENTS --status=done`
5. Show the next available task with `task-master next`
```

## Tool Allowlist Recommendations

Add to `.claude/settings.json`:

```json
{
  "allowedTools": [
    "Edit",
    "Bash(task-master *)",
    "Bash(git commit:*)",
    "Bash(git add:*)",
    "Bash(npm run *)",
    "mcp__task_master_ai__*"
  ]
}
```

## Configuration & Setup

### API Keys Required

At least **one** of these API keys must be configured:

- `ANTHROPIC_API_KEY` (Claude models) - **Recommended**
- `PERPLEXITY_API_KEY` (Research features) - **Highly recommended**
- `OPENAI_API_KEY` (GPT models)
- `GOOGLE_API_KEY` (Gemini models)
- `MISTRAL_API_KEY` (Mistral models)
- `OPENROUTER_API_KEY` (Multiple models)
- `XAI_API_KEY` (Grok models)

An API key is required for any provider used across any of the 3 roles defined in the `models` command.

### Model Configuration

```bash
# Interactive setup (recommended)
task-master models --setup

# Set specific models
task-master models --set-main claude-3-5-sonnet-20241022
task-master models --set-research perplexity-llama-3.1-sonar-large-128k-online
task-master models --set-fallback gpt-4o-mini
```

## Task Structure & IDs

### Task ID Format

- Main tasks: `1`, `2`, `3`, etc.
- Subtasks: `1.1`, `1.2`, `2.1`, etc.
- Sub-subtasks: `1.1.1`, `1.1.2`, etc.

### Task Status Values

- `pending` - Ready to work on
- `in-progress` - Currently being worked on
- `done` - Completed and verified
- `deferred` - Postponed
- `cancelled` - No longer needed
- `blocked` - Waiting on external factors

### Task Fields

```json
{
  "id": "1.2",
  "title": "Implement user authentication",
  "description": "Set up JWT-based auth system",
  "status": "pending",
  "priority": "high",
  "dependencies": ["1.1"],
  "details": "Use bcrypt for hashing, JWT for tokens...",
  "testStrategy": "Unit tests for auth functions, integration tests for login flow",
  "subtasks": []
}
```

## Claude Code Best Practices with Task Master

### Context Management

- Use `/clear` between different tasks to maintain focus
- This CLAUDE.md file is automatically loaded for context
- Use `task-master show <id>` to pull specific task context when needed

### Iterative Implementation

1. `task-master show <subtask-id>` - Understand requirements
2. Explore codebase and plan implementation
3. `task-master update-subtask --id=<id> --prompt="detailed plan"` - Log plan
4. `task-master set-status --id=<id> --status=in-progress` - Start work
5. Implement code following logged plan
6. `task-master update-subtask --id=<id> --prompt="what worked/didn't work"` - Log progress
7. `task-master set-status --id=<id> --status=done` - Complete task

### Complex Workflows with Checklists

For large migrations or multi-step processes:

1. Create a markdown PRD file describing the new changes: `touch task-migration-checklist.md` (prds can be .txt or .md)
2. Use Taskmaster to parse the new prd with `task-master parse-prd --append` (also available in MCP)
3. Use Taskmaster to expand the newly generated tasks into subtasks. Consdier using `analyze-complexity` with the correct --to and --from IDs (the new ids) to identify the ideal subtask amounts for each task. Then expand them.
4. Work through items systematically, checking them off as completed
5. Use `task-master update-subtask` to log progress on each task/subtask and/or updating/researching them before/during implementation if getting stuck

### Git Integration

Task Master works well with `gh` CLI:

```bash
# Create PR for completed task
gh pr create --title "Complete task 1.2: User authentication" --body "Implements JWT auth system as specified in task 1.2"

# Reference task in commits
git commit -m "feat: implement JWT auth (task 1.2)"
```

#### Git-Subrepo Integration

SundialKit uses git-subrepo for managing plugin packages. Reference: https://github.com/ingydotnet/git-subrepo

**Plugin Subrepo Structure:**
```
Packages/
├── SundialKitStream/       # → brightdigit/SundialKitStream (branch: v1.0.0)
├── SundialKitBinary/       # → brightdigit/SundialKitBinary (branch: v1.0.0)
├── SundialKitCombine/      # → brightdigit/SundialKitCombine (branch: v1.0.0)
└── SundialKitMessagable/   # → brightdigit/SundialKitMessagable (branch: v1.0.0)
```

**Essential git-subrepo Commands:**

```bash
# Check status of all subrepos
git subrepo status

# Pull updates from plugin repository
git subrepo pull Packages/SundialKitStream

# Push local changes to plugin repository
git subrepo push Packages/SundialKitStream

# Clone a new subrepo (initial setup)
git subrepo clone git@github.com:brightdigit/SundialKitStream.git Packages/SundialKitStream -b v1.0.0
```

**Workflow for Plugin Development:**

1. **Making changes to plugins:**
   ```bash
   # Edit files in Packages/SundialKitStream/
   # Commit to main repo first
   git add Packages/SundialKitStream/
   git commit -m "feat(stream/task-7.2): implement NetworkStream actor"

   # Then push to plugin's separate repo
   git subrepo push Packages/SundialKitStream
   ```

2. **Pulling updates from plugin repos:**
   ```bash
   # Pull latest from a plugin
   git subrepo pull Packages/SundialKitCombine

   # Update all plugins
   for pkg in Packages/*/; do git subrepo pull "$pkg"; done
   ```

3. **Task Master + Subrepo Workflow:**
   ```bash
   # Working on Task 7 (Stream plugin)
   task-master show 7.1

   # Make changes in Packages/SundialKitStream/
   vim Packages/SundialKitStream/Sources/NetworkStream.swift

   # Commit locally
   git add Packages/SundialKitStream/
   git commit -m "feat(stream/task-7.1): create NetworkStream actor (#issue)"

   # Update Task Master
   task-master set-status --id=7.1 --status=done

   # Push to plugin repo when subtask or task complete
   git subrepo push Packages/SundialKitStream
   ```

**Understanding .gitrepo Files:**

Each subrepo has a `.gitrepo` file tracking upstream metadata:
```ini
[subrepo]
    remote = git@github.com:brightdigit/SundialKitStream.git
    branch = v1.0.0
    commit = abc123...  # Upstream commit
    parent = def456...  # Local commit
```
This file is automatically managed by git-subrepo. Never edit manually.

**Best Practices:**

- **Work in main repo first**: Make changes in `Packages/`, commit to main repo
- **Push to subrepo after task completion**: Use `git subrepo push` when subtask or task is done
- **Check status regularly**: Run `git subrepo status` to see which subrepos have unpushed changes
- **Pull before working**: Always `git subrepo pull` before starting work on a plugin
- **Task Master integration**: Reference subrepo in task updates: `task-master update-subtask --id=7.1 --prompt="Implemented in Packages/SundialKitStream"`

**Troubleshooting:**

```bash
# If subrepo gets out of sync
git subrepo clean Packages/SundialKitStream
git subrepo pull Packages/SundialKitStream

# Force push (use carefully)
git subrepo push Packages/SundialKitStream --force

# Check subrepo configuration
cat Packages/SundialKitStream/.gitrepo
```

### GitHub Issues & Pull Request Integration

**Workflow Overview**: Each Task Master task should have a corresponding GitHub issue, with subtasks represented as sub-issues or task lists within the main issue. Major features should have dedicated branches and pull requests.

#### 1. Creating Issues for Tasks

```bash
# Create GitHub issue for a main task
task-master show <id>                                  # Get task details
gh issue create \
  --title "[Component] Task <id>: <title>" \
  --label "component:<name>" \
  --body "$(cat <<EOF
## Component/Subrepo
<component-name> (e.g., SundialKit, WatchConnectivity, Network, etc.)

## Description
<task description>

## Implementation Details
<task details>

## Test Strategy
<task test strategy>

## Task Master Reference
- Task ID: <id>
- Status: pending
- Dependencies: <list dependencies>
- Component: <component-name>

## Subtasks
<list of subtasks from task-master>
EOF
)"

# Store the issue number for reference
task-master update-task --id=<id> --prompt="GitHub Issue: #<issue-number>"
```

**Component/Subrepo Labeling**:
- Use title prefixes: `[Network] Task 1.2: ...`, `[WatchConnectivity] Task 2.1: ...`
- Apply GitHub labels: `--label "component:network"`, `--label "component:watchconnectivity"`
- Document component in issue body under "Component/Subrepo" section
- Update Task Master with component info for tracking

**Common Component Labels**:
```bash
# Network subsystem
--label "component:network"

# WatchConnectivity subsystem
--label "component:watchconnectivity"

# Infrastructure/tooling
--label "component:infrastructure"

# Documentation
--label "component:docs"

# Testing
--label "component:tests"
```

#### 2. Creating Sub-Issues for Subtasks

For complex tasks with many subtasks, create individual sub-issues:

```bash
# Create sub-issue linked to parent (inherits component from parent)
gh issue create \
  --title "[Component] Subtask <id>: <subtask-title>" \
  --body "Part of #<parent-issue-number>\n\n<subtask-details>" \
  --label "subtask" \
  --label "component:<name>"

# Link back to Task Master
task-master update-subtask --id=<id> --prompt="GitHub Issue: #<sub-issue-number>"
```

**Note**: Subtasks inherit the component label from their parent task for consistency.

Alternatively, use GitHub's task list feature in the main issue:

```markdown
## Subtasks
- [ ] Task 1.1: Setup authentication module (#123)
- [ ] Task 1.2: Implement JWT tokens (#124)
- [ ] Task 1.3: Add password hashing (#125)
```

#### 3. Branch Strategy for Major Features

Create feature branches for each major task (typically tasks without dots, like `1`, `2`, `3`):

```bash
# Get task information
task-master show 1

# Create feature branch
git checkout -b feature/task-1-network-observer

# Set task to in-progress
task-master set-status --id=1 --status=in-progress

# Work on subtasks on the same branch
task-master next  # Get next subtask
# ... implement subtask ...
git add . && git commit -m "feat(task-1.1): implement PathMonitor abstraction"

# Continue with more subtasks on the same branch
task-master next
# ... implement next subtask ...
git add . && git commit -m "feat(task-1.2): add NetworkPing integration"
```

#### 4. Creating Pull Requests for Completed Tasks

When all subtasks are complete, create a PR:

```bash
# Verify all subtasks are done
task-master show 1

# Push branch
git push -u origin feature/task-1-network-observer

# Create PR with comprehensive details
gh pr create \
  --title "feat(network): Task 1 - Implement NetworkObserver" \
  --label "component:network" \
  --body "$(cat <<EOF
## Component
Network

## Summary
Implements NetworkObserver system as specified in Task Master task 1.

## Changes
- PathMonitor abstraction over NWPathMonitor
- NetworkPing integration for connectivity verification
- Combine publishers for reactive state management
- Comprehensive test coverage

## Task Master Reference
- Task ID: 1
- Component: Network
- All subtasks completed (1.1, 1.2, 1.3, 1.4)
- Dependencies: None

## Related Issues
Closes #<issue-number>

## Testing
- [x] Unit tests pass
- [x] Integration tests pass
- [x] Manual testing completed

## Test Plan
- PathMonitor correctly reports network state changes
- NetworkPing functions when reachability changes
- Publishers emit expected values
- Error handling works correctly
EOF
)" \
  --base main

# Mark task as done
task-master set-status --id=1 --status=done
```

#### 5. Commit Message Convention

Use consistent commit messages that reference tasks and components:

```bash
# Format: <type>(component/task-<id>): <description>
git commit -m "feat(network/task-1.1): implement PathMonitor protocol abstraction"
git commit -m "test(network/task-1.2): add NetworkPing unit tests"
git commit -m "docs(network/task-1.3): document NetworkObserver public API"
git commit -m "fix(network/task-1.4): handle edge case in status transitions"

# WatchConnectivity component examples
git commit -m "feat(watchconnectivity/task-2.1): implement ConnectivitySession protocol"
git commit -m "test(watchconnectivity/task-2.2): add message encoding tests"

# Infrastructure/cross-cutting examples
git commit -m "chore(infra/task-3.1): setup CI/CD pipeline"
git commit -m "docs(all/task-4.1): update README with API examples"

# Types: feat, fix, docs, test, refactor, chore, style, perf
```

**Commit Scope Format**:
- Use `component/task-id` format: `feat(network/task-1.1): ...`
- Component should match the GitHub label: `network`, `watchconnectivity`, `infra`, `docs`, `tests`
- This provides clear traceability from commit → component → task → issue

#### 6. Linking Issues in Commits

Reference GitHub issues in commits for automatic tracking:

```bash
# Link to issue with component scope
git commit -m "feat(network/task-1.1): implement PathMonitor (#42)"

# Close issue on merge with component
git commit -m "feat(network/task-1): complete NetworkObserver implementation

Closes #42"

# Multiple component commits
git commit -m "feat(watchconnectivity/task-2.1): add message encoding (#43)"
git commit -m "fix(network/task-1.2): handle edge case in ping timeout (#42)"
```

#### 7. Automated Workflow Commands

Create a custom slash command `.claude/commands/github-task.md`:

```markdown
Create a GitHub issue for Task Master task: $ARGUMENTS

Steps:
1. Get task details with `task-master show $ARGUMENTS`
2. Identify the component/subrepo for this task (Network, WatchConnectivity, etc.)
3. Create GitHub issue using `gh issue create` with:
   - Title prefix: `[Component] Task X: ...`
   - Component label: `--label "component:<name>"`
   - Component section in body
4. Update Task Master with issue reference AND component: `task-master update-task --id=$ARGUMENTS --prompt="GitHub Issue: #X, Component: <name>"`
5. Create feature branch if it's a main task: `feature/<component>-task-X-<description>`
6. Display next steps
```

Create `.claude/commands/github-pr.md`:

```markdown
Create a pull request for Task Master task: $ARGUMENTS

Steps:
1. Verify task completion with `task-master show $ARGUMENTS`
2. Get component from Task Master task metadata
3. Ensure all changes are committed
4. Push branch to remote
5. Create PR with `gh pr create` including:
   - Title with component scope: `feat(<component>): Task X - ...`
   - Component label: `--label "component:<name>"`
   - Component section in PR body
   - Task summary and subtask list
6. Link PR number back to Task Master
7. Mark task as done
```

#### 8. Best Practices

**Issue Creation**:
- Create issues for main tasks (1, 2, 3) at project start
- Create sub-issues or use task lists for subtasks (1.1, 1.2, etc.)
- Use labels: `task-master`, `feature`, `subtask`, `bug`, `enhancement`, `component:<name>`
- Link issues to project milestones when applicable
- **Always include component/subrepo** in issue title and labels
- Add "Component/Subrepo" section in issue body

**Component/Subrepo Tracking**:
- Prefix all issue titles with component: `[Network] Task 1.2: ...`
- Apply component labels to all issues and PRs: `--label "component:network"`
- Use component scope in commit messages: `feat(network/task-1.1): ...`
- Document component in Task Master: `task-master update-task --id=1 --prompt="Component: Network"`
- Filter issues by component using GitHub label search

**Branch Management**:
- One branch per main task (feature/task-1-description)
- All subtasks implemented on the same feature branch
- Keep branches focused and merge when task complete
- Delete branches after PR merge
- Branch names should reflect component when clear: `feature/network-task-1-observer`

**Pull Request Workflow**:
- One PR per main task (includes all subtasks)
- Reference all related issues and subtasks in PR description
- Include Task Master task ID and component in PR title: `feat(network): Task 1 - ...`
- Apply component label to PR
- Use "Closes #<issue>" to auto-close issues on merge
- Request reviews before merging

**Synchronization**:
- Update Task Master when creating issues: `task-master update-task --id=<id> --prompt="GitHub Issue: #<number>, Component: <name>"`
- Update Task Master when creating PRs: `task-master update-task --id=<id> --prompt="Pull Request: #<number>"`
- Update GitHub issues when Task Master status changes
- Keep both systems in sync throughout development
- Maintain component information across all systems

**Example Full Workflow**:

```bash
# 1. Start new task
task-master next  # Returns task 1 (Network module)

# 2. Create GitHub issue with component labeling
gh issue create \
  --title "[Network] Task 1: Implement NetworkObserver" \
  --label "component:network" \
  --label "task-master" \
  --body "$(cat <<EOF
## Component/Subrepo
Network

## Description
Implement NetworkObserver for monitoring network connectivity status.
...
EOF
)"
# Returns issue #42

# 3. Link issue to task with component information
task-master update-task --id=1 --prompt="GitHub Issue: #42, Component: Network"

# 4. Create feature branch
git checkout -b feature/network-task-1-observer

# 5. Set status
task-master set-status --id=1 --status=in-progress

# 6. Work through subtasks with component in commits
task-master show 1.1
# ... implement 1.1 ...
git commit -m "feat(network/task-1.1): implement PathMonitor protocol abstraction (#42)"
task-master set-status --id=1.1 --status=done

task-master show 1.2
# ... implement 1.2 ...
git commit -m "feat(network/task-1.2): add NetworkPing integration (#42)"
task-master set-status --id=1.2 --status=done

task-master show 1.3
# ... implement 1.3 ...
git commit -m "test(network/task-1.3): add NetworkObserver unit tests (#42)"
task-master set-status --id=1.3 --status=done

# ... continue for all subtasks ...

# 7. Create PR when task complete with component labeling
git push -u origin feature/network-task-1-observer
gh pr create \
  --title "feat(network): Task 1 - Implement NetworkObserver" \
  --label "component:network" \
  --body "$(cat <<EOF
## Component
Network

## Summary
Implements NetworkObserver system as specified in Task Master task 1.
...

Closes #42
EOF
)"
# Returns PR #45

# 8. Link PR to task
task-master update-task --id=1 --prompt="Pull Request: #45"

# 9. After merge
task-master set-status --id=1 --status=done
git checkout main && git pull
git branch -d feature/network-task-1-observer

# 10. Move to next component/task
task-master next  # Returns task 2 (WatchConnectivity module)
```

**Component Filtering on GitHub**:

```bash
# View all Network component issues
gh issue list --label "component:network"

# View all WatchConnectivity component issues
gh issue list --label "component:watchconnectivity"

# View all open PRs for a component
gh pr list --label "component:network" --state open
```

### Parallel Development with Git Worktrees

```bash
# Create worktrees for parallel task development
git worktree add ../project-auth feature/auth-system
git worktree add ../project-api feature/api-refactor

# Run Claude Code in each worktree
cd ../project-auth && claude    # Terminal 1: Auth work
cd ../project-api && claude     # Terminal 2: API work
```

## Troubleshooting

### AI Commands Failing

```bash
# Check API keys are configured
cat .env                           # For CLI usage

# Verify model configuration
task-master models

# Test with different model
task-master models --set-fallback gpt-4o-mini
```

### MCP Connection Issues

- Check `.mcp.json` configuration
- Verify Node.js installation
- Use `--mcp-debug` flag when starting Claude Code
- Use CLI as fallback if MCP unavailable

### Task File Sync Issues

```bash
# Regenerate task files from tasks.json
task-master generate

# Fix dependency issues
task-master fix-dependencies
```

DO NOT RE-INITIALIZE. That will not do anything beyond re-adding the same Taskmaster core files.

## Important Notes

### AI-Powered Operations

These commands make AI calls and may take up to a minute:

- `parse_prd` / `task-master parse-prd`
- `analyze_project_complexity` / `task-master analyze-complexity`
- `expand_task` / `task-master expand`
- `expand_all` / `task-master expand --all`
- `add_task` / `task-master add-task`
- `update` / `task-master update`
- `update_task` / `task-master update-task`
- `update_subtask` / `task-master update-subtask`

### File Management

- Never manually edit `tasks.json` - use commands instead
- Never manually edit `.taskmaster/config.json` - use `task-master models`
- Task markdown files in `tasks/` are auto-generated
- Run `task-master generate` after manual changes to tasks.json

### Claude Code Session Management

- Use `/clear` frequently to maintain focused context
- Create custom slash commands for repeated Task Master workflows
- Configure tool allowlist to streamline permissions
- Use headless mode for automation: `claude -p "task-master next"`

### Multi-Task Updates

- Use `update --from=<id>` to update multiple future tasks
- Use `update-task --id=<id>` for single task updates
- Use `update-subtask --id=<id>` for implementation logging

### Research Mode

- Add `--research` flag for research-based AI enhancement
- Requires a research model API key like Perplexity (`PERPLEXITY_API_KEY`) in environment
- Provides more informed task creation and updates
- Recommended for complex technical tasks

---

_This guide ensures Claude Code has immediate access to Task Master's essential functionality for agentic development workflows._
