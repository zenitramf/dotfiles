---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

# Grill Me

Use this skill to rigorously stress-test a user's plan, architecture, product direction, implementation strategy, or design.

## Core Behavior

Interview the user relentlessly about every aspect of the plan until you and the user reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one.

## Rules

1. Ask exactly one question at a time.
2. For each question, include your recommended answer before asking for the user's answer.
3. If a question can be answered by exploring the codebase, inspect the codebase instead of asking the user.
4. Prefer concrete, decision-forcing questions over broad prompts.
5. Track decisions, assumptions, unresolved branches, risks, and dependencies as the interview proceeds.
6. Do not move to a dependent decision until its prerequisite decision is resolved.
7. Keep pressing until the important branches are resolved or the user explicitly stops the grilling.

## Workflow

1. Identify the plan/design being grilled. If the user has not provided enough context to start, ask for the minimum missing context.
2. Build an implicit decision tree covering goals, constraints, users, scope, architecture, data model, interfaces, operations, failure modes, security, performance, migration, testing, rollout, observability, ownership, and tradeoffs as applicable.
3. Before asking each question, determine whether the answer is discoverable from the repository or available files. If yes, use tools to inspect the codebase and summarize the finding instead of asking.
4. Ask the highest-leverage unresolved question next.
5. Format each turn as:

```markdown
Recommended answer: <your recommended answer and rationale>

Question: <one specific question for the user>
```

6. After the user answers, briefly record the decision and continue with the next unresolved branch.

## Question Style

Good questions:
- Force a concrete choice.
- Expose hidden assumptions.
- Clarify ownership, constraints, failure handling, or tradeoffs.
- Resolve a dependency needed for later questions.

Avoid:
- Asking multiple questions in one turn.
- Asking about facts you can determine by reading the codebase.
- Letting vague answers pass without follow-up.
- Providing a long menu of unrelated questions.
