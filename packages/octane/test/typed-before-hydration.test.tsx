/** @jsxImportSource octane */
import type * as React from "octane"
import { act, hydrateRoot, type Root } from "octane"
import { afterAll, afterEach, beforeAll, expect, test, vi } from "vitest"
import * as apps from "./typed-before-hydration-apps"
import { type Server, startServer, startTimeout } from "./server-html"

let root: Root | undefined
let server: Server
let onServer: typeof apps

beforeAll(async () => {
  server = await startServer()
  onServer = await server.load("./typed-before-hydration-apps.tsx")
}, startTimeout)

afterAll(() => server.close())

afterEach(async () => {
  await act(async () => root?.unmount())
  root = undefined
  document.body.replaceChildren()
})

type App = Exclude<keyof typeof apps, "a" | "b">

// The server's HTML for the fixture `name`, in the page.
function serve(name: App) {
  const container = document.body.appendChild(document.createElement("div"))
  container.innerHTML = server.html(onServer[name], {})
  return container
}

async function hydrate(
  container: HTMLElement,
  name: App,
  handlers: Record<string, (...args: any[]) => void> = {}
) {
  const Component = apps[name] as React.ComponentType<typeof handlers>
  await act(async () => {
    root = hydrateRoot(container, <Component {...handlers} />)
  })
}

// Server markup in the page, text typed into the field, then hydration.
async function typeThenHydrate(
  name: App,
  handlers: Record<string, (...args: any[]) => void>,
  text: string,
  { focused = false } = {}
) {
  const container = serve(name)
  const input = container.querySelector("input")!
  if (focused) {
    input.focus()
  }
  input.value = text
  await hydrate(container, name, handlers)
  return container.querySelector("input")!
}

test("a combobox keeps text typed before hydration, and opens while focused", async () => {
  const onQueryChange = vi.fn()
  const onOpenChange = vi.fn()
  const input = await typeThenHydrate(
    "FruitCombobox",
    { onQueryChange, onOpenChange },
    "Ban",
    { focused: true }
  )
  expect(input.value).toBe("Ban")
  expect(onQueryChange).toHaveBeenCalledWith("Ban", expect.anything())
  expect(onOpenChange).toHaveBeenCalledWith(true, expect.anything())
})

test("a combobox that lost focus settles the text as a blur would, and stays closed", async () => {
  const onValueChange = vi.fn()
  const onOpenChange = vi.fn()
  const input = await typeThenHydrate(
    "CustomCombobox",
    { onValueChange, onOpenChange },
    "Kiwi"
  )
  expect(input.value).toBe("Kiwi")
  expect(onValueChange).toHaveBeenCalledWith("Kiwi", expect.anything())
  expect(onOpenChange).not.toHaveBeenCalled()
})

test("an autocomplete keeps text typed before hydration", async () => {
  const onValueChange = vi.fn()
  const input = await typeThenHydrate(
    "FruitAutocomplete",
    { onValueChange },
    "Che"
  )
  expect(input.value).toBe("Che")
  expect(onValueChange).toHaveBeenCalledWith("Che", expect.anything())
})

test("a command keeps text typed before hydration", async () => {
  const input = await typeThenHydrate("ActionCommand", {}, "Pas")
  expect(input.value).toBe("Pas")
  expect(
    document.querySelectorAll('[data-slot="command-item"]:not([hidden])')
  ).toHaveLength(1)
})

test("a number input commits text typed before hydration once it lost focus", async () => {
  const onValueChange = vi.fn()
  const input = await typeThenHydrate("Quantity", { onValueChange }, "57")
  expect(input.value).toBe("57")
  expect(onValueChange).toHaveBeenCalledWith(57, expect.anything())
})

test("a date picker keeps text typed before hydration", async () => {
  const onValueChange = vi.fn()
  const input = await typeThenHydrate(
    "DateField",
    { onValueChange },
    "04/05/2026"
  )
  expect(input.value).toBe("04/05/2026")
  expect(onValueChange).toHaveBeenCalledWith("2026-04-05", expect.anything())
})

test("a color picker keeps text typed before hydration", async () => {
  const onValueChange = vi.fn()
  await typeThenHydrate("ColorField", { onValueChange }, "#00ff00")
  expect(onValueChange).toHaveBeenCalled()
  expect(onValueChange.mock.calls.at(-1)?.[0]).toMatch(/^#00ff00/)
})

test("a number input reads text typed before hydration in the page's language", async () => {
  const onValueChange = vi.fn()
  await typeThenHydrate("GermanQuantity", { onValueChange }, "1.234")
  expect(onValueChange).toHaveBeenLastCalledWith(1234, expect.anything())
})

test("a combobox emptied before hydration clears its value, even without focus", async () => {
  const onValueChange = vi.fn()
  const input = await typeThenHydrate("AppleCombobox", { onValueChange }, "")
  expect(input.value).toBe("")
  expect(onValueChange).toHaveBeenCalledWith(null, expect.anything())
})

test("a token input keeps text typed before hydration, beside its tokens", async () => {
  const onValueChange = vi.fn()
  const error = vi.spyOn(console, "error").mockImplementation(() => {})
  const container = serve("ExplainPrompt")
  const editor = container.querySelector<HTMLElement>('[role="textbox"]')!
  editor.append(" please")
  await hydrate(container, "ExplainPrompt", { onValueChange })
  expect(onValueChange).toHaveBeenCalledWith(
    ["Explain ", expect.objectContaining(apps.a), " please"],
    expect.anything()
  )
  expect(editor.textContent).toContain(" please")
  expect(error).not.toHaveBeenCalled()
  error.mockRestore()
})

test("a token input left as the server rendered it changes nothing as it hydrates", async () => {
  const onValueChange = vi.fn()
  const container = serve("ExplainPrompt")
  await hydrate(container, "ExplainPrompt", { onValueChange })
  expect(onValueChange).not.toHaveBeenCalled()
})

test("a token input keeps the tokens after one deleted before hydration", async () => {
  const onValueChange = vi.fn()
  const container = serve("ComparePrompt")
  container.querySelector('[data-slot="token-input-host"]')!.remove()
  await hydrate(container, "ComparePrompt", { onValueChange })
  expect(onValueChange).toHaveBeenCalledWith(
    ["Compare  and ", expect.objectContaining(apps.b)],
    expect.anything()
  )
})
