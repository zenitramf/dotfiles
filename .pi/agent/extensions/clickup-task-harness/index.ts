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

type HerdrContext = {
  paneId: string;
  workspaceId: string;
  repoRoot: string;
};

type TerminalAgentInfo = {
  kind: Exclude<AgentKind, "orchestrator">;
  name: string;
  paneId: string;
  tabId: string;
  cwd?: string;
  foregroundCwd?: string;
  reused: boolean;
  agentType?: string;
};

type HerdrPane = {
  pane_id?: string;
  tab_id?: string;
  workspace_id?: string;
  cwd?: string;
  foreground_cwd?: string;
  agent?: string;
  agent_status?: string;
};

type TerminalBootstrap = HerdrContext & {
  taskSlug: string;
  workersTabId: string;
  reviewerTabId: string;
  agents: Record<Exclude<AgentKind, "orchestrator">, TerminalAgentInfo>;
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
let terminalBootstrap: TerminalBootstrap | undefined;

const workerKinds = ["worker1", "worker2", "worker3"] as const;
const reviewerKinds = ["reviewer1", "reviewer2", "reviewer3"] as const;
const subagentKinds = [...workerKinds, ...reviewerKinds] as const;

type PiTheme = { fg?: (token: string, text: string) => string };

function color(theme: PiTheme | undefined, token: string, text: string): string {
  return theme?.fg ? theme.fg(token, text) : text;
}

function truncate(input: string, width: number): string {
  const clean = input.replace(/\s+/g, " ").trim();
  if (width <= 0) return "";
  if (clean.length <= width) return clean;
  if (width === 1) return "…";
  return clean.slice(0, width - 1) + "…";
}

function pad(input: string, width: number): string {
  const clipped = truncate(input, width);
  return clipped + " ".repeat(Math.max(0, width - clipped.length));
}

function statusIcon(status: string): string {
  const s = status.toLowerCase();
  if (s.includes("error") || s.includes("blocked") || s.includes("failed")) return "✗";
  if (s.includes("complete") || s.includes("done") || s.includes("approved")) return "✓";
  if (s.includes("working") || s.includes("running") || s.includes("review") || s.includes("progress") || s.includes("retrieving") || s.includes("checking") || s.includes("starting")) return "●";
  return "○";
}

function statusToken(status: string): string {
  const s = status.toLowerCase();
  if (s.includes("error") || s.includes("blocked") || s.includes("failed")) return "error";
  if (s.includes("complete") || s.includes("done") || s.includes("approved")) return "success";
  if (s.includes("working") || s.includes("running") || s.includes("review") || s.includes("progress") || s.includes("retrieving") || s.includes("checking") || s.includes("starting")) return "warning";
  return "muted";
}

function statusProgress(status: string): number {
  const s = status.toLowerCase();
  if (s.includes("complete") || s.includes("done") || s.includes("approved")) return 100;
  if (s.includes("review")) return 75;
  if (s.includes("working") || s.includes("running") || s.includes("progress")) return 55;
  if (s.includes("retrieving")) return 35;
  if (s.includes("checking") || s.includes("starting")) return 20;
  return 0;
}

function progressBar(percent: number): string {
  const slots = 7;
  const filled = Math.max(0, Math.min(slots, Math.round((percent / 100) * slots)));
  return `[${"=".repeat(filled)}${"-".repeat(slots - filled)}] ${percent}%`;
}

function usageSummary(card: AgentCard): string {
  const parts: string[] = [];
  if (typeof card.tokens === "number") parts.push(`${card.tokens} tok`);
  if (typeof card.cost === "number") parts.push(`$${card.cost.toFixed(4)}`);
  return parts.length > 0 ? ` · ${parts.join(" · ")}` : "";
}

function cardContext(key: AgentKind, card: AgentCard): string {
  if (key === "orchestrator") return `MCP ${state.mcpStatus} · herdr ${state.herdrStatus}`;
  return card.taskId ? `Task ${card.taskId}` : "No task assigned";
}

function renderCard(key: AgentKind, width: number, theme?: PiTheme): string[] {
  const card = state.cards[key];
  const border = (text: string) => color(theme, "warning", text);
  const row = (text: string, token = "text") => `${border("│")} ${color(theme, token, pad(text, width - 4))} ${border("│")}`;
  const detail = card.details.find((line) => line.trim().length > 0) ?? "Waiting for an update";
  const progress = statusProgress(card.status);

  return [
    border(`┌${"─".repeat(width - 2)}┐`),
    row(card.name, "accent"),
    row(`${statusIcon(card.status)} ${card.status}`, statusToken(card.status)),
    row(`${progressBar(progress)}${usageSummary(card)}`, "warning"),
    row(cardContext(key, card), "muted"),
    row(detail, "text"),
    border(`└${"─".repeat(width - 2)}┘`),
  ];
}

function renderWidget(width: number, theme?: PiTheme): string[] {
  if (!state.enabled) return [];
  const lineWidth = Math.max(40, width);
  const gap = "  ";
  const minCardWidth = 34;
  const columns = Math.max(1, Math.min(3, Math.floor((lineWidth + gap.length) / (minCardWidth + gap.length))));
  const cardWidth = Math.max(24, Math.floor((lineWidth - gap.length * (columns - 1)) / columns));
  const lines: string[] = [];
  const title = `ClickUp Task Harness${state.primaryTaskId ? ` · ${state.primaryTaskId}` : ""}`;
  const meta = `MCP: ${state.mcpStatus} · herdr: ${state.herdrStatus}`;
  const header = `${truncate(title, Math.max(0, lineWidth - meta.length - 3))} · ${meta}`;

  lines.push(color(theme, "accent", truncate(header, lineWidth)));
  lines.push("");

  const ordered: AgentKind[] = ["orchestrator", "worker1", "worker2", "worker3", "reviewer1", "reviewer2", "reviewer3"];
  const cards = ordered.map((key) => renderCard(key, cardWidth, theme));
  const cardHeight = cards[0]?.length ?? 0;

  for (let start = 0; start < cards.length; start += columns) {
    const rowCards = cards.slice(start, start + columns);
    for (let line = 0; line < cardHeight; line++) {
      lines.push(rowCards.map((card) => card[line]).join(gap));
    }
    if (start + columns < cards.length) lines.push("");
  }

  lines.push(color(theme, "borderAccent", "─".repeat(Math.min(lineWidth, 120))));
  return lines;
}

function refresh(ctx: ExtensionContext) {
  if (!ctx.hasUI) return;
  ctx.ui.setWidget(WIDGET_ID, state.enabled ? ((_tui: any, theme: PiTheme) => ({ render: (width: number) => renderWidget(width, theme), invalidate() {} })) : undefined, { placement: "aboveEditor" });
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
      if (error) reject(new Error(`${error.message}${stderr ? `\n${stderr}` : ""}${stdout ? `\n${stdout}` : ""}`));
      else resolve(stdout.trim());
    });
  });
}

function slugify(input: string): string {
  const slug = input.toLowerCase().replace(/[^a-z0-9._-]+/g, "-").replace(/^-+|-+$/g, "");
  return (slug || "task").slice(0, 80);
}

function terminalAgentName(kind: Exclude<AgentKind, "orchestrator">, taskSlug: string): string {
  const role = kind.startsWith("worker") ? "Worker" : "Reviewer";
  return `${kind} - ${taskSlug} - ${role}`;
}

function parseJsonOutput(output: string): any {
  const firstJsonLine = output.split(/\r?\n/).find((line) => line.trim().startsWith("{"));
  if (!firstJsonLine) throw new Error(`Expected JSON output, got: ${output.slice(0, 200)}`);
  return JSON.parse(firstJsonLine);
}

async function getCurrentHerdrContext(): Promise<HerdrContext> {
  const output = await execHerdr(["pane", "current", "--current"]);
  const parsed = parseJsonOutput(output);
  const pane = parsed?.result?.pane;
  const paneId = pane?.pane_id;
  const workspaceId = pane?.workspace_id;
  const repoRoot = pane?.cwd || pane?.foreground_cwd;
  if (!paneId) throw new Error("Could not determine current herdr pane id");
  if (!workspaceId) throw new Error("Could not determine current herdr workspace id");
  if (!repoRoot) throw new Error("Could not determine current herdr cwd/repo root");
  return { paneId, workspaceId, repoRoot };
}

async function ensureHerdrTab(workspaceId: string, repoRoot: string, label: "workers" | "reviewer"): Promise<string> {
  const listOutput = await execHerdr(["tab", "list", "--workspace", workspaceId]);
  const listed = parseJsonOutput(listOutput);
  const existing = listed?.result?.tabs?.find((tab: any) => tab?.label === label)?.tab_id;
  if (existing) return existing;

  const createOutput = await execHerdr(["tab", "create", "--workspace", workspaceId, "--cwd", repoRoot, "--label", label, "--no-focus"]);
  const created = parseJsonOutput(createOutput);
  const tabId = created?.result?.tab?.tab_id || created?.result?.tabs?.find((tab: any) => tab?.label === label)?.tab_id;
  if (!tabId) throw new Error(`Could not create or parse ${label} tab id`);
  return tabId;
}

async function listTabPanes(workspaceId: string, tabId: string): Promise<HerdrPane[]> {
  const output = await execHerdr(["pane", "list", "--workspace", workspaceId]);
  const parsed = parseJsonOutput(output);
  const panes = parsed?.result?.panes ?? [];
  return panes
    .filter((pane: HerdrPane) => pane?.tab_id === tabId)
    .sort((a: HerdrPane, b: HerdrPane) => String(a.pane_id ?? "").localeCompare(String(b.pane_id ?? "")));
}

async function splitTerminalPane(tabId: string, sourcePaneId: string, repoRoot: string): Promise<HerdrPane> {
  const output = await execHerdr(["pane", "split", sourcePaneId, "--direction", "right", "--cwd", repoRoot, "--no-focus"], 10000);
  const pane = parseJsonOutput(output)?.result?.pane;
  const paneId = pane?.pane_id;
  if (!paneId) throw new Error(`Could not parse split pane id for tab ${tabId}`);
  return pane;
}

async function paneLooksLikePi(paneId: string): Promise<boolean> {
  try {
    const output = await execHerdr(["pane", "process-info", "--pane", paneId], 5000);
    const processes = parseJsonOutput(output)?.result?.process_info?.foreground_processes ?? [];
    return processes.some((processInfo: any) => {
      const text = [processInfo?.name, processInfo?.cmdline, ...(processInfo?.argv ?? [])].filter(Boolean).join(" ");
      return /(?:^|[\s/])pi(?:$|[\s-])|pi-coding-agent|coding-agent/i.test(text);
    });
  } catch (_error) {
    return false;
  }
}

async function prepareTerminalPane(kind: Exclude<AgentKind, "orchestrator">, taskSlug: string, pane: HerdrPane, tabId: string, repoRoot: string, reused: boolean): Promise<TerminalAgentInfo> {
  const paneId = pane.pane_id;
  if (!paneId) throw new Error(`Missing pane id for ${kind}`);
  const name = terminalAgentName(kind, taskSlug);
  if (pane.agent === "pi" || (await paneLooksLikePi(paneId))) {
    throw new Error(`${name} cannot use pane ${paneId}; it is already running pi`);
  }
  await execHerdr(["pane", "rename", paneId, name], 5000);
  await execHerdr(["pane", "run", paneId, "printf '\\nClickUp Task Harness terminal ready. Pi is intentionally not started yet.\\n'"], 5000);
  return {
    kind,
    name,
    paneId,
    tabId,
    cwd: pane.cwd,
    foregroundCwd: pane.foreground_cwd,
    reused,
    agentType: pane.agent,
  };
}

async function ensureThreeTerminalAgents(workspaceId: string, tabId: string, repoRoot: string, kinds: readonly Exclude<AgentKind, "orchestrator">[], taskSlug: string): Promise<Partial<Record<Exclude<AgentKind, "orchestrator">, TerminalAgentInfo>>> {
  let panes = await listTabPanes(workspaceId, tabId);
  const existingPaneCount = panes.length;
  if (panes.length === 0) throw new Error(`Tab ${tabId} has no panes`);
  if (panes.length > kinds.length) {
    throw new Error(`Tab ${tabId} already has ${panes.length} panes; expected exactly ${kinds.length}. Close the extra pane(s) and rerun so each ${kinds[0].startsWith("worker") ? "worker" : "reviewer"} slot maps to one pane.`);
  }

  while (panes.length < kinds.length) {
    await splitTerminalPane(tabId, panes[0].pane_id!, repoRoot);
    panes = await listTabPanes(workspaceId, tabId);
  }

  const agents: Partial<Record<Exclude<AgentKind, "orchestrator">, TerminalAgentInfo>> = {};
  for (let i = 0; i < kinds.length; i++) {
    const kind = kinds[i];
    agents[kind] = await prepareTerminalPane(kind, taskSlug, panes[i], tabId, repoRoot, i < existingPaneCount);
  }
  return agents;
}

async function bootstrapTerminalAgents(ctx: ExtensionContext, taskId: string, herdrContext: HerdrContext): Promise<TerminalBootstrap> {
  const taskSlug = slugify(taskId);
  for (const kind of subagentKinds) {
    state.cards[kind].status = "starting terminal";
    state.cards[kind].details = ["Starting terminal-only shell", "Pi will not be started until work is selected"];
  }
  refresh(ctx);

  const workersTabId = await ensureHerdrTab(herdrContext.workspaceId, herdrContext.repoRoot, "workers");
  const reviewerTabId = await ensureHerdrTab(herdrContext.workspaceId, herdrContext.repoRoot, "reviewer");
  const agents = {} as Record<Exclude<AgentKind, "orchestrator">, TerminalAgentInfo>;
  const failures: string[] = [];

  const applyReadyCards = (infos: Partial<Record<Exclude<AgentKind, "orchestrator">, TerminalAgentInfo>>) => {
    for (const info of Object.values(infos)) {
      if (!info) continue;
      agents[info.kind] = info;
      state.cards[info.kind].status = "terminal ready";
      state.cards[info.kind].details = [
        `${info.reused ? "Reused" : "Started"} terminal pane ${info.paneId}`,
        `Tab ${info.tabId}; cwd ${info.foregroundCwd || info.cwd || herdrContext.repoRoot}`,
        "Pi agent intentionally not started yet",
      ];
    }
    refresh(ctx);
  };

  const blockGroup = (kinds: readonly Exclude<AgentKind, "orchestrator">[], message: string) => {
    failures.push(message);
    for (const kind of kinds) {
      state.cards[kind].status = "blocked: terminal layout invalid";
      state.cards[kind].details = [message, "Each tab must contain exactly 3 panes: one pane per slot"];
    }
    refresh(ctx);
  };

  try {
    applyReadyCards(await ensureThreeTerminalAgents(herdrContext.workspaceId, workersTabId, herdrContext.repoRoot, workerKinds, taskSlug));
  } catch (error) {
    blockGroup(workerKinds, error instanceof Error ? error.message : String(error));
  }

  try {
    applyReadyCards(await ensureThreeTerminalAgents(herdrContext.workspaceId, reviewerTabId, herdrContext.repoRoot, reviewerKinds, taskSlug));
  } catch (error) {
    blockGroup(reviewerKinds, error instanceof Error ? error.message : String(error));
  }

  if (failures.length > 0) throw new Error(`Failed to prepare worker/reviewer terminal tabs:\n${failures.join("\n")}`);
  return { ...herdrContext, taskSlug, workersTabId, reviewerTabId, agents };
}

function formatTerminalRoster(bootstrap: TerminalBootstrap): string {
  return subagentKinds
    .map((kind) => {
      const info = bootstrap.agents[kind];
      return `- ${kind}: pane ${info.paneId}, tab ${info.tabId}, terminal label "${info.name}"`;
    })
    .join("\n");
}

function buildKickoff(taskId: string, bootstrap: TerminalBootstrap) {
  return `Run Clickup Task Harness for ${taskId}.

You are the Orchestrator for the Clickup Task Harness extension. Follow this exact operating plan:

The extension has already prestarted all worker and reviewer subagents as terminal-only shell panes. These panes are ready in-terminal, but no subagent pi process has been started yet. The workers tab and reviewer tab must each contain exactly 3 panes total: one pane per slot, with no extra original/unassigned pane.

Prestarted terminal roster:
- Workspace: ${bootstrap.workspaceId}
- Repo root: ${bootstrap.repoRoot}
- Workers tab: ${bootstrap.workersTabId}
- Reviewer tab: ${bootstrap.reviewerTabId}
${formatTerminalRoster(bootstrap)}

Critical startup invariant: until the user selects work and you are ready to execute it, keep every worker/reviewer pane as a terminal shell only. Do not start pi in any worker/reviewer pane during task retrieval, ranking, or user selection.

1. Use the @ogulcancelik/pi-herdr extension for every herdr-related action (detecting/inspecting tabs/panes, creating tabs, spawning panes, running commands in panes, and cleanup). Do not bypass it with ad-hoc terminal/tmux/herdr automation. For all subagents, do not create separate herdr workspaces; use tabs/panes in the current workspace instead. Treat all worker/reviewer agents as idempotent: use stable labels, inspect before spawning, reuse existing matching panes, and avoid duplicating side effects on rerun.
2. Verify you are inside a herdr instance using the deterministic environment check: HERDR_ENV must equal "1". If not, stop and tell the user the harness must run inside herdr.
3. The extension intentionally did not check ClickUp MCP readiness in the orchestrator pane. In the orchestrator pane, do not run /mcp, do not run /mcp:start clickup, and do not run /mcp:list just to inspect status. Proceed using the available ClickUp MCP tools; if no mcp_clickup_* tools are callable when you need task data, report that as blocked and ask the user to start/fix ClickUp MCP. Worker and reviewer panes are terminal-only shells at this point. When a selected work batch is ready to execute, use wt commands in the appropriate prestarted worker terminal panes to switch workers to their assigned worktrees, then start pi in those worker panes, then run /mcp:start clickup in each started worker pi agent before sending any worker prompt. Reviewers are started only after workers finish; start reviewer pi with only read-only tools enabled and do not start ClickUp MCP in reviewer panes.
4. Use the ClickUp MCP tools to retrieve the primary task and all subtasks for: ${taskId}
5. Return a markdown table of all available subtasks with columns: Rank, ClickUp ID, Title, Status, Assignee, Priority, Blockers/Dependencies, Rationale.
6. Recommend which subtasks you would run first and explain the ranking briefly, but do not choose for the user.
7. STOP and WAIT for the user's explicit selection of which subtasks to run. The user may choose any listed subtasks, not necessarily your recommendations. Do not assign workers, create worktrees, start pi in worker/reviewer terminals, send prompts to subagents, or change ClickUp subtask statuses until the user lists the subtasks they want run.
8. After the user selects subtasks, use the clickup_task_harness_update_agent tool to keep the seven UI cards current. Assign worker1/worker2/worker3 only to the user-selected subtasks, up to three workers at a time. If the user selects more than three, run them in batches and wait for each batch to complete before assigning the next. The card tool updates only the local harness UI; it does not update ClickUp and must never be treated as a substitute for worker ClickUp MCP status updates.
9. Fast-start rule: do not discover command syntax at runtime. Do not run wt -h, wt --help, wt list, herdr -h, herdr --help, herdr <subcommand> --help, herdr workspace list, herdr pane list, or herdr agent list during worker/reviewer startup. Use only the command recipes below. If one of these commands fails, update the UI card and ask the user instead of trying help/list variants.

Agent wait protocol: every time you wait for a worker or reviewer response, use the @ogulcancelik/pi-herdr wait_agent operation, not ad-hoc sleeps, manual polling, repeated pane reads, or user-visible guessing. Use a deterministic 30 minute timeout: 1800000 ms. Wait in stable slot order (worker1, worker2, worker3; then reviewer1, reviewer2, reviewer3), and record whether each wait completed, blocked, or timed out. If the pi-herdr wait_agent operation is unavailable but the herdr CLI is available, use the deterministic equivalent: herdr wait agent-status <pane-id> --status done --timeout 1800000. If that times out, read that pane once with recent-unwrapped output for diagnosis, update the UI card as blocked/timed out, and ask the user how to proceed. Do not try help/list discovery variants.

10. Prestarted terminal pane rules for the current batch:
   - Prefer the exact pane ids from the prestarted terminal roster above. Do not spawn duplicate worker/reviewer panes during normal startup. Keep the workers tab at exactly 3 panes and the reviewer tab at exactly 3 panes.
   - The worker pane mapping is fixed: worker1 -> ${bootstrap.agents.worker1.paneId}, worker2 -> ${bootstrap.agents.worker2.paneId}, worker3 -> ${bootstrap.agents.worker3.paneId}.
   - The reviewer pane mapping is fixed: reviewer1 -> ${bootstrap.agents.reviewer1.paneId}, reviewer2 -> ${bootstrap.agents.reviewer2.paneId}, reviewer3 -> ${bootstrap.agents.reviewer3.paneId}.
   - Use <repo-root> = ${bootstrap.repoRoot} and <workspace-id> = ${bootstrap.workspaceId} unless you verify they changed with herdr pane current --current.
   - If a prestarted pane is missing or not a terminal shell when you need it, update the matching UI card as blocked and ask the user for cleanup/restart instead of using help/list discovery or creating duplicates.
11. For each selected subtask in the current batch, create/reuse the worktree with wt, switch the assigned prestarted worker terminal to that worktree with wt, then start pi. Use deterministic branch names and paths; do not call wt list:
   - Branch pattern: clickup/${bootstrap.taskSlug}/<worker-slot>/<clickup-subtask-id-slug>. Build <clickup-subtask-id-slug> from the ClickUp subtask ID by lowercasing it and replacing every non-alphanumeric/dot/underscore/dash character with a dash.
   - First try existing branch/worktree from the orchestrator pane: wt -C <repo-root> switch <branch> --format json --no-cd -y
   - If and only if that fails because the branch does not exist, create it from the current worktree from the orchestrator pane: wt -C <repo-root> switch --create <branch> --base @ --format json --no-cd -y
   - Parse the worktree path from the first JSON line's path field. Store both the branch and worktree path for that worker slot and for reviewer startup.
   - Write/update the worker prompt to /tmp/clickup-harness-<worker-slot>-<ClickUp Subtask ID>.md before starting pi. The prompt must be idempotent and include the mandatory ClickUp MCP status protocol below.
   - In the assigned prestarted worker terminal pane, use wt to switch to the worktree and then execute pi in that worktree; do not use cd: herdr pane run <worker-pane-id> "wt -C <repo-root> switch <branch> -y --execute pi -- --provider openai --model gpt-5.3-codex --thinking medium --name \"<worker-slot> - ${bootstrap.taskSlug} - Worker\""
   - After pi is ready in that pane, start ClickUp MCP with exactly: herdr pane run <worker-pane-id> /mcp:start clickup
   - Do not send the worker prompt until after the ClickUp MCP start command has completed in that worker pane. If ClickUp MCP fails to start or the worker reports that no mcp_clickup_* tools are available, update that worker card as blocked and ask the user for the fix instead of letting the worker continue.
   - Send the worker prompt only after ClickUp MCP is started by running: herdr pane run <worker-pane-id> @/tmp/clickup-harness-<worker-slot>-<ClickUp Subtask ID>.md
   - After all worker prompts for the current batch have been sent, wait for worker responses deterministically in slot order with wait_agent and timeout 1800000 ms per active worker. Do not rely on sleeps or repeated pane reads. For each worker, update the UI card immediately after wait_agent returns done/blocked/timed out.
   - If the pane is already running pi for the same subtask and has already reported final results, do not resend the prompt; only collect status. If it is running pi for a different subtask, update the card as blocked and ask the user for cleanup instead of reusing it.
   - The worker prompt must include this mandatory ClickUp MCP status protocol: fetch the assigned subtask through ClickUp MCP; before editing files, use ClickUp MCP to update that exact subtask, not the parent task, to the workspace's in-progress/working status; if the in-progress status update fails, stop and report blocked without implementing; when implementation and self-tests are complete, use ClickUp MCP to update that same subtask to the workspace's done/complete/closed status; never use shell/curl/browser/manual ClickUp updates for statuses and never ask the orchestrator to update the worker's subtask status; include previous status, final status, and status-update evidence in the final report.
   - Worker instructions: fetch its subtask from ClickUp MCP; follow the mandatory ClickUp MCP status protocol above; complete the implementation; comment relevant results on the subtask without duplicating prior harness comments if rerun; report status, results, token usage, cost, and model back to you. Workers must use provider openai, model gpt-5.3-codex, and medium thinking.
12. After workers finish, use the matching prestarted reviewer terminal panes. Do not create reviewer panes during normal startup:
   - Start reviewer1 in worker1's stored branch/worktree, reviewer2 in worker2's stored branch/worktree, and reviewer3 in worker3's stored branch/worktree. If a worker slot did not run in this batch, leave the matching reviewer terminal idle.
   - Write/update the reviewer prompt to /tmp/clickup-harness-<reviewer-slot>-${bootstrap.taskSlug}.md before starting pi. The reviewer prompt must be idempotent and must include all task context the reviewer needs, including the assigned ClickUp subtask context, worker final report, branch/worktree path, acceptance criteria when available, and the relevant git diff/stat collected by the orchestrator.
   - The reviewer prompt must explicitly state that the reviewer is read-only: it must not modify code or any repository files, must not create/delete/rename files, must not apply patches, must not run formatting/fix commands, must not update ClickUp statuses, must not create/update ClickUp comments, and must report findings only back to the orchestrator.
   - In the assigned prestarted reviewer terminal pane, use wt to switch to the worker worktree and then execute pi in that worktree with only read-only built-in tools enabled; do not use cd: herdr pane run <reviewer-pane-id> "wt -C <repo-root> switch <worker-branch> -y --execute pi -- --provider openai --model gpt-5.5 --thinking high --tools read,grep,find,ls --name \"<reviewer-slot> - ${bootstrap.taskSlug} - Reviewer\""
   - Do not start ClickUp MCP in reviewer panes. Reviewers must not use ClickUp tools or any extension tools; if they need missing task context, they must ask the orchestrator for it in their final report instead of querying or updating ClickUp.
   - Send the reviewer prompt after pi is ready by running: herdr pane run <reviewer-pane-id> @/tmp/clickup-harness-<reviewer-slot>-${bootstrap.taskSlug}.md
   - After all reviewer prompts for the current batch have been sent, wait for reviewer responses deterministically in slot order with wait_agent and timeout 1800000 ms per active reviewer. Do not rely on sleeps or repeated pane reads. For each reviewer, update the UI card immediately after wait_agent returns done/blocked/timed out.
   - Each reviewer performs only read-only code review of the assigned worker worktree based on the prompt, worker reports, and code changes. Its sole output is a report to the orchestrator with findings, evidence, severity, and recommended next steps.
13. Collect reviewer1/reviewer2/reviewer3 results after wait_agent completes for each active reviewer, reconcile disagreements, and report consolidated review results plus recommended next steps to the user. Do not merge or remove worktrees until the user approves.
14. After approval only, merge worker changes, update the main ClickUp task with results/tech debt/next steps, then close/cleanup herdr subagent panes through @ogulcancelik/pi-herdr and remove worktrees with wt remove -D. Never remove or close the prestarted terminal panes before the user approves cleanup.

If any required command/MCP/tool is unavailable, update the UI card and ask the user for the needed fix.`;
}

export default function (pi: ExtensionAPI) {
  pi.on("before_agent_start", async (_event: any, ctx) => {
    if (!state.enabled) return;
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
      terminalBootstrap = undefined;
      state.enabled = true;
      state.primaryTaskId = taskId;
      state.cards.orchestrator.status = "starting terminal subagents";
      state.cards.orchestrator.details = ["Will prestart workers/reviewers as terminal-only shells", "Will not start subagent pi until selected work is ready", "Will not check orchestrator ClickUp MCP status"];
      refresh(ctx);
      state.herdrStatus = await detectHerdr();
      if (state.herdrStatus !== "inside") {
        state.cards.orchestrator.status = "blocked: not inside herdr";
        state.cards.orchestrator.details = ["HERDR_ENV is not 1", "Run /clickup-harness from inside a herdr-managed pi pane"];
        refresh(ctx);
        return;
      }

      try {
        const herdrContext = await getCurrentHerdrContext();
        terminalBootstrap = await bootstrapTerminalAgents(ctx, taskId, herdrContext);
        state.mcpStatus = "unknown";
        const tools = enableClickUpMcpTools(pi);
        state.cards.orchestrator.status = "retrieving subtasks";
        state.cards.orchestrator.details = [
          `Prestarted worker/reviewer terminal panes in ${herdrContext.workspaceId}`,
          "Skipped orchestrator ClickUp MCP readiness check; did not run /mcp or /mcp:start clickup",
          tools.length > 0 ? `Enabled ${tools.length} mcp_clickup_* tools opportunistically` : "No mcp_clickup_* tools visible yet; orchestrator should report blocked if ClickUp tools are unavailable",
        ];
        refresh(ctx);
        pi.sendUserMessage(buildKickoff(taskId, terminalBootstrap));
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        state.cards.orchestrator.status = "blocked: harness startup failed";
        state.cards.orchestrator.details = [message, "Fix the blocked startup step, then rerun /clickup-harness <task id or URL>"];
        refresh(ctx);
      }
    },
  });

  pi.registerCommand("clickup-harness-clear", {
    description: "Hide and reset the Clickup Task Harness cards",
    handler: async (_args, ctx) => {
      state = defaults();
      terminalBootstrap = undefined;
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
