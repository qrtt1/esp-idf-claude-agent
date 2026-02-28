# ESP32 Shared Environment Information

- **Target**: All ESP-IDF supported chips (ESP32, ESP32-S2, ESP32-S3, ESP32-C3, ESP32-C6, ESP32-H2, etc.)
- **ESP-IDF**: Detected by setup agent via `IDF_PATH` environment variable or auto-search
- **Examples**: `$IDF_PATH/examples/` (subdirectories: wifi/, protocols/, peripherals/, system/, bluetooth/, storage/)

## Path Resolution Rules

ALL paths in this project are NOT hardcoded. They are detected by the setup agent at startup.
Subsequent agents receive prompts with actual resolved paths.

The following are placeholders that the orchestrator replaces with actual values when composing prompts:

| Placeholder | Description | Example Value |
|:------------|:------------|:--------------|
| `{IDF_PATH}` | ESP-IDF installation path | `/Users/qty/esp/v5.5.1/esp-idf` |
| `{IDF_VERSION}` | ESP-IDF version | `v5.5.1` |
| `{EXAMPLES_PATH}` | Examples directory | `/Users/qty/esp/v5.5.1/esp-idf/examples` |
| `{PORT}` | Serial port | `/dev/cu.usbmodem2101` |
| `{PROJECT_DIR}` | Current project directory | `/Users/qty/projects/my-esp32` |

## CRITICAL: Monitor and Logging Rules

### MUST Use idf.py monitor

**RULE**: You MUST ONLY use `idf.py monitor` to read serial output. Do NOT use any other serial port reader (minicom, screen, pyserial, etc.).

**WHY**:
- `idf.py monitor` automatically decodes backtraces to function names and line numbers
- It provides color-coded output for log levels
- It handles ESP32-specific boot messages and panic dumps correctly
- It integrates with the ESP-IDF toolchain

**FORBIDDEN**: Using cat, tail, minicom, screen, pyserial, or any direct serial port reading is PROHIBITED.

### Background Execution with script

Since `idf.py monitor` monopolizes the console and blocks the shell, it MUST run in background with output captured to `log.txt`:

```bash
# CORRECT way (macOS):
script -F log.txt idf.py -p {PORT} flash monitor &

# CORRECT way (Linux):
script -f log.txt -c "idf.py -p {PORT} flash monitor" &

# Log analysis reads from log.txt
tail -F log.txt
```

### Platform-Specific script Syntax

| Platform | Command | Notes |
|:---------|:--------|:------|
| macOS | `script -F log.txt <cmd>` | Uppercase -F for flush mode |
| Linux | `script -f log.txt -c "<cmd>"` | Lowercase -f, requires -c flag |

## Workflow: Build → Monitor → Analyze

**CRITICAL FLOW**:

1. **Builder agent** (Bash subagent):
   - Starts `script -F log.txt idf.py -p {PORT} flash monitor &` in background
   - Waits ONLY for build/flash completion (not monitor)
   - Reports PID and exits quickly
   - **Does NOT stuck main session**

2. **Monitor process** (background):
   - Runs indefinitely in background
   - Writes to log.txt continuously
   - Stops only on device disconnect or manual kill

3. **Log-analyzer agent** (Explore subagent):
   - Reads log.txt at any time
   - Can be called repeatedly while monitor runs
   - Independent of monitor process

## Command Syntax

```bash
# Main development command: build + flash + monitor in background
# ALWAYS remove old log.txt first for clean start
rm -f log.txt
script -F log.txt idf.py -p {PORT} flash monitor &

# Watch log in real-time (for debugging)
tail -F log.txt

# Build only
idf.py build

# Flash only (after build)
idf.py -p {PORT} flash

# Clean (when cache issues occur)
idf.py fullclean

# Kill running monitor (when needed)
pkill -f "idf.py.*monitor"
pkill -f "script.*log.txt"
```

## Serial Port Conventions

- macOS: `/dev/cu.usbmodem*` or `/dev/cu.usbserial-*`
- Linux: `/dev/ttyUSB*` or `/dev/ttyACM*`
- Check devices: `ls /dev/cu.* 2>/dev/null || ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null`
- Check if in use: `lsof {PORT} 2>/dev/null`

## Log Keywords Reference

| Keyword | Meaning | Severity |
|:--------|:--------|:--------:|
| `[E]` | Error | 🔴 |
| `Guru Meditation Error` | Panic/Crash | 🔴 |
| `Backtrace` | Stack trace (locate crash) | 🔴 |
| `assert failed` | Assertion failure | 🔴 |
| `Task watchdog` | Task timeout | 🔴 |
| `Stack overflow` | Insufficient stack | 🔴 |
| `[W]` | Warning | 🟡 |
| `[I]` | Info | ⚪ |
| `WiFi connected` / `got ip` | Connection success | ✅ |
