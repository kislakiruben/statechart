# Render a chart

In Claude Code, prefer one of these, in order:

1. **Artifact page.** When the Artifact tool is available, publish an HTML page that renders each `.mmd` with Mermaid from `https://cdn.jsdelivr.net/npm/mermaid@11.4.1/dist/mermaid.min.js`, with `startOnLoad: false`, `securityLevel: "strict"`, `maxEdges: 10000` and `maxTextSize: 1000000`, so that a chart of 500 states fits. Put the Mermaid text in a `<pre class="mermaid">` element, escaped as HTML. Next to each chart, put the hand-off: one line for each bug, and the bug paths from the report. Load the `artifact-design` skill first.
2. **SVG file.** When the user wants a file, render each `.mmd` outside the repo with `npx -y @mermaid-js/mermaid-cli@11.4.2 -i chart.mmd -o chart.svg -c config.json`, where `config.json` is `{"maxEdges": 10000, "maxTextSize": 1000000}`. Write each SVG next to its `.mmd` file, with the same name. If the render fails, show the user the Mermaid text and the error.

## Colors

The command gives each state the color class of its group, such as `class sN teal`. It marks each bad state with `class sN breaks` or `class sN mayBreak`, each state on the shortest path to a bug with `class sN bugPath`, and each state that a PROPERTY counterexample repeats forever with `class sN repeats`.

The `.mmd` file has a `classDef` line for `breaks` and for `mayBreak`, so any Mermaid viewer shows the bug marks. It has no `classDef` for the group colors, `bugPath` or `repeats`. Before you render, add these lines to a copy of the chart. Put the mark lines last, so that a mark shows over the group color.

```
classDef blue fill:#c3e0ff
classDef orange fill:#f0d3bf
classDef purple fill:#e3d5ff
classDef yellow fill:#f0dcbf
classDef teal fill:#bfe3df
classDef tan fill:#e5d9ce
classDef pink fill:#ffcbe6
classDef bugPath stroke:#1680f3,stroke-width:2.5px
classDef repeats stroke:#9b35d6,stroke-width:2.5px,stroke-dasharray:6 3
```

For a dark page: blue `#1b3857`, orange `#573117`, purple `#3c2e57`, yellow `#573d17`, teal `#174641`, tan `#3d3127`, pink `#57233e`, bugPath stroke `#116dd2`, repeats stroke `#9a3fcf`, breaks fill `#2e2021` stroke `#cf2b35` text `#ff6463`, mayBreak fill `#2e2619` stroke `#d0700f` text `#ffa257`.
