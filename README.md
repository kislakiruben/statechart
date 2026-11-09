# statechart for Claude Code

A [Claude Code](https://claude.com/claude-code) skill that checks a [TLA+](https://lamport.azurewebsites.net/tla/tla.html) model of a system that moves between states (a product flow, a protocol, a service) with the TLC model checker, and draws it as a Mermaid statechart. The report gives the shortest path to each state that breaks a rule.

This is an unofficial port of the `statechart` skill from [cursor/plugins](https://github.com/cursor/plugins/tree/main/pstack/skills/statechart) (`pstack`), by Lauren Tan, MIT licensed. It is not maintained by or affiliated with Cursor.

## What changed from upstream

The first commit is the upstream skill, unchanged. Everything after it is the port, so `git diff HEAD~1 -- . ':!README.md'` shows all of it:

- **No host Java.** Upstream installs Java and TLC with `mise`. Here `scripts/docker-java` stands in for `java` and runs each TLC call in a throwaway container (`docker/Dockerfile`: Temurin 21 JRE plus a checksum-pinned `tla2tools.jar` 1.7.4, no network at run time). Set `TLA2TOOLS` and `JAVA` to use a local Java instead.
- **No Pele.** Charts are shown as Mermaid code blocks, rendered as a Claude Artifact page or with mermaid-cli (`references/render.md`).
- **SKILL.md** is upstream's text with the Run and Show sections adapted for Claude Code.

## Install

```sh
git clone git@github.com:kislakiruben/statechart.git ~/.claude/skills/statechart
```

Needs Docker and Node 22.18+ (or Node 23.6+, Bun 1.1.5+, Deno 2+). The first run builds the image `statechart-tlc:1.7.4`, which takes about half a minute.

The skill has `disable-model-invocation: true`, so it runs only when you type `/statechart`.

## Run it by hand

```sh
~/.claude/skills/statechart/scripts/statechart SPEC.tla --config SPEC.cfg --view view.ts --out out
```

This writes `out/chart.mmd`, `out/report.md` and `out/tlc.out`. It exits with 0 when every rule holds, 1 when a rule breaks and 2 on an error.

## How the code works

It is laid out like a small compiler: TLC's output goes in, a graph in memory is transformed in passes, and files come out. Read it in this order.

| Step | File | What it does |
| --- | --- | --- |
| 1. CLI | `scripts/statechart` → `statechart.ts` | The shell launcher picks a TypeScript runtime (and, in this port, Docker). `statechart.ts` parses flags, starts `worker.ts` in its own process group so Ctrl-C can kill TLC cleanly, and moves the finished files into `--out`. |
| 2. Worker | `worker.ts` | Imports your view module, checks it (`frontends/view.ts`), runs the check, compiles the result and writes the files. |
| 3. Run TLC | `run.ts` → `check()` | Runs SANY (the TLA+ parser) to read the spec, then TLC with pinned flags (`-workers 1 -fp 0`, so runs are repeatable) and `-dump dot`, which writes the whole state graph. When a rule breaks, it drops that rule from a generated config and runs TLC again, until nothing breaks, with a 100,000-state limit after the first break. |
| 4. Read TLC | `frontends/` | `messages.ts` splits TLC's output into tagged messages, `dot.ts` parses the state graph dump, `value.ts` parses TLA+ values (sets, records, sequences), and `trace.ts`, `marks.ts` and `verdict.ts` pull out counterexamples and which rule broke. `config.ts` and `spec.ts` read the `.cfg` file and SANY's XML. |
| 5. IR | `ir.ts` | The shared types: `Graph` (model states and steps), `Walk`, `Chart`, `Bug` and so on. Read this before the passes. |
| 6. Passes | `pipeline.ts` → `passes/` | `reach.ts` does a breadth-first search from the start states, giving shortest paths and the bugs. `label.ts` asks your view for `state()` and `step()` once per state or step and merges model states into chart states. `annotate.ts` marks `breaks` and `mayBreak`. `regions.ts` and `region-check.ts` build parallel regions and fall back to nested states when regions would mislead. `loop-check.ts` and `lift.ts` tidy the chart. |
| 7. Output | `backends/` | `mermaid.ts` writes `chart.mmd`, `report.ts` writes `report.md`, `plain-text.ts` writes `tlc.out`, and `cfg.ts` writes the configs for reruns. |

`scripts/test/` holds the tests, including property-based tests with fast-check. `chart.test.ts` and `cli.test.ts` are the best place to see what the chart and the command promise. Run them with `cd scripts && npm install && npm test`. The tests that run TLC are skipped unless `TLA2TOOLS` is set. To run them through Docker: `TLA2TOOLS=/opt/tla/tla2tools.jar JAVA=$PWD/docker-java npm test`.

## License

MIT. See [LICENSE](LICENSE). The original copyright belongs to Lauren Tan, and the port changes are under the same license.
