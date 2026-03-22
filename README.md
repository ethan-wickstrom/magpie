# magpie

> Just a magpie collecting interesting things about you...

## Prerequisites

### Conceptual

- [[2507.19457] GEPA: Reflective Prompt Evolution Can Outperform Reinforcement Learning](https://arxiv.org/abs/2507.19457)
- [[2509.13237v1] Metacognitive Reuse: Turning Recurring LLM Reasoning Into Concise Behaviors](https://arxiv.org/abs/2509.13237)
- [Replit — Decision-Time Guidance: Keeping Replit Agent Reliable](https://blog.replit.com/decision-time-guidance)

## Overview

TODO: Write a brief overview of the project.

For information on the tech stack, see [`TECHSTACK.md`](./TECHSTACK.md).

## Features

TODO: List the main features of the project.

## Project Structure

```
magpie/                    ← root package (CLI entrypoint)
├── src/magpie/            ← CLI app
├── packages/
│   ├── core/              ← Pydantic models, shared types
│   ├── ai/                ← DSPy pipeline logic (depends on core)
│   └── api/               ← FastAPI server (depends on core + ai)
├── pyproject.toml         ← workspace root, dev dependencies
├── ruff.toml              ← linter/formatter config
├── ty.toml                ← type checker config
├── uv.lock                ← pinned lockfile
├── .env.example           ← environment variable template
└── setup.sh               ← first-time setup script
```

This is a **uv workspace monorepo**. All packages are managed together and share a single lockfile.

## Installation

### Requirements

- [uv](https://docs.astral.sh/uv/getting-started/installation/) (package/project manager)
- Python 3.13 (installed automatically by `setup.sh` if missing)

### Quick Start

```bash
git clone <repo-url> && cd magpie
./setup.sh
```

The setup script will:

1. Verify `uv` is installed and Python 3.13 is available (installs it via `uv` if not).
2. Run `uv sync --all-packages` to create the venv and install all workspace packages + dev tools.
3. Copy `.env.example` → `.env` if `.env` doesn't exist yet.
4. Run lint, format, type check, test, and smoke tests, reporting any issues as warnings.

### Environment Variables

Copy `.env.example` to `.env` and fill in at least one LLM provider key:

| Variable | Required | Description |
|---|---|---|
| `OPENAI_API_KEY` | Yes (or alternative) | OpenAI API key for DSPy |
| `ANTHROPIC_API_KEY` | Optional | Anthropic API key (alternative provider) |
| `OPENAI_API_BASE` | Optional | Custom base URL (e.g., for Ollama at `http://localhost:11434/v1`) |

## Usage

```bash
# Run the CLI
uv run magpie

# Start the API dev server
uv run fastapi dev

# Lint / format / type check / test
uv run ruff check .
uv run ruff format .
uv run ty check
uv run pytest
```

## Contributing

```bash
# After making changes, run the full check suite:
uv run ruff check . && uv run ruff format --check . && uv run ty check && uv run pytest
```

All code is formatted and linted by **Ruff**, type-checked by **ty**, and tested with **pytest**. These are installed as dev dependencies — no global installs needed.

## License

TODO: Specify the license for the project.