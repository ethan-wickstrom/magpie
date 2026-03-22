# magpie

> Just a magpie collecting interesting things about you...

A conversational agent who learns from you. Magpie extracts structured user preferences from chat interactions, stores them in a retrievable format, and injects relevant preferences at inference time to personalize future responses.

## How it Works

Magpie operates as a chat application with a learning loop underneath. As you converse, a DSPy pipeline analyzes conversation traces to identify what you care about. Extracted preferences are organized into a two-layer structure:

- Categories are broad topic domains: programming, movies, books, hobbies.
- Preferences are specific claims within a category: "prefers Rust over Go for systems work," "dislikes jump scares in horror films."

Each conversation turn is an opportunity to refine the preference model. The system reflects on the full trace (your messages, its responses, corrections you make) to propose new preferences or update existing ones. Over time, the preference store becomes a compressed representation of your tastes and working style.

Magpie does all of this in the background. You don't need to think about it - just chat normally and the system will learn from your interactions.

## Prerequisites

### Conceptual

- [[2507.19457] GEPA: Reflective Prompt Evolution Can Outperform Reinforcement Learning](https://arxiv.org/abs/2507.19457)
- [[2509.13237v1] Metacognitive Reuse: Turning Recurring LLM Reasoning Into Concise Behaviors](https://arxiv.org/abs/2509.13237)
- [Replit — Decision-Time Guidance: Keeping Replit Agent Reliable](https://blog.replit.com/decision-time-guidance)

### Preference Extraction via Metacognitive Reflection
 
Inspired by [Metacognitive Reuse](https://arxiv.org/abs/2509.13237) (Didolkar et al., 2025). That paper shows LLMs can analyze their own reasoning traces, identify recurring patterns, and compress them into named reusable "behaviors" stored in a handbook. Magpie applies the same principle to user preferences instead of reasoning patterns. The model reflects on conversation traces, extracts generalizable preference claims, and stores them as structured entries. This is procedural memory for personalization: the system learns *how to respond to you*, not just *what you asked*.

### Dynamic Preference Injection at Decision Time
 
Inspired by [Decision-Time Guidance](https://blog.replit.com/decision-time-guidance) (Replit, 2026). Static system prompts that front-load all known preferences degrade as the preference store grows. Magpie instead retrieves and injects only the preferences relevant to the current conversational context. This keeps the context window focused and avoids the failure mode where hundreds of rules compete for attention in a monolithic prompt.

### Pipeline Optimization with GEPA
 
Inspired by [GEPA](https://arxiv.org/abs/2507.19457) (Agrawal et al., 2025). The preference extraction and personalization pipelines are built as modular DSPy programs. GEPA optimizes the prompts driving these modules through evolutionary search guided by natural-language reflection on execution traces. This means the system's ability to extract, identify, and apply preferences improves automatically from observed successes and failures, without manual prompt tuning.

## Overview

TODO: Write a brief overview of the project.

For information on the tech stack, see [`TECHSTACK.md`](./TECHSTACK.md).

## Features

TODO: List the main features of the project.

## Project Structure

```
magpie/
├── src/magpie/            ← CLI entrypoint
├── packages/              ← Python uv workspace
│   ├── core/              ← Pydantic models, shared types
│   ├── ai/                ← DSPy pipeline logic (depends on core)
│   └── api/               ← FastAPI server (depends on core + ai)
├── web/                   ← Frontend Turborepo workspace (Bun)
│   ├── apps/web/          ← TanStack Start app
│   └── packages/ui/       ← shadcn component library (@workspace/ui)
├── pyproject.toml         ← Python workspace root, dev dependencies
├── ruff.toml              ← linter/formatter config
├── ty.toml                ← type checker config
├── uv.lock                ← Python lockfile
├── .env.example           ← environment variable template
└── setup.sh               ← first-time setup script
```

The repo has two workspaces:

- **Python** (`packages/`) — managed by **uv**, single `uv.lock`
- **Frontend** (`web/`) — managed by **Bun** + **Turborepo**, single `bun.lock`

## Installation

### Requirements

- [uv](https://docs.astral.sh/uv/getting-started/installation/) (Python package/project manager)
- [Bun](https://bun.sh/docs/installation) (JavaScript runtime/package manager)
- Python 3.13 (installed automatically by `setup.sh` if missing)

### Quick Start

```bash
git clone <repo-url> && cd magpie
./setup.sh
```

The setup script will:

1. Verify `uv` and `bun` are installed; install Python 3.13 via `uv` if missing.
2. Run `uv sync --all-packages` to create the venv and install all Python packages + dev tools.
3. Run `bun install` in `web/` to install frontend dependencies.
4. Copy `.env.example` → `.env` if `.env` doesn't exist yet.
5. Run lint, format, type check, test, and smoke tests for both Python and frontend.

### Environment Variables

Copy `.env.example` to `.env` and fill in at least one LLM provider key:

| Variable | Required | Description |
|---|---|---|
| `OPENAI_API_KEY` | Yes (or alternative) | OpenAI API key for DSPy |
| `ANTHROPIC_API_KEY` | Optional | Anthropic API key (alternative provider) |
| `OPENAI_API_BASE` | Optional | Custom base URL (e.g., for Ollama at `http://localhost:11434/v1`) |

## Usage

### Python

```bash
uv run magpie            # Run the CLI
uv run fastapi dev       # Start the API dev server
uv run ruff check .      # Lint
uv run ruff format .     # Format
uv run ty check          # Type check
uv run pytest            # Run tests
```

### Frontend (from `web/`)

```bash
bun run dev              # Start the dev server (port 3000)
bun run build            # Build for production
bun run typecheck        # Type check
bun run lint             # Lint
bun run format           # Format
```

## Contributing

```bash
# Python checks:
uv run ruff check . && uv run ruff format --check . && uv run ty check && uv run pytest

# Frontend checks (from web/):
bun run typecheck && bun run lint
```

- **Python** — formatted/linted by **Ruff**, type-checked by **ty**, tested with **pytest**
- **Frontend** — formatted by **Prettier**, linted by **ESLint**, type-checked by **TypeScript**, built by **Turborepo**

All tools are installed as dev dependencies — no global installs needed beyond `uv` and `bun`.

## License

TODO: Specify the license for the project.