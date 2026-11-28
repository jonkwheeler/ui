/** @jsxImportSource octane */
import { act, createRoot, type Root } from "octane"
import { afterEach, expect, test } from "vitest"
import { menu } from "@ui-sdk/core/menu"
import { usePart, usePrimitive, type PrimitiveHandle } from "../src/primitive"

let root: Root | undefined

afterEach(async () => {
  await act(async () => root?.unmount())
  root = undefined
  document.body.replaceChildren()
})

test("a closed menu stays asleep when its trigger and content render", async () => {
  let handle: PrimitiveHandle<typeof menu> | undefined
  function ClosedMenu() {
    handle = usePrimitive(menu, { id: "file" })
    return (
      <>
        {usePart(handle, "trigger", {}, { children: "File" })}
        {usePart(handle, "content", {}, {})}
      </>
    )
  }
  const container = document.body.appendChild(document.createElement("div"))
  root = createRoot(container)
  await act(async () => root!.render(<ClosedMenu />))
  const asleep =
    (handle!.instance.part("trigger") as { api?: unknown }).api === undefined
  expect(asleep).toBe(true)
})
