/** @jsxImportSource octane */
import { definePrimitive } from "@ui-sdk/core"
import { act, createRoot, type Root } from "octane"
import { afterEach, expect, test } from "vitest"
import { createAgent } from "../src/agent"
import { createParts } from "../src/primitive"

let root: Root | undefined
afterEach(async () => {
  await act(async () => root?.unmount())
  root = undefined
  document.body.replaceChildren()
})

const ran: string[] = []

const shell = definePrimitive({
  name: "shell",
  state: () => ({}),
  api: () => ({
    run: (command: string, flag?: { verbose: boolean }) => {
      ran.push(flag?.verbose ? `${command} -v` : command)
    },
  }),
  slots: (slot) => ({ root: slot({ attrs: () => ({ role: "group" }) }) }),
  agent: { actions: ["run"] },
})
const { Root: Shell } = createParts(shell, { root: "div" })

test("a component's own run action gets its arguments as written", async () => {
  root = createRoot(document.body.appendChild(document.createElement("div")))
  await act(async () => root!.render(<Shell aria-label="Shell" />))
  const agent = createAgent()
  const result = await agent.act({
    steps: [
      { ref: "Shell", action: "run", args: ["ls"] },
      { ref: "Shell", action: "run", args: ["pwd", { verbose: true }] },
    ],
  })
  expect(result.ok).toBe(true)
  expect(ran).toEqual(["ls", "pwd -v"])
})
