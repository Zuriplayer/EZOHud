# Changelog

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
