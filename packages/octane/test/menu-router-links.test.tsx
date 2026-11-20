/** @jsxImportSource octane */
// A router's link can call `preventDefault()` before the item's handler, on
// the native event both share. The item still closes the menu.
import * as React from "octane"
import { act, createRoot, type Root } from "octane"
import { afterEach, expect, test } from "vitest"
import { Menu, MenuContent, MenuItem, MenuTrigger } from "../src/menu"

Element.prototype.getAnimations ??= () => []

let root: Root | undefined

afterEach(async () => {
  await act(async () => root?.unmount())
  root = undefined
  document.body.replaceChildren()
})

function Link(props: React.ComponentProps<"a">) {
  return (
    <a
      {...props}
      onClick={(event) => {
        event.preventDefault()
        props.onClick?.(event)
      }}
    />
  )
}

async function mount(onSelect?: (event: Event) => void) {
  const state = { open: true, actions: [] as string[] }
  root = createRoot(document.body.appendChild(document.createElement("div")))
  await act(async () =>
    root!.render(
      <Menu
        defaultOpen
        onOpenChange={(open) => (state.open = open)}
        onAction={(value) => state.actions.push(value)}
      >
        <MenuTrigger>Account</MenuTrigger>
        <MenuContent>
          <MenuItem
            value="settings"
            onSelect={onSelect}
            render={<Link href="/settings" />}
          >
            Settings
          </MenuItem>
        </MenuContent>
      </Menu>
    )
  )
  return state
}

const clickLink = async () => {
  const event = new MouseEvent("click", { bubbles: true, cancelable: true })
  await act(async () => {
    document
      .querySelector<HTMLAnchorElement>('a[href="/settings"]')!
      .dispatchEvent(event)
  })
  return event
}

test("a link item the router navigates closes the menu and runs its action", async () => {
  const state = await mount()
  const click = await clickLink()
  expect(click.defaultPrevented).toBe(true)
  expect(state.open).toBe(false)
  expect(state.actions).toEqual(["settings"])
})

test("onSelect can still keep the menu open", async () => {
  const state = await mount((event) => event.preventDefault())
  const click = await clickLink()
  expect(click.defaultPrevented).toBe(true)
  expect(state.open).toBe(true)
  expect(state.actions).toEqual([])
})
