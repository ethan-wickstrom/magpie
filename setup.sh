#!/usr/bin/env bash
# ── magpie — first-time setup ───────────────────────────────────────
# Usage: ./setup.sh
set -euo pipefail

# ── Helpers ──────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { printf "${BOLD}▸ %s${RESET}\n" "$*"; }
ok()      { printf "  ${GREEN}✓${RESET} %s\n" "$*"; }
warn()    { printf "  ${YELLOW}⚠${RESET}  %s\n" "$*"; }
fail()    { printf "  ${RED}✗${RESET} %s\n" "$*"; exit 1; }
section() { printf "\n${BOLD}── %s ──${RESET}\n" "$*"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

REQUIRED_PYTHON="3.13"

# ── 1. Prerequisites ────────────────────────────────────────────────

section "Prerequisites"

# uv
if ! command -v uv >/dev/null 2>&1; then
    fail "uv is not installed. Install it: https://docs.astral.sh/uv/getting-started/installation/"
fi
UV_VERSION="$(uv --version | awk '{print $2}')"
ok "uv $UV_VERSION"

# Python
if uv python find "$REQUIRED_PYTHON" >/dev/null 2>&1; then
    ok "Python $REQUIRED_PYTHON found"
else
    info "Python $REQUIRED_PYTHON not found — installing via uv…"
    uv python install "$REQUIRED_PYTHON"
    ok "Python $REQUIRED_PYTHON installed"
fi

# ── 2. Sync workspace ───────────────────────────────────────────────

section "Workspace"

info "Syncing all packages and dev dependencies…"
uv sync --all-packages
ok "Workspace synced"

# Verify workspace packages are importable
for pkg in core ai api; do
    if uv run python -c "import $pkg" 2>/dev/null; then
        ok "package '$pkg' importable"
    else
        warn "package '$pkg' failed to import"
    fi
done

# ── 3. Environment file ─────────────────────────────────────────────

section "Environment"

if [ -f .env ]; then
    ok ".env already exists"
else
    if [ -f .env.example ]; then
        cp .env.example .env
        ok ".env created from .env.example"
        warn "Edit .env to add your API keys before running the AI pipeline"
    else
        warn "No .env.example found — skipping .env creation"
    fi
fi

# ── 4. Verification ─────────────────────────────────────────────────

section "Verification"

ISSUES=0

# Lint
if uv run ruff check . --quiet 2>/dev/null; then
    ok "ruff lint passed"
else
    warn "ruff lint reported issues (run: uv run ruff check .)"
    ISSUES=$((ISSUES + 1))
fi

# Format check
if uv run ruff format --check . --quiet 2>/dev/null; then
    ok "ruff format passed"
else
    warn "ruff format reported issues (run: uv run ruff format .)"
    ISSUES=$((ISSUES + 1))
fi

# Type check
if uv run ty check 2>/dev/null; then
    ok "ty type check passed"
else
    warn "ty reported issues (run: uv run ty check)"
    ISSUES=$((ISSUES + 1))
fi

# Tests
if uv run pytest --tb=short -q 2>/dev/null; then
    ok "pytest passed"
else
    warn "pytest reported issues or no tests found (run: uv run pytest)"
    ISSUES=$((ISSUES + 1))
fi

# API smoke test
if uv run python -c "from api.app import app; assert app.title == 'magpie'" 2>/dev/null; then
    ok "FastAPI app loads"
else
    warn "FastAPI app failed to load (run: uv run fastapi dev)"
    ISSUES=$((ISSUES + 1))
fi

# ── Summary ──────────────────────────────────────────────────────────

section "Done"

if [ "$ISSUES" -eq 0 ]; then
    printf "  ${GREEN}All checks passed.${RESET}\n"
else
    printf "  ${YELLOW}%d check(s) reported warnings — see above.${RESET}\n" "$ISSUES"
fi

printf "\n${BOLD}Common commands:${RESET}\n"
printf "  %-30s %s\n" "uv run magpie"         "Run the CLI"
printf "  %-30s %s\n" "uv run fastapi dev"    "Start the API dev server"
printf "  %-30s %s\n" "uv run ruff check ."   "Lint"
printf "  %-30s %s\n" "uv run ruff format ."  "Format"
printf "  %-30s %s\n" "uv run ty check"       "Type check"
printf "  %-30s %s\n" "uv run pytest"         "Run tests"
printf "\n"
