/** @jsxImportSource octane */
import { act, Activity, createRoot, type Root } from "octane"
import { afterEach, expect, test } from "vitest"
import { Field, FieldControl, FieldError } from "../src/field"

Element.prototype.getAnimations ??= () => []

let root: Root | undefined
const container = () => document.body.firstElementChild as HTMLElement

afterEach(async () => {
  await act(async () => root?.unmount())
  root = undefined
  document.body.replaceChildren()
})

const page = ({
  mode,
  shown,
}: {
  mode: "visible" | "hidden"
  shown: [boolean, boolean]
}) => (
  <Field invalid>
    <FieldControl />
    <Activity mode={mode}>
      <FieldError match={shown[0]}>A</FieldError>
    </Activity>
    <FieldError match={shown[1]}>B</FieldError>
  </Field>
)

const described = () => {
  const ids = [
    ...container().querySelectorAll('[data-slot="field-error"]'),
  ].map((error) => error.id)
  const names = (
    container().querySelector("input")!.getAttribute("aria-describedby") ?? ""
  )
    .split(" ")
    .filter(Boolean)
    .map((id) => document.getElementById(id)?.textContent)
  return { ids, names }
}

const settle = () =>
  act(() => new Promise((resolve) => setTimeout(resolve, 100)))

test("errors keep their own ids and descriptions as they flip or hide", async () => {
  const steps: [Parameters<typeof page>[0], string[]][] = [
    [{ mode: "visible", shown: [true, true] }, ["A", "B"]],
    [{ mode: "hidden", shown: [true, true] }, ["B"]],
    [{ mode: "visible", shown: [true, true] }, ["A", "B"]],
    [{ mode: "visible", shown: [false, true] }, ["B"]],
    [{ mode: "visible", shown: [true, true] }, ["A", "B"]],
  ]
  document.body.append(document.createElement("div"))
  root = createRoot(container())
  for (const [props, names] of steps) {
    await act(async () => root!.render(page(props)))
    await settle()
    const state = described()
    expect(new Set(state.ids).size, JSON.stringify(props)).toBe(
      state.ids.length
    )
    expect([...state.names].sort(), JSON.stringify(props)).toEqual(names)
  }
})
