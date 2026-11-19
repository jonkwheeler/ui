/** @jsxImportSource octane */
import { act, createRoot, type Root } from "octane"
import { afterEach, expect, test } from "vitest"
import {
  Field,
  FieldControl,
  FieldDescription,
  FieldLegend,
  FieldSet,
} from "../src/field"

let root: Root | undefined

afterEach(async () => {
  await act(async () => root?.unmount())
  root = undefined
  document.body.replaceChildren()
})

const texts = (el: Element) =>
  (el.getAttribute("aria-describedby") ?? "")
    .split(" ")
    .filter(Boolean)
    .map((id) => document.getElementById(id)?.textContent)

test("each description gets an id of its own, and the control names them all", async () => {
  const container = document.body.appendChild(document.createElement("div"))
  await act(async () => {
    root = createRoot(container)
    root.render(
      <Field>
        <FieldDescription>First</FieldDescription>
        <FieldControl />
        <FieldDescription>Second</FieldDescription>
      </Field>
    )
  })
  await act(() => new Promise((resolve) => setTimeout(resolve, 20)))
  const ids = [
    ...container.querySelectorAll('[data-slot="field-description"]'),
  ].map((el) => el.id)
  expect(new Set(ids).size).toBe(2)
  expect(texts(container.querySelector("input")!)).toEqual(["First", "Second"])
})

test("each description of a field set gets an id of its own", async () => {
  const container = document.body.appendChild(document.createElement("div"))
  await act(async () => {
    root = createRoot(container)
    root.render(
      <FieldSet>
        <FieldLegend>Address</FieldLegend>
        <FieldDescription>First</FieldDescription>
        <FieldDescription>Second</FieldDescription>
      </FieldSet>
    )
  })
  await act(() => new Promise((resolve) => setTimeout(resolve, 20)))
  expect(texts(container.querySelector("fieldset")!)).toEqual([
    "First",
    "Second",
  ])
})
