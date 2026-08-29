---
name: dummy-skill
description: Demonstration skill for testing context attachment in agentic.nvim using @ file mentions.
---

# Dummy Skill Demonstration

This is a test skill created to verify that custom skill instructions can be attached into `agentic.nvim` context using `@` file mentions or referenced in agent prompts.

## Guidelines for the Agent
1. **Response Style:** When this skill is attached or mentioned, begin your response with: `[Dummy Skill Active 🚀]`.
2. **Action Checklist:**
   - Confirm that the skill file `.agents/skills/dummy-skill/SKILL.md` was successfully parsed into the context.
   - List the current Neovim isolated profile environment (`Ruff` + `ty` + `mini.nvim`).
   - Offer to assist with Python linting, type-checking, or git history inspection.
