---
name: cosmoteer-mod-workflow
description: Compatibility shim for older SWACD Cosmoteer workflow prompts. Use when a request broadly asks for SWACD modding workflow help and route it to the newer layered skills: `cosmoteer-vanilla-reference`, `swacd-architecture`, `swacd-maintenance-governance`, and the relevant `swacd-*` subsystem skill.
---

# Cosmoteer Mod Workflow

## Objective

Act as a thin router for legacy prompts and redirect work to the newer layered SWACD skill system.

## Routing Workflow

1. Start with `swacd-architecture` to map the repo area and cross-file impact.
2. Use `cosmoteer-vanilla-reference` if the task depends on vanilla parity, inheritance, or feature import.
3. Use `swacd-maintenance-governance` for release-gate audits, impact reviews, or documentation refresh decisions.
4. Use the matching subsystem skill for implementation details:
   - `swacd-weapons-and-shots`
   - `swacd-shields-and-buffs`
   - `swacd-power-thrusters-and-utilities`
   - `swacd-gui-and-strings`
   - `swacd-resources-effects-and-statuses`
   - `swacd-modes-and-career-integration`

## Notes

- Prefer the new skill set for all future maintenance and implementation work.
