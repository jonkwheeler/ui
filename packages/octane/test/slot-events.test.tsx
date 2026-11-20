/** @jsxImportSource octane */
import { definePrimitive } from "@ui-sdk/core"
import { act, createRoot, type Root } from "octane"
import { afterEach, expect, test } from "vitest"
import { usePart, usePrimitive } from "../src/primitive"

let root: Root | undefined

afterEach(async () => {
  await act(async () => root?.unmount())
  root = undefined
  document.body.replaceChildren()
})

const heard: string[] = []
const probe = definePrimitive({
  name: "probe",
  state: (_options: {}) => ({}),
  api: () => ({}),
  slots: (slot) => ({
    root: slot({
      on: {
        focus: () => heard.push("focus"),
        blur: () => heard.push("blur"),
        wheel: () => heard.push("wheel"),
        keydown: () => heard.push("keydown"),
      },
    }),
  }),
})

function Probe() {
  return usePart(
    usePrimitive(probe, {}),
    "root",
    {},
    { children: "Probe" },
    "button"
  )
}

test("a slot's handlers run for event types Octane has no prop mapping for", async () => {
  const container = document.body.appendChild(document.createElement("div"))
  root = createRoot(container)
  await act(async () => root!.render(<Probe />))
  const button = container.querySelector("button")!
  button.focus()
  button.dispatchEvent(new WheelEvent("wheel", { bubbles: true }))
  button.dispatchEvent(
    new KeyboardEvent("keydown", { key: "a", bubbles: true })
  )
  button.blur()
  expect(heard).toEqual(["focus", "wheel", "keydown", "blur"])
})
