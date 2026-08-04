# EZOhud

Prefer Spanish? Read the [Spanish README](README.es.md).
EZOhud is a beta HUD addon for The Elder Scrolls Online in the EZO addon family. Its current purpose is to provide configurable, visual HUD indicators for player resources, ultimate readiness, custom action bars, execute opportunities, Arcanist Crux tracking, limited native widget positioning tweaks, custom quest tracking, custom synergy, custom group-search status, a custom companion frame, and custom loot history while keeping the implementation small and testable.

Support, bug reports, and suggestions: <https://discord.gg/ekw8zUAcRm>

## Beta Status

EZOhud is public beta quality. The addon is usable for testing, but layout, visuals, options, and indicator behavior may still change. It should not be treated as a finished replacement for mature HUD suites.

## Version Metadata

- Addon version: `0.1.146`
- AddOnVersion: `10146`
- APIVersion: `101049 101050`
- Status: public beta

## Requirements

- The Elder Scrolls Online.
- `LibAddonMenu-2.0` is required for the settings panel.
- `LibChatMessage` is optional and used for cleaner addon chat messages when available.
- `LibDebugLogger` is optional and used by the debug options when available.
- `EZOCore` is optional and provides the central `Settings > EZO` panel, shared EZO-family language preference and global or per-surface interface layout mode when installed.

## Installation

1. Download or clone this repository.
2. Place the `EZOhud` folder in your ESO AddOns directory:
   `Documents/Elder Scrolls Online/live/AddOns/EZOhud`
3. Enable `EZOhud` from the ESO AddOns screen.
4. With EZOCore installed, open Settings > EZO > EZOhud. Without EZOCore, use Settings > Addons > EZOhud.

## Implemented Features

- Attribute HUD for Health, Magicka, and Stamina.
- Automatic hiding of the default ESO player attribute bars when the custom Attribute HUD is enabled, with a manual toggle still available.
- Attribute HUD movement mode that lets the three resource bars move as a group.
- Attribute HUD layout selector with the classic split model and a tighter left-aligned vertical stack for Health, Stamina, and Magicka.
- Resource bar width settings for Health, Magicka, and Stamina, with a maximum size of 750.
- Optional equal-size lock for both Attribute HUD layouts. It gives all three bars the same exact maximum width regardless of resource maximums, and changing any Size slider updates the other two immediately.
- Resource color pickers constrained to each resource color family.
- Per-resource warning thresholds that change the resource numbers and consumed background to a soft alarm tint.
- Optional Health-state overlays integrated into the Health bar. They use ESO's native attribute-visual data for damage shields, trauma, and blocked healing instead of inferring states from ability names or IDs; a five-second LAM preview verifies all three layers without requiring an active combat state.
- Out-of-combat alpha for the custom attribute HUD.
- Resource bar scaling based on each resource maximum, so the dominant maximum resource can appear larger when the equal-size lock is disabled.
- Ultimate HUD indicators for main and backup ultimate slots.
- Ultimate display modes: main, backup, both, or inactive bar only.
- Movable ultimate indicators, with main and backup positions handled independently.
- Ultimate icon size setting, progress bar, current ultimate value, cost, readiness, and active-bar state.
- Custom Action Bars that show the main and backup ability bars as one movable two-row block, with an optional toggle to hide ESO's native HUD action bar only while a normal primary or backup weapon bar is active. Temporary and mechanic-specific native action bars remain visible.
- Custom Action Bars display modes: off, main, backup, both, or active bar only.
- Parallel horizontal Custom Action Bars with generic weapon-category icons, inactive weapon-icon hiding, optional hiding of backup-row abilities when that row is inactive and both their native effect time and stack count reach zero, slot-use flash animation, larger centered white native effect timers with a bold thick-outline font, enlarged orange upper-right stack counts, a configurable proportional timer-warning threshold, one optional scalable set of native key labels below the lowest visible row, configurable shared timer-bar color, icon size up to 96 px, spacing, inactive-bar alpha, dimmed-slot alpha, a smaller independently centered ultimate readiness percentage with `%` plus current/cost below, not-ready dimming, an optional active-ultimate mode that replaces its not-ready icon and both text rows with a purple charge bar, and saved global dimming choices for weapon, ability 1-5, and ultimate slots. The main row always remains complete, while timed backup abilities remain visible until their native effect ends.
- Independent active quickslot icon for Custom Action Bars, movable separately and scaled from the same icon-size setting. When ESO reports a quickslot cooldown, the icon dims, refills vertically as the cooldown completes, and shows remaining time instead of the item count until ready.
- Execute HUD that scans slotted execute abilities on the active bar and shows an alert when the current target is inside the detected threshold.
- Execute thresholds for known execute abilities, with additional tooltip-based threshold detection when available.
- Movable execute alert and execute alert size setting.
- Arcanist Crux HUD with stack count, remaining duration bar, timer text, 140 px default size, 25 px default bar spacing, size setting, and bar spacing setting.
- Crux HUD visibility limited to Arcanist characters.
- Optional hiding of the Crux HUD when no Crux stacks are active.
- Experimental native widget positioning for center screen announcements, active combat tips, and the complete death and resurrection prompt with apply-position, a temporary three-second green preview, an optional one-at-a-time move-handle checkbox, X/Y offset, scale, and reset controls. The death prompt is enabled by default above the default Custom Action Bars position.
- Custom Quest Tracker that can hide ESO's native focused quest tracker on the HUD and show a movable, scalable native-style panel with the focused quest, current objective, right-aligned optional hints, optional combat hiding, ESO's native Cycle Focused Quest keybind display, and a full quest-detail tooltip on mouse hover.
- Custom Synergy UI that hides ESO's native synergy prompt and uses an independent movable overlay.
- Custom Group Search label that hides ESO's native on-screen Activity Finder status tracker, keeps a compact native-style category/status format, and adds smaller left-aligned selected-activity or instance, search-duration, and visible group-role lines.
- Custom Companion Frame for the local active companion with name, a native-inspired health bar, optional numeric health formats, solo/group visibility modes, saved movement, scale, width, opacity, and optional hiding of ESO's local solo companion frame without changing native group or raid companion rows.
- Custom Loot History module that fully replaces the native game's loot UI with a modern, right-aligned scrolling panel with memory, bottom-hover review, scrolling, and adjustable fade.
- HUD-scene visibility handling so visual controls are intended for the normal HUD and HUD UI scenes, not menus.
- Custom Action Bars, Custom Loot History, custom Quest Tracker, custom Group Search, Custom Companion Frame, and custom Synergy windows are restricted to HUD scenes so native menu panels remain accessible.
- English and Spanish localization with shared EZOCore, Automatic, English, and Spanish language selection, including localized fallback labels for custom HUD text when ESO does not expose a native string.
- Debug options in a dedicated settings section, with optional LibDebugLogger output and optional chat output.
- Local `/ezohudcrux` debug command for focused Crux diagnostics.
- Settings reset through the LibAddonMenu defaults mechanism.
- Native `Settings > EZO` integration through EZOCore, with the standard LibAddonMenu panel retained as a standalone fallback.

## Main Settings

EZOhud follows the EZO-family settings style: every settings section uses a purple 26 px information icon in its heading. Hover the heading for the general purpose and scope of that section, and hover each individual field for field-specific help.

When EZOCore is active, the complete panel is rendered inside `Settings > EZO` and is not duplicated in the standard Addons settings list. Attribute, Ultimate, Custom Action Bars, Execute, Crux, custom Quest Tracker, custom Synergy, custom Group Search, Custom Companion Frame, custom Loot History, and Native UI Tweaks surfaces are registered independently in the shared interface layout mode. Without EZOCore, the same options and temporary local movement controls remain available through the normal LibAddonMenu panel.

Master enable controls defer their settings refresh until the current LAM callback finishes. In the EZOCore-hosted panel this requests a forced rebuild, so dependent controls immediately recalculate their enabled state instead of remaining visually greyed out.

With EZOCore active, EZOhud follows the EZO family preference storage policy: ordinary HUD settings use the selected account-wide or per-character scope. When the scope is per character, the first load copies existing account-wide EZOhud settings into that character profile. Without EZOCore, EZOhud keeps its historical account-wide storage.

- General: inherit the shared EZOCore language or select Automatic, English, or Spanish locally.
- Attribute HUD: enable custom bars, automatically hide vanilla bars when enabling the HUD, choose the bar layout, optionally lock all three bars to the same Size and exact maximum width, integrate native shield/trauma/blocked-healing states into Health, enable HUD movement, set out-of-combat alpha, and adjust per-resource size up to 750, color, and warning threshold.
- Ultimate HUD: enable indicators, enable movement, choose displayed bar slots, and set icon size.
- Custom Action Bars: enable visual copies of ability bars, optionally hide ESO's native HUD action bar only for normal primary/backup weapon bars while keeping temporary or mechanic-specific native bars visible, choose visible rows, move the paired action-bar block and active quickslot indicator independently, adjust icon size/spacing/alpha, optionally hide backup-row abilities when that row is inactive and their native effect time and stacks are both zero while keeping the main row complete, toggle larger bold outlined native action-slot effect timers and orange upper-right stack counts, replace the active ultimate icon and values with a charge bar until it reaches 100%, choose the shared timer-bar color and proportional warning threshold, choose key labels off/auto/keyboard/gamepad below only the lowest visible row, and choose globally dimmed logical slots. Ultimate otherwise shows a centered percentage with `%` and a smaller current/cost reading underneath; the active quickslot icon mirrors ESO's cooldown data with a vertical refill and remaining-time label.
- Execute HUD: enable alert, enable movement, and set alert size.
- Crux HUD: enable indicator, enable movement, hide without Crux, set indicator size, and adjust bar spacing.
- Native UI Tweaks: apply custom positioning for ESO's native center screen announcements, active combat tips (Break Free, Interrupt, Dodge), and complete death and resurrection prompt. The death prompt keeps ESO's resurrection requests, revive or release choices, countdowns, and death recap above the default Custom Action Bars position. Applying or changing a position shows its green preview for three seconds; enable the move-handle checkbox to keep one handle visible until it is turned off. The same move modes are available through EZOCore's shared layout controls. Tune X/Y offsets, adjust scale, and reset the values. Turning off a custom-position toggle restores that native element's original runtime anchor.
- Custom Quest Tracker: enable the custom focused-quest panel, choose whether it hides in combat, allow movement, adjust scale, and choose whether optional hints are shown. The panel mirrors ESO's focused quest, shows hints as separate right-aligned lines, raises the full quest-detail tooltip above the tracker on mouse hover, and leaves keyboard/gamepad quest cycling on the native `ASSIST_NEXT_TRACKED_QUEST` binding.
- Custom Synergy UI: enable the custom synergy prompt, allow movement, and adjust scale.
- Custom Group Search: enable the custom Activity Finder status label, allow movement, and adjust scale. The label replaces only the small HUD status tracker, not the full finder window, and shows left-aligned selected-activity or current-instance, search-duration, and visible group-role lines. While queued it labels the requested activity as `Selection`; it labels a final/current activity as `Instance` only when ESO exposes that LFG activity id, otherwise it keeps the instance pending instead of reusing a potentially misleading queue request. For role-based dungeon searches it reports visible group composition as `T 0/1 H 1/1 DD 1/2` so missing roles are visible without claiming to know hidden matchmaking roles.
- Custom Companion Frame: enable a custom frame for the local active companion, optionally hide ESO's local solo companion frame, choose solo/group visibility, move the frame, select hidden/percent/current-maximum/both health values, and adjust scale, width, and opacity. Group and raid companion rows remain native and unchanged.
- Custom Loot History: enable the custom loot panel, allow movement, and adjust scale and the time loot remains visible before fading.
- Debug: enable debug logging and optionally mirror debug output to chat.

## Safety Limits

- EZOhud is visual only.
- It does not cast abilities, press keys, automate rotations, block, dodge, interrupt, target enemies, or make gameplay decisions.
- Execute, ultimate, custom action bar, resource, and Crux indicators are informational only.
- Native UI tweaks only reanchor and scale ESO's native elements; they do not replace the elements or alter their core behavior.
- Custom Quest Tracker is informational only. It can hide the native focused quest tracker while enabled and show journal-style details in a hover tooltip, but it does not add keybinds, abandon, share, select, cycle, or automate quest actions; ESO's own Cycle Focused Quest keybind remains responsible for changing the focused mission.
- Custom Action Bars are informational only. When requested, they can hide ESO's native HUD action bar visually for normal primary/backup weapon bars; temporary and mechanic-specific native bars remain visible. They do not cast abilities, change weapons, use quickslot items, trigger keybinds, or automate rotations. Effect timers, stack counts, backup-slot visibility, ultimate percentage/current-cost values or charge bar, and quickslot cooldowns follow only the native slot data exposed by ESO; slots without native timer data remain blank. Key labels are display-only and follow ESO's current bindings when enabled.
- Custom Group Search is informational only. It can hide the native on-screen Activity Finder tracker while enabled, but it does not join, leave, accept, decline, or automate group-finder actions. Instance and role details are limited to the Activity Finder and group-role data exposed by ESO's UI API.
- Custom Companion Frame is informational only and follows the local player's active companion. Its native-hide option affects only ESO's local solo companion frame; it does not hide or replace companion rows in native group or raid frames.
- Custom Action Bars, Custom Loot History, custom Quest Tracker, custom Group Search, Custom Companion Frame, and custom Synergy surfaces are hidden outside normal HUD scenes, and Custom Loot only captures the mouse while its move mode is active.
- Move modes are temporary UI positioning helpers and reset on `/reloadui` or logout; saved HUD positions remain persisted.
- EZOhud does not add keybinds or input handling and is intended to remain compatible with keyboard and gamepad play.
- Debug tools are diagnostics only and should remain disabled during normal play unless troubleshooting.

## Testing Notes

Recommended beta checks:

- Test on Arcanist and non-Arcanist characters to confirm Crux HUD visibility is correct.
- Test normal HUD, HUD UI, menus, champion points, Tales of Tribute, and other non-HUD scenes.
- Test native configuration panels such as Skills and Settings while Custom Loot History is enabled to confirm HUD-only panels do not block them.
- Test Custom Quest Tracker with several tracked quests, `T` / Cycle Focused Quest on keyboard, and the matching gamepad button to confirm the custom panel follows the native focused quest without breaking cycling. Hover the custom panel in HUD UI to confirm the tooltip draws above the tracker and shows the title, level/repeatable metadata when available, quest text, and current tasks. Confirm optional hints remain right-aligned when one or two hint lines are visible.
- Test Custom Group Search while queued for a dungeon or other Activity Finder activity, during ready check, and after queue completion to confirm the native tracker hides, the native-style category/status text updates, the selected activity is not mislabeled as the final instance, final/current instance data appears only when ESO exposes it, the left-aligned search-duration and visible group-role lines display, role counts update when group members or roles change, the label can be dragged in move mode, and it disappears outside HUD scenes.
- Test Custom Companion Frame with an active companion while solo, after joining and leaving a group, after dismissing or changing the companion, after companion death/revival, and after `/reloadui`. Confirm health updates immediately, every numeric format fits, movement/scale/width/opacity persist, the frame disappears outside HUD scenes, the native solo frame is restored when requested, and native group/raid companion rows are never hidden.
- Test combat and out-of-combat alpha behavior.
- Test that enabling the EZOhud Attribute HUD automatically hides vanilla ESO bars, and that the manual vanilla-bar toggle still applies afterward.
- Test Health-state overlays with an active damage shield, a trauma mechanic, and blocked healing. Confirm soft blue, violet, and dark-red states update immediately, survive `/reloadui` when the native state remains active, remain inside the Health bar in both layouts, and disappear when the corresponding state ends or the option is disabled.
- Test the equal attribute-size lock in both layouts with different Health, Magicka, and Stamina maximums. Confirm all three bases keep the same width, their fills still show each resource percentage, and changing any Size slider immediately updates the other two in both Settings > EZO and the standalone LAM panel without requiring `/reloadui`.
- Test each ultimate display mode and active/inactive bar state.
- Test Custom Action Bars with main, backup, both, and active-only modes. Confirm the master enable toggle immediately enables dependent settings in both Settings > EZO and the standalone LAM panel without leaving them visually greyed out; both rows stay parallel and move together as one block; weapon icons update after weapon swap; only the active weapon icon remains visible with the purple frame; active-row highlighting follows bar swaps; used slots flash when activated; dimmed slot choices apply to both rows except when a native timer is currently active; native timers use larger centered white bold thick-outline numbers and remain readable at the default 42 px icon size; enlarged stack counts appear in orange at the upper-right; enabling backup-at-zero hiding removes only backup ability slots 1-5 while that row is inactive and both native remaining time and stacks are zero, while the main row always remains complete; the shared timer-bar color and warning threshold apply; key-label Off keeps the compact layout while Auto/Keyboard/Gamepad show one label set below the backup row when both rows are visible, or below the single visible row in the other display modes; the active quickslot icon still moves independently, shows item count when ready, switches to remaining time during potion/drink cooldown, and refills vertically; ultimate normally shows a smaller independently centered bold outlined readiness percentage with `%` and a smaller current/cost reading underneath; enabling the active-ultimate 100% option replaces the not-ready active icon and both text rows with a purple charge bar, restores them at 100%, and leaves the inactive row unchanged; the native action bar hides/restores with its toggle for normal primary/backup bars; and entering a temporary or mechanic-specific hotbar restores the native bar until a normal weapon bar becomes active again.
- Test execute alert behavior with known execute abilities on the active bar.
- Test shared EZOCore, English, Spanish, and Automatic language modes.
- Test the `Settings > EZO` route with EZOCore and the standard Addons fallback without it. Toggle each master enable setting from off to on and confirm dependent controls immediately become available without closing or reopening the panel.
- Test different resolutions and UI scale values.
- Test `/reloadui` after moving HUD elements.
- Test native widget positioning with keyboard and gamepad UI for center screen announcements, active combat tips, and the complete death and resurrection prompt. Confirm that applying a position shows a green preview for roughly three seconds, and that Enable move handle and EZOCore's shared layout controls keep only the selected handle visible. With Custom Action Bars enabled, die and accept a group resurrection request; confirm the prompt stays above the bars, its native buttons work, and disabling custom positioning restores the default anchor.

When reporting layout or behavior issues, include the addon version, ESO API version, character class, language mode, active settings, and a screenshot.

## Repository Notes

- `AGENTS.md` is intentionally ignored and kept local for development-agent instructions.
- No ZIP, release artifact, or Discord announcement is generated by this repository setup.

## License

EZOhud is released under the [MIT License](LICENSE).
