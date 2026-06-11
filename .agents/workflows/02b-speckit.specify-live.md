---
description: Trigger the interactive Spec Kit discovery workflow to define a feature.
handoffs:
  - label: Build Technical Plan
    agent: speckit.plan
    prompt: Create a plan from the completed discovered spec.
---

# Workflow: Specify Live

When the user initiates this workflow, execute the `specify-live` skill to begin an interactive feature discovery session. 

Follow the strict constraints of the `specify-live` skill, particularly maintaining a living draft and asking only ONE clarification question at a time.
