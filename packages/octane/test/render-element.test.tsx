/** @jsxImportSource octane */
import { Activity, act, createRoot, type Root } from "octane"
import { afterEach, expect, test } from "vitest"
import { Field } from "../src/field"
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

test("a part renders children that hold an <Activity>", async () => {
  function Page(props: { mode: "visible" | "hidden" }) {
    return (
      <Field>
        <b>before</b>
        <Activity mode={props.mode}>
          <span>shown</span>
        </Activity>
      </Field>
    )
  }
  const container = document.body.appendChild(document.createElement("div"))
  root = createRoot(container)
  await act(async () => root!.render(<Page mode="visible" />))
  expect(container.querySelector("span")?.textContent).toBe("shown")
})

test("a part renders text children written inside a list", async () => {
  function Page() {
    return (
      <div>
        {[1, 2].map((n) => (
          <Field key={n}>Item {n}</Field>
        ))}
      </div>
    )
  }
  const container = document.body.appendChild(document.createElement("div"))
  root = createRoot(container)
  await act(async () => root!.render(<Page />))
  expect(container.textContent).toBe("Item 1Item 2")
})
