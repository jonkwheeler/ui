/** @jsxImportSource octane */
import { act, hydrateRoot } from "octane"
import { afterAll, afterEach, beforeAll, expect, test, vi } from "vitest"
import { App } from "./popover-suspense-trigger-app"
import { type Server, startServer, startTimeout } from "./server-html"

Element.prototype.getAnimations ??= () => []
HTMLElement.prototype.showPopover ??= function () {}
HTMLElement.prototype.hidePopover ??= function () {}

let server: Server
let onServer: typeof import("./popover-suspense-trigger-app")

beforeAll(async () => {
  server = await startServer()
  onServer = await server.load("./popover-suspense-trigger-app.tsx")
}, startTimeout)

afterAll(() => server.close())

afterEach(() => document.body.replaceChildren())

test("a trigger beside a boundary the client renders names the popup it opens", async () => {
  const error = vi.spyOn(console, "error").mockImplementation(() => {})
  const root = document.createElement("div")
  root.innerHTML = server.html(onServer.App, { server: true })
  document.body.append(root)
  await act(async () => {
    hydrateRoot(root, <App server={false} />, { onRecoverableError: () => {} })
  })
  const account = [...root.querySelectorAll("button")].find(
    (button) => button.textContent === "Account"
  )!
  await act(async () => account.click())
  const content = document.querySelector('[role="dialog"]')!
  const label = content.getAttribute("aria-labelledby")!
  expect(document.getElementById(label)?.textContent).toBe("Account")
  error.mockRestore()
})
