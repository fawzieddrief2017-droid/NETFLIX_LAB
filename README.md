# NETFLIX_LAB



## 🏗️ The Architecture

The toolkit is organized into modular components that provide both the logic (Scripts) and the structure (Templates) for the agent.

```text
.agent/
├── skills/                  # @ Mentions (Agent Intelligence)
│   ├── speckit.analyze      # Consistency Checker
│   ├── speckit.checker      # Static Analysis Aggregator
│   ├── speckit.checklist    # Requirements Validator
│   ├── speckit.clarify      # Ambiguity Resolver
│   ├── speckit.constitution # Governance Manager
│   ├── speckit.diff         # Artifact Comparator
│   ├── speckit.implement    # Code Builder (Anti-Regression)
│   ├── speckit.migrate      # Legacy Code Migrator
│   ├── speckit.plan         # Technical Planner
│   ├── speckit.quizme       # Logic Challenger (Red Team)
│   ├── speckit.reviewer     # Code Reviewer
│   ├── speckit.specify      # Feature Definer
│   ├── speckit.status       # Progress Dashboard
│   ├── speckit.tasks        # Task Breaker
│   ├── speckit.taskstoissues# Issue Tracker Syncer
│   ├── speckit.tester       # Test Runner & Coverage
│   └── speckit.validate     # Implementation Validator
│
├── workflows/               # / Slash Commands (Orchestration)
│   ├── 00-speckit.all.md           # Full Pipeline
│   ├── 01-speckit.constitution.md  # Governance
│   ├── 02-speckit.specify.md       # Feature Spec
│   ├── ... (Numbered 00-11)
│   ├── speckit.prepare.md          # Prep Pipeline
│   └── util-speckit.*.md           # Utilities
│
└── scripts/                 # Shared Bash Core (Kinetic logic)
```

---

## 🗺️ Mapping: Commands to Capabilities

| Phase | Workflow Trigger | Antigravity Skill | Role |
| :--- | :--- | :--- | :--- |
| **Pipeline** | `/00-speckit.all` | N/A | Runs the full SDLC pipeline. |
| **Governance** | `/01-speckit.constitution` | `@speckit.constitution` | Establishes project rules & principles. |
| **Definition** | `/02-speckit.specify` | `@speckit.specify` | Drafts structured `spec.md`. |
| **Ambiguity** | `/03-speckit.clarify` | `@speckit.clarify` | Resolves gaps post-spec. |
| **Architecture** | `/04-speckit.plan` | `@speckit.plan` | Generates technical `plan.md`. |
| **Decomposition** | `/05-speckit.tasks` | `@speckit.tasks` | Breaks plans into atomic tasks. |
| **Consistency** | `/06-speckit.analyze` | `@speckit.analyze` | Cross-checks Spec vs Plan vs Tasks. |
| **Execution** | `/07-speckit.implement` | `@speckit.implement` | Builds implementation with safety protocols. |
| **Quality** | `/08-speckit.checker` | `@speckit.checker` | Runs static analysis (Linting, Security, Types). |
| **Testing** | `/09-speckit.tester` | `@speckit.tester` | Runs test suite & reports coverage. |
| **Review** | `/10-speckit.reviewer` | `@speckit.reviewer` | Performs code review (Logic, Perf, Style). |
| **Validation** | `/11-speckit.validate` | `@speckit.validate` | Verifies implementation matches Spec requirements. |
| **Preparation** | `/speckit.prepare` | N/A | Runs Specify -> Analyze sequence. |
| **Checklist** | `/util-speckit.checklist` | `@speckit.checklist` | Generates feature checklists. |
| **Diff** | `/util-speckit.diff` | `@speckit.diff` | Compares artifact versions. |
| **Migration** | `/util-speckit.migrate` | `@speckit.migrate` | Port existing code to Spec-Kit. |
| **Red Team** | `/util-speckit.quizme` | `@speckit.quizme` | Challenges logical flaws. |
| **Status** | `/util-speckit.status` | `@speckit.status` | Shows feature completion status. |
| **Tracking** | `/util-speckit.taskstoissues`| `@speckit.taskstoissues`| Syncs tasks to GitHub/Jira/etc. |

---

## 🛡️ The Quality Assurance Pipeline

The following skills are designed to work together as a comprehensive defense against regression and poor quality. Run them in this order:

| Step | Skill | Core Question | Focus |
| :--- | :--- | :--- | :--- |
| **1. Checker** | `@speckit.checker` | *"Is the code compliant?"* | **Syntax & Security**. Runs compilation, linting (ESLint/GolangCI), and vulnerability scans (npm audit/govulncheck). Catches low-level errors first. |
| **2. Tester** | `@speckit.tester` | *"Does it work?"* | **Functionality**. Executes your test suite (Jest/Pytest/Go Test) to ensure logic performs as expected and tests pass. |
| **3. Reviewer** | `@speckit.reviewer` | *"Is the code written well?"* | **Quality & Maintainability**. Analyzes code structure for complexity, performance bottlenecks, and best practices, acting as a senior peer reviewer. |
| **4. Validate** | `@speckit.validate` | *"Did we build the right thing?"* | **Requirements**. Semantically compares the implementation against the defined `spec.md` and `plan.md` to ensure all feature requirements are met. |

> **🤖 Power User Tip:** You can amplify this pipeline by creating a custom **Claude Code (MCP) Server** or subagent that delegates heavy reasoning to **Gemini Pro 3** via the `gemini` CLI.
>
> *   **Use Case:** Bind the `@speckit.validate` and `@speckit.reviewer` steps to Gemini Pro 3.
> *   **Benefit:** Gemini's 1M+ token context and reasoning capabilities excel at analyzing the full project context against the Spec, finding subtle logical flaws that smaller models miss.
> *   **How:** Create a wrapper script `scripts/gemini-reviewer.sh` that pipes the `tasks.md` and codebase to `gemini chat`, then expose this as a tool to Claude.

