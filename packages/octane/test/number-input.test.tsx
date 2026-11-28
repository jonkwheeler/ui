/** @jsxImportSource octane */
import * as React from "octane"
import { act, createRoot, type Root } from "octane"
import { afterEach, expect, test } from "vitest"
import {
  NumberInput,
  NumberInputControl,
  NumberInputGroup,
} from "../src/number-input"

let root: Root | undefined

afterEach(async () => {
  await act(async () => root?.unmount())
  document.body.innerHTML = ""
})

test("clearing a field stepped from empty reports null", async () => {
  const changes: (number | null)[] = []
  function Field() {
    const [value, setValue] = React.useState<number | null>(null)
    return (
      <NumberInput
        value={value}
        onValueChange={(next) => {
          changes.push(next)
          setValue(next)
        }}
      >
        <NumberInputGroup>
          <NumberInputControl aria-label="Amount" />
        </NumberInputGroup>
      </NumberInput>
    )
  }
  const container = document.body.appendChild(document.createElement("div"))
  root = createRoot(container)
  await act(async () => root!.render(<Field />))
  const input = container.querySelector<HTMLInputElement>("input[type=text]")!
  await act(async () => input.focus())
  await act(async () => {
    input.dispatchEvent(
      new KeyboardEvent("keydown", { key: "ArrowUp", bubbles: true })
    )
    input.dispatchEvent(
      new KeyboardEvent("keyup", { key: "ArrowUp", bubbles: true })
    )
  })
  expect(input.value).toBe("1")
  await act(async () => {
    Object.getOwnPropertyDescriptor(
      HTMLInputElement.prototype,
      "value"
    )!.set!.call(input, "")
    input.dispatchEvent(new Event("input", { bubbles: true }))
  })
  await act(async () => input.blur())
  expect(changes).toEqual([1, null])
})

test("a form reset keeps a controlled field's text with its value", async () => {
  function Field() {
    const [value, setValue] = React.useState<number | null>(5)
    return (
      <form>
        <NumberInput value={value} onValueChange={setValue}>
          <NumberInputGroup>
            <NumberInputControl aria-label="Amount" />
          </NumberInputGroup>
        </NumberInput>
      </form>
    )
  }
  const container = document.body.appendChild(document.createElement("div"))
  root = createRoot(container)
  await act(async () => root!.render(<Field />))
  const input = container.querySelector<HTMLInputElement>("input[type=text]")!
  await act(async () => input.focus())
  await act(async () => {
    input.dispatchEvent(
      new KeyboardEvent("keydown", { key: "ArrowUp", bubbles: true })
    )
    input.dispatchEvent(
      new KeyboardEvent("keyup", { key: "ArrowUp", bubbles: true })
    )
  })
  expect(input.value).toBe("6")
  await act(async () => {
    container.querySelector("form")!.reset()
    await new Promise((resolve) => setTimeout(resolve))
  })
  expect(input.value).toBe("6")
})

test("typing the text a form reset replaced reports it again", async () => {
  const changes: (number | null)[] = []
  const container = document.body.appendChild(document.createElement("div"))
  root = createRoot(container)
  await act(async () =>
    root!.render(
      <form>
        <NumberInput
          defaultValue={5}
          onValueChange={(next) => changes.push(next)}
        >
          <NumberInputGroup>
            <NumberInputControl aria-label="Amount" />
          </NumberInputGroup>
        </NumberInput>
      </form>
    )
  )
  const input = container.querySelector<HTMLInputElement>("input[type=text]")!
  const type = async (text: string) => {
    await act(async () => input.focus())
    await act(async () => {
      Object.getOwnPropertyDescriptor(
        HTMLInputElement.prototype,
        "value"
      )!.set!.call(input, text)
      input.dispatchEvent(new Event("input", { bubbles: true }))
    })
    await act(async () => input.blur())
  }
  await type("7")
  await act(async () => {
    container.querySelector("form")!.reset()
    await new Promise((resolve) => setTimeout(resolve))
  })
  expect(input.value).toBe("5")
  await type("7")
  expect(changes).toEqual([7, 5, 7])
})
