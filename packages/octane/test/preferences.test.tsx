/** @jsxImportSource octane */
// Preferences across a page load: the server's HTML, its script run the way
// the parser would, then hydration.
import * as React from "octane"
import { act, createRoot, hydrateRoot, type Root } from "octane"
import { afterAll, afterEach, beforeAll, expect, test, vi } from "vitest"
import { setup } from "./preferences-app"
import { type Server, startServer, startTimeout } from "./server-html"

let root: Root | undefined
let server: Server
let onServer: { setup: typeof setup }

beforeAll(async () => {
  server = await startServer()
  onServer = await server.load("./preferences-app.tsx")
}, startTimeout)

afterAll(() => server.close())

afterEach(async () => {
  await act(async () => root?.unmount())
  root = undefined
  document.body.replaceChildren()
  localStorage.clear()
  delete (window as Window & { __uiSdkStorage?: unknown }).__uiSdkStorage
  for (const name of document.documentElement.getAttributeNames()) {
    if (name.startsWith("data-")) {
      document.documentElement.removeAttribute(name)
    }
  }
})

// The server's HTML for the fixture `setup(...args)` makes.
const serverHtml = (part: "App" | "Bare", ...args: Parameters<typeof setup>) =>
  server.html(onServer.setup(...args)[part])

// What the browser does with server HTML: insert it, and run each script as it's parsed.
function load(container: HTMLElement, html: string) {
  container.innerHTML = html
  for (const script of container.querySelectorAll("script")) {
    Object.defineProperty(document, "currentScript", {
      configurable: true,
      value: script,
    })
    new Function(script.textContent!)()
  }
  Object.defineProperty(document, "currentScript", {
    configurable: true,
    value: null,
  })
}

test("the server renders one script first, and the defaults on its element", () => {
  const html = serverHtml("App")
  expect(html.match(/<script/g)).toHaveLength(1)
  // Without the comments Octane marks its hydration ranges with.
  expect(html.replace(/<!--[^]*?-->/g, "")).toMatch(
    /^<div data-slot="preferences" data-skin-tone="default" style="display:contents;"><script>/
  )
  expect(html).toContain("Tone: default")
})

test("saved values show before hydration, which then matches, and content catches up after", async () => {
  localStorage.setItem("color-scheme", "dark")
  localStorage.setItem("skin-tone", "medium")
  const { App, skinTone } = setup()
  const container = document.body.appendChild(document.createElement("div"))
  load(container, serverHtml("App"))
  const element = container.querySelector<HTMLElement>(
    '[data-slot="preferences"]'
  )!
  // The first paint.
  expect(document.documentElement.dataset.colorScheme).toBe("dark")
  expect(element.dataset.skinTone).toBe("medium")
  expect(container.querySelector("p")!.textContent).toBe("Tone: default")

  const errors = vi.spyOn(console, "error").mockImplementation(() => {})
  await act(async () => {
    root = hydrateRoot(container, <App />)
  })
  errors.mockRestore()
  expect(errors).not.toHaveBeenCalled()
  expect(document.documentElement.dataset.colorScheme).toBe("dark")
  expect(element.dataset.skinTone).toBe("medium")
  expect(container.querySelector("p")!.textContent).toBe("Tone: medium")
  // The script did its job, so it's gone after hydration.
  expect(container.querySelector("script")).toBeNull()

  await act(async () => skinTone.set("dark", { reason: "item-press" }))
  expect(element.dataset.skinTone).toBe("dark")
  expect(localStorage.getItem("skin-tone")).toBe("dark")
})

test("a client-only render leaves the script out, and still shows the saved values", async () => {
  localStorage.setItem("color-scheme", "light")
  const { App, colorScheme } = setup()
  const container = document.body.appendChild(document.createElement("div"))
  root = createRoot(container)
  await act(async () => root!.render(<App />))
  expect(container.querySelector("script")).toBeNull()
  expect(document.documentElement.dataset.colorScheme).toBe("light")
  await act(async () => colorScheme.set("dark"))
  expect(document.documentElement.dataset.colorScheme).toBe("dark")
})

test("a global value is on <html> before the first paint of a client-only render", async () => {
  localStorage.setItem("color-scheme", "dark")
  const { App } = setup()
  let painted: string | undefined
  function Page() {
    React.useLayoutEffect(() => {
      painted = document.documentElement.dataset.colorScheme
    }, [])
    return <App />
  }
  const container = document.body.appendChild(document.createElement("div"))
  root = createRoot(container)
  await act(async () => root!.render(<Page />))
  expect(painted).toBe("dark")
})

test("a restore that onValueChange cancels leaves the default on the attributes the script set", async () => {
  localStorage.setItem("color-scheme", "dark")
  localStorage.setItem("skin-tone", "medium")
  const cancel = (_value: string, details: { cancel: () => void }) =>
    details.cancel()
  const { Bare, skinTone } = setup(cancel)
  const container = document.body.appendChild(document.createElement("div"))
  load(container, serverHtml("Bare", cancel))
  const element = container.querySelector<HTMLElement>(
    '[data-slot="preferences"]'
  )!
  expect(element.dataset.skinTone).toBe("medium")
  await act(async () => {
    root = hydrateRoot(container, <Bare />)
  })
  expect(skinTone.get().value).toBe("default")
  expect(element.dataset.skinTone).toBe("default")
  expect(document.documentElement.dataset.colorScheme).toBe("system")
})
