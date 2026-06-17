import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

type AgentKind = "orchestrator" | "worker1" | "worker2" | "worker3" | "reviewer";

type AgentCard = {
  name: string;
  status: string;
  model: string;
  details: string[];
  taskId?: string;
  tokens?: number;
  cost?: number;
};

type HarnessState = {
  enabled: boolean;
  primaryTaskId?: string;
  mcpStatus: "unknown" | "starting" | "running" | "error";
  herdrStatus: "unknown" | "inside" | "outside";
  cards: Record<AgentKind, AgentCard>;
};

const WIDGET_ID = "clickup-task-harness";

const defaults = (): HarnessState => ({
  enabled: false,
  mcpStatus: "unknown",
  herdrStatus: "unknown",
  cards: {
    orchestrator: {
      name: "Orchestrator",
      status: "idle",
      model: "GPT-5.5 · high reasoning",
      details: ["Awaiting /clickup-harness <ClickUp task id or URL>"],
    },
    worker1: { name: "Worker 1", status: "idle", model: "GPT-5-codex · medium reasoning", details: ["No subtask assigned"] },
    worker2: { name: "Worker 2", status: "idle", model: "GPT-5-codex · medium reasoning", details: ["No subtask assigned"] },
    worker3: { name: "Worker 3", status: "idle", model: "GPT-5-codex · medium reasoning", details: ["No subtask assigned"] },
    reviewer: { name: "Reviewer", status: "idle", model: "GPT-5.5 · high reasoning", details: ["Waiting for worker completion"] },
  },
});

let state: HarnessState = defaults();

function truncate(input: string, width: number): string {
  if (input.length <= width) return input;
  return input.slice(0, Math.max(0, width - 1)) + "…";
}

function statusIcon(status: string): string {
  const s = status.toLowerCase();
  if (s.includes("error") || s.includes("blocked") || s.includes("failed")) return "✗";
  if (s.includes("complete") || s.includes("done") || s.includes("approved")) return "✓";
  if (s.includes("working") || s.includes("running") || s.includes("review") || s.includes("progress")) return "●";
  return "○";
}

function renderWidget(width: number): string[] {
  if (!state.enabled) return [];
  const lineWidth = Math.max(40, width);
  const sep = "─".repeat(Math.min(lineWidth, 100));
  const lines: string[] = [];
  lines.push(truncate(`Clickup Task Harness${state.primaryTaskId ? ` · ${state.primaryTaskId}` : ""}`, lineWidth));
  lines.push(sep);

  const ordered: AgentKind[] = ["orchestrator", "worker1", "worker2", "worker3", "reviewer"];
  for (const key of ordered) {
    const c = state.cards[key];
    const extra = key === "orchestrator"
      ? ` · MCP: ${state.mcpStatus} · herdr: ${state.herdrStatus}`
      : c.taskId ? ` · ${c.taskId}` : "";
    lines.push(truncate(`${statusIcon(c.status)} ${c.name} — ${c.status} · ${c.model}${extra}`, lineWidth));
    for (const detail of c.details.slice(0, 3)) lines.push(truncate(`   ${detail}`, lineWidth));
    if (typeof c.tokens === "number" || typeof c.cost === "number") {
      lines.push(truncate(`   usage: ${c.tokens ?? "?"} tokens · $${(c.cost ?? 0).toFixed(6)}`, lineWidth));
    }
  }
  lines.push(sep);
  return lines;
}

function refresh(ctx: ExtensionContext) {
  if (!ctx.hasUI) return;
  ctx.ui.setWidget(WIDGET_ID, state.enabled ? ((_tui, _theme) => ({ render: renderWidget, invalidate() {} })) : undefined, { placement: "aboveEditor" });
  ctx.ui.setStatus(WIDGET_ID, state.enabled ? `ClickUp Harness: ${state.cards.orchestrator.status}` : undefined);
}

async function detectHerdr(): Promise<HarnessState["herdrStatus"]> {
  return process.env.HERDR_ENV === "1" ? "inside" : "outside";
}

function buildKickoff(taskId: string) {
  return `Run Clickup Task Harness for ${taskId}.

You are the Orchestrator for the Clickup Task Harness extension. Follow this exact operating plan:

1. Use the @ogulcancelik/pi-herdr extension for every herdr-related action (detecting/inspecting panes, spawning workspaces, running commands in panes, and cleanup). Do not bypass it with ad-hoc terminal/tmux/herdr automation.
2. Verify you are inside a herdr instance using the deterministic environment check: HERDR_ENV must equal "1". If not, stop and tell the user the harness must run inside herdr.
3. Start ClickUp MCP if needed through @ogulcancelik/pi-herdr by targeting the active herdr pane ID: herdr run <herdr-pane-id> /mcp:start clickup (example pane target: herdr run w7:p1 /mcp:start clickup). Do not run herdr run without an explicit pane ID.
3. Use the ClickUp MCP to retrieve the primary task and all subtasks for: ${taskId}
4. Return a markdown table of all available subtasks with columns: Rank, ClickUp ID, Title, Status, Assignee, Priority, Blockers/Dependencies, Rationale.
5. Recommend which subtasks you would run first and explain the ranking briefly, but do not choose for the user.
6. STOP and WAIT for the user's explicit selection of which subtasks to run. The user may choose any listed subtasks, not necessarily your recommendations. Do not assign workers, create worktrees, spawn worker workspaces, or change ClickUp subtask statuses until the user lists the subtasks they want run.
7. After the user selects subtasks, use the clickup_task_harness_update_agent tool to keep the five UI cards current. Assign worker1/worker2/worker3 only to the user-selected subtasks, up to three workers at a time. If the user selects more than three, run them in batches and wait for each batch to complete before assigning the next.
8. For each user-selected subtask in the current batch, stage a worktree with: wt switch -c <subagent-branch-name> -b @
9. Spawn herdr worker workspaces through @ogulcancelik/pi-herdr for those staged worktrees, label each workspace "<ClickUp Subtask ID> - Worker", and instruct each worker to:
   - run herdr run <worker-herdr-pane-id> /mcp:start clickup, using that worker workspace's herdr pane ID (example: herdr run w7:p1 /mcp:start clickup),
   - fetch its subtask from ClickUp MCP,
   - set the subtask in-progress,
   - complete the implementation,
   - comment relevant results on the subtask,
   - set the subtask complete only when done,
   - report status, results, token usage, cost, and model back to you.
   Workers use GPT-5-codex with medium reasoning.
10. After workers finish, spawn a reviewer workspace through @ogulcancelik/pi-herdr labeled "${taskId} - Reviewer". Reviewer uses GPT-5.5 high reasoning, has no ClickUp access, checks the workers' worktrees, and reviews based on worker reports and code changes.
11. Report review results and recommended next steps to the user. Do not merge or remove worktrees until the user approves.
12. After approval only, merge worker changes, update the main ClickUp task with results/tech debt/next steps, then delete herdr workspaces through @ogulcancelik/pi-herdr and remove worktrees with wt remove -D.

If any required command/MCP/tool is unavailable, update the UI card and ask the user for the needed fix.`;
}

export default function (pi: ExtensionAPI) {
  pi.on("message_end", async (event: any, ctx) => {
    if (!state.enabled || event.message?.role !== "assistant") return;
    const usage = event.message.usage;
    if (usage) {
      state.cards.orchestrator.tokens = usage.totalTokens ?? usage.tokens ?? usage.inputTokens + usage.outputTokens;
      state.cards.orchestrator.cost = usage.cost?.total ?? usage.cost;
      refresh(ctx);
    }
  });

  pi.registerCommand("clickup-harness", {
    description: "Run Clickup Task Harness for a ClickUp task id or URL",
    handler: async (args, ctx) => {
      const taskId = (args || "").trim() || (ctx.hasUI ? (await ctx.ui.input("Clickup Task Harness", "ClickUp task ID or URL:"))?.trim() : "");
      if (!taskId) return;
      state = defaults();
      state.enabled = true;
      state.primaryTaskId = taskId;
      state.cards.orchestrator.status = "checking herdr and MCP";
      state.cards.orchestrator.details = ["Preparing orchestration prompt", "Will use @ogulcancelik/pi-herdr for all herdr actions", "Will start ClickUp MCP via targeted herdr pane if needed"];
      refresh(ctx);
      state.herdrStatus = await detectHerdr();
      state.mcpStatus = "starting";
      refresh(ctx);
      pi.sendUserMessage(buildKickoff(taskId));
    },
  });

  pi.registerCommand("clickup-harness-clear", {
    description: "Hide and reset the Clickup Task Harness cards",
    handler: async (_args, ctx) => {
      state = defaults();
      refresh(ctx);
    },
  });

  pi.registerTool({
    name: "clickup_task_harness_update_agent",
    label: "Update ClickUp Harness Card",
    description: "Update one of the five Clickup Task Harness UI cards with status, task assignment, usage, cost, and details.",
    parameters: Type.Object({
      agent: Type.Union([Type.Literal("orchestrator"), Type.Literal("worker1"), Type.Literal("worker2"), Type.Literal("worker3"), Type.Literal("reviewer")]),
      status: Type.String(),
      details: Type.Optional(Type.Array(Type.String())),
      taskId: Type.Optional(Type.String()),
      mcpStatus: Type.Optional(Type.Union([Type.Literal("unknown"), Type.Literal("starting"), Type.Literal("running"), Type.Literal("error")])),
      herdrStatus: Type.Optional(Type.Union([Type.Literal("unknown"), Type.Literal("inside"), Type.Literal("outside")])),
      model: Type.Optional(Type.String()),
      tokens: Type.Optional(Type.Number()),
      cost: Type.Optional(Type.Number()),
    }),
    async execute(_toolCallId, params: any, _signal, _onUpdate, ctx) {
      if (!state.enabled) {
        return { content: [{ type: "text", text: "ClickUp Task Harness is inactive. Run /clickup-harness <task id or URL> first." }] };
      }
      const card = state.cards[params.agent as AgentKind];
      card.status = params.status;
      if (params.details) card.details = params.details;
      if (params.taskId) card.taskId = params.taskId;
      if (params.model) card.model = params.model;
      if (typeof params.tokens === "number") card.tokens = params.tokens;
      if (typeof params.cost === "number") card.cost = params.cost;
      if (params.mcpStatus) state.mcpStatus = params.mcpStatus;
      if (params.herdrStatus) state.herdrStatus = params.herdrStatus;
      refresh(ctx);
      return { content: [{ type: "text", text: `Updated ${card.name}: ${card.status}` }], details: { state } };
    },
  });
}
