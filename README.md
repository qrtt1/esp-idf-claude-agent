# esp-idf-claude-agent

ESP32 full-cycle development assistant for [Claude Code](https://claude.com/claude-code). Supports all ESP-IDF targets. Orchestrates sub-agents for environment setup, build/flash, log analysis, example lookup, and code fixing.

## Features

- **Auto-detect environment** — finds `IDF_PATH`, serial port, and platform automatically
- **Sub-agent architecture** — each task runs in an isolated context, keeping the main conversation clean
- **Smart iteration loop** — build → flash → analyze → fix → repeat (up to 5 rounds)
- **ESP-IDF example lookup** — searches official examples and extracts code patterns for you
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
    └── fixer.md             ← Code modification (general-purpose agent)
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

## License

MIT
