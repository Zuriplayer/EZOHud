# EZOhud

Prefer Spanish? Read the [Spanish README](README.es.md).

EZOhud is a beta HUD addon for The Elder Scrolls Online in the EZO addon family. Its current purpose is to provide configurable, visual HUD indicators for player resources, ultimate readiness, execute opportunities, and Arcanist Crux tracking while keeping the implementation small and testable.

Support, bug reports, and suggestions: <https://discord.gg/ekw8zUAcRm>

## Beta Status

EZOhud is public beta quality. The addon is usable for testing, but layout, visuals, options, and indicator behavior may still change. It should not be treated as a finished replacement for mature HUD suites.

## Requirements

- The Elder Scrolls Online.
- `LibAddonMenu-2.0` is required for the settings panel.
- `LibChatMessage` is optional and used for cleaner addon chat messages when available.
- `LibDebugLogger` is optional and used by the debug options when available.

## Installation

1. Download or clone this repository.
2. Place the `EZOhud` folder in your ESO AddOns directory:
   `Documents/Elder Scrolls Online/live/AddOns/EZOhud`
3. Enable `EZOhud` from the ESO AddOns screen.
4. Open Settings > Addons > EZOhud to configure the addon.

## Implemented Features

- Attribute HUD for Health, Magicka, and Stamina.
- Optional hiding of the default ESO player attribute bars.
- Attribute HUD movement mode that lets the three resource bars move as a group.
- Resource bar width settings for Health, Magicka, and Stamina.
- Resource color pickers constrained to each resource color family.
- Per-resource warning thresholds that change only the resource numbers to an alarm color.
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
- HUD-scene visibility handling so visual controls are intended for the normal HUD and HUD UI scenes, not menus.
- English and Spanish localization with Automatic, English, and Spanish language selection.
- Debug options in a dedicated settings section, with optional LibDebugLogger output and optional chat output.
- Local `/ezohudcrux` debug command for focused Crux diagnostics.
- Settings reset through the LibAddonMenu defaults mechanism.

## Main Settings

- General: language selection.
- Attribute HUD: enable custom bars, hide vanilla bars, enable HUD movement, out-of-combat alpha, and per-resource size, color, and warning threshold.
- Ultimate HUD: enable indicators, enable movement, choose displayed bar slots, and set icon size.
- Execute HUD: enable alert, enable movement, and set alert size.
- Crux HUD: enable indicator, enable movement, hide without Crux, set indicator size, and adjust bar spacing.
- Debug: enable debug logging and optionally mirror debug output to chat.

## Safety Limits

- EZOhud is visual only.
- It does not cast abilities, press keys, automate rotations, block, dodge, interrupt, target enemies, or make gameplay decisions.
- Execute, ultimate, resource, and Crux indicators are informational only.
- Move modes are temporary UI positioning helpers and reset on `/reloadui` or logout.
- EZOhud does not add keybinds or input handling and is intended to remain compatible with keyboard and gamepad play.
- Debug tools are diagnostics only and should remain disabled during normal play unless troubleshooting.

## Testing Notes

Recommended beta checks:

- Test on Arcanist and non-Arcanist characters to confirm Crux HUD visibility is correct.
- Test normal HUD, HUD UI, menus, champion points, Tales of Tribute, and other non-HUD scenes.
- Test combat and out-of-combat alpha behavior.
- Test hiding EZOhud attribute bars independently from hiding vanilla ESO bars.
- Test each ultimate display mode and active/inactive bar state.
- Test execute alert behavior with known execute abilities on the active bar.
- Test English, Spanish, and Automatic language modes.
- Test different resolutions and UI scale values.
- Test `/reloadui` after moving HUD elements.

When reporting layout or behavior issues, include the addon version, ESO API version, character class, language mode, active settings, and a screenshot.

## Repository Notes

- `AGENTS.md` is intentionally ignored and kept local for development-agent instructions.
- No ZIP, release artifact, or Discord announcement is generated by this repository setup.

## License

EZOhud is released under the [MIT License](LICENSE).
