/** @jsxImportSource octane */
import { act, createRoot, type Root } from "octane"
import { afterEach, expect, test } from "vitest"
import { mergeProps, renderElement } from "../src/primitive"

let root: Root | undefined

afterEach(async () => {
  await act(async () => root?.unmount())
  root = undefined
  document.body.replaceChildren()
})

// A button whose props merge an earlier and a later source, as a part's own
// props merge with the user's.
async function renderMerged(
  earlier: Record<string, unknown>,
  later: Record<string, unknown>
) {
  function Merged() {
    return renderElement("button", mergeProps(earlier, later))
  }
  const container = document.body.appendChild(document.createElement("div"))
  root = createRoot(container)
  await act(async () => root!.render(<Merged />))
  return container.querySelector("button")!
}

test("the later of two merged click handlers runs first", async () => {
  const calls: string[] = []
  const button = await renderMerged(
    { onClick: () => calls.push("earlier") },
    { onClick: () => calls.push("later") }
  )
  await act(async () => button.click())
  expect(calls).toEqual(["later", "earlier"])
})

test("preventDefault() on the native event in the later handler skips the earlier one", async () => {
  const calls: string[] = []
  const button = await renderMerged(
    { onClick: () => calls.push("earlier") },
    {
      onClick: (event: Event) => {
        calls.push(event instanceof MouseEvent ? "native" : "other")
        event.preventDefault()
      },
    }
  )
  await act(async () => button.click())
  expect(calls).toEqual(["native"])
})

test("merged class names are joined", async () => {
  const button = await renderMerged(
    { className: "part" },
    { className: "user" }
  )
  expect(button.className).toBe("part user")
})
