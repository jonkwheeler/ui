/** @jsxImportSource octane */
import * as React from "octane"
import { act, createRoot, type Root } from "octane"
import { afterEach, expect, test, vi } from "vitest"
import {
  Combobox,
  ComboboxContent,
  ComboboxInput,
  ComboboxItem,
  ComboboxItemText,
  ComboboxLabel,
  ComboboxList,
} from "../src/combobox"
import { Field, FieldControl, FieldError, FieldLabel } from "../src/field"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectItemText,
  SelectLabel,
  SelectList,
  SelectTrigger,
  SelectValue,
} from "../src/select"

Object.assign(globalThis, { IS_REACT_ACT_ENVIRONMENT: true })

let root: Root | undefined
let container: HTMLElement

afterEach(async () => {
  await act(async () => root?.unmount())
  root = undefined
  document.body.replaceChildren()
  vi.restoreAllMocks()
})

// Testing Library's `render` mounts in a synchronous act(). Octane's act stays
// open while it drains after returning, so an update left for after it changes
// the page without a warning.
async function updatesAfterRendering(ui: React.ReactElement) {
  const error = vi.spyOn(console, "error").mockImplementation(() => {})
  if (!root) {
    container = document.body.appendChild(document.createElement("div"))
    root = createRoot(container)
  }
  act(() => root!.render(ui))
  const rendered = container.innerHTML
  await new Promise((resolve) => setTimeout(resolve, 20))
  const updates = error.mock.calls
    .filter(([message]) => String(message).includes("not wrapped in act("))
    .map(([message]) => String(message))
  if (container.innerHTML !== rendered) {
    updates.push(container.innerHTML)
  }
  return updates
}

const field = (error: boolean) => (
  <Field>
    <FieldLabel>Name</FieldLabel>
    <FieldControl />
    {error && <FieldError match>Required</FieldError>}
  </Field>
)

const select = (open: boolean) => (
  <Select defaultOpen={open}>
    <SelectLabel>Fruit</SelectLabel>
    <SelectTrigger>
      <SelectValue />
    </SelectTrigger>
    <SelectContent>
      <SelectList>
        <SelectItem value="apple">
          <SelectItemText>Apple</SelectItemText>
        </SelectItem>
      </SelectList>
    </SelectContent>
  </Select>
)

const combobox = (
  <Combobox items={["Apple"]}>
    <ComboboxLabel>Fruit</ComboboxLabel>
    <ComboboxInput />
    <ComboboxContent>
      <ComboboxList>
        <ComboboxItem value="Apple">
          <ComboboxItemText>Apple</ComboboxItemText>
        </ComboboxItem>
      </ComboboxList>
    </ComboboxContent>
  </Combobox>
)

test.each([
  ["an input in a field", field(true)],
  [
    "a closed select in a field",
    <Field>
      <FieldLabel>Fruit</FieldLabel>
      {select(false)}
    </Field>,
  ],
  ["an open select", select(true)],
  ["a combobox", combobox],
])(
  "mounting %s in a synchronous act() leaves no updates for after it",
  async (_, ui) => {
    expect(await updatesAfterRendering(ui)).toEqual([])
  }
)

test("a field's error rendering in a later synchronous act() leaves no updates for after it", async () => {
  expect(await updatesAfterRendering(field(false))).toEqual([])
  expect(await updatesAfterRendering(field(true))).toEqual([])
})
