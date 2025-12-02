# Dynamic List Discovery Guide

## Overview

The left sidebar now **auto-discovers lists** from the `tasks/` directory and displays them in a **fixed 5-slot layout** with pagination.

## How It Works

### 1. Auto-Discovery

**No more manual metadata!** Lists are automatically discovered by scanning the `tasks/` directory for folders matching the pattern `listN` (e.g., `list1`, `list2`, etc.).

```r
# In R/config/metadata.R
discover_lists("tasks")
# Returns: c("list1", "list2", "list3", "list4", "list5", "list6")
```

### 2. Metadata Generation

For each discovered list, metadata is generated on the fly:

```r
# list1 →
list(
  id = "list1",
  num = 1,
  name = "Lista I",      # Roman numerals automatically converted
  subtitle = "Lista 1"
)
```

### 3. Fixed 5-Slot Layout

The left sidebar **always shows exactly 5 slots** per page, even if some are empty.

**Example with 6 lists:**

**Page 1:** (Lists 1-5)
```
┌──────────────┐
│ Lista I      │ ✓
│ Lista II     │ ✓
│ Lista III    │ ✓
│ Lista IV     │ ✓
│ Lista V      │ ✓
└──────────────┘
   ↓ Next
```

**Page 2:** (List 6 + 4 empty slots)
```
   ↑ Prev
┌──────────────┐
│ Lista VI     │ ✓
│      —       │ (empty)
│      —       │ (empty)
│      —       │ (empty)
│      —       │ (empty)
└──────────────┘
```

### 4. Empty Slot Behavior

Empty slots are:
- **Non-clickable** (pointer-events: none)
- **Dimmed** (opacity: 0.4)
- **Styled with dashes** ("—")
- **No hover effects**

## Adding a New List

### Before (Old System)
```r
# Had to manually edit R/config/metadata.R
list_metadata <- list(
  list1 = list(...),
  list2 = list(...),
  list7 = list(...)  # ← Add manually
)
```

### Now (Dynamic System)
```bash
# Just create the folder!
mkdir tasks/list7

# That's it! The app auto-discovers it on next load.
```

## Benefits

### 1. Zero Configuration
- No manual metadata editing
- No hardcoded list definitions
- Folders = buttons automatically

### 2. Consistent UI
- Always 5 slots visible
- Predictable pagination
- Clean, organized appearance

### 3. Scalability
- Supports unlimited lists (pagination handles it)
- Easy to add/remove lists
- No code changes needed

### 4. Flexibility
- Lists discovered in numerical order
- Roman numerals auto-generated
- Works with any `listN` pattern

## Technical Details

### File Changes

**Modified:**
- `R/config/metadata.R` - Dynamic discovery functions
- `R/ui/sidebar_left.R` - Fixed 5-slot layout logic
- `www/css/left-sidebar.css` - Empty slot styling
- `app.R` - Added comments about dynamic discovery

**Unchanged:**
- All other UI components
- Task loading system
- Server logic (already flexible)

### Key Functions

**Discovery:**
```r
discover_lists(tasks_dir = "tasks")
# Finds all list directories

generate_list_metadata(list_id)
# Creates metadata for one list

get_list_metadata(tasks_dir = "tasks")
# Returns complete metadata for all discovered lists
```

**Layout:**
```r
get_page_list_indices(page, slots_per_page, total_lists)
# Returns 5 indices (some may be NA for empty slots)

create_empty_list_slot()
# Creates placeholder for empty slot
```

### Pagination Logic

**Example with 13 lists:**

| Page | Lists Shown | Empty Slots |
|------|-------------|-------------|
| 1    | 1-5         | 0           |
| 2    | 6-10        | 0           |
| 3    | 11-13       | 2           |

**Total pages:** `ceil(13 / 5) = 3`

## Testing

### Test Case 1: Exactly 5 Lists
```bash
ls tasks/
# list1 list2 list3 list4 list5

# Expected: 1 page, all slots filled
```

### Test Case 2: 6 Lists (Pagination)
```bash
ls tasks/
# list1 list2 list3 list4 list5 list6

# Expected:
# Page 1: Lists 1-5
# Page 2: List 6 + 4 empty slots
```

### Test Case 3: Add New List
```bash
mkdir tasks/list7
# Reload app

# Expected: list7 appears automatically in UI
```

### Test Case 4: Remove List
```bash
rm -rf tasks/list3
# Reload app

# Expected: list3 disappears from UI
```

## Migration from Old System

### What Changed
- ✅ Metadata now generated dynamically
- ✅ Fixed 5-slot layout instead of variable
- ✅ Empty slots shown as placeholders

### What Stayed the Same
- ✅ Same visual appearance
- ✅ Same navigation behavior
- ✅ Same progress tracking
- ✅ Same task loading

### Backward Compatibility
- Old `list_metadata` format still understood
- Server observers work unchanged
- No breaking changes to existing code

## Future Enhancements

### Possible Improvements
1. **Custom titles**: Read from `tasks/listN/config.json`
2. **Icons**: Custom icons per list
3. **Descriptions**: Tooltips with list descriptions
4. **Reordering**: Drag-and-drop list reordering
5. **Hiding lists**: Mark lists as hidden via config

### Implementation Example
```json
// tasks/list1/config.json
{
  "name": "Podstawy R",
  "subtitle": "Wprowadzenie do języka R",
  "icon": "r-project",
  "visible": true
}
```

## Troubleshooting

### Lists Not Appearing
```r
# Check discovery function
source("R/config/metadata.R")
discover_lists("tasks")
# Should return vector of discovered lists
```

### Wrong Number of Slots
```r
# Check sidebar configuration
# In R/ui/sidebar_left.R, line 21:
slots_per_page <- 5  # Should always be 5
```

### Empty Slots Clickable
```css
/* Check CSS in www/css/left-sidebar.css */
.list-item-empty {
  pointer-events: none;  /* Should prevent clicks */
}
```

## Summary

The new dynamic list system:
- 🎯 **Auto-discovers** lists from folders
- 📐 **Fixed 5-slot** layout for consistency
- 🔄 **Pagination** through list packages
- 🚀 **Zero config** - just create folders!

No more manual metadata updates. Just create a `listN` folder and it appears automatically!
