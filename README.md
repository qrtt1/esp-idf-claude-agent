# esp-idf-claude-agent

ESP32 full-cycle development assistant for [Claude Code](https://claude.com/claude-code). Supports all ESP-IDF targets. Orchestrates sub-agents for environment setup, build/flash, log analysis, example lookup, and code fixing.

## Features

- **Auto-detect environment** — finds `IDF_PATH`, serial port, and platform automatically
- **Sub-agent architecture** — each task runs in an isolated context, keeping the main conversation clean
- **Smart iteration loop** — build → flash → analyze → fix → repeat (up to 5 rounds)
- **ESP-IDF example lookup** — searches official examples and extracts code patterns for you
- **Code refactoring assistant** — analyzes code structure and guides you through component extraction
- **Cross-platform** — works on macOS and Linux

## Prerequisites

- [ESP-IDF](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/get-started/) installed
- ESP-IDF environment sourced (`source $IDF_PATH/export.sh`)
- [Claude Code](https://claude.com/claude-code) installed

## Install

First, add the marketplace:

```bash
claude plugin marketplace add qrtt1/esp-idf-claude-agent
```

Then install the plugin:

```bash
claude plugin install esp-idf-claude-agent
```

## Usage

Start a session with the ESP32 development agent:

```bash
claude --agent esp-idf-claude-agent:esp32-dev
```

Then just tell it what you need:

```
> Set up the environment
> Help me develop a WiFi + HTTP server feature
> Why did it crash? Check the log
> Build and flash
```

The agent automatically determines which phase to run (setup, build, analyze, find-example, or fix) and dispatches work to specialized sub-agents.

## Architecture

```
agents/esp32-dev.md          ← Orchestrator (routes tasks, manages state)
skills/esp32-dev/
├── shared-context.md        ← Shared knowledge (paths, commands, log keywords)
└── sub-agents/
    ├── setup.md             ← Environment detection (Bash agent)
    ├── builder.md           ← Build + Flash + Monitor (Bash agent)
    ├── log-analyzer.md      ← Serial log analysis (Explore agent, haiku)
    ├── example-finder.md    ← ESP-IDF example lookup (Explore agent, haiku)
    ├── fixer.md             ← Code modification (general-purpose agent)
    ├── code-advisor.md      ← Code structure analysis (Explore agent, haiku)
    └── component-helper.md  ← Component extraction guide (general-purpose agent)
```

### How it works

1. **Orchestrator** receives your request and determines the phase
2. **Reads** shared context + sub-agent prompt at runtime
3. **Dispatches** via Task tool with the composed prompt
4. **Receives** structured results (not raw build output)
5. **Decides** next step or reports back to you

Sub-agents run in isolated contexts — build logs, example code, and debug traces stay in their own context windows, not yours.

### Development loop

```
FIND_EXAMPLE → FIX → BUILD → ANALYZE → success?
                ↑                         │ no
                └─────────────────────────┘
```

## Configuration

No hardcoded paths. The setup sub-agent auto-detects:

| What | How |
|:-----|:----|
| `IDF_PATH` | `$IDF_PATH` env var → `which idf.py` → common paths |
| Serial port | `/dev/cu.usbmodem*` (macOS) or `/dev/ttyUSB*` (Linux) |
| Platform | `uname -s` |
| ESP-IDF version | `idf.py --version` |

Just make sure you've sourced `export.sh` before starting Claude Code.

## Code Refactoring Assistant

The agent can help you refactor monolithic code into modular components.

### Automatic Analysis

When your `main.c` grows beyond 200 lines, the agent automatically analyzes your code structure and suggests componentization:

```
✅ Build successful!

📊 Code Analysis: main.c has 350 lines, 18 functions

💡 Identified Modules:
   1. wifi_utils (5 functions, ~90 lines)
   2. api_client (6 functions, ~140 lines)
   3. beacon_utils (4 functions, ~80 lines)

Would you like help creating these components?
```

### Guided Component Extraction

The agent guides you through a safe, step-by-step process:

1. **Create component skeleton** → build verify
2. **Add function declarations** → build verify
3. **Guide you to move code manually** → wait for confirmation
4. **Update main.c includes** → build verify
5. **Handle any build errors** → provide specific fixes

**Why manual migration?** You stay in control, and the agent catches errors at each step through build verification.

See [docs/COMPONENTIZATION_GUIDE.md](docs/COMPONENTIZATION_GUIDE.md) for detailed usage guide.

## License

MIT
