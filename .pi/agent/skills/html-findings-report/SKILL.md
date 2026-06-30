---
name: html-findings-report
description: Create standalone HTML documents for findings, investigations, research summaries, code reviews, audits, and debugging reports using a Simple.css-based report style.
---

# HTML Findings Report

Use this skill whenever the user asks you to create an HTML file for findings, research, investigations, code reviews, audits, debugging notes, PR reviews, or similar technical reports.

The output should use the standalone Simple.css-based report pattern described below.

## Destination

- Prefer placing new report files in `investigations/` unless the user specifies another location.
- Use a descriptive kebab-case or existing-convention filename ending in `.html`.
- Do not overwrite an existing report unless the user explicitly asks.

## Required HTML Shell

Create a complete standalone HTML document:

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Report Title</title>
    <link rel="stylesheet" href="https://cdn.simplecss.org/simple.min.css" />
    <style>
      body {
        grid-template-columns: 1fr min(90%, 90%) 1fr;
      }
    </style>
  </head>

  <body>
    ...
  </body>
</html>
```

Follow the project's formatting convention: 4-space indentation, semantic HTML, and readable line wrapping.

## Document Structure

Use this high-level structure unless the user's requested report needs a better variant:

1. `<header>`
   - A short category label in a paragraph with `<strong>`, such as `Investigation`, `Code Review`, `Research Findings`, or `Scheduler Investigation`.
   - One clear `<h1>` report title.
   - One or two paragraphs summarizing the target, scope, or question answered.
   - A `<small>` metadata line listing reviewed code paths, documents, PRs, commands, or date when useful.
   - A required `<nav>` containing links to every top-level `<main>` section.

2. `<main>` with sections such as:
   - `Summary`
   - `Scope` or `Review scope`
   - `Findings`
   - `Recommended fix`, `Recommendations`, or `Next steps`
   - `Suggested acceptance check`, `Validation`, or `Testing notes`

3. `<footer>`
   - A concise note about the basis of the report, for example: local source review, tests run, production data not inspected, or assumptions.

## Header Navigation

Every report must include a navigation bar inside `<header>` linking to each top-level section in `<main>`.

- Add an `id` to every top-level `<section>`.
- Use short, title-case nav labels matching the section headings, such as `Summary`, `Findings`, `Recommended Fix`, and `Suggested Acceptance Check`.
- Place the `<nav>` after the introductory/metadata paragraphs and before `</header>`.
- Keep links in the same order as the sections.
- Use fragment links only; do not link to external pages from this nav.

Example:

```html
<header>
  <p><strong>Scheduler Investigation</strong></p>
  <h1>Month Planner · Template Team Added After Planning</h1>
  <p>
    Investigation target: a planned month where the template was later modified
    to add a required team.
  </p>
  <p>
    <small
      >Reviewed code paths in <code>getMonthPlan</code> · Investigated
      2026-06-30</small
    >
  </p>
  <nav>
    <a href="#summary">Summary</a>
    <a href="#findings">Findings</a>
    <a href="#recommended-fix">Recommended Fix</a>
    <a href="#suggested-acceptance-check">Suggested Acceptance Check</a>
  </nav>
</header>

<main>
  <section id="summary">
    <h2>Summary</h2>
    ...
  </section>
</main>
```

## Summary Section

Prefer a compact table for executive summary information:

```html
<section id="summary">
  <h2>Summary</h2>
  <table>
    <tbody>
      <tr>
        <th scope="row">Verdict</th>
        <td><strong>Short conclusion.</strong></td>
      </tr>
      <tr>
        <th scope="row">Impact</th>
        <td>User-visible or engineering impact.</td>
      </tr>
      <tr>
        <th scope="row">Root cause</th>
        <td>Brief cause if known.</td>
      </tr>
      <tr>
        <th scope="row">Fix shape</th>
        <td>High-level remediation.</td>
      </tr>
    </tbody>
  </table>
</section>
```

Adapt row labels to the report type. Good labels include `Verdict`, `Risk`, `Impact`, `Root cause`, `Recommendation`, `Status`, `Reviewed`, and `Fix shape`.

## Findings Style

Represent each major finding as an `<article>` inside a `Findings` section.

Use a `<mark>` label before the finding title when a severity or status helps scanning:

- `CONFIRMED`
- `ROOT CAUSE`
- `IMPORTANT`
- `HIGH RISK`
- `MEDIUM RISK`
- `LOW RISK`
- `RECOMMENDED`
- `FOLLOW-UP`

Finding pattern:

```html
<article>
  <mark>CONFIRMED</mark>
  <h3>Concise finding title</h3>
  <p>
    Explain the finding in plain language. Use <code>inlineCode</code> for
    symbols, paths, functions, tables, commands, and identifiers.
  </p>
  <blockquote>
    Evidence: cite reviewed files, functions, behavior, commands, or observed
    outputs. Be specific and avoid unsupported claims.
  </blockquote>
  <details open>
    <summary>Why this matters</summary>
    <ul>
      <li>Concrete implication.</li>
      <li>Concrete risk or user-facing effect.</li>
    </ul>
  </details>
</article>
```

Use `<details open>` blocks for drill-down evidence, relevant flows, edge cases, or rationale. Use `<ol>` for sequences and `<ul>` for unordered implications.

## Evidence and Code

- Use `<blockquote>` for evidence statements.
- Use `<code>` for inline symbols, file paths, functions, database columns, commands, and status values.
- Use `<pre><code>...</code></pre>` for multi-line snippets, simplified flows, SQL, logs, or pseudocode.
- Keep code snippets short and directly relevant.
- Escape HTML-sensitive characters inside code snippets: `&lt;`, `&gt;`, and `&amp;`.

## Mermaid Diagrams (Gantt, Flowcharts, etc.)

When a report embeds a Mermaid diagram, the diagram must stay readable in both light and dark color schemes. Simple.css switches to a dark background (`--bg: #212121`, `--text: #dcdcdc`) under `@media (prefers-color-scheme: dark)`, but Mermaid's default theme draws dark text meant for white pages — so unstyled diagrams become dark-on-dark and unreadable in dark mode.

### Required setup

1. Load Mermaid from CDN in `<head>`:

   ```html
   <script src="https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js"></script>
   ```

2. Initialize with a theme chosen from `window.matchMedia("(prefers-color-scheme: dark)")`, and pass `themeVariables` for both modes.

3. Wrap each diagram in a `<div class="mermaid">` inside a section. Add container styling (padding, border, background) so the chart is visually contained.

### Critical text-contrast rule

**Do not force all task/label text to a single color in light mode.** Mermaid uses separate variables for text *on* colored bars versus text *outside* bars (against the chart background):

- `taskTextLightColor` / `taskTextColor` — text rendered on top of colored task bars (use light/white).
- `taskTextDarkColor` — text rendered outside bars against the chart background (use dark in light mode).

Forcing `taskTextDarkColor: "#ffffff"` in light mode makes outside labels white-on-white and invisible. In light mode, **leave the `taskText*` / `textColor` / `labelTextColor` variables unset** so Mermaid's default light theme picks the correct contrast automatically. Only override the bar fills (`.task`, `.crit`).

In dark mode, force light text everywhere because the chart background is dark.

### Working pattern

```html
<style>
  .mermaid {
    overflow-x: auto;
    padding: 1rem;
    border-radius: 5px;
    border: 1px solid var(--border);
    background-color: var(--accent-bg);
  }
  @media (prefers-color-scheme: dark) {
    .mermaid { background-color: #181818; }
    .mermaid text { fill: #dcdcdc !important; }
    .mermaid .grid,
    .mermaid .grid path { stroke: #3a3a3a !important; }
    .mermaid .task { fill: #2b6cb0 !important; stroke: #4a90d9 !important; }
    .mermaid .taskText { fill: #fff !important; stroke: none !important; }
    .mermaid .taskTextOutsideRight,
    .mermaid .taskTextOutsideLeft { fill: #dcdcdc !important; }
    .mermaid .crit { fill: #c53030 !important; stroke: #f56565 !important; }
    .mermaid .crit > .taskText { fill: #fff !important; }
    .mermaid .section0,
    .mermaid .section2 { fill: #232323 !important; }
    .mermaid .section1,
    .mermaid .section3 { fill: #1c1c1c !important; }
  }
  @media (prefers-color-scheme: light) {
    .mermaid .task { fill: #3b82f6 !important; stroke: #1d4ed8 !important; }
    .mermaid .crit { fill: #dc2626 !important; stroke: #991b1b !important; }
    /* Do NOT override taskText here — let Mermaid keep outside labels dark. */
  }
</style>
```

```html
<script>
  const darkMode =
    window.matchMedia &&
    window.matchMedia("(prefers-color-scheme: dark)").matches;
  mermaid.initialize({
    startOnLoad: true,
    securityLevel: "loose",
    theme: darkMode ? "dark" : "default",
    themeVariables: darkMode
      ? {
          primaryColor: "#2b6cb0",
          primaryBorderColor: "#4a90d9",
          lineColor: "#ababab",
          textColor: "#dcdcdc",
          background: "#181818",
          mainBkg: "#2b6cb0",
          doneBkg: "#3182ce",
          critBkg: "#c53030",
          critBorderColor: "#f56565",
          gridColor: "#3a3a3a",
          taskTextColor: "#ffffff",
          taskTextDarkColor: "#ffffff",
          taskTextLightColor: "#ffffff",
          labelTextColor: "#ffffff",
          sectionBkgColor: "#232323",
          sectionBkgColor2: "#1c1c1c",
          altSectionBkgColor: "#1c1c1c",
        }
      : {
          /* Light mode: only set bar colors. Leave text variables unset so
             Mermaid keeps outside labels dark and on-bar labels light. */
          primaryColor: "#3b82f6",
          primaryBorderColor: "#1d4ed8",
          mainBkg: "#3b82f6",
          critBkg: "#dc2626",
          critBorderColor: "#991b1b",
        },
  });
</script>
```

### Gantt-specific notes

- ClickUp and many trackers expose only a due date, not a start date. Use one-day bars anchored on the due date (`task, id, YYYY-MM-DD, 1d`) rather than fabricating durations.
- Use `crit` for overdue or high-risk bars so they render in the critical-path color (red by default).
- Use `section` to group by assignee, team, or category.
- If the chart is wide, keep `.mermaid { overflow-x: auto }` so the page scrolls horizontally instead of clipping.

## Tone and Content Rules

- Be direct, evidence-based, and useful to an engineering reader.
- Separate confirmed facts from inferences or recommendations.
- Do not imply production data was inspected unless it was.
- Do not claim commands or tests passed unless they were actually run and passed.
- Prefer concrete remediation steps over vague advice.
- Preserve nuance: if a UI-only fix is insufficient, if a risk is conditional, or if a recommendation has tradeoffs, say so.

## Recommended Sections by Report Type

For debugging or investigations:

- `Summary`
- `Findings`
- `Recommended fix`
- `Suggested acceptance check`

For code reviews or PR reviews:

- `Summary`
- `Review scope`
- `Notable strengths` when appropriate
- `Findings`
- `Merge recommendation` or `Recommended changes`

For research reports:

- `Summary`
- `Research question`
- `Findings`
- `Options considered`
- `Recommendation`
- `Open questions`

## Accessibility and Validity

- Use semantic headings in order: one `<h1>`, section `<h2>` elements, article `<h3>` elements.
- Include a header `<nav>` with links to every top-level section.
- Give every top-level section a stable kebab-case `id` matching its heading, such as `summary`, `findings`, `recommended-fix`, or `suggested-acceptance-check`.
- Use `<th scope="row">` for summary table row headers.
- Avoid inline JavaScript and unnecessary custom CSS.
- Do not use Markdown syntax inside the HTML body unless intentionally shown inside code.
- Ensure the final file is valid HTML and can be opened directly in a browser.

## Validation

After creating or editing a report:

- If practical, run a formatter or project check only if it is appropriate for HTML files in the repository.
- At minimum, review the generated file for a complete HTML shell, consistent Simple.css link, and no accidental Markdown-only formatting.
