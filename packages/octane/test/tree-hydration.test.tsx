/** @jsxImportSource octane */
import * as React from "octane"
import { act, hydrateRoot, type Root } from "octane"
import { afterAll, afterEach, beforeAll, expect, test, vi } from "vitest"
import { type Server, startServer, startTimeout } from "./server-html"
import { App } from "./tree-hydration-app"

Element.prototype.getAnimations ??= () => []

let root: Root | undefined
let server: Server
let onServer: typeof import("./tree-hydration-app")

beforeAll(async () => {
  server = await startServer()
  onServer = await server.load("./tree-hydration-app.tsx")
}, startTimeout)

afterAll(() => server.close())

afterEach(async () => {
  await act(async () => root?.unmount())
  root = undefined
  vi.restoreAllMocks()
  document.body.replaceChildren()
})

test("an item hydrates at its depth when hydration yields inside its branch", async () => {
  const { promise, resolve } = Promise.withResolvers<void>()
  const container = document.body.appendChild(document.createElement("div"))
  container.innerHTML = server.html(onServer.App, { onHydrated: resolve })
  const errors = vi.spyOn(console, "error").mockImplementation(() => {})
  React.startTransition(() => {
    root = hydrateRoot(container, <App onHydrated={resolve} />)
  })
  await promise
  expect(errors.mock.calls).toEqual([])
  expect(
    [...container.querySelectorAll('[role="treeitem"]')].map((item) =>
      item.getAttribute("aria-level")
    )
  ).toEqual(["1", "2", "3"])
})
