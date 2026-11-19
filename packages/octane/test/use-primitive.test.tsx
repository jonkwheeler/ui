/** @jsxImportSource octane */
import { definePrimitive } from "@ui-sdk/core"
import {
  act,
  Activity,
  createRoot,
  hydrateRoot,
  type ReactElement,
  type Root,
} from "octane"
import { octane } from "octane/compiler/vite"
import { createServer } from "vite"
import { afterEach, expect, test, vi } from "vitest"
import { createParts, usePart, usePrimitive } from "../src/primitive"
import { DescribedInput, idNames, renderedIds } from "./described-input"

let root: Root | undefined

async function render(element: ReactElement) {
  const container = document.body.appendChild(document.createElement("div"))
  root = createRoot(container)
  await act(async () => root!.render(element))
  return container
}

const settle = () => new Promise((resolve) => setTimeout(resolve))

afterEach(async () => {
  await act(async () => root?.unmount())
  root = undefined
  document.body.replaceChildren()
})

test("typing in a part calls the slot's input handler once per edit", async () => {
  const typed: string[] = []
  const echo = definePrimitive({
    name: "echo",
    state: (_options: {}) => ({}),
    api: () => ({}),
    slots: (slot) => ({
      root: slot<{}, {}>({
        on: {
          input: (event) =>
            typed.push((event.target as HTMLInputElement).value),
        },
      }),
    }),
  })
  function Echo() {
    return usePart(usePrimitive(echo, {}), "root", {}, {}, "input")
  }
  const view = await render(<Echo />)
  const input = view.querySelector("input")!
  for (const char of "abc") {
    input.value += char
    input.dispatchEvent(new Event("input", { bubbles: true }))
  }
  expect(typed).toEqual(["a", "ab", "abc"])
})

const labelled = definePrimitive({
  name: "labelled",
  options: { onPress: "callback" },
  state: (_options: { onPress?: (label: string) => void }) => ({}),
  api: ({ options }) => ({
    press: (label: string) => options().onPress?.(label),
  }),
  slots: (slot) => ({
    root: slot<{ label: string }, {}>({
      props: { label: "string" },
      on: { click: (_event, { props, api }) => api.press(props.label) },
    }),
  }),
})

function Labelled({
  label,
  onPress,
}: {
  label: string
  onPress: (label: string) => void
}) {
  return usePart(
    usePrimitive(labelled, { onPress }),
    "root",
    { label },
    {},
    "button"
  )
}

test("a part's props from a later commit reach its handlers after that commit", async () => {
  const pressed: string[] = []
  const press = (label: string) => pressed.push(label)
  const view = await render(<Labelled label="first" onPress={press} />)
  await act(async () =>
    root!.render(<Labelled label="second" onPress={press} />)
  )
  await act(async () => view.querySelector("button")!.click())
  expect(pressed).toEqual(["second"])
})

test("a root's options from a later commit reach its instance after that commit", async () => {
  const pressed: string[] = []
  const view = await render(<Labelled label="save" onPress={() => {}} />)
  await act(async () =>
    root!.render(
      <Labelled label="save" onPress={(label) => pressed.push(label)} />
    )
  )
  await act(async () => view.querySelector("button")!.click())
  expect(pressed).toEqual(["save"])
})

// Octane renders on the server only from modules compiled for it, so the
// server's HTML comes through Vite's server loader.
async function serverHtml() {
  const vite = await createServer({
    root: import.meta.dirname,
    configFile: false,
    logLevel: "silent",
    appType: "custom",
    server: { middlewareMode: true, hmr: false, ws: false },
    plugins: [octane({ ssr: true })],
  })
  try {
    const { renderToString } = await vite.ssrLoadModule("octane/server")
    const fixture = await vite.ssrLoadModule("./described-input.tsx")
    return renderToString(fixture.DescribedInput).html as string
  } finally {
    await vite.close()
  }
}

test("hydrating a part renders the three ids the server gave it", async () => {
  const container = document.body.appendChild(document.createElement("div"))
  container.innerHTML = await serverHtml()
  const input = container.querySelector("input")!
  const fromServer = idNames.map((name) => input.getAttribute(name))
  await act(async () => {
    root = hydrateRoot(container, <DescribedInput />)
  })
  expect(new Set(fromServer).size).toBe(3)
  expect(renderedIds.at(-1)).toEqual(fromServer)
}, 30_000)

const tally = definePrimitive({
  name: "tally",
  state: (_options: {}) => ({ count: 0 }),
  api: ({ store }) => ({
    add: () => store.set({ count: store.get().count + 1 }),
  }),
  slots: (slot) => ({
    root: slot<{}, {}>({}),
    button: slot<{}, {}>({
      attrs: (state) => ({ "data-count": String(state.count) }),
      on: { click: (_event, { api }) => api.add() },
    }),
  }),
})

test.each([
  ["renders an element", createParts(tally, { root: "div", button: "button" })],
  ["renders no element", createParts(tally, { button: "button" })],
])(
  "a part finds its root's instance when the root %s",
  async (_, { Root, Button }) => {
    const view = await render(
      <Root>
        <Button />
      </Root>
    )
    const button = view.querySelector("button")!
    await act(async () => button.click())
    expect(button.dataset.count).toBe("1")
  }
)

function lifecyclePrimitive(destroy: () => void) {
  return definePrimitive({
    name: "counter",
    state: (_options: {}) => ({ count: 0 }),
    api: ({ store, onDestroy }) => {
      onDestroy(destroy)
      return { increment: () => store.set({ count: store.get().count + 1 }) }
    },
    slots: (slot) => ({
      root: slot<{}, { count: number }>({
        state: ({ count }) => ({ count }),
        on: { click: (_event, { api }) => api.increment() },
      }),
    }),
  })
}

function counterIn(counter: ReturnType<typeof lifecyclePrimitive>) {
  return function Counter() {
    return usePart(
      usePrimitive(counter, {}),
      "root",
      {},
      { children: (state: { count: number }) => state.count },
      "button"
    )
  }
}

test("unmounting a root destroys its instance once", async () => {
  const destroy = vi.fn()
  const Counter = counterIn(lifecyclePrimitive(destroy))
  await render(<Counter />)
  await act(async () => root!.unmount())
  root = undefined
  await settle()
  expect(destroy).toHaveBeenCalledTimes(1)
})

test("hiding a root with <Activity> keeps its state and its instance", async () => {
  const destroy = vi.fn()
  const Counter = counterIn(lifecyclePrimitive(destroy))
  const page = (mode: "visible" | "hidden") => (
    <Activity mode={mode}>
      <Counter />
    </Activity>
  )
  const view = await render(page("visible"))
  await act(async () => view.querySelector("button")!.click())
  await act(async () => root!.render(page("hidden")))
  await settle()
  await act(async () => root!.render(page("visible")))
  expect(view.querySelector("button")!.textContent).toBe("1")
  expect(destroy).not.toHaveBeenCalled()
})
