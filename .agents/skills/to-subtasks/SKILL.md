---
name: to-subtasks
description: Update a primary ClickUp task with implementation subtasks based on tracer-bullet vertical slices.
disable-model-invocation: true
---

# To Issues

Break a plan into independently-grabbable ClickUp subtasks using vertical slices (tracer bullets), then attach those subtasks to a primary ClickUp task.

## Required gates

Before doing any breakdown or publishing, ensure both ClickUp MCP access and a primary ClickUp task ID or URL are available.

### ClickUp MCP availability

- First, verify that the ClickUp MCP tools are available in the current environment.
- If the ClickUp MCP is not available, stop and tell the user that this skill requires ClickUp MCP access to fetch the primary task, create subtasks, and create task dependencies.
- Do not draft, create, or simulate ClickUp subtasks without ClickUp MCP access unless the user explicitly asks for a non-publishing draft only.

### Primary ClickUp task

- If the user provided a ClickUp task ID or URL, use the ClickUp MCP to fetch the task and confirm it exists.
- If no ClickUp task ID or URL is in context, stop and ask the user for the primary ClickUp task ID or URL.
- Do not create subtasks until the primary task has been fetched successfully.

## Process

### 1. Gather context

Work from whatever is already in the conversation context plus the primary ClickUp task. Use the ClickUp MCP to read the primary task's title, description, existing subtasks, comments, and any relevant linked information.

If the user passes an additional source reference (document URL, file path, issue URL, PRD, or notes), fetch/read it and incorporate it into the plan.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code. Subtask titles and descriptions should use the project's domain glossary vocabulary, and respect ADRs in the area you're touching.

Look for opportunities to prefactor the code to make the implementation easier. "Make the change easy, then make the easy change." Prefactoring can be its own first vertical slice when it is independently verifiable and reduces risk for later slices.

### 3. Draft vertical slices

Break the plan into **tracer bullet** subtasks. Each subtask is a thin vertical slice that cuts through ALL relevant integration layers end-to-end, NOT a horizontal slice of one layer.

<vertical-slice-rules>

- Each slice delivers a narrow but COMPLETE path through every relevant layer (for example schema, API, UI, background job, docs, tests)
- A completed slice is demoable or verifiable on its own
- Each slice is small enough for one human or agent to implement without needing to redesign the whole project
- Any prefactoring should happen before slices that depend on it
- Use dependency relationships to preserve implementation order without over-serializing independent work

</vertical-slice-rules>

For each proposed subtask decide whether it is:

- `AFK`: suitable for an autonomous coding agent with minimal clarification
- `HITL`: requires human-in-the-loop decisions, credentials, product judgment, manual QA, or risky migrations

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each slice, show:

- **Mode**: AFK or HITL
- **Title**: short descriptive name, without the `[AFK]`/`[HITL]` prefix in the preview
- **Blocked by**: which other slices (if any) must complete first
- **User stories covered**: which user stories this addresses (if the source material has them)
- **Verification**: how someone can prove the slice works

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the AFK/HITL classifications correct?
- Are the dependency relationships correct?
- Should any slices be merged or split further?

Iterate until the user explicitly approves the breakdown for ClickUp subtask creation.

### 5. Publish subtasks to ClickUp

Before publishing, re-confirm that ClickUp MCP access is still available. If it is unavailable, stop and report that publishing cannot proceed until ClickUp MCP access is restored.

For each approved slice, use the ClickUp MCP to create a subtask under the primary ClickUp task.

Subtask creation requirements:

- Create each item as a ClickUp **subtask** of the confirmed primary task.
- Title format must be exactly: `[AFK] <name of sub-task>` or `[HITL] <name of sub-task>`.
- Description must contain enough information for a human or agent to implement the slice without reading the whole original conversation.
- Acceptance criteria must be written in Gherkin/BDD style using `Given`, `When`, and `Then` statements.
- Publish subtasks in dependency order (blockers first) so real ClickUp task IDs are available for dependencies.
- After creating subtasks, use the ClickUp MCP to add dependencies between ClickUp tasks according to the approved `Blocked by` relationships.
- Do not rely only on textual "Blocked by" notes; create actual ClickUp task dependencies via the MCP.
- If the ClickUp MCP cannot create a dependency, report the exact failed dependency and ask the user how to proceed.

<subtask-template>
## Parent

Primary ClickUp task: <primary task ID or URL>

## What to build

A concise description of this vertical slice. Describe the end-to-end behavior, not layer-by-layer implementation. Include relevant product context, constraints, edge cases, and integration points needed to implement the slice.

Avoid brittle file paths or large code snippets unless they encode a key decision more precisely than prose can. If including a snippet from a prototype, trim it to the decision-rich parts and explain why it matters.

## Implementation notes

- Important constraints, domain vocabulary, and architectural expectations
- Existing behavior that must be preserved
- Testing guidance and any manual verification notes
- Known risks, migrations, feature flags, or rollout considerations

## Acceptance criteria

```gherkin
Scenario: <primary successful behavior>
  Given <initial context>
  When <user or system action occurs>
  Then <observable expected outcome occurs>

Scenario: <important edge case or failure behavior>
  Given <initial context>
  When <user or system action occurs>
  Then <observable expected outcome occurs>
```

## Dependencies

- Blocked by: <ClickUp subtask IDs or "None - can start immediately">
- Blocks: <ClickUp subtask IDs if known, otherwise omit>
</subtask-template>

### 6. Report completion

After creating subtasks and dependencies, summarize:

- Primary ClickUp task ID/URL
- Created subtasks with IDs, titles, and AFK/HITL mode
- Created dependency links
- Any dependency links that failed or need manual follow-up

Do NOT close the primary ClickUp task unless the user explicitly asks.
