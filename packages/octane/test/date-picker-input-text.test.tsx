/** @jsxImportSource octane */
import * as React from "octane"
import { act, createRoot, type Root } from "octane"
import { afterEach, expect, test } from "vitest"
import { DatePicker, DatePickerInput } from "../src/date-picker"

Element.prototype.getAnimations ??= () => []

let root: Root | undefined

afterEach(async () => {
  await act(async () => root?.unmount())
  root = undefined
  document.body.innerHTML = ""
})

const type = (input: HTMLInputElement, text: string) =>
  act(async () => {
    Object.getOwnPropertyDescriptor(
      HTMLInputElement.prototype,
      "value"
    )!.set!.call(input, text)
    input.dispatchEvent(new Event("input", { bubbles: true }))
  })

test("clearing a date the app set reports null", async () => {
  const changes: unknown[] = []
  let pick: (date: string) => void = () => {}
  function Field() {
    const [value, setValue] = React.useState<string | null>(null)
    pick = setValue
    return (
      <DatePicker
        value={value}
        onValueChange={(next) => {
          changes.push(next)
          setValue(next as string | null)
        }}
      >
        <DatePickerInput aria-label="Due" />
      </DatePicker>
    )
  }
  const container = document.body.appendChild(document.createElement("div"))
  root = createRoot(container)
  await act(async () => root!.render(<Field />))
  const input = container.querySelector<HTMLInputElement>("input[type=text]")!
  await act(async () => pick("2026-03-14"))
  expect(input.value).not.toBe("")
  await act(async () => input.focus())
  await type(input, "")
  await act(async () => input.blur())
  expect(changes).toEqual([null])
})

test("a form reset keeps a controlled field's text with its value", async () => {
  let pick: (date: string) => void = () => {}
  function Field() {
    const [value, setValue] = React.useState<string | null>("2026-03-14")
    pick = setValue
    return (
      <form>
        <DatePicker
          value={value}
          onValueChange={(next) => setValue(next as string | null)}
        >
          <DatePickerInput aria-label="Due" />
        </DatePicker>
      </form>
    )
  }
  const container = document.body.appendChild(document.createElement("div"))
  root = createRoot(container)
  await act(async () => root!.render(<Field />))
  const input = container.querySelector<HTMLInputElement>("input[type=text]")!
  const march = input.value
  await act(async () => pick("2026-04-01"))
  const april = input.value
  expect(april).not.toBe(march)
  await act(async () => {
    container.querySelector("form")!.reset()
    await new Promise((resolve) => setTimeout(resolve, 10))
  })
  expect(input.value).toBe(april)
})

test("typing the text a form reset replaced reports it again", async () => {
  const changes: unknown[] = []
  const container = document.body.appendChild(document.createElement("div"))
  root = createRoot(container)
  await act(async () =>
    root!.render(
      <form>
        <DatePicker
          name="due"
          defaultValue="2026-03-14"
          onValueChange={(next) => changes.push(next)}
        >
          <DatePickerInput aria-label="Due" />
        </DatePicker>
      </form>
    )
  )
  const input = container.querySelector<HTMLInputElement>("input[type=text]")!
  const enter = async (text: string) => {
    await act(async () => input.focus())
    await type(input, text)
    await act(async () => input.blur())
  }
  await enter("04/01/2026")
  await act(async () => {
    container.querySelector("form")!.reset()
    await new Promise((resolve) => setTimeout(resolve, 10))
  })
  expect(input.value).toBe("03/14/2026")
  await enter("04/01/2026")
  expect(changes).toEqual(["2026-04-01", "2026-03-14", "2026-04-01"])
})
