/** @jsxImportSource octane */
import * as React from "octane"
import { act, createRoot, type Root } from "octane"
import { afterEach, expect, test } from "vitest"
import { DateInput } from "../src/date-input"
import { TimeInput } from "../src/time-input"

let root: Root | undefined

afterEach(async () => {
  await act(async () => root?.unmount())
  document.body.innerHTML = ""
})

async function render(node: React.ReactElement) {
  const form = document.body.appendChild(document.createElement("form"))
  const heard: string[] = []
  for (const type of ["input", "change"]) {
    form.addEventListener(type, (event) => {
      heard.push(`${type} ${(event.target as HTMLInputElement).name}`)
    })
  }
  root = createRoot(form)
  await act(async () => root!.render(node))
  return { form, heard }
}

const segment = (form: HTMLElement, type: string) =>
  form.querySelector<HTMLInputElement>(`input[data-type="${type}"]`)!

async function press(el: HTMLElement, key: string) {
  await act(async () => {
    el.focus()
    el.dispatchEvent(
      new KeyboardEvent("keydown", { key, bubbles: true, cancelable: true })
    )
    await Promise.resolve()
  })
}

async function type(text: string) {
  for (const char of text) {
    await act(async () => {
      document.activeElement!.dispatchEvent(
        new InputEvent("beforeinput", {
          inputType: "insertText",
          data: char,
          bubbles: true,
          cancelable: true,
        })
      )
      await Promise.resolve()
    })
  }
}

test("a user's change to a date fires input and change on the form", async () => {
  const { form, heard } = await render(
    <DateInput
      name="date"
      aria-label="Date"
      defaultValue="2026-11-12"
      locale="en-US"
    />
  )
  await press(segment(form, "month"), "ArrowUp")
  expect(new FormData(form).get("date")).toBe("2026-12-12")
  expect(heard).toEqual(["input date", "change date"])
  heard.length = 0
  segment(form, "day").focus()
  await type("15")
  expect(new FormData(form).get("date")).toBe("2026-12-15")
  expect(heard).toEqual(["input date", "change date"])
})

test("a user's change to a time fires input and change on the form", async () => {
  const { form, heard } = await render(
    <TimeInput
      name="time"
      aria-label="Time"
      defaultValue="09:30"
      locale="en-US"
    />
  )
  await press(segment(form, "hour"), "ArrowUp")
  expect(new FormData(form).get("time")).toBe("10:30")
  expect(heard).toEqual(["input time", "change time"])
})

test("a form reset fires no change events", async () => {
  const { form, heard } = await render(
    <DateInput
      name="date"
      aria-label="Date"
      defaultValue="2026-11-12"
      locale="en-US"
    />
  )
  await press(segment(form, "month"), "ArrowUp")
  heard.length = 0
  await act(async () => {
    form.reset()
    await new Promise((resolve) => setTimeout(resolve, 20))
  })
  expect(new FormData(form).get("date")).toBe("2026-11-12")
  expect(heard).toEqual([])
})
