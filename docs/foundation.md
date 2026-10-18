# Foundation 0.1 capabilities

The API is intentionally small and native to each platform. It is not source-compatible with Telerik. Both packages expose 11 components. `NgRadioGroup` covers the first-stage Radio requirement and `NgTabs` covers Tabs.

| Component | Blazor implemented | Flutter implemented | Deferred / limits |
|---|---|---|---|
| NgButton | primary/default, disabled, click, submit type | primary/default, disabled, callback | icons/loading/style variants |
| NgTextBox | label, placeholder, disabled, immediate binding, EditForm | label, placeholder, disabled, controller or initialValue, Form validator | masks, multiline, password variants |
| NgNumericTextBox | nullable decimal, native number input, min/max/step attributes, EditForm parsing | nullable double, finite number and min/max validation, external value updates | locale-specific formatting, custom spinners; Blazor business bounds need model validation |
| NgCheckBox | bool binding, label, disabled, EditForm | bool callback, label, disabled | indeterminate state |
| NgRadioGroup | string options, per-option/group disabled, EditForm | string options, per-option/group disabled, callback | generic values, custom item templates |
| NgSwitch | bool binding, native checkbox keyboard behavior with switch role | bool callback, native Flutter switch | additional size/style variants |
| NgDropDownList | native select, string options, disabled options, placeholder, EditForm | controlled string selection, disabled options, Form validation | search, virtualization, async loading, generic data |
| NgTabs | controlled index, ARIA roles, arrow/Home/End keys, disabled tabs, preserved panels | controlled index, native TabBar navigation, selected panel | Flutter disabled tabs; dynamic empty/out-of-range selection must be avoided |
| NgDialog | native modal dialog, focus containment, Escape/close callbacks, title and action slots | modal route, Escape, close action, action slots | nested dialogs, drag/resize, positioning; focus return needs browser verification |
| NgTooltip | hover/focus content, ARIA description | native Tooltip and semantics | Blazor viewport collision and Escape dismissal |
| NgNotification | controlled visibility, dismiss, success/error, status/alert role | dismiss callback, success/error, live region | queue, auto-dismiss timer, placement service |

## Theme contract

`design/tokens.json` is authoritative. Run `python3 scripts/generate_theme.py` after edits; generated outputs are committed with source. Light/dark palettes are shared. Blazor uses CSS variables; Flutter uses generated colors and metrics in `ThemeData`. Flutter retains native Material interaction and touch target behavior, so layout metrics are not pixel-identical. Compact mode retains keyboard/touch interaction.

Typography currently requests Arial and uses platform fallbacks. No font assets or Telerik logos are copied. Primary colors are adjusted for contrast; strict Telerik Default visual matching is pending reference-based review.

## Completion criteria for future stages

For each component: audit the linked reference features, define the platform API, implement real behavior, add interaction tests, visually verify light/dark and compact/regular layouts in local visible Chrome, record known gaps. Do not change `planned` to full parity based only on rendering.
