/** @jsxImportSource octane */
import * as React from "octane"
import { act, createRoot, flushSync, type Root } from "octane"
import { afterEach, expect, test } from "vitest"
import {
  Select,
  SelectContent,
  SelectInput,
  SelectItem,
  SelectList,
  SelectTrigger,
  SelectValue,
} from "../src/select"

let root: Root | undefined

afterEach(async () => {
  await act(async () => root?.unmount())
  root = undefined
  document.body.replaceChildren()
})

const fruits = ["Apple", "Banana", "Cherry", "Mango", "Orange", "Grape"]

function Fruits() {
  const [query, setQuery] = React.useState("")
  const shown = fruits.filter((fruit) =>
    fruit.toLowerCase().includes(query.toLowerCase())
  )
  return (
    <Select defaultOpen filter={false}>
      <SelectTrigger aria-label="Fruit">
        <SelectValue />
      </SelectTrigger>
      <SelectContent>
        <SelectInput
          aria-label="Search fruits"
          render={
            <input
              value={query}
              onInput={(event) => {
                const next = event.currentTarget.value
                flushSync(() => setQuery(next))
              }}
            />
          }
        />
        <SelectList>
          {shown.map((fruit) => (
            <SelectItem key={fruit} value={fruit}>
              {fruit}
            </SelectItem>
          ))}
        </SelectList>
      </SelectContent>
    </Select>
  )
}

const settle = () => new Promise((resolve) => setTimeout(resolve, 20))

test("a search field that flushes its filter in onInput still moves the highlight to the first match", async () => {
  root = createRoot(document.body.appendChild(document.createElement("div")))
  await act(async () => {
    root!.render(<Fruits />)
    await settle()
  })
  const input = document.querySelector<HTMLInputElement>(
    'input[aria-label="Search fruits"]'
  )!
  input.focus()
  const highlighted = () =>
    document.querySelector("[data-highlighted]")?.textContent
  while (highlighted() !== "Orange") {
    await act(async () => {
      input.dispatchEvent(
        new KeyboardEvent("keydown", { key: "ArrowDown", bubbles: true })
      )
      await settle()
    })
  }

  const setValue = Object.getOwnPropertyDescriptor(
    HTMLInputElement.prototype,
    "value"
  )!.set!
  await act(async () => {
    setValue.call(input, "an")
    input.dispatchEvent(new Event("input", { bubbles: true }))
    await settle()
  })

  expect(input.value).toBe("an")
  expect(highlighted()).toBe("Banana")
  expect(input.getAttribute("aria-activedescendant")).toBe(
    document.querySelector("[data-highlighted]")?.id
  )
})
