/** @jsxImportSource octane */
import * as React from "octane"
import { act, createRoot, type Root } from "octane"
import { afterEach, expect, test } from "vitest"
import { Menu, MenuContent, MenuRadioGroup, MenuRadioItem } from "../src/menu"

Element.prototype.getAnimations ??= () => []

let root: Root | undefined

afterEach(async () => {
  await act(async () => root?.unmount())
  root = undefined
  document.body.innerHTML = ""
})

test("an unnamed radio group keeps its choice after the menu closes", async () => {
  let setOpen: (open: boolean) => void = () => {}
  function Theme() {
    const [open, set] = React.useState(true)
    setOpen = set
    return (
      <Menu open={open} onOpenChange={set}>
        <MenuContent>
          <MenuRadioGroup defaultValue="light">
            <MenuRadioItem value="light">Light</MenuRadioItem>
            <MenuRadioItem value="dark">Dark</MenuRadioItem>
          </MenuRadioGroup>
        </MenuContent>
      </Menu>
    )
  }
  const container = document.body.appendChild(document.createElement("div"))
  root = createRoot(container)
  await act(async () => root!.render(<Theme />))
  const dark = () =>
    [...document.querySelectorAll('[role="menuitemradio"]')].find(
      (item) => item.textContent === "Dark"
    )!
  await act(async () =>
    dark().dispatchEvent(new MouseEvent("click", { bubbles: true }))
  )
  expect(dark().getAttribute("aria-checked")).toBe("true")
  await act(async () => {
    setOpen(false)
    await new Promise((resolve) => setTimeout(resolve, 20))
  })
  expect(document.querySelector('[role="menuitemradio"]')).toBeNull()
  await act(async () => setOpen(true))
  expect(dark().getAttribute("aria-checked")).toBe("true")
})
