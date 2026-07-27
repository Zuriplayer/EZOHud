# Changelog

## 0.1.130 - Custom Action Bars Settings Enable Refresh

- Fixed Custom Action Bars dependent settings remaining visually disabled after enabling the section, including the EZOCore-hosted Settings > EZO panel.
- Hardened similar dependent settings in Custom Quest Tracker, Custom Group Search, Custom Synergy, and Custom Loot so their disabled state is recalculated from current SavedVariables.

## 0.1.129 - Larger Attribute Size Range

- Raised the Attribute HUD Health, Magicka, and Stamina size slider maximum from 500 to 750.

## 0.1.128 - Smaller Gamepad Action Labels

- Reduced the Custom Action Bars key-label scale when gamepad labels are shown, including Auto mode while ESO is in gamepad-preferred mode.

## 0.1.127 - Larger Crux Defaults

- Raised the default Crux HUD size to 140 px and the default Crux bar spacing to 25 px.
- Migrates saved Crux settings that still used the previous exact defaults so existing default-profile users see the larger indicator after updating.

## 0.1.126 - Custom Action Bar Active Timer Visibility

- Keeps custom action-bar ability slots at full opacity while they have an active native timer, even when the slot belongs to the inactive bar.
- Preserves inactive weapon-icon hiding so only the active weapon icon remains visible.

## 0.1.125 - Custom Quickslot Cooldown Fill

- Added a vertical cooldown refill to the independent Custom Action Bars quickslot icon using ESO's native quickslot cooldown data.
- Shows remaining quickslot cooldown time on the icon and restores the item count once the cooldown is ready.

## 0.1.124 - Custom Action Bar Vertical Feedback

- Reordered vertical Custom Action Bars so ability slots are inverted for gamepad-style reading while ultimate stays at the bottom.
- Added a visual flash on used custom action slots using ESO's native action-slot ability-used event.
- Added a configurable proportional timer-warning threshold that changes low remaining custom action-bar timers to a soft warning tint.

## 0.1.123 - Settings Host Refresh Coverage

- Applied the shared settings-panel refresh to the remaining LAM master enable toggles, including Custom Quest Tracker, Custom Group Search, Custom Synergy, Custom Loot, native widget positioning, Attribute HUD, Ultimate HUD, Execute HUD and Crux HUD.
- Fixed dependent controls staying disabled after first enabling sections in the EZOCore-hosted Settings > EZO panel.

## 0.1.122 - Custom Action Bars Settings Refresh

- Added a shared settings-panel refresh helper that uses EZOCore's active settings host when present and LibAddonMenu refresh when running standalone.
- Fixed the Custom Action Bars master toggle so dependent settings become available immediately after the first enable in both Settings > EZO and the standalone LAM panel.

## 0.1.121 - Custom Action Bar Native Toggle and Quickslot

- Added a Custom Action Bars option to hide ESO's native action bar while the custom bars are enabled and visible.
- Added an independent movable active quickslot icon that scales with the Custom Action Bars icon size and shows item counts when ESO exposes them.
- Hid the inactive custom weapon icon while preserving the active weapon icon and its purple active-frame treatment.

## 0.1.120 - Custom Action Bar Movement and Timer Controls

- Scaled Custom Action Bars key labels with the configured icon size and re-registered native key labels after icon-size changes.
- Added a shared Custom Action Bars timer-bar color picker.
- Fixed Custom Action Bars drag mode so timer refreshes no longer interrupt active dragging.

## 0.1.119 - Custom Action Bar Readability Controls

- Raised the Custom Action Bars icon-size limit to 96 px and enlarged the timer text and bottom timer bar.
- Added a Custom Action Bars key-label selector for off, automatic, keyboard, or gamepad native action-button labels.
- Added current/cost ultimate text on the custom ultimate slot and dims that slot while the ultimate is not ready.

## 0.1.118 - Custom Action Bar Slot Active Detection

- Added active-bar detection by comparing the current active action slots against the main and backup custom bars before falling back to ESO's native active hotbar and weapon-pair state.

## 0.1.117 - Native Custom Action Bar Active State Hotfix

- Fixed Custom Action Bars active-bar highlighting by using ESO's active weapon-pair state before falling back to active hotbar category checks.
- Added active-slot native timer fallbacks so the active custom bar can read ESO's current action-slot effect data even when the explicit primary/backup category does not report it.

## 0.1.116 - Native Custom Action Bar Timers

- Changed Custom Action Bars effect timers to use ESO's native action-slot effect APIs instead of scanning player and reticle-over buffs by matching abilityId.
- Added native action-slot stack-count display when ESO exposes stacks for a custom action-bar slot.
- Updated Custom Action Bars settings text and documentation to describe the native slot-timer source and its blank-slot limitation.

## 0.1.115 - Custom Action Bar Timer Startup Fix

- Fixed Custom Action Bars startup after adding effect timers by avoiding a local layout-orientation constant shadowing ESO's native status-bar orientation constant.

## 0.1.114 - Custom Action Bar Effect Timers

- Added an optional Custom Action Bars effect-timer overlay that shows remaining time only when ESO exposes an active player or reticle-over effect with the same abilityId as the slot.
- Added a `Show effect timers` LAM control and kept unmatched effects blank instead of guessing duration associations.

## 0.1.113 - Custom Action Bar Weapon Icons

- Added generic Custom Action Bar weapon-category icons for sword and shield, dual wield, two-handed, bow, destruction staff, restoration staff, one-hand fallback, and unknown weapons.
- Changed the Custom Action Bars weapon slot to classify equipped main/off-hand weapon types instead of showing the exact equipped item icon.

## 0.1.112 - Custom Action Bars LAM Refresh

- Refreshes dependent Custom Action Bars settings immediately after toggling `Enable custom action bars`, so display, movement, sizing, alpha, and dimmed-slot controls become available without `/reloadui`.

## 0.1.111 - Custom Action Bars Phase One

- Added disabled-by-default Custom Action Bars that show movable visual copies of the main and backup ability bars without replacing ESO's native action bar.
- Added LAM controls for displayed bars, horizontal or vertical orientation, icon size, spacing, inactive-bar alpha, dimmed-slot alpha, and globally remembered dimmed logical slots.
- Registered independent EZOCore layout surfaces for the main and backup custom action bars.

## 0.1.110 - Custom Loot Visibility Refresh

- Reapplies native loot-history hiding from the Custom Loot visibility refresh path so LAM toggles and scene changes keep native loot panels in sync.
- Synchronized version metadata that was partially updated in the initial 0.1.110 commit.

## 0.1.109 - Quest Tracker Combat Visibility

- Added a Custom Quest Tracker setting to hide the custom focused-quest panel while the player is in combat.
- Kept movement mode able to show the panel temporarily so placement remains possible.

## 0.1.108 - Bilingual Text Fallbacks

- Localized the language selector choices instead of hardcoding visible language labels in the settings panel.
- Added English and Spanish fallback labels for Custom Group Search category text when ESO does not expose a native Activity Finder string.
- Refreshed EZOFamilyTools announcement metadata for the current EZOhud version with bilingual EN/ES copy.

## 0.1.107 - Quest Tracker Tooltip Layering

- Raised the Custom Quest Tracker hover tooltip above the custom tracker text so quest details remain readable when they overlap.
- Split optional quest hints into separate right-aligned one-line labels so the hint block keeps native-style right alignment.

## 0.1.106 - Group Search Instance Label Cleanup

- Changed Custom Group Search to show queued Activity Finder requests as `Selection` instead of presenting them as the final destination instance.
- Added guarded final/current LFG activity detection so the panel only labels an activity as `Instance` when ESO exposes a concrete activity id, otherwise it leaves the instance pending.
- Relabeled dungeon role counts as visible group composition because the addon can only count roles exposed through the current group and local LFG role API.

## 0.1.105 - Group Search Role Composition

- Changed Custom Group Search to show separate search-duration and role-composition lines instead of only the player's selected role.
- Added role-count refreshes for group joins, leaves, updates, and role changes so dungeon queue composition can show missing `T`, `H`, or `DD` slots.

## 0.1.104 - Custom Quest Tracker Tooltip

- Added a hover tooltip to the Custom Quest Tracker with focused quest title, level/repeatable metadata when available, long quest text, and current visible tasks.
- Kept the tooltip disabled while moving the custom quest tracker so drag behavior remains unchanged.

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
