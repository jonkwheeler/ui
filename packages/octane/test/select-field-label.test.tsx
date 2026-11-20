/** @jsxImportSource octane */
import { act, createRoot, type Root } from "octane"
import { afterAll, afterEach, beforeAll, expect, test } from "vitest"
import { Field, FieldLabel } from "../src/field"
import { Select, SelectTrigger, SelectValue } from "../src/select"
import { LabelledTrigger } from "./select-field-label-app"
import { type Server, startServer, startTimeout } from "./server-html"

Element.prototype.getAnimations ??= () => []

let root: Root | undefined
let server: Server
let onServer: typeof import("./select-field-label-app")

beforeAll(async () => {
  server = await startServer()
  onServer = await server.load("./select-field-label-app.tsx")
}, startTimeout)

afterAll(() => server.close())

afterEach(async () => {
  await act(async () => root?.unmount())
  document.body.replaceChildren()
})

test("a select in a Field keeps the Field's label as its name", async () => {
  const container = document.body.appendChild(document.createElement("div"))
  root = createRoot(container)
  await act(async () =>
    root!.render(
      <Field>
        <FieldLabel>Fruit</FieldLabel>
        <Select items={["Apple", "Pear"]}>
          <SelectTrigger>
            <SelectValue />
          </SelectTrigger>
        </Select>
      </Field>
    )
  )
  await act(async () => new Promise((resolve) => setTimeout(resolve, 10)))
  const trigger = container.querySelector<HTMLElement>('[role="combobox"]')!
  const label = container.querySelector('[data-slot="field-label"]')!
  expect(trigger.getAttribute("aria-labelledby")?.split(" ")).toContain(
    label.id
  )
})

test("a trigger named by its own aria-labelledby keeps it, on the server too", async () => {
  expect(server.html(onServer.LabelledTrigger)).toContain(
    'aria-labelledby="fruit"'
  )
  const container = document.body.appendChild(document.createElement("div"))
  root = createRoot(container)
  await act(async () => root!.render(<LabelledTrigger />))
  await act(async () => new Promise((resolve) => setTimeout(resolve, 10)))
  expect(
    container
      .querySelector('[role="combobox"]')!
      .getAttribute("aria-labelledby")
  ).toBe("fruit")
})

const listNaming = () => {
  const list = document.querySelector('[role="listbox"]')!
  return [list.getAttribute("aria-label"), list.getAttribute("aria-labelledby")]
}

test("a list open from the start takes the name its trigger was given", async () => {
  const container = document.body.appendChild(document.createElement("div"))
  root = createRoot(container)
  await act(async () =>
    root!.render(
      <Select items={["Apple", "Pear"]} defaultOpen>
        <SelectTrigger aria-label="Fruit">
          <SelectValue />
        </SelectTrigger>
      </Select>
    )
  )
  await act(async () => new Promise((resolve) => setTimeout(resolve, 10)))
  expect(listNaming()).toEqual(["Fruit", null])
})

test("a list opened in a Field takes the Field's label as its name", async () => {
  const container = document.body.appendChild(document.createElement("div"))
  root = createRoot(container)
  await act(async () =>
    root!.render(
      <Field>
        <FieldLabel>Fruit</FieldLabel>
        <Select items={["Apple", "Pear"]}>
          <SelectTrigger>
            <SelectValue />
          </SelectTrigger>
        </Select>
      </Field>
    )
  )
  await act(async () => new Promise((resolve) => setTimeout(resolve, 10)))
  await act(async () =>
    container.querySelector<HTMLElement>('[role="combobox"]')!.click()
  )
  await act(async () => new Promise((resolve) => setTimeout(resolve, 10)))
  expect(listNaming()).toEqual(["Fruit", null])
})
