/** @jsxImportSource octane */
import path from "node:path"
import { createController, definePrimitive, selects } from "@ui-sdk/core"
import * as React from "octane"
import { act, createRoot, flushSync, type Root } from "octane"
import { octane } from "octane/compiler/vite"
import { createServer } from "vite"
import { afterEach, expect, test, vi } from "vitest"
import { useAsyncOptions } from "../src/async-options"
import {
  Dialog,
  DialogContent,
  DialogTitle,
  DialogTrigger,
} from "../src/dialog"
import { Field } from "../src/field"
import { Popover, PopoverContent, PopoverTrigger } from "../src/popover"
import { usePart, usePrimitive, type PrimitiveHandle } from "../src/primitive"

Element.prototype.getAnimations ??= () => []

// An instance's life as Octane sees it: <Activity> hiding a tree with its
// state, effects that start work, and event handlers that run before the
// built-in ones. Octane's StrictMode throws nothing away, so it isn't tested.

// jsdom has no top layer. With one, popups render in place, as in a browser.
HTMLElement.prototype.showPopover ??= function (this: HTMLElement) {
  this.toggleAttribute("data-top-layer", true)
}
HTMLElement.prototype.hidePopover ??= function (this: HTMLElement) {
  this.removeAttribute("data-top-layer")
}

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

const wait = (ms: number) => new Promise((done) => setTimeout(done, ms))
// A modal locks the page a frame after it shows, so a check waits for that frame.
const settle = () =>
  new Promise((done) => requestAnimationFrame(() => setTimeout(done, 5)))

const counter = definePrimitive({
  name: "counter",
  state: (_options: {}) => ({ count: 0 }),
  api: ({ store }) => ({
    increment: () => store.set({ count: store.get().count + 1 }),
  }),
  slots: (slot) => ({
    root: slot<{}, { count: number }>({
      state: ({ count }) => ({ count }),
      on: { click: (_event, { api }) => api.increment() },
    }),
  }),
})

function Counter() {
  const handle = usePrimitive(counter, {})
  return usePart(
    handle,
    "root",
    {},
    { children: (state: { count: number }) => state.count },
    "button"
  )
}

function Hideable({
  mode,
  children,
}: {
  mode: "visible" | "hidden"
  children: React.ReactNode
}) {
  return <React.Activity mode={mode}>{children}</React.Activity>
}

test("<Activity> hid and showed again keeps state that has no default option", async () => {
  const view = await render(<Hideable mode="visible">{<Counter />}</Hideable>)
  await act(async () => view.querySelector("button")!.click())
  await act(async () =>
    root!.render(<Hideable mode="hidden">{<Counter />}</Hideable>)
  )
  await settle()
  await act(async () =>
    root!.render(<Hideable mode="visible">{<Counter />}</Hideable>)
  )
  expect(view.querySelector("button")!.textContent).toBe("1")
  await act(async () => view.querySelector("button")!.click())
  expect(view.querySelector("button")!.textContent).toBe("2")
})

let textCounter: PrimitiveHandle<typeof counter> | undefined

// Renders its count as text, so no element binds: nothing in the page tells
// whether Octane hid it or removed it.
function TextCounter() {
  textCounter = usePrimitive(counter, {})
  return usePart(
    textCounter,
    "root",
    {},
    { render: (_props, state) => <>{state.count}</> }
  )
}

test("<Activity> hid and showed again keeps the state of a primitive that binds no element", async () => {
  const view = await render(
    <Hideable mode="visible">{<TextCounter />}</Hideable>
  )
  await act(async () => textCounter!.api.increment())
  expect(view.textContent).toBe("1")
  await act(async () =>
    root!.render(<Hideable mode="hidden">{<TextCounter />}</Hideable>)
  )
  await settle()
  await act(async () =>
    root!.render(<Hideable mode="visible">{<TextCounter />}</Hideable>)
  )
  expect(view.textContent).toBe("1")
})

type LampController = { switchOn: () => void }

const lamp = definePrimitive({
  name: "lamp",
  options: { controller: "value" },
  state: (_options: { controller?: LampController }) => ({ on: false }),
  api: (context) => ({ switchOn: () => context.store.set({ on: true }) }),
  slots: (slot) => ({
    root: slot<{}, { on: boolean }>({ state: ({ on }) => ({ on }) }),
  }),
})

function Lamp({ controller }: { controller: LampController }) {
  const handle = usePrimitive(lamp, { controller })
  return usePart(
    handle,
    "root",
    {},
    { render: (_props, state) => <>{state.on ? "on" : "off"}</> }
  )
}

test("a primitive that binds no element lets its controller go while hidden, and when it leaves", async () => {
  const controller = createController<LampController>()
  const view = await render(
    <Hideable mode="visible">{<Lamp controller={controller} />}</Hideable>
  )
  await act(async () =>
    root!.render(
      <Hideable mode="hidden">{<Lamp controller={controller} />}</Hideable>
    )
  )
  await settle()
  expect("switchOn" in controller).toBe(false)
  await act(async () =>
    root!.render(
      <Hideable mode="visible">{<Lamp controller={controller} />}</Hideable>
    )
  )
  await act(async () => controller.switchOn())
  expect(view.textContent).toBe("on")
  await act(async () => root!.render(null))
  expect("switchOn" in controller).toBe(false)
})

test("<Activity> hid and showed again keeps a field's shown errors", async () => {
  const form = (mode: "visible" | "hidden") => (
    <Hideable mode={mode}>
      <Field>
        <input name="title" required />
      </Field>
    </Hideable>
  )
  const view = await render(form("visible"))
  await settle()
  await act(async () => view.querySelector("input")!.checkValidity())
  const field = () => view.querySelector("[data-slot=field]")!
  expect(field().hasAttribute("data-invalid")).toBe(true)
  await act(async () => root!.render(form("hidden")))
  await settle()
  await act(async () => root!.render(form("visible")))
  expect(field().hasAttribute("data-invalid")).toBe(true)
})

test("an instance hidden and then removed with its elements is destroyed", async () => {
  const destroy = vi.fn()
  const watched = definePrimitive({
    name: "watched",
    state: (_options: {}) => ({}),
    api: ({ onDestroy }) => (onDestroy(destroy), {}),
    slots: (slot) => ({ root: slot<{}, {}>({}) }),
  })
  function Watched() {
    return usePart(usePrimitive(watched, {}), "root", {}, {}, "div")
  }
  await render(<Hideable mode="visible">{<Watched />}</Hideable>)
  await act(async () =>
    root!.render(<Hideable mode="hidden">{<Watched />}</Hideable>)
  )
  await settle()
  expect(destroy).not.toHaveBeenCalled()
  await act(async () => root!.render(null))
  await wait(1100)
  expect(destroy).toHaveBeenCalledTimes(1)
})

// Octane hides the elements at the top of a hidden tree and of a portal under
// it, and a popup rendered into a container also hides itself.
const placements = [
  { placement: "in place", container: () => undefined },
  { placement: "in the body", container: () => document.body },
]

const dialog = () => document.querySelector<HTMLElement>('[role="dialog"]')
// Shown unless it or an element around it has `display: none`, as Octane and a hidden popup write it.
const rendered = (el: HTMLElement | null) => {
  for (let node = el; node; node = node.parentElement) {
    if (node.style.display === "none") {
      return false
    }
  }
  return !!el
}
// Whether the dialog shows, is in the top layer, and locks the page's scroll.
const effects = () => ({
  rendered: rendered(dialog()),
  topLayer: !!dialog()?.hasAttribute("data-top-layer"),
  locked: document.documentElement.style.overflow === "hidden",
})
const shown = { rendered: true, topLayer: true, locked: true }
const gone = { rendered: false, topLayer: false, locked: false }

// A page with a dialog and its trigger, inside an element, as pages are.
function SettingsPage({
  mode,
  ...options
}: { mode: "visible" | "hidden" } & React.ComponentProps<typeof Dialog>) {
  return (
    <Hideable mode={mode}>
      <main>
        <Dialog {...options}>
          <DialogTrigger>Settings</DialogTrigger>
          <DialogContent>
            <DialogTitle>Settings</DialogTitle>
          </DialogContent>
        </Dialog>
      </main>
    </Hideable>
  )
}

// Renders the page in a mode and lets its effects settle.
async function showPage(
  mode: "visible" | "hidden",
  options: React.ComponentProps<typeof Dialog>
) {
  const page = <SettingsPage mode={mode} {...options} />
  if (root) {
    await act(async () => root!.render(page))
  } else {
    await render(page)
  }
  await settle()
}

test.each(placements)(
  "an open dialog rendered $placement leaves the top layer while its <Activity> hides, and comes back",
  async ({ container }) => {
    const options = { defaultOpen: true, container: container() }
    await showPage("visible", options)
    expect(effects()).toEqual(shown)
    for (const cycle of [1, 2]) {
      await showPage("hidden", options)
      expect(effects(), `hidden ${cycle}`).toEqual(gone)
      await showPage("visible", options)
      expect(effects(), `visible ${cycle}`).toEqual(shown)
    }
  }
)

test.each(placements)(
  "a dialog rendered $placement that opens while its <Activity> is hidden shows once it's visible",
  async ({ container }) => {
    const options = { open: false, container: container() }
    await showPage("visible", options)
    await showPage("hidden", options)
    // A controller lets go while its tree is hidden, so the hidden page renders again with the dialog open.
    await showPage("hidden", { ...options, open: true })
    expect(effects()).toEqual(gone)
    await showPage("visible", { ...options, open: true })
    expect(effects()).toEqual(shown)
  }
)

test.each(placements)(
  "an open dialog rendered $placement that mounts in a hidden <Activity> shows once it's visible",
  async ({ container }) => {
    const options = { defaultOpen: true, container: container() }
    await showPage("hidden", options)
    expect(effects()).toEqual(gone)
    await showPage("visible", options)
    expect(effects()).toEqual(shown)
  }
)

// Renders nothing until it has mounted, and its effects never run while its <Activity> hides.
function AfterMount(props: React.ComponentProps<"div">) {
  const [isMounted, setMounted] = React.useState(false)
  React.useEffect(() => setMounted(true), [])
  return isMounted ? <div {...props} /> : null
}

test("a hidden dialog whose content renders nothing yet leaves an open popover in the same container shown", async () => {
  const portals = document.body.appendChild(document.createElement("div"))
  await render(
    <>
      <Popover defaultOpen container={portals}>
        <PopoverTrigger>Filters</PopoverTrigger>
        <PopoverContent>Filters</PopoverContent>
      </Popover>
      <Hideable mode="hidden">
        <Dialog defaultOpen container={portals}>
          <DialogContent render={<AfterMount />}>
            <DialogTitle>Settings</DialogTitle>
          </DialogContent>
        </Dialog>
      </Hideable>
    </>
  )
  await settle()
  const popover = portals.querySelector<HTMLElement>(
    "[data-slot=popover-content]"
  )
  expect(rendered(popover)).toBe(true)
  expect(popover!.hasAttribute("data-top-layer")).toBe(true)
})

test("a hidden dialog in the body whose content renders nothing yet leaves the page shown", async () => {
  const view = await render(
    <Hideable mode="hidden">
      <Dialog defaultOpen container={document.body}>
        <DialogContent render={<AfterMount />}>
          <DialogTitle>Settings</DialogTitle>
        </DialogContent>
      </Dialog>
    </Hideable>
  )
  await settle()
  expect(rendered(view)).toBe(true)
})

// Renders the content with an element of its own after it.
function WithNote(props: React.ComponentProps<"section">) {
  return (
    <>
      <section {...props} />
      <p data-note="">Saved a minute ago</p>
    </>
  )
}

test("an open dialog in the body whose content renders an element after it hides both with its <Activity>", async () => {
  await render(
    <Hideable mode="hidden">
      <main>
        <Dialog defaultOpen container={document.body}>
          <DialogContent render={<WithNote />}>
            <DialogTitle>Settings</DialogTitle>
          </DialogContent>
        </Dialog>
      </main>
    </Hideable>
  )
  await settle()
  expect(effects()).toEqual(gone)
  expect(rendered(document.querySelector("[data-note]"))).toBe(false)
})

test("an open dialog in a container whose content changes element while its <Activity> hides stays hidden", async () => {
  const page = (mode: "visible" | "hidden", render?: React.ReactElement) => (
    <Hideable mode={mode}>
      <Dialog defaultOpen container={document.body}>
        <DialogContent render={render}>
          <DialogTitle>Settings</DialogTitle>
        </DialogContent>
      </Dialog>
    </Hideable>
  )
  await render(page("visible"))
  await act(async () => root!.render(page("hidden")))
  await settle()
  await act(async () => root!.render(page("hidden", <section />)))
  await settle()
  expect(dialog()!.localName).toBe("section")
  expect(effects()).toEqual(gone)
  await act(async () => root!.render(page("visible", <section />)))
  await settle()
  expect(effects()).toEqual(shown)
})

test("an open dialog in a container keeps the display Octane gives it while its <Activity> hides", async () => {
  const page = (mode: "visible" | "hidden", display?: string) => (
    <Hideable mode={mode}>
      <Dialog defaultOpen container={document.body}>
        <DialogContent style={{ display }}>
          <DialogTitle>Settings</DialogTitle>
        </DialogContent>
      </Dialog>
    </Hideable>
  )
  await render(page("visible"))
  await act(async () => root!.render(page("hidden")))
  await settle()
  await act(async () => root!.render(page("hidden", "grid")))
  await settle()
  expect(effects()).toEqual(gone)
  await act(async () => root!.render(page("visible", "grid")))
  await settle()
  expect(effects()).toEqual(shown)
  expect(dialog()!.style.display).toBe("grid")
})

test("an open dialog rendered into a container hides while a Suspense boundary shows its fallback again", async () => {
  // Reads a promise, so a pending one suspends the page.
  function Data({ ready }: { ready: Promise<string> }) {
    return <p>{React.use(ready)}</p>
  }
  const page = (ready: Promise<string>) => (
    <React.Suspense fallback={<p>Loading</p>}>
      <main>
        <Data ready={ready} />
        <Dialog defaultOpen container={document.body}>
          <DialogContent>
            <DialogTitle>Settings</DialogTitle>
          </DialogContent>
        </Dialog>
      </main>
    </React.Suspense>
  )
  const loaded = Promise.resolve("Loaded")
  await render(page(loaded))
  await settle()
  expect(effects()).toEqual(shown)
  let resolve = (_value: string) => {}
  const reloading = new Promise<string>((done) => (resolve = done))
  await act(async () => root!.render(page(reloading)))
  await settle()
  expect(effects()).toEqual(gone)
  await act(async () => resolve("Loaded again"))
  await settle()
  expect(effects()).toEqual(shown)
})

test("a field inside a form leaves submitting to the form's own onSubmit", async () => {
  const submit = vi.fn((event: Event) => event.preventDefault())
  const view = await render(
    <form onSubmit={submit}>
      <Field name="title">
        <input defaultValue="Draft" />
      </Field>
      <button type="submit">Submit</button>
    </form>
  )
  await act(async () => view.querySelector("button")!.click())
  expect(submit).toHaveBeenCalledTimes(1)
})

const signals: AbortSignal[] = []
const load = (_query: string, { signal }: { signal: AbortSignal }) => {
  signals.push(signal)
  return new Promise<string[]>(() => {})
}

function Options() {
  const { status } = useAsyncOptions(load, { immediate: true })
  return <p>{status}</p>
}

// Octane renders on the server only from modules compiled for it, so the
// server's HTML comes through Vite's server loader, from a copy of `Options`.
async function serverHtml() {
  const id = path.join(import.meta.dirname, "options.tsx")
  const vite = await createServer({
    root: import.meta.dirname,
    configFile: false,
    logLevel: "silent",
    appType: "custom",
    server: { middlewareMode: true, hmr: false, ws: false },
    plugins: [
      {
        name: "options",
        enforce: "pre",
        resolveId: (request) => (request === "./options.tsx" ? id : undefined),
        load: (request) =>
          request === id
            ? [
                "/** @jsxImportSource octane */",
                'import { useAsyncOptions } from "../src/async-options"',
                "export function Options({ load }) {",
                "  const { status } = useAsyncOptions(load, { immediate: true })",
                "  return <p>{status}</p>",
                "}",
              ].join("\n")
            : undefined,
      },
      octane({ ssr: true }),
    ],
  })
  try {
    const { renderToString } = await vite.ssrLoadModule("octane/server")
    const { Options } = await vite.ssrLoadModule("./options.tsx")
    return renderToString(Options, { load }).html as string
  } finally {
    await vite.close()
  }
}

test("useAsyncOptions loads once Octane mounts, not while rendering, and cancels on unmount", async () => {
  signals.length = 0
  expect(await serverHtml()).toContain("loading")
  expect(signals).toHaveLength(0)
  const view = await render(<Options />)
  expect(view.textContent).toBe("loading")
  expect(signals).toHaveLength(1)
  await act(async () => root!.unmount())
  await act(async () => {})
  root = undefined
  expect(signals.map((signal) => signal.aborted)).toEqual([true])
}, 60_000)

const choice = definePrimitive({
  name: "choice",
  state: (_options: {}) => ({ selected: "" }),
  api: ({ store }) => ({
    select: (selected: string) => store.set({ selected }),
  }),
  slots: (slot) => ({
    option: slot<{ target: string }, { selected: boolean }>({
      props: { target: "string" },
      state: (state, { props }) => ({
        selected: state.selected === props.target,
      }),
      selects: selects({ selected: ({ props }) => [props.target] }),
    }),
  }),
})

function Choice({ target }: { target: string }) {
  const handle = usePrimitive(choice, {})
  return (
    <>
      <button onClick={() => handle.api.select("after")}>Pick</button>
      {usePart(
        handle,
        "option",
        { target },
        { children: (state: { selected: boolean }) => String(state.selected) },
        "span"
      )}
    </>
  )
}

test("a part subscribes again when the prop it selects on changes", async () => {
  const view = await render(<Choice target="before" />)
  await act(async () => root!.render(<Choice target="after" />))
  await act(async () => view.querySelector("button")!.click())
  expect(view.querySelector("span")!.textContent).toBe("true")
})

test("a dialog whose content takes an inline ref leaves Escape to the popover opened inside it", async () => {
  function Settings() {
    const [open, setOpen] = React.useState(false)
    return (
      <Dialog defaultOpen>
        <DialogContent ref={(el) => void el}>
          <DialogTitle>Settings</DialogTitle>
          <Popover open={open} onOpenChange={setOpen}>
            <PopoverTrigger>Filters</PopoverTrigger>
            <PopoverContent>Filter list</PopoverContent>
          </Popover>
        </DialogContent>
      </Dialog>
    )
  }
  const view = await render(<Settings />)
  await act(async () =>
    view.querySelector<HTMLElement>('[aria-haspopup="dialog"]')!.click()
  )
  await act(() => settle())
  await act(async () => {
    document.activeElement!.dispatchEvent(
      new KeyboardEvent("keydown", { key: "Escape", bubbles: true })
    )
  })
  await act(() => settle())
  expect(view.textContent).not.toContain("Filter list")
  expect(view.querySelector('[role="dialog"]')?.hasAttribute("data-open")).toBe(
    true
  )
})

test("unmounting an open dialog lets the page go in the same commit", async () => {
  let hide = () => {}
  function App() {
    const [shown, setShown] = React.useState(true)
    hide = () => setShown(false)
    return (
      <>
        <input aria-label="Outside" />
        {shown && (
          <Dialog defaultOpen>
            <DialogContent>
              <DialogTitle>Settings</DialogTitle>
            </DialogContent>
          </Dialog>
        )}
      </>
    )
  }
  const view = await render(<App />)
  const inert = (el: HTMLElement | null): boolean =>
    !!el && (el.inert || inert(el.parentElement))
  const outside = view.querySelector("input")!
  await act(() => settle())
  expect(inert(outside)).toBe(true)
  act(() => flushSync(hide))
  expect(inert(outside)).toBe(false)
})
