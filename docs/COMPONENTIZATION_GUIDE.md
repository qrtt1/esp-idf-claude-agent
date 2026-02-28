# Component Refactoring Assistant - User Guide

## Overview

The ESP-IDF Claude Agent now includes intelligent code analysis and component extraction assistance to help you refactor monolithic code into a modular component architecture.

## Features

✅ **Smart Analysis** - Automatically identifies module boundaries in your code
✅ **Safe Refactoring** - Step-by-step guidance with build verification at each stage
✅ **Non-intrusive** - Provides suggestions only, never forces action
✅ **User Control** - Manual code migration to avoid automation errors

## Workflow

```
main.c (350 lines)
    ↓
[Auto-triggered analysis] or [User request]
    ↓
📊 Analysis Report
    - wifi_utils (5 functions, ~90 lines)
    - api_client (6 functions, ~140 lines)
    - beacon_utils (4 functions, ~80 lines)
    ↓
❓ User decides whether to proceed
    ↓ (agrees)
🔧 Create components one by one
    - Generate skeleton
    - Build verify skeleton
    - Guide code migration
    - Build verify migration
    ↓
✅ Done! main.c → modular architecture
```

## Usage

### Method 1: Auto-trigger (Recommended)

When your `main.c` exceeds certain line thresholds, the agent automatically provides suggestions after successful BUILD:

```
User: "build and flash"

Agent:
  → BUILD SUCCESS
  → Detected main.c = 350 lines
  → Trigger code-advisor

Agent: "✅ Build successful!

📊 Code Analysis:
   Current main.c has 350 lines, 18 functions.

💡 Refactoring Suggestion:
   I've identified 3 distinct modules:

   1️⃣ wifi_utils (~90 lines, 4 functions)
   2️⃣ api_client (~140 lines, 6 functions)
   3️⃣ beacon_utils (~80 lines, 4 functions)

   Would you like help creating component skeletons?"
```

**Trigger Thresholds**:
- 150+ lines: First suggestion
- 350+ lines: Strong recommendation
- 500+ lines: Urgent recommendation

### Method 2: Manual Request

You can request analysis at any time:

```
User: "analyze code structure"
User: "split into components"
User: "refactor code"
```

## Refactoring Process Details

### Phase 1: Analysis

The agent analyzes your code and generates a report:

```
ANALYSIS_STATUS: SUGGEST_COMPONENTIZE
URGENCY: MEDIUM
LINES: 350
FUNCTIONS: 18

IDENTIFIED_MODULES:

Module: wifi_utils
  Estimated Lines: ~90
  Functions:
    - wifi_connect() [line 45]
    - wifi_generate_device_id() [line 89]
    - wifi_event_handler() [line 120]
  Reason: All functions handle WiFi connectivity
  Dependencies: esp_wifi, nvs_flash

Module: api_client
  Estimated Lines: ~140
  Functions:
    - api_register_device() [line 200]
    - api_send_heartbeat() [line 250]
    - http_event_handler() [line 300]
  Reason: All functions interact with HTTP API
  Dependencies: esp_http_client, cjson

...
```

### Phase 2: Create Components (One at a Time)

Example: Creating `wifi_utils` component

#### Step 1: Generate Skeleton

Agent automatically creates:
```
components/wifi_utils/
├── CMakeLists.txt
├── include/wifi_utils.h
└── wifi_utils.c
```

Then **immediately verifies** the skeleton builds correctly.

#### Step 2: Add Function Declarations

Agent adds to `wifi_utils.h`:
```c
#pragma once

#include "esp_err.h"

esp_err_t wifi_connect(const char *ssid, const char *password);
void wifi_generate_device_id(char *device_id, size_t len);
```

**Build verify** again.

#### Step 3: Migrate Code (Manual)

Agent provides clear instructions:

```
📋 Please copy the following functions from main.c to components/wifi_utils/wifi_utils.c:

1. wifi_connect() [line 45-78]
   - Copy the entire function
   - Paste into wifi_utils.c

2. wifi_generate_device_id() [line 89-105]
   - Copy the entire function
   - Paste into wifi_utils.c

3. wifi_event_handler() [line 120-150]
   - This is a static function, keep it static in wifi_utils.c

Let me know when done.
```

**Why manual migration?**
- ✅ Safer (you review each function)
- ✅ Learning opportunity (understand module organization)
- ✅ Avoid automation errors (AI might misjudge dependencies)

#### Step 4: Update main.c

```
Now update main.c:

1. Add at the top:
   #include "wifi_utils.h"

2. Remove the function definitions you just copied (keep main() function)

Type 'yes' when done
```

#### Step 5: Build Verification

```bash
idf.py build
```

**Success**:
```
✅ Build successful! wifi_utils component is complete.

Summary:
- Created components/wifi_utils/
- Migrated 3 functions
- main.c: 350 → 260 lines

Ready to create next component (api_client)?
```

**Failure**:
```
❌ Build failed, analyzing errors...

Error: 'esp_netif_t' undeclared

Fix: Add to wifi_utils.c:
  #include "esp_netif.h"

After fixing, run: idf.py build
```

### Phase 3: Repeat for Other Components

One at a time, gradually complete:
- wifi_utils ✅
- api_client ⏳
- beacon_utils ⏳

## Example Conversation

### Complete Example: Analysis to Completion

```
User: "build"

Agent: ✅ Build successful!

       📊 Code Analysis: main.c has 350 lines

       💡 Suggest splitting into 3 components:
          - wifi_utils
          - api_client
          - beacon_utils

       Start refactoring?

User: "yes"

Agent: Creating wifi_utils...

       [Generate skeleton]
       ✅ Skeleton created, build verified

       📋 Please copy these functions from main.c to
          components/wifi_utils/wifi_utils.c:
          - wifi_connect() [line 45-78]
          - wifi_generate_device_id() [line 89-105]

       Let me know when done.

User: "done"

Agent: Good. Now please:
       1. Add to main.c top: #include "wifi_utils.h"
       2. Remove the function definitions you just copied

       Type 'yes' when ready

User: "yes"

Agent: Running build verification...

       ✅ Build successful! wifi_utils component complete.

       main.c: 350 → 280 lines

       Continue with api_client?

User: "yes"

Agent: [Start next component...]
```

## Best Practices

### ✅ Recommended

1. **One component at a time** - Don't create multiple simultaneously to avoid confusion
2. **Build at each step** - Ensure each stage compiles
3. **Git commit frequently** - Commit after each component completion
4. **Test functionality** - After build succeeds, flash to device and verify

### ❌ Avoid

1. **Don't skip build verification** - Verify at every step
2. **Don't change too much at once** - Gradual progress is easier to debug
3. **Don't rush to delete code** - Confirm new component works before removing old code
4. **Don't ignore errors** - Address build failures immediately

## Auto-trigger Configuration

### Trigger Conditions

Agent automatically checks code under these conditions:

✅ **Will trigger**:
- After BUILD success
- main.c crosses threshold (150/350/500 lines)
- More than 2 iterations since last suggestion

❌ **Won't trigger**:
- BUILD failed
- Already using component architecture (2+ components exist)
- Just suggested recently (avoid nagging)

### Temporarily Disable

If you don't want automatic suggestions:

```
User: "please don't suggest componentization for now"
```

Agent will remember your preference and stop proactive suggestions (you can still request manually).

## FAQ

### Q: When should I split components?

**A**:
- Code exceeds 200 lines
- Clear functional modules exist (WiFi, HTTP, BLE, etc.)
- Plan to reuse these functions in future projects

### Q: Could refactoring break my code?

**A**:
No, because:
- Build verification at each step
- You manually migrate code (full control)
- Can always revert via git

### Q: Must I follow the agent's suggested module split?

**A**:
No. The suggestions are recommendations. You can:
- Choose to split only some modules
- Use different module boundaries
- Not split at all (continue with monolithic structure)

### Q: Will performance degrade after splitting?

**A**:
No. Components are only a compile-time organization. The final binary is the same, execution efficiency is identical.

### Q: Can I stop halfway through refactoring?

**A**:
Yes. Each component is created independently, you can stop anytime:
- Created components remain
- Remaining code stays in main.c
- Mixed architecture works fine

## Technical Details

### Component Skeleton Structure

```
components/wifi_utils/
├── CMakeLists.txt           # Build configuration
├── include/
│   └── wifi_utils.h         # Public API
└── wifi_utils.c             # Implementation
```

### CMakeLists.txt Template

```cmake
idf_component_register(
    SRCS "wifi_utils.c"
    INCLUDE_DIRS "include"
    PRIV_REQUIRES esp_wifi nvs_flash
)
```

**Explanation**:
- `SRCS`: Source files
- `INCLUDE_DIRS`: Public header directory
- `PRIV_REQUIRES`: Other ESP-IDF components this component depends on

### Dependency Handling

If function A calls function B, they should:

✅ **Be in the same component** (if tightly coupled)
✅ **Split into two components, B provides public API to A** (if different domains)

The agent will highlight these dependencies for you.

## Advanced Usage

### Creating Reusable Components

Created components can be:

1. **Shared across different targets in the same project**
2. **Copied to other projects for reuse**
3. **Published as standalone ESP-IDF components**

### Component Version Control

Recommended approach:
```bash
# Commit after completing each component
git add components/wifi_utils/
git commit -m "refactor: extract wifi_utils component"

# Continue with next
git add components/api_client/
git commit -m "refactor: extract api_client component"
```

Benefits:
- Clear refactoring history
- Can revert step-by-step if issues arise
- Easier code review

## Summary

The Component Refactoring Assistant makes refactoring:

✅ **Safe** - Verified at each step, won't break code
✅ **Simple** - Clear guidance, easy to follow
✅ **Controllable** - You decide the pace, can stop anytime

With this tool, you can easily evolve single-file prototype code into a well-structured modular project.
