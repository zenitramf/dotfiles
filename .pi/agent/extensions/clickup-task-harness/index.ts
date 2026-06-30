import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { execFile } from "node:child_process";
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { Type } from "typebox";

type AgentKind = "orchestrator" | "worker1" | "worker2" | "worker3" | "reviewer1" | "reviewer2" | "reviewer3";
type AgentType = "orchestrator" | "worker" | "reviewer";
type TmuxStatus = "unknown" | "inside" | "outside" | "error";

type AgentCard = { name: string; status: string; model: string; details: string[]; taskId?: string; tokens?: number; cost?: number };
type HarnessState = { enabled: boolean; primaryTaskId?: string; mcpStatus: "unknown" | "starting" | "running" | "error"; tmuxStatus: TmuxStatus; mcpToolsEnabled: string[]; cards: Record<AgentKind, AgentCard> };
type TmuxContext = { session: string; orchestratorPaneId: string; orchestratorWindowId: string; repoRoot: string; orchestratorBranchName: string };
type TerminalAgentInfo = { kind: Exclude<AgentKind, "orchestrator">; name: string; paneId: string; windowId: string; windowName: string; cwd?: string; command?: string; reused: boolean };
type TerminalBootstrap = TmuxContext & { taskSlug: string; agents: Record<Exclude<AgentKind, "orchestrator">, TerminalAgentInfo> };
type AgentConfig = { name: string; description: string; tools?: string; model: string; thinking: string; prompt: string };
type TmuxPane = { index: number; paneId: string; cwd?: string; command?: string };

const WIDGET_ID = "clickup-task-harness";
const EXTENSION_DIR = dirname(fileURLToPath(import.meta.url));
const agentConfigFiles: Record<AgentType, string> = { orchestrator: "orchestrator.md", worker: "worker.md", reviewer: "reviewer.md" };
const workerKinds = ["worker1", "worker2", "worker3"] as const;
const reviewerKinds = ["reviewer1", "reviewer2", "reviewer3"] as const;
const subagentKinds = [...workerKinds, ...reviewerKinds] as const;

function parseAgentConfig(type: AgentType): AgentConfig {
  const path = join(EXTENSION_DIR, agentConfigFiles[type]);
  const raw = readFileSync(path, "utf8");
  const match = raw.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n?([\s\S]*)$/);
  if (!match) throw new Error(`Invalid agent config ${path}: missing YAML frontmatter`);
  const fields: Record<string, string> = {};
  for (const line of match[1].split(/\r?\n/)) {
    const parsed = line.match(/^([A-Za-z0-9_-]+):\s*(.*)$/);
    if (parsed) fields[parsed[1]] = parsed[2].trim().replace(/^["']|["']$/g, "");
  }
  for (const required of ["name", "description", "model", "thinking"] as const) if (!fields[required]) throw new Error(`Invalid agent config ${path}: missing ${required}`);
  return { name: fields.name, description: fields.description, tools: fields.tools, model: fields.model, thinking: fields.thinking, prompt: match[2].trim() };
}
function agentConfig(type: AgentType) { return parseAgentConfig(type); }
function displayModel(config: AgentConfig) { return `${config.model} · ${config.thinking} thinking`; }

const defaults = (): HarnessState => {
  const orchestrator = agentConfig("orchestrator"), worker = agentConfig("worker"), reviewer = agentConfig("reviewer");
  return { enabled: false, mcpStatus: "unknown", tmuxStatus: "unknown", mcpToolsEnabled: [], cards: {
    orchestrator: { name: "Orchestrator", status: "idle", model: displayModel(orchestrator), details: ["Awaiting /clickup-harness <ClickUp task id or URL>"] },
    worker1: { name: "Worker 1", status: "idle", model: displayModel(worker), details: ["No subtask assigned"] },
    worker2: { name: "Worker 2", status: "idle", model: displayModel(worker), details: ["No subtask assigned"] },
    worker3: { name: "Worker 3", status: "idle", model: displayModel(worker), details: ["No subtask assigned"] },
    reviewer1: { name: "Reviewer 1", status: "idle", model: displayModel(reviewer), details: ["Waiting for worker completion"] },
    reviewer2: { name: "Reviewer 2", status: "idle", model: displayModel(reviewer), details: ["Waiting for worker completion"] },
    reviewer3: { name: "Reviewer 3", status: "idle", model: displayModel(reviewer), details: ["Waiting for worker completion"] },
  }};
};
let state: HarnessState = defaults();
let terminalBootstrap: TerminalBootstrap | undefined;

type PiTheme = { fg?: (token: string, text: string) => string };
const color = (theme: PiTheme | undefined, token: string, text: string) => theme?.fg ? theme.fg(token, text) : text;
function truncate(input: string, width: number) { const clean = input.replace(/\s+/g, " ").trim(); return width <= 0 ? "" : clean.length <= width ? clean : width === 1 ? "…" : clean.slice(0, width - 1) + "…"; }
function pad(input: string, width: number) { const clipped = truncate(input, width); return clipped + " ".repeat(Math.max(0, width - clipped.length)); }
function statusIcon(status: string) { const s = status.toLowerCase(); if (s.match(/error|blocked|failed/)) return "✗"; if (s.match(/complete|done|approved|clean/)) return "✓"; if (s.match(/working|running|review|progress|retrieving|checking|starting/)) return "●"; return "○"; }
function statusToken(status: string) { const s = status.toLowerCase(); if (s.match(/error|blocked|failed/)) return "error"; if (s.match(/complete|done|approved|clean/)) return "success"; if (s.match(/working|running|review|progress|retrieving|checking|starting/)) return "warning"; return "muted"; }
function statusProgress(status: string) { const s = status.toLowerCase(); if (s.match(/complete|done|approved|clean/)) return 100; if (s.includes("review")) return 75; if (s.match(/working|running|progress/)) return 55; if (s.includes("retrieving")) return 35; if (s.match(/checking|starting/)) return 20; return 0; }
function progressBar(percent: number) { const slots = 7, filled = Math.max(0, Math.min(slots, Math.round((percent / 100) * slots))); return `[${"=".repeat(filled)}${"-".repeat(slots - filled)}] ${percent}%`; }
function usageSummary(card: AgentCard) { const parts: string[] = []; if (typeof card.tokens === "number") parts.push(`${card.tokens} tok`); if (typeof card.cost === "number") parts.push(`$${card.cost.toFixed(4)}`); return parts.length ? ` · ${parts.join(" · ")}` : ""; }
function cardContext(key: AgentKind, card: AgentCard) { return key === "orchestrator" ? `MCP ${state.mcpStatus} · tmux ${state.tmuxStatus}` : card.taskId ? `Task ${card.taskId}` : "No task assigned"; }
function renderCard(key: AgentKind, width: number, theme?: PiTheme) { const card = state.cards[key]; const border = (text: string) => color(theme, "warning", text); const row = (text: string, token = "text") => `${border("│")} ${color(theme, token, pad(text, width - 4))} ${border("│")}`; const detail = card.details.find((line) => line.trim()) ?? "Waiting for an update"; const progress = statusProgress(card.status); return [border(`┌${"─".repeat(width - 2)}┐`), row(card.name, "accent"), row(`${statusIcon(card.status)} ${card.status}`, statusToken(card.status)), row(`${progressBar(progress)}${usageSummary(card)}`, "warning"), row(cardContext(key, card), "muted"), row(detail), border(`└${"─".repeat(width - 2)}┘`)]; }
function renderWidget(width: number, theme?: PiTheme) { if (!state.enabled) return []; const lineWidth = Math.max(40, width), gap = "  "; const columns = Math.max(1, Math.min(3, Math.floor((lineWidth + gap.length) / (34 + gap.length)))); const cardWidth = Math.max(24, Math.floor((lineWidth - gap.length * (columns - 1)) / columns)); const title = `ClickUp Task Harness${state.primaryTaskId ? ` · ${state.primaryTaskId}` : ""}`; const meta = `MCP: ${state.mcpStatus} · tmux: ${state.tmuxStatus}`; const lines = [color(theme, "accent", truncate(`${truncate(title, Math.max(0, lineWidth - meta.length - 3))} · ${meta}`, lineWidth)), ""]; const cards = (["orchestrator", "worker1", "worker2", "worker3", "reviewer1", "reviewer2", "reviewer3"] as AgentKind[]).map((k) => renderCard(k, cardWidth, theme)); for (let start = 0; start < cards.length; start += columns) { const rowCards = cards.slice(start, start + columns); for (let line = 0; line < (cards[0]?.length ?? 0); line++) lines.push(rowCards.map((c) => c[line]).join(gap)); if (start + columns < cards.length) lines.push(""); } lines.push(color(theme, "borderAccent", "─".repeat(Math.min(lineWidth, 120)))); return lines; }
function refresh(ctx: ExtensionContext) { if (!ctx.hasUI) return; ctx.ui.setWidget(WIDGET_ID, state.enabled ? ((_tui: any, theme: PiTheme) => ({ render: (width: number) => renderWidget(width, theme), invalidate() {} })) : undefined, { placement: "aboveEditor" }); ctx.ui.setStatus(WIDGET_ID, state.enabled ? `ClickUp Harness: ${state.cards.orchestrator.status}` : undefined); }

function isClickUpMcpTool(name: string) { return name.startsWith("mcp_clickup_"); }
function enableClickUpMcpTools(pi: ExtensionAPI) { const tools = pi.getAllTools().map((tool) => tool.name).filter(isClickUpMcpTool); if (!tools.length) return []; const activeTools = new Set(pi.getActiveTools()); for (const tool of tools) activeTools.add(tool); pi.setActiveTools([...activeTools]); state.mcpToolsEnabled = tools; return tools; }
function execTmux(args: string[], timeoutMs = 10000): Promise<string> { return new Promise((resolve, reject) => execFile("tmux", args, { timeout: timeoutMs }, (error, stdout, stderr) => error ? reject(new Error(`${error.message}${stderr ? `\n${stderr}` : ""}${stdout ? `\n${stdout}` : ""}`)) : resolve(stdout.trim()))); }
function execGit(args: string[], timeoutMs = 10000): Promise<string> { return new Promise((resolve, reject) => execFile("git", args, { timeout: timeoutMs }, (error, stdout, stderr) => error ? reject(new Error(`${error.message}${stderr ? `\n${stderr}` : ""}${stdout ? `\n${stdout}` : ""}`)) : resolve(stdout.trim()))); }
async function detectTmux(): Promise<TmuxStatus> { if (!process.env.TMUX) return "outside"; try { await execTmux(["display-message", "-p", "#{session_name}"], 3000); return "inside"; } catch { return "error"; } }
function slugify(input: string) { const slug = input.toLowerCase().replace(/[^a-z0-9._-]+/g, "-").replace(/^-+|-+$/g, ""); return (slug || "task").slice(0, 80); }
function terminalAgentName(kind: Exclude<AgentKind, "orchestrator">, taskSlug: string) { const role = kind.startsWith("worker") ? "Worker" : "Reviewer"; return `${kind} - ${taskSlug} - ${role}`; }
async function getCurrentTmuxContext(): Promise<TmuxContext> { const out = await execTmux(["display-message", "-p", "#{session_name}\t#{pane_id}\t#{window_id}\t#{pane_current_path}"]); const [session, orchestratorPaneId, orchestratorWindowId, repoRoot] = out.split("\t"); if (!session || !orchestratorPaneId || !orchestratorWindowId || !repoRoot) throw new Error("Could not determine current tmux session/window/pane/repo root"); const orchestratorBranchName = await getCurrentGitBranch(repoRoot); await execTmux(["rename-window", "-t", orchestratorWindowId, "cu-orchestrator"]); return { session, orchestratorPaneId, orchestratorWindowId, repoRoot, orchestratorBranchName }; }
async function getCurrentGitBranch(repoRoot: string): Promise<string> { const branch = await execGit(["-C", repoRoot, "branch", "--show-current"], 5000); if (branch) return branch; const ref = await execGit(["-C", repoRoot, "rev-parse", "--abbrev-ref", "HEAD"], 5000); if (ref && ref !== "HEAD") return ref; throw new Error("Could not determine orchestrator branch name; cleanup requires `wt switch <orchestrator branch name>` in every team pane before `wt remove -D`"); }
async function findWindow(session: string, name: string): Promise<string | undefined> { const out = await execTmux(["list-windows", "-t", session, "-F", "#{window_name}\t#{window_id}"]); return out.split(/\r?\n/).map((l) => l.split("\t")).find(([n]) => n === name)?.[1]; }
async function ensureTeamWindow(session: string, repoRoot: string, name: string): Promise<{ windowId: string; reused: boolean }> { const existing = await findWindow(session, name); if (existing) return { windowId: existing, reused: true }; const out = await execTmux(["new-window", "-d", "-P", "-F", "#{window_id}", "-t", session, "-n", name, "-c", repoRoot]); return { windowId: out.trim(), reused: false }; }
async function listPanes(windowId: string): Promise<TmuxPane[]> { const out = await execTmux(["list-panes", "-t", windowId, "-F", "#{pane_index}\t#{pane_id}\t#{pane_current_path}\t#{pane_current_command}"]); return out ? out.split(/\r?\n/).map((l) => { const [index, paneId, cwd, command] = l.split("\t"); return { index: Number(index), paneId, cwd, command }; }).sort((a, b) => a.index - b.index) : []; }
function commandLooksLikePi(command?: string) { return !!command && /^(pi|node|bun)$|pi-coding-agent|coding-agent/i.test(command); }
async function ensurePanePair(windowId: string, repoRoot: string): Promise<{ worker: TmuxPane; reviewer: TmuxPane; reused: boolean }> { let panes = await listPanes(windowId); const original = panes.length; if (panes.length > 2) throw new Error(`Window ${windowId} already has ${panes.length} panes; expected worker/reviewer pair only`); if (!panes.length) throw new Error(`Window ${windowId} has no panes`); if (panes.length === 1) { await execTmux(["split-window", "-h", "-t", panes[0].paneId, "-c", repoRoot]); await execTmux(["select-layout", "-t", windowId, "even-horizontal"]); panes = await listPanes(windowId); } if (panes.length !== 2) throw new Error(`Window ${windowId} did not settle into exactly two panes`); return { worker: panes[0], reviewer: panes[1], reused: original === 2 }; }
async function prepareTerminalPane(kind: Exclude<AgentKind, "orchestrator">, taskSlug: string, pane: TmuxPane, windowId: string, windowName: string, reused: boolean): Promise<TerminalAgentInfo> { const name = terminalAgentName(kind, taskSlug); if (commandLooksLikePi(pane.command)) throw new Error(`${name} cannot use ${pane.paneId}; it is already running ${pane.command}`); await execTmux(["select-pane", "-t", pane.paneId, "-T", name], 3000); await execTmux(["send-keys", "-t", pane.paneId, "printf '\\nClickUp Task Harness terminal ready. Pi is intentionally not started yet.\\n'", "C-m"], 3000); return { kind, name, paneId: pane.paneId, windowId, windowName, cwd: pane.cwd, command: pane.command, reused }; }
async function bootstrapTerminalAgents(ctx: ExtensionContext, taskId: string, tmuxContext: TmuxContext): Promise<TerminalBootstrap> { const taskSlug = slugify(taskId); for (const kind of subagentKinds) { state.cards[kind].status = "starting tmux pane"; state.cards[kind].details = ["Preparing team pane pair", "Pi will not be started until work is selected"]; } refresh(ctx); const agents = {} as Record<Exclude<AgentKind, "orchestrator">, TerminalAgentInfo>; const failures: string[] = []; for (let i = 1; i <= 3; i++) { const windowName = `team${i}`; const workerKind = workerKinds[i - 1], reviewerKind = reviewerKinds[i - 1]; try { const { windowId, reused: reusedWindow } = await ensureTeamWindow(tmuxContext.session, tmuxContext.repoRoot, windowName); const pair = await ensurePanePair(windowId, tmuxContext.repoRoot); const worker = await prepareTerminalPane(workerKind, taskSlug, pair.worker, windowId, windowName, reusedWindow || pair.reused); const reviewer = await prepareTerminalPane(reviewerKind, taskSlug, pair.reviewer, windowId, windowName, reusedWindow || pair.reused); agents[workerKind] = worker; agents[reviewerKind] = reviewer; for (const info of [worker, reviewer]) { state.cards[info.kind].status = "tmux pane ready"; state.cards[info.kind].details = [`${info.reused ? "Reused" : "Started"} ${info.windowName} pane ${info.paneId}`, `cwd ${info.cwd || tmuxContext.repoRoot}`, "Pi agent intentionally not started yet"]; } refresh(ctx); } catch (error) { const message = error instanceof Error ? error.message : String(error); failures.push(`${windowName}: ${message}`); for (const kind of [workerKind, reviewerKind]) { state.cards[kind].status = "blocked: tmux layout invalid"; state.cards[kind].details = [message, "Each team window must contain exactly two panes: worker left, reviewer right"]; } refresh(ctx); } } if (failures.length) throw new Error(`Failed to prepare tmux team windows:\n${failures.join("\n")}`); return { ...tmuxContext, taskSlug, agents }; }
function formatTerminalRoster(bootstrap: TerminalBootstrap) { return [1, 2, 3].map((i) => { const w = bootstrap.agents[`worker${i}` as Exclude<AgentKind, "orchestrator">], r = bootstrap.agents[`reviewer${i}` as Exclude<AgentKind, "orchestrator">]; return `- team${i}: worker left ${w.paneId} (${w.name}); reviewer right ${r.paneId} (${r.name})`; }).join("\n"); }

function buildKickoff(taskId: string, bootstrap: TerminalBootstrap) {
  const orchestrator = agentConfig("orchestrator"), worker = agentConfig("worker"), reviewer = agentConfig("reviewer");
  return `Run Clickup Task Harness for ${taskId}.

The agent configurations below were loaded from orchestrator.md, worker.md, and reviewer.md in the extension directory. Treat these markdown files as the primary source for each agent type's role, model, thinking level, tool policy, and base instructions.

## Orchestrator configuration (${agentConfigFiles.orchestrator})
- name: ${orchestrator.name}
- description: ${orchestrator.description}
- model: ${orchestrator.model}
- thinking: ${orchestrator.thinking}
- tools: ${orchestrator.tools ?? "default"}

${orchestrator.prompt}

## Worker configuration (${agentConfigFiles.worker})
- name: ${worker.name}
- description: ${worker.description}
- model: ${worker.model}
- thinking: ${worker.thinking}
- tools: ${worker.tools ?? "default"}

${worker.prompt}

## Reviewer configuration (${agentConfigFiles.reviewer})
- name: ${reviewer.name}
- description: ${reviewer.description}
- model: ${reviewer.model}
- thinking: ${reviewer.thinking}
- tools: ${reviewer.tools ?? "default"}

${reviewer.prompt}

Follow this exact operating plan:

The extension has already prepared tmux windows and pane pairs. The current orchestrator window has been renamed to \`cu-orchestrator\`. Each team window has the worker in the left pane and the matching reviewer in the right pane. These panes are terminal shells only; no subagent pi process has been started yet.

Tmux roster:
- Session: ${bootstrap.session}
- Repo root: ${bootstrap.repoRoot}
- Orchestrator branch name: ${bootstrap.orchestratorBranchName}
- Orchestrator pane/window: ${bootstrap.orchestratorPaneId} / ${bootstrap.orchestratorWindowId} (window name cu-orchestrator)
${formatTerminalRoster(bootstrap)}

Critical startup invariant: until the user selects work and you are ready to execute it, keep every worker/reviewer pane as a terminal shell only. Do not start pi in any worker/reviewer pane during task retrieval, ranking, or user selection.

1. Use tmux for terminal orchestration. Do not use herdr or pi-herdr. Do not create separate workspaces. Use the exact precreated pane ids above, stable window labels (team1, team2, team3), and stable pi intercom names.
2. Verify you are inside tmux using \`TMUX\`; if not, stop and tell the user the harness must run inside tmux.
3. Proceed using available ClickUp MCP tools in the orchestrator. If no \`mcp_clickup_*\` tools are callable when task data is needed, report blocked and ask the user to fix ClickUp MCP access.
4. Use ClickUp MCP tools to retrieve the primary task and all subtasks for: ${taskId}
5. Return a markdown table of all available subtasks with columns: Rank, ClickUp ID, Title, Status, Assignee, Priority, Blockers/Dependencies, Rationale.
6. Recommend which subtasks to run first, but do not choose for the user.
7. STOP and WAIT for explicit user selection. Do not assign workers, create worktrees, start subagent pi, send prompts, or update ClickUp statuses until selection.
8. After selection, use \`clickup_task_harness_update_agent\` to keep UI cards current. Assign worker1/2/3 in batches of up to three. Determine the current orchestrator pi-intercom target/name with \`intercom({ action: "status" })\` and/or \`intercom({ action: "list" })\`, then include that orchestrator target in every worker prompt.
9. Fast-start rule: do not discover command syntax at runtime. Do not run help/list variants for wt or tmux during startup. Use only the command recipes below; if a command fails, update the UI card and ask the user.
10. For each selected subtask in the current batch, create/reuse a deterministic worktree with wt from the orchestrator pane:
   - Branch pattern: \`clickup/${bootstrap.taskSlug}/<worker-slot>/<clickup-subtask-id-slug>\`.
   - First try: \`wt -C <repo-root> switch <branch> --format json --no-cd -y\`.
   - If and only if that fails because the branch does not exist, create: \`wt -C <repo-root> switch --create <branch> --base @ --format json --no-cd -y\`.
   - Parse the first JSON line's \`path\` field. Store branch/worktree for both worker and reviewer.
11. Start each worker with its prompt as an initial pi message in the matching left pane:
   - Write \`/tmp/clickup-harness-<worker-slot>-<ClickUp Subtask ID>.md\`.
   - Command recipe: \`tmux send-keys -t <worker-pane-id> "wt -C <repo-root> switch <branch> -y --execute pi -- --model ${worker.model} --thinking ${worker.thinking} --tools 'read,grep,find,ls,bash,edit,write,mcp,intercom,mcp_clickup_*' --name '<worker-slot> - ${bootstrap.taskSlug} - Worker' @/tmp/clickup-harness-<worker-slot>-<ClickUp Subtask ID>.md" C-m\`.
   - Important for zsh: keep the \`--tools\` value quoted anywhere \`mcp_clickup_*\` appears, otherwise zsh may expand or reject the glob.
   - Worker prompt must include worker.md plus assigned subtask context, branch/worktree, mandatory status protocol, matching reviewer intercom name, and orchestrator intercom target/name for the final handoff.
   - Workers must fetch the assigned subtask, update that exact subtask to in-progress before edits, implement, self-test, update that subtask to done/complete when implementation is ready for review, and add/maintain comments only on that subtask (never the parent task).
12. Reviewer/worker loop, per team:
   - After the worker worktree exists and the worker has been started, start the matching reviewer in the right pane with instructions to wait for the worker's pi-intercom review request before reviewing.
   - Reviewer command recipe: \`tmux send-keys -t <reviewer-pane-id> "wt -C <repo-root> switch <worker-branch> -y --execute pi -- --model ${reviewer.model} --thinking ${reviewer.thinking} --tools 'read,grep,find,ls,bash,mcp,intercom,mcp_clickup_*' --name '<reviewer-slot> - ${bootstrap.taskSlug} - Reviewer' @/tmp/clickup-harness-<reviewer-slot>-${bootstrap.taskSlug}.md" C-m\`.
   - Important for zsh: keep the \`--tools\` value quoted anywhere \`mcp_clickup_*\` appears, otherwise zsh may expand or reject the glob.
   - Reviewer prompt must include reviewer.md, ClickUp subtask context, worker intercom name, branch/worktree path, acceptance criteria, and instructions to wait for worker reports/diffs over pi-intercom.
   - Reviewer may inspect code read-only and may create/update ClickUp comments only on the assigned subtask. Reviewer must not modify repository files, status, parent task comments, or main task data.
   - Worker sends implementation-ready requests to reviewer via pi-intercom; reviewer sends findings back to worker via pi-intercom. If changes are requested, the worker fixes and notifies the reviewer again. Continue worker -> reviewer -> worker until reviewer returns clean/approved.
   - When reviewer returns clean, the worker sends the completed handoff to the orchestrator via pi-intercom. The handoff must include worker summary, subtask status/comment evidence, reviewer clean report, validation, risks, usage, model, and cost.
13. Communication boundaries:
   - Worker/reviewer pairs cross-talk through pi-intercom inside their team.
   - Workers hand completed clean-review handoffs to the orchestrator through pi-intercom.
   - Worker and reviewer may comment only on the assigned subtask.
   - The orchestrator is the only agent that may comment on or update the main parent task.
14. Orchestrator waits by pi-intercom handoff, not herdr. Track outstanding workers by slot. If a handoff is missing after a reasonable interval, read tmux pane output once for diagnosis, update UI as blocked/timed out, and ask the user.
15. Consolidate clean handoffs for the user. Do not merge branches, remove worktrees, close panes, or cleanup until explicit user approval.
16. After approval only, merge worker changes and update/comment the main ClickUp task with consolidated results/tech debt/next steps.
17. Mandatory cleanup order before any \`wt remove -D\`:
   - Ensure every worker/reviewer tmux pane started by the harness has exited from Pi back to a normal shell. Do not remove a worktree while any team pane is still running Pi in that worktree.
   - In each individual team pane that used a worker worktree (worker and reviewer panes, one pane at a time), run exactly \`wt switch ${bootstrap.orchestratorBranchName}\` and verify it succeeds before continuing. This per-pane switch is required before any \`wt remove -D\`; do not rely on a single orchestrator-pane switch.
   - From the orchestrator pane, also run exactly \`wt switch ${bootstrap.orchestratorBranchName}\` and verify it succeeds.
   - Only after every team pane and the orchestrator pane have successfully switched to \`${bootstrap.orchestratorBranchName}\`, remove worker worktrees with \`wt remove -D <worktree-or-branch>\`.
   - If any pane cannot exit Pi or any \`wt switch ${bootstrap.orchestratorBranchName}\` fails, stop cleanup, update the UI card as blocked, and ask the user how to proceed.
18. Clean up tmux panes/windows if requested only after the Pi-exit and all per-pane \`wt switch ${bootstrap.orchestratorBranchName}\` checks above are complete.

If any required command/MCP/tool is unavailable, update the UI card and ask the user for the needed fix.`;
}

export default function (pi: ExtensionAPI) {
  pi.on("before_agent_start", async (_event: any, ctx) => { if (!state.enabled) return; const tools = enableClickUpMcpTools(pi); if (tools.length) { state.cards.orchestrator.details = [...state.cards.orchestrator.details.slice(0, 2), `Enabled ${tools.length} mcp_clickup_* tools before agent start`]; refresh(ctx); } });
  pi.on("message_end", async (event: any, ctx) => { if (!state.enabled || event.message?.role !== "assistant") return; const usage = event.message.usage; if (usage) { state.cards.orchestrator.tokens = usage.totalTokens ?? usage.tokens ?? usage.inputTokens + usage.outputTokens; state.cards.orchestrator.cost = usage.cost?.total ?? usage.cost; refresh(ctx); } });

  pi.registerCommand("clickup-harness", { description: "Run Clickup Task Harness for a ClickUp task id or URL", handler: async (args, ctx) => {
    const taskId = (args || "").trim() || (ctx.hasUI ? (await ctx.ui.input("Clickup Task Harness", "ClickUp task ID or URL:"))?.trim() : ""); if (!taskId) return;
    state = defaults(); terminalBootstrap = undefined; state.enabled = true; state.primaryTaskId = taskId; state.cards.orchestrator.status = "starting tmux subagents"; state.cards.orchestrator.details = ["Will prepare team1/team2/team3 pane pairs", "Will not start subagent pi until selected work is ready", "Will use pi-intercom for handoffs"]; refresh(ctx);
    state.tmuxStatus = await detectTmux(); if (state.tmuxStatus !== "inside") { state.cards.orchestrator.status = "blocked: not inside tmux"; state.cards.orchestrator.details = ["TMUX is not available/healthy", "Run /clickup-harness from inside a tmux-managed pi pane"]; refresh(ctx); return; }
    try { const tmuxContext = await getCurrentTmuxContext(); terminalBootstrap = await bootstrapTerminalAgents(ctx, taskId, tmuxContext); state.mcpStatus = "unknown"; const tools = enableClickUpMcpTools(pi); state.cards.orchestrator.status = "retrieving subtasks"; state.cards.orchestrator.details = [`Prepared tmux session ${tmuxContext.session}: cu-orchestrator + team1/team2/team3`, "Skipped orchestrator ClickUp MCP readiness check; no MCP slash commands were run", tools.length ? `Enabled ${tools.length} mcp_clickup_* tools opportunistically` : "No mcp_clickup_* tools visible yet; orchestrator should report blocked if ClickUp tools are unavailable"]; refresh(ctx); pi.sendUserMessage(buildKickoff(taskId, terminalBootstrap)); }
    catch (error) { const message = error instanceof Error ? error.message : String(error); state.tmuxStatus = "error"; state.cards.orchestrator.status = "blocked: harness startup failed"; state.cards.orchestrator.details = [message, "Fix the blocked startup step, then rerun /clickup-harness <task id or URL>"]; refresh(ctx); }
  }});

  pi.registerCommand("clickup-harness-clear", { description: "Hide and reset the Clickup Task Harness cards", handler: async (_args, ctx) => { state = defaults(); terminalBootstrap = undefined; refresh(ctx); } });

  pi.registerTool({ name: "clickup_task_harness_update_agent", label: "Update ClickUp Harness Card", description: "Update one of the seven Clickup Task Harness UI cards with status, task assignment, usage, cost, and details.", parameters: Type.Object({ agent: Type.Union([Type.Literal("orchestrator"), Type.Literal("worker1"), Type.Literal("worker2"), Type.Literal("worker3"), Type.Literal("reviewer1"), Type.Literal("reviewer2"), Type.Literal("reviewer3")]), status: Type.String(), details: Type.Optional(Type.Array(Type.String())), taskId: Type.Optional(Type.String()), mcpStatus: Type.Optional(Type.Union([Type.Literal("unknown"), Type.Literal("starting"), Type.Literal("running"), Type.Literal("error")])), tmuxStatus: Type.Optional(Type.Union([Type.Literal("unknown"), Type.Literal("inside"), Type.Literal("outside"), Type.Literal("error")])), herdrStatus: Type.Optional(Type.Union([Type.Literal("unknown"), Type.Literal("inside"), Type.Literal("outside")])), model: Type.Optional(Type.String()), tokens: Type.Optional(Type.Number()), cost: Type.Optional(Type.Number()) }), async execute(_toolCallId, params: any, _signal, _onUpdate, ctx) { if (!state.enabled) return { content: [{ type: "text", text: "ClickUp Task Harness is inactive. Run /clickup-harness <task id or URL> first." }] }; const card = state.cards[params.agent as AgentKind]; card.status = params.status; if (params.details) card.details = params.details; if (params.taskId) card.taskId = params.taskId; if (params.model) card.model = params.model; if (typeof params.tokens === "number") card.tokens = params.tokens; if (typeof params.cost === "number") card.cost = params.cost; if (params.mcpStatus) state.mcpStatus = params.mcpStatus; if (params.tmuxStatus) state.tmuxStatus = params.tmuxStatus; if (params.herdrStatus && !params.tmuxStatus) state.tmuxStatus = params.herdrStatus; refresh(ctx); return { content: [{ type: "text", text: `Updated ${card.name}: ${card.status}` }], details: { state } }; } });
}
