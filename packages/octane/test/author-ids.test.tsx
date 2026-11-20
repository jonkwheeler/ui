/** @jsxImportSource octane */
// An id passed to a part is its element's, and every reference to the part points at it.
import * as React from "octane"
import { act, createRoot, hydrateRoot, type Root } from "octane"
import { octane } from "octane/compiler/vite"
import { createServer } from "vite"
import { afterEach, expect, test, vi } from "vitest"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogTitle,
  DialogTrigger,
} from "../src/dialog"
import { Tabs, TabsList, TabsPanel, TabsTab } from "../src/tabs"
import { Toolbar, ToolbarLink } from "../src/toolbar"

Element.prototype.getAnimations ??= () => []
HTMLElement.prototype.showPopover ??= function () {}
HTMLElement.prototype.hidePopover ??= function () {}

let root: Root | undefined

async function render(element: React.ReactElement) {
  const container = document.body.appendChild(document.createElement("div"))
  root = createRoot(container)
  await act(async () => root!.render(element))
  return container
}

afterEach(async () => {
  await act(async () => root?.unmount())
  root = undefined
  document.body.replaceChildren()
})

test("a dialog's parts keep the ids passed to them, and the dialog points at them", async () => {
  const view = await render(
    <Dialog defaultOpen modal={false}>
      <DialogTrigger id="mine">Edit</DialogTrigger>
      <DialogContent id="sheet">
        <DialogTitle id="heading">Profile</DialogTitle>
        <DialogDescription id="hint">Change it.</DialogDescription>
      </DialogContent>
    </Dialog>
  )
  const trigger = view.querySelector("button")!
  const content = document.querySelector<HTMLElement>('[role="dialog"]')!
  expect(trigger.id).toBe("mine")
  expect(content.id).toBe("sheet")
  expect(document.querySelector("h2")!.id).toBe("heading")
  expect(document.querySelector("p")!.id).toBe("hint")
  expect(trigger.getAttribute("aria-controls")).toBe("sheet")
  expect(content.getAttribute("aria-labelledby")).toBe("heading")
  expect(content.getAttribute("aria-describedby")).toBe("hint")
})

test("a dialog's content is labelled by the id passed to its title, which renders after it", async () => {
  await render(
    <Dialog defaultOpen modal={false}>
      <DialogContent>
        <DialogTitle id="heading">Profile</DialogTitle>
      </DialogContent>
    </Dialog>
  )
  expect(
    document.querySelector('[role="dialog"]')!.getAttribute("aria-labelledby")
  ).toBe("heading")
})

test("a tab keeps the id passed to it, and its panel is labelled by it", async () => {
  const view = await render(
    <Tabs defaultValue="a">
      <TabsList aria-label="Settings">
        <TabsTab value="a" id="account">
          Account
        </TabsTab>
      </TabsList>
      <TabsPanel value="a">A</TabsPanel>
    </Tabs>
  )
  const tab = view.querySelector<HTMLElement>('[role="tab"]')!
  const panel = view.querySelector<HTMLElement>('[role="tabpanel"]')!
  expect(tab.id).toBe("account")
  expect(panel.getAttribute("aria-labelledby")).toBe("account")
  expect(tab.getAttribute("aria-controls")).toBe(panel.id)
})

test("a part whose key is its id keeps the id on its element", async () => {
  const view = await render(
    <Toolbar aria-label="Formatting">
      <ToolbarLink id="docs" href="#docs">
        Docs
      </ToolbarLink>
    </Toolbar>
  )
  expect(view.querySelector("a")!.id).toBe("docs")
})

test("a tab's panel follows the id passed to the tab as it changes or goes", async () => {
  const view = (id?: string) => (
    <Tabs defaultValue="a">
      <TabsList aria-label="Settings">
        <TabsTab value="a" id={id}>
          Account
        </TabsTab>
      </TabsList>
      <TabsPanel value="a">A</TabsPanel>
    </Tabs>
  )
  const container = await render(view("first"))
  const tab = container.querySelector<HTMLElement>('[role="tab"]')!
  const panel = container.querySelector<HTMLElement>('[role="tabpanel"]')!
  await act(async () => root!.render(view("second")))
  expect(tab.id).toBe("second")
  expect(panel.getAttribute("aria-labelledby")).toBe("second")
  await act(async () => root!.render(view()))
  expect(tab.id).toMatch(/-tab-a$/)
  expect(panel.getAttribute("aria-labelledby")).toBe(tab.id)
})

type Modules = {
  octane: typeof import("octane")
  dialog: typeof import("../src/dialog")
  tabs: typeof import("../src/tabs")
}

// Octane renders on the server only from modules compiled for it, so the
// server's HTML comes through Vite's server loader, built from its own parts.
async function serverHtml(app: (modules: Modules) => unknown) {
  const vite = await createServer({
    root: import.meta.dirname,
    configFile: false,
    logLevel: "silent",
    appType: "custom",
    server: { middlewareMode: true, hmr: false, ws: false },
    plugins: [octane({ ssr: true })],
  })
  try {
    const server = await vite.ssrLoadModule("octane/server")
    const modules = {
      octane: await vite.ssrLoadModule("octane"),
      dialog: await vite.ssrLoadModule("../src/dialog.tsx"),
      tabs: await vite.ssrLoadModule("../src/tabs.tsx"),
    } as Modules
    return server.renderToString(app(modules)).html as string
  } finally {
    await vite.close()
  }
}

test("a dialog hydrated from server HTML matches it, then points at the ids passed to its parts", async () => {
  const app = (
    <Dialog defaultOpen modal={false}>
      <DialogTrigger id="mine">Edit</DialogTrigger>
      <DialogContent id="sheet">
        <DialogTitle id="heading">Profile</DialogTitle>
      </DialogContent>
    </Dialog>
  )
  const container = document.body.appendChild(document.createElement("div"))
  container.innerHTML = await serverHtml(
    ({ octane: { createElement: h }, dialog }) =>
      h(
        dialog.Dialog,
        { defaultOpen: true, modal: false },
        h(dialog.DialogTrigger, { id: "mine" }, "Edit"),
        h(
          dialog.DialogContent,
          { id: "sheet" },
          h(dialog.DialogTitle, { id: "heading" }, "Profile")
        )
      )
  )
  const errors = vi.spyOn(console, "error").mockImplementation(() => {})
  // Octane reports a mismatch to `onRecoverableError` only, not the console.
  const recovered = vi.fn()
  await act(async () => {
    root = hydrateRoot(container, app, { onRecoverableError: recovered })
  })
  errors.mockRestore()
  expect(errors).not.toHaveBeenCalled()
  expect(recovered).not.toHaveBeenCalled()
  const content = document.querySelector<HTMLElement>('[role="dialog"]')!
  expect(container.querySelector("button")!.getAttribute("aria-controls")).toBe(
    "sheet"
  )
  expect(content.getAttribute("aria-labelledby")).toBe("heading")
}, 60_000)

function HydratesLater({
  until,
  children,
}: {
  until?: Promise<void>
  children: React.ReactNode
}) {
  if (until) {
    React.use(until)
  }
  return children
}

test("a tab and its panel in one Suspense boundary that hydrates late match the server HTML", async () => {
  let resolve = () => {}
  const until = new Promise<void>((done) => (resolve = done))
  const app = (until?: Promise<void>) => (
    <Tabs defaultValue="a">
      <React.Suspense fallback={null}>
        <HydratesLater until={until}>
          <TabsList aria-label="Settings">
            <TabsTab value="a" id="account">
              Account
            </TabsTab>
          </TabsList>
          <TabsPanel value="a">A</TabsPanel>
        </HydratesLater>
      </React.Suspense>
    </Tabs>
  )
  const container = document.body.appendChild(document.createElement("div"))
  container.innerHTML = await serverHtml(
    ({ octane: { createElement: h, Suspense }, tabs }) =>
      h(
        tabs.Tabs,
        { defaultValue: "a" },
        h(Suspense, {
          fallback: null,
          children: h(({ children }: { children: unknown }) => children, {
            children: [
              h(
                tabs.TabsList,
                { "aria-label": "Settings" },
                h(tabs.TabsTab, { value: "a", id: "account" }, "Account")
              ),
              h(tabs.TabsPanel, { value: "a" }, "A"),
            ],
          }),
        })
      )
  )
  const errors = vi.spyOn(console, "error").mockImplementation(() => {})
  const recovered = vi.fn()
  await act(async () => {
    root = hydrateRoot(container, app(until), {
      onRecoverableError: recovered,
    })
  })
  await act(async () => resolve())
  errors.mockRestore()
  expect(errors).not.toHaveBeenCalled()
  expect(recovered).not.toHaveBeenCalled()
  expect(
    container
      .querySelector('[role="tabpanel"]')!
      .getAttribute("aria-labelledby")
  ).toBe("account")
}, 60_000)
