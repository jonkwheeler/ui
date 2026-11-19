// @vitest-environment jsdom
import { afterEach, expect, test } from "vitest"
import { combobox } from "../src/components/combobox/combobox"
import { field } from "../src/components/field/field"
import { bind } from "../src/foundation/kernel/part"
import { comboboxChips } from "../src/renderer"
import { mount } from "../src/testing/mount"

let cleanups: (() => void)[] = []
afterEach(() => {
  cleanups.splice(0).forEach((cleanup) => cleanup())
})

async function mountInField(chipsName?: string) {
  const view = mount(
    field,
    { name: "tags" },
    `<root><label>Tags</label></root>`
  )
  const instance = combobox({
    id: "tags",
    multiple: true,
    defaultValue: ["a"],
    items: [{ value: "a", label: "Alpha" }],
  })
  instance.use(comboboxChips)
  const chips = document.createElement("div")
  if (chipsName) {
    chips.setAttribute("aria-labelledby", chipsName)
  }
  const input = chips.appendChild(document.createElement("input"))
  view.root.append(chips)
  cleanups.push(
    bind(instance.part("chips"), chips),
    bind(instance.part("input"), input),
    () => instance.destroy(),
    () => view.unmount()
  )
  await new Promise((resolve) => setTimeout(resolve, 0))
  return { chips, input, label: view.root.querySelector("label")! }
}

test("inside a Field, the chips toolbar takes the name the field's label gives the input", async () => {
  const { chips, input, label } = await mountInField()
  expect(input.getAttribute("aria-labelledby")).toBe(label.id)
  expect(chips.getAttribute("aria-labelledby")).toBe(label.id)
})

test("a name the author gave the chips toolbar stays", async () => {
  const { chips } = await mountInField("own-name")
  expect(chips.getAttribute("aria-labelledby")).toBe("own-name")
})
