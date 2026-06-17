import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { execFile } from "node:child_process";
import { Type } from "typebox";

type AgentKind = "orchestrator" | "worker1" | "worker2" | "worker3" | "reviewer1" | "reviewer2" | "reviewer3";

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
  mcpToolsEnabled: string[];
  cards: Record<AgentKind, AgentCard>;
};

const WIDGET_ID = "clickup-task-harness";

const defaults = (): HarnessState => ({
  enabled: false,
  mcpStatus: "unknown",
  herdrStatus: "unknown",
  mcpToolsEnabled: [],
  cards: {
    orchestrator: {
      name: "Orchestrator",
      status: "idle",
      model: "GPT-5.5 · high reasoning",
      details: ["Awaiting /clickup-harness <ClickUp task id or URL>"],
    },
    worker1: { name: "Worker 1", status: "idle", model: "openai · gpt-5.3-codex · medium thinking", details: ["No subtask assigned"] },
    worker2: { name: "Worker 2", status: "idle", model: "openai · gpt-5.3-codex · medium thinking", details: ["No subtask assigned"] },
    worker3: { name: "Worker 3", status: "idle", model: "openai · gpt-5.3-codex · medium thinking", details: ["No subtask assigned"] },
    reviewer1: { name: "Reviewer 1", status: "idle", model: "openai · gpt-5.5 · high thinking", details: ["Waiting for worker completion"] },
    reviewer2: { name: "Reviewer 2", status: "idle", model: "openai · gpt-5.5 · high thinking", details: ["Waiting for worker completion"] },
    reviewer3: { name: "Reviewer 3", status: "idle", model: "openai · gpt-5.5 · high thinking", details: ["Waiting for worker completion"] },
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

  const ordered: AgentKind[] = ["orchestrator", "worker1", "worker2", "worker3", "reviewer1", "reviewer2", "reviewer3"];
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

function isClickUpMcpTool(name: string): boolean {
  return name.startsWith("mcp_clickup_");
}

function enableClickUpMcpTools(pi: ExtensionAPI): string[] {
  const tools = pi.getAllTools().map((tool) => tool.name).filter(isClickUpMcpTool);
  if (tools.length === 0) return [];

  const activeTools = new Set(pi.getActiveTools());
  for (const tool of tools) activeTools.add(tool);
  pi.setActiveTools([...activeTools]);
  state.mcpToolsEnabled = tools;
  return tools;
}

function execHerdr(args: string[], timeoutMs = 10000): Promise<string> {
  return new Promise((resolve, reject) => {
    execFile("herdr", args, { timeout: timeoutMs }, (error, stdout, stderr) => {
      if (error) reject(new Error(`${error.message}${stderr ? `\n${stderr}` : ""}`));
      else resolve(stdout.trim());
    });
  });
}

async function getCurrentHerdrPaneId(): Promise<string> {
  const output = await execHerdr(["pane", "current", "--current"]);
  const parsed = JSON.parse(output);
  const paneId = parsed?.result?.pane?.pane_id;
  if (!paneId) throw new Error("Could not determine current herdr pane id");
  return paneId;
}

async function checkClickUpMcpReadyBeforeTurn(): Promise<string> {
  const paneId = await getCurrentHerdrPaneId();
  await execHerdr(["pane", "run", paneId, "/mcp"], 10000);
  const output = await execHerdr(["pane", "read", paneId, "--source", "recent-unwrapped", "--lines", "120", "--format", "text"], 5000);
  const clickUpReadyLine = output
    .split(/\r?\n/)
    .find((line) => /^\s*(?:[✓✔]\s*)?clickup\s*\(ready\)\s*$/i.test(line.trim()));
  if (!clickUpReadyLine) {
    throw new Error("ClickUp MCP is not ready according to /mcp output; expected a line like: ✓ clickup (ready)");
  }
  return paneId;
}

function buildKickoff(taskId: string) {
  return `Run Clickup Task Harness for ${taskId}.

You are the Orchestrator for the Clickup Task Harness extension. Follow this exact operating plan:

1. Use the @ogulcancelik/pi-herdr extension for every herdr-related action (detecting/inspecting tabs/panes, creating tabs, spawning panes, running commands in panes, and cleanup). Do not bypass it with ad-hoc terminal/tmux/herdr automation. For all subagents, do not create separate herdr workspaces; use tabs/panes in the current workspace instead. Treat all worker/reviewer agents as idempotent: use stable labels, inspect before spawning, reuse existing matching panes, and avoid duplicating side effects on rerun.
2. Verify you are inside a herdr instance using the deterministic environment check: HERDR_ENV must equal "1". If not, stop and tell the user the harness must run inside herdr.
3. The extension already ran plain /mcp in the orchestrator pane before this conversation turn and verified clickup is ready. In the orchestrator pane, do not run /mcp:start clickup and do not run /mcp:list. Worker panes still run the exact /mcp:start clickup command specified below.
4. Use the ClickUp MCP to retrieve the primary task and all subtasks for: ${taskId}
5. Return a markdown table of all available subtasks with columns: Rank, ClickUp ID, Title, Status, Assignee, Priority, Blockers/Dependencies, Rationale.
6. Recommend which subtasks you would run first and explain the ranking briefly, but do not choose for the user.
7. STOP and WAIT for the user's explicit selection of which subtasks to run. The user may choose any listed subtasks, not necessarily your recommendations. Do not assign workers, create worktrees, spawn worker panes, or change ClickUp subtask statuses until the user lists the subtasks they want run.
8. After the user selects subtasks, use the clickup_task_harness_update_agent tool to keep the seven UI cards current. Assign worker1/worker2/worker3 only to the user-selected subtasks, up to three workers at a time. If the user selects more than three, run them in batches and wait for each batch to complete before assigning the next.
9. Fast-start rule: do not discover command syntax at runtime. Do not run wt -h, wt --help, wt list, herdr -h, herdr --help, herdr <subcommand> --help, herdr workspace list, herdr pane list, or herdr agent list during worker/reviewer startup. Use only the command recipes below. If one of these commands fails, update the UI card and ask the user instead of trying help/list variants.
10. One-time herdr context and tab setup for the current batch:
   - Run: herdr pane current --current
   - Parse result.pane.workspace_id as <workspace-id> and result.pane.cwd or result.pane.foreground_cwd as <repo-root>.
   - Run exactly once for workers tab lookup: herdr tab list --workspace <workspace-id>
   - If no tab has label "workers", run: herdr tab create --workspace <workspace-id> --cwd <repo-root> --label workers --no-focus
   - Parse the workers tab id from result.tabs[].tab_id or result.tab.tab_id.
11. For each selected subtask in the current batch, create/reuse the worktree with wt, then start/reuse one worker pane. Use deterministic branch names and paths; do not call wt list:
   - Branch pattern: clickup/${taskId}/<worker-slot>/<clickup-subtask-id-slug>. Build <clickup-subtask-id-slug> from the ClickUp subtask ID by lowercasing it and replacing every non-alphanumeric/dot/underscore/dash character with a dash.
   - First try existing branch/worktree: wt -C <repo-root> switch <branch> --format json --no-cd -y
   - If and only if that fails because the branch does not exist, create it from the current worktree: wt -C <repo-root> switch --create <branch> --base @ --format json --no-cd -y
   - Parse the worktree path from the first JSON line's path field. Store it as that worker slot's worktree path for reviewer startup.
   - Stable worker agent name/pane label: <worker-slot> - <ClickUp Subtask ID> - Worker, where <worker-slot> is worker1, worker2, or worker3.
   - Check idempotency by running only: herdr agent get "<worker-slot> - <ClickUp Subtask ID> - Worker"
   - If that agent exists and its cwd/foreground_cwd matches the worktree path, reuse its result.agent.pane_id. Do not spawn a duplicate.
   - If it does not exist, write the worker prompt to /tmp/clickup-harness-<worker-slot>-<ClickUp Subtask ID>.md, then run: herdr agent start "<worker-slot> - <ClickUp Subtask ID> - Worker" --cwd <worktree-path> --tab <workers-tab-id> --split right --no-focus -- pi --provider openai --model gpt-5.3-codex --thinking medium --name "<worker-slot> - <ClickUp Subtask ID> - Worker" @/tmp/clickup-harness-<worker-slot>-<ClickUp Subtask ID>.md
   - Parse result.agent.pane_id from herdr agent start.
   - Start ClickUp MCP in that worker pane with exactly: herdr pane run <worker-pane-id> /mcp:start clickup
   - Worker instructions: fetch its subtask from ClickUp MCP; set the subtask in-progress; complete the implementation; comment relevant results on the subtask without duplicating prior harness comments if rerun; set the subtask complete only when done; report status, results, token usage, cost, and model back to you. Workers must use provider openai, model gpt-5.3-codex, and medium thinking.
12. After workers finish, create/reuse reviewer panes using the same fast-start pattern:
   - Run exactly once for reviewer tab lookup: herdr tab list --workspace <workspace-id>
   - If no tab has label "reviewer", run: herdr tab create --workspace <workspace-id> --cwd <repo-root> --label reviewer --no-focus
   - Parse the reviewer tab id from result.tabs[].tab_id or result.tab.tab_id.
   - Start reviewer1 in worker1's stored worktree path, reviewer2 in worker2's stored worktree path, and reviewer3 in worker3's stored worktree path. If a worker slot did not run in this batch, leave the matching reviewer idle.
   - Stable reviewer agent names/pane labels: reviewer1 - ${taskId} - Reviewer, reviewer2 - ${taskId} - Reviewer, reviewer3 - ${taskId} - Reviewer.
   - For each reviewer, check idempotency with only: herdr agent get "<reviewer-slot> - ${taskId} - Reviewer"
   - If that agent exists and its cwd/foreground_cwd matches the assigned worker worktree path, reuse it. Do not spawn a duplicate.
   - If it does not exist, write the reviewer prompt to /tmp/clickup-harness-<reviewer-slot>-${taskId}.md, then run: herdr agent start "<reviewer-slot> - ${taskId} - Reviewer" --cwd <assigned-worker-worktree-path> --tab <reviewer-tab-id> --split right --no-focus -- pi --provider openai --model gpt-5.5 --thinking high --no-extensions --tools read,bash,grep,find,ls --name "<reviewer-slot> - ${taskId} - Reviewer" @/tmp/clickup-harness-<reviewer-slot>-${taskId}.md
   - Each reviewer has no ClickUp access; performs read-only review only; checks the workers' worktrees; and reviews based on worker reports and code changes.
13. Collect reviewer1/reviewer2/reviewer3 results, reconcile disagreements, and report consolidated review results plus recommended next steps to the user. Do not merge or remove worktrees until the user approves.
14. After approval only, merge worker changes, update the main ClickUp task with results/tech debt/next steps, then close/cleanup herdr subagent panes through @ogulcancelik/pi-herdr and remove worktrees with wt remove -D.

If any required command/MCP/tool is unavailable, update the UI card and ask the user for the needed fix.`;
}

export default function (pi: ExtensionAPI) {
  pi.on("before_agent_start", async (_event: any, ctx) => {
    if (!state.enabled || state.mcpStatus !== "running") return;
    const tools = enableClickUpMcpTools(pi);
    if (tools.length > 0) {
      state.cards.orchestrator.details = [
        ...state.cards.orchestrator.details.slice(0, 2),
        `Enabled ${tools.length} mcp_clickup_* tools before agent start`,
      ];
      refresh(ctx);
    }
  });

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
      state.cards.orchestrator.status = "checking ClickUp MCP readiness";
      state.cards.orchestrator.details = ["Will run plain /mcp only", "Will not run /mcp:start clickup", "Will fail immediately if clickup is not ready"];
      refresh(ctx);
      state.herdrStatus = await detectHerdr();
      if (state.herdrStatus !== "inside") {
        state.cards.orchestrator.status = "blocked: not inside herdr";
        state.cards.orchestrator.details = ["HERDR_ENV is not 1", "Run /clickup-harness from inside a herdr-managed pi pane"];
        refresh(ctx);
        return;
      }

      try {
        state.mcpStatus = "starting";
        refresh(ctx);
        const paneId = await checkClickUpMcpReadyBeforeTurn();
        state.mcpStatus = "running";
        const tools = enableClickUpMcpTools(pi);
        state.cards.orchestrator.status = "retrieving subtasks";
        state.cards.orchestrator.details = [
          `Ran plain /mcp in ${paneId}`,
          "Verified clickup is ready; did not run /mcp:start clickup",
          tools.length > 0 ? `Enabled ${tools.length} mcp_clickup_* tools before orchestration` : "No mcp_clickup_* tools visible yet; will retry before agent start",
        ];
        refresh(ctx);
        pi.sendUserMessage(buildKickoff(taskId));
      } catch (error) {
        state.mcpStatus = "error";
        state.cards.orchestrator.status = "blocked: ClickUp MCP not ready";
        state.cards.orchestrator.details = [error instanceof Error ? error.message : String(error), "Start ClickUp MCP separately, then rerun /clickup-harness <task id or URL>"];
        refresh(ctx);
      }
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
    description: "Update one of the seven Clickup Task Harness UI cards with status, task assignment, usage, cost, and details.",
    parameters: Type.Object({
      agent: Type.Union([Type.Literal("orchestrator"), Type.Literal("worker1"), Type.Literal("worker2"), Type.Literal("worker3"), Type.Literal("reviewer1"), Type.Literal("reviewer2"), Type.Literal("reviewer3")]),
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
