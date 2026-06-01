/**
 * Intent Overlay — OpenCode hard gate (template).
 *
 * The installer copies this into ~/.config/opencode/plugins/, resolving the GATE constant below to
 * the absolute path of the installed check-intent-frozen.sh. The plugin blocks code-mutating tool
 * calls when no frozen Intent Contract exists for the project.
 *
 * Known limitation (opencode#5894): tool.execute.before does NOT intercept tool calls made by
 * subagents spawned via the task tool. For those, the gate is best-effort and the always-on
 * instruction plane (AGENTS.md) plus opencode.json `permission` are the backstop.
 */
import type { Plugin } from "@opencode-ai/plugin"
import { execFileSync } from "node:child_process"

const GATE = "__GATE__"
const GUARDED = new Set(["edit", "write", "apply_patch"])

export const IntentGate: Plugin = async () => ({
  "tool.execute.before": async (input: { tool: string }) => {
    if (!GUARDED.has(input.tool)) return
    try {
      execFileSync("bash", [GATE], { stdio: "ignore" })
    } catch {
      throw new Error(
        "Intent Overlay: no frozen Intent Contract — freeze it before editing code " +
          "(intent-overlay freeze <change>), or set INTENT_OVERLAY_BYPASS=1 to override.",
      )
    }
  },
})
