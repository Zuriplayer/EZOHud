# Changelog

## 0.1.103 - Native Quest Tracker Tweak Cleanup

- Removed the Native UI Tweaks controls, defaults, and runtime widget entry for repositioning ESO's native focused quest tracker.
- Kept Custom Quest Tracker as the supported movable replacement for focused quest display on HUD scenes.

## 0.1.102 - Custom Quest Tracker Text Fit

- Widened the Custom Quest Tracker panel and removed the visible hints header.
- Kept focused quest objective and hint text constrained to two ellipsis-truncated lines.

## 0.1.101 - Custom Quest Tracker Move Hotfix

- Fixed Custom Quest Tracker move mode so its preview can be shown from settings scenes and the panel becomes temporarily movable while dragging.

## 0.1.100 - Custom Quest Tracker Prototype

- Added a disabled-by-default Custom Quest Tracker panel that can replace ESO's focused quest tracker on HUD scenes.
- Shows the focused quest, current objective, optional hint lines, and ESO's native Cycle Focused Quest keybind while leaving keyboard/gamepad quest cycling under native control.

## 0.1.99 - Group Search Layout Cleanup

- Left-aligned the Custom Group Search label text and split the lower information into separate destination and search-duration/role lines.
- Removed the Native UI Tweaks mover for ESO's native Activity Finder group-search status indicator now that EZOhud has its own movable replacement.

## 0.1.98 - Group Search Detail Line

- Restored Custom Group Search extra information as a smaller third line below the native-style category and status.
- Shows destination, search duration, and compact role acronym (`DD`, `T`, or `H`) while keeping the custom label movable and scalable.

## 0.1.97 - Native-Style Group Search Hotfix

- Changed the Custom Group Search display to a compact native-style two-line label.
- Fixed movement by using explicit mouse down/up drag handlers and saving position when dragging stops.
- Expanded the scale range for the custom label.

## 0.1.96 - Custom Group Search Panel

- Added a movable Custom Group Search panel that can replace ESO's native on-screen Activity Finder status tracker.
- Shows available group-search status in a compact native-style label.
- Keeps the feature visual only: it does not queue, accept, decline, leave, or automate Activity Finder actions.
- Registered the panel as an independent EZOCore layout surface and synchronized English/Spanish documentation.

## 0.1.95 - Native Widget Move Handles

- Stopped opening every enabled native widget drag preview automatically when the Native UI Tweaks section opens.
- Added a per-widget move-handle button so only the selected native widget shows its green drag handle while testing placement.
- Clarified native widget labels and documentation so disabling custom positioning is understood as restoring ESO's original runtime anchor.

## 0.1.94 - Native Group Search Indicator

- Corrected the Activity Finder native tweak to target ESO's HUD group-search status indicator instead of the full Dungeon Finder/Activity Finder panel.
- Reapplies the indicator layout after Activity Finder status updates so native queue refreshes do not immediately restore the default anchor.

## 0.1.93 - Native Dungeon Finder Positioning

- Added experimental Native UI Tweaks controls for moving and scaling ESO's native Dungeon Finder/Activity Finder panel without automating activity finder actions.

## 0.1.92 - Custom Loot Hover Review

- Added a bottom hover zone to Custom Loot History so recent loot can be revealed and scrolled without keeping the whole panel mouse-active by default.

## 0.1.91 - Automatic Vanilla Bar Hiding

- Automatically enables vanilla attribute-bar hiding when the custom Attribute HUD is turned on.

## 0.1.90 - Soft Resource Warning Background

- Added a soft alarm tint to the consumed background of resource bars when their warning threshold is active.

## 0.1.89 - Stamina Stack Order

- Reordered the left-stacked Attribute HUD model to show Stamina above Magicka and tightened the vertical spacing.

## 0.1.88 - Left Attribute Stack Hotfix

- Corrected the stacked Attribute HUD model to align Health, Magicka, and Stamina on the left edge.

## 0.1.87 - Attribute Layout Selector

- Added an Attribute HUD layout selector with a classic split layout and a right-aligned Health, Magicka, and Stamina stack.
- Follows EZOCore's family preference storage policy for HUD settings, with one-time account-to-character migration when the default scope is per character.

## 0.1.86 - HUD Scene Blocking Hotfix

- Restricted Custom Loot History and custom Synergy windows to HUD/HUD UI scenes so they do not cover native menu panels.
- Disabled Custom Loot mouse capture except while its move mode is active.
- Synchronized addon version metadata and public documentation.

## 0.1.85 - Native Widgets and Custom UI Stabilization

- Added native UI positioning controls for the focused quest tracker, center screen announcements, synergy prompt, and active combat tips.
- Added custom Synergy and custom Loot History modules with independent movement surfaces.
- Hardened native loot suppression and custom loot event handling.
- Kept package contents runtime-focused and prevented extracted ESO UI reference files from being included accidentally.
- Synchronized addon version metadata and public documentation.

## 0.1.72 - Native Synergy Removal

- Removed native keyboard and gamepad synergy positioning/management logic to enforce the use of the custom synergy module.


## 0.1.53 - Move Initialization Hotfix

- Removes unsupported mouse-button initialization calls that crashed overlay startup on some ESO clients.
- Keeps left-button drag handling through the existing mouse handlers and move mode state.

## 0.1.52 - Shared diagnostics control

- Registers general debug logging and the transient Crux diagnostic mode with EZOCore.
- The family-wide disable action clears debug-to-chat and unregisters Crux diagnostic events and updates.
- Enforces left-button dragging for every movable HUD surface.

## 0.1.51 - HUD Position Persistence

- Saves HUD element positions defensively when dragging stops or when movement mode is disabled.
- Clarifies that movement edit modes reset on `/reloadui` or logout, while saved positions remain persisted.

## 0.1.50 - Shared Layout Integration

- Registers Attribute, Ultimate, Execute and Crux HUD surfaces independently with EZOCore `family.layout`.
- Allows central global or per-surface movement without persisting edit state.
- Keeps movement previews restricted to HUD/HUD_UI, including previews for currently disabled or context-inactive surfaces.

## 0.1.49 - EZOCore Settings Integration

- Registered the complete EZOhud settings panel in the native `Settings > EZO` hub when EZOCore is available.
- Kept the standard LibAddonMenu panel as a standalone fallback when EZOCore is absent or rejects registration.
- Added the permanent EZO Discord feedback link to the settings panel header.

## 0.1.48 - LAM Registration Robustness

- Aligned LibAddonMenu registration with the EZOTools pattern.
- Stored the registered LAM panel reference for diagnostics and future opening helpers.
- Added optional debug-logger reporting when a registered settings section fails to build.
- Added optional EZOCore integration for the shared EZO-family language preference.
- Added an explicit Automatic client-language fallback when EZOCore is unavailable.

## 0.1.47 - LAM Presentation Standard

- Reformatted the LibAddonMenu settings panel to use shared EZO informational headers.
- Added purple 26 px information icons to settings section headers.
- Moved general section explanations into header tooltips and kept field-specific help on each field.
- Removed the permanent Execute HUD description paragraph without changing execute behavior.
- Updated English and Spanish public documentation for the settings presentation standard.

## 0.1.46 - Public Beta Preparation

- Prepared the repository for public beta publication on GitHub.
- Added public English and Spanish READMEs, changelog, MIT license, stricter ignore rules, and line-ending policy.
- Kept `AGENTS.md` local-only by removing it from Git tracking and adding it to `.gitignore`.
- Added resource warning thresholds for Health, Magicka, and Stamina text.
- Moved debug options into a dedicated settings section.
- Improved execute threshold handling for known execute abilities and tooltip-derived thresholds.
- Improved Arcanist Crux HUD layout and hid it on non-Arcanist characters.

## 0.1.41 and earlier

- Initial EZOhud beta development.
- Added localized settings, HUD bars, ultimate indicators, execute indicator, Crux indicator, and debug support.
