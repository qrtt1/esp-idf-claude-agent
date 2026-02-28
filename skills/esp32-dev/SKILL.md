---
name: esp32-dev
description: ESP32 development knowledge base for all ESP-IDF targets. Contains shared environment info, sub-agent prompt templates, and ESP-IDF example reference. The main agent (agents/esp32-dev.md) reads files from this skill directory at runtime to compose sub-agent prompts.
---

# ESP32 Development Skill

This skill directory contains all reference materials and sub-agent prompt templates needed for ESP32 development.

## Directory Structure

```
skills/esp32-dev/
├── SKILL.md              ← This file
├── shared-context.md     ← Shared environment info (paths, commands, log keywords)
└── sub-agents/           ← Sub-agent prompt templates
    ├── setup.md          ← Environment detection and setup
    ├── builder.md        ← Build + Flash + Monitor
    ├── log-analyzer.md   ← Serial log analysis
    ├── example-finder.md ← ESP-IDF example lookup
    └── fixer.md          ← Code fixing
```

## Usage

These files are NOT triggered directly. Instead, `agents/esp32-dev.md` (the orchestrator) loads them via the Read tool when needed, composes them into sub-agent prompts, and dispatches via the Task tool.
