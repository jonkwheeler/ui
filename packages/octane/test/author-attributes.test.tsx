/** @jsxImportSource octane */
import * as React from "octane"
import { act, createRoot, type Root } from "octane"
import { afterEach, expect, test } from "vitest"
import { Combobox, ComboboxInput, ComboboxLabel } from "../src/combobox"
import { Field, FieldLabel } from "../src/field"
import { Select, SelectLabel, SelectTrigger, SelectValue } from "../src/select"

Element.prototype.getAnimations ??= () => []
HTMLElement.prototype.showPopover ??= function () {}
HTMLElement.prototype.hidePopover ??= function () {}

let root: Root | undefined

async function render(element: React.ReactElement) {
  const container = document.body.appendChild(document.createElement("div"))
  root = createRoot(container)
  await act(async () => root!.render(element))
  return container
}

afterEach(async () => {
  await act(async () => root?.unmount())
  root = undefined
  document.body.replaceChildren()
})

test("a trigger keeps the label it's given after the select's own label mounts", async () => {
  const view = await render(
    <>
      <span id="mine">Plan</span>
      <Select items={["Free", "Pro"]}>
        <SelectLabel>Tier</SelectLabel>
        <SelectTrigger aria-labelledby="mine">
          <SelectValue />
        </SelectTrigger>
      </Select>
    </>
  )
  await act(async () => new Promise((resolve) => setTimeout(resolve, 20)))
  expect(view.querySelector("button")!.getAttribute("aria-labelledby")).toBe(
    "mine"
  )
})

test("a field's label names a combobox input over the combobox's own label", async () => {
  const view = await render(
    <Field>
      <FieldLabel>Fruit</FieldLabel>
      <Combobox>
        <ComboboxLabel>Pick one</ComboboxLabel>
        <ComboboxInput />
      </Combobox>
    </Field>
  )
  const label = view.querySelector('[data-slot="field-label"]')!
  expect(view.querySelector("input")!.getAttribute("aria-labelledby")).toBe(
    label.id
  )
})

test("a combobox input inside a labelled field keeps the label reference passed to it", async () => {
  const view = await render(
    <>
      <span id="mine">Favorite</span>
      <Field>
        <FieldLabel>Fruit</FieldLabel>
        <Combobox>
          <ComboboxLabel>Pick one</ComboboxLabel>
          <ComboboxInput aria-labelledby="mine" />
        </Combobox>
      </Field>
    </>
  )
  expect(view.querySelector("input")!.getAttribute("aria-labelledby")).toBe(
    "mine"
  )
})
