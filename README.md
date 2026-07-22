# EZOhud

Prefer Spanish? Read the [Spanish README](README.es.md).
EZOhud is a beta HUD addon for The Elder Scrolls Online in the EZO addon family. Its current purpose is to provide configurable, visual HUD indicators for player resources, ultimate readiness, execute opportunities, Arcanist Crux tracking, limited native widget positioning tweaks, custom synergy, custom group-search status, and custom loot history while keeping the implementation small and testable.

Support, bug reports, and suggestions: <https://discord.gg/ekw8zUAcRm>

## Beta Status

EZOhud is public beta quality. The addon is usable for testing, but layout, visuals, options, and indicator behavior may still change. It should not be treated as a finished replacement for mature HUD suites.

## Version Metadata

- Addon version: `0.1.97`
- AddOnVersion: `10097`
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
- Resource bar width settings for Health, Magicka, and Stamina.
- Resource color pickers constrained to each resource color family.
- Per-resource warning thresholds that change the resource numbers and consumed background to a soft alarm tint.
- Out-of-combat alpha for the custom attribute HUD.
- Resource bar scaling based on each resource maximum, so the dominant maximum resource can appear larger.
- Ultimate HUD indicators for main and backup ultimate slots.
- Ultimate display modes: main, backup, both, or inactive bar only.
- Movable ultimate indicators, with main and backup positions handled independently.
- Ultimate icon size setting, progress bar, current ultimate value, cost, readiness, and active-bar state.
- Execute HUD that scans slotted execute abilities on the active bar and shows an alert when the current target is inside the detected threshold.
- Execute thresholds for known execute abilities, with additional tooltip-based threshold detection when available.
- Movable execute alert and execute alert size setting.
- Arcanist Crux HUD with stack count, remaining duration bar, timer text, size setting, and bar spacing setting.
- Crux HUD visibility limited to Arcanist characters.
- Optional hiding of the Crux HUD when no Crux stacks are active.
- Experimental native widget positioning for the focused quest tracker, center screen announcements, Activity Finder group-search status indicator, and active combat tips with apply-position, one-at-a-time move handle, X/Y offset, scale, and reset controls.
- Custom Synergy UI that hides ESO's native synergy prompt and uses an independent movable overlay.
- Custom Group Search label that hides ESO's native on-screen Activity Finder status tracker and keeps a compact native-style two-line format with scaling.
- Custom Loot History module that fully replaces the native game's loot UI with a modern, right-aligned scrolling panel with memory, bottom-hover review, scrolling, and adjustable fade.
- HUD-scene visibility handling so visual controls are intended for the normal HUD and HUD UI scenes, not menus.
- Custom Loot History, custom Group Search, and custom Synergy windows are restricted to HUD scenes so native menu panels remain accessible.
- English and Spanish localization with shared EZOCore, Automatic, English, and Spanish language selection.
- Debug options in a dedicated settings section, with optional LibDebugLogger output and optional chat output.
- Local `/ezohudcrux` debug command for focused Crux diagnostics.
- Settings reset through the LibAddonMenu defaults mechanism.
- Native `Settings > EZO` integration through EZOCore, with the standard LibAddonMenu panel retained as a standalone fallback.

## Main Settings

EZOhud follows the EZO-family settings style: every settings section uses a purple 26 px information icon in its heading. Hover the heading for the general purpose and scope of that section, and hover each individual field for field-specific help.

When EZOCore is active, the complete panel is rendered inside `Settings > EZO` and is not duplicated in the standard Addons settings list. Attribute, Ultimate, Execute, Crux, custom Synergy, custom Group Search, and custom Loot History surfaces are registered independently in the shared interface layout mode. Without EZOCore, the same options and temporary local movement controls remain available through the normal LibAddonMenu panel. Native UI Tweaks are settings-driven only and are not shared layout-mode surfaces.

With EZOCore active, EZOhud follows the EZO family preference storage policy: ordinary HUD settings use the selected account-wide or per-character scope. When the scope is per character, the first load copies existing account-wide EZOhud settings into that character profile. Without EZOCore, EZOhud keeps its historical account-wide storage.

- General: inherit the shared EZOCore language or select Automatic, English, or Spanish locally.
- Attribute HUD: enable custom bars, automatically hide vanilla bars when enabling the HUD, choose the bar layout, enable HUD movement, set out-of-combat alpha, and adjust per-resource size, color, and warning threshold.
- Ultimate HUD: enable indicators, enable movement, choose displayed bar slots, and set icon size.
- Execute HUD: enable alert, enable movement, and set alert size.
- Crux HUD: enable indicator, enable movement, hide without Crux, set indicator size, and adjust bar spacing.
- Native UI Tweaks: apply custom positioning for ESO's native focused quest tracker, center screen announcements, Activity Finder group-search status indicator, and active combat tips (Break Free, Interrupt, Dodge). Tune X/Y offsets, adjust scale, show one green drag handle at a time, and reset the values. Turning off a custom-position toggle restores that native element's original runtime anchor.
- Custom Synergy UI: enable the custom synergy prompt, allow movement, and adjust scale.
- Custom Group Search: enable the custom Activity Finder status label, allow movement, and adjust scale. The label replaces only the small HUD status tracker, not the full finder window.
- Custom Loot History: enable the custom loot panel, allow movement, and adjust scale and the time loot remains visible before fading.
- Debug: enable debug logging and optionally mirror debug output to chat.

## Safety Limits

- EZOhud is visual only.
- It does not cast abilities, press keys, automate rotations, block, dodge, interrupt, target enemies, or make gameplay decisions.
- Execute, ultimate, resource, and Crux indicators are informational only.
- Native UI tweaks only reanchor and scale ESO's native elements; they do not replace the elements or alter their core behavior, and group-search indicator positioning does not open the finder panel or queue, accept, or automate activity finder actions.
- Custom Group Search is informational only. It can hide the native on-screen Activity Finder tracker while enabled, but it does not join, leave, accept, decline, or automate group-finder actions.
- Custom Loot History, custom Group Search, and custom Synergy surfaces are hidden outside normal HUD scenes, and Custom Loot only captures the mouse while its move mode is active.
- Move modes are temporary UI positioning helpers and reset on `/reloadui` or logout; saved HUD positions remain persisted.
- EZOhud does not add keybinds or input handling and is intended to remain compatible with keyboard and gamepad play.
- Debug tools are diagnostics only and should remain disabled during normal play unless troubleshooting.

## Testing Notes

Recommended beta checks:

- Test on Arcanist and non-Arcanist characters to confirm Crux HUD visibility is correct.
- Test normal HUD, HUD UI, menus, champion points, Tales of Tribute, and other non-HUD scenes.
- Test native configuration panels such as Skills and Settings while Custom Loot History is enabled to confirm HUD-only panels do not block them.
- Test Custom Group Search while queued for a dungeon or other Activity Finder activity, during ready check, and after queue completion to confirm the native tracker hides, the native-style category/status text updates, the label can be dragged in move mode, and it disappears outside HUD scenes.
- Test combat and out-of-combat alpha behavior.
- Test that enabling the EZOhud Attribute HUD automatically hides vanilla ESO bars, and that the manual vanilla-bar toggle still applies afterward.
- Test each ultimate display mode and active/inactive bar state.
- Test execute alert behavior with known execute abilities on the active bar.
- Test shared EZOCore, English, Spanish, and Automatic language modes.
- Test the `Settings > EZO` route with EZOCore and the standard Addons fallback without it.
- Test different resolutions and UI scale values.
- Test `/reloadui` after moving HUD elements.
- Test native widget positioning with keyboard and gamepad UI for all customized elements.

When reporting layout or behavior issues, include the addon version, ESO API version, character class, language mode, active settings, and a screenshot.

## Repository Notes

- `AGENTS.md` is intentionally ignored and kept local for development-agent instructions.
- No ZIP, release artifact, or Discord announcement is generated by this repository setup.

## License

EZOhud is released under the [MIT License](LICENSE).
