/** @jsxImportSource octane */
import * as React from "octane"
import { act, Activity, createRoot, type Root } from "octane"
import { afterEach, expect, test } from "vitest"
import { Input } from "../src/input"

let root: Root | undefined
afterEach(async () => {
  await act(async () => root?.unmount())
  root = undefined
  document.body.replaceChildren()
})

const native = Object.getOwnPropertyDescriptor(
  HTMLInputElement.prototype,
  "value"
)!
const seen: string[] = []

function wrapOnce(el: HTMLInputElement) {
  const inner = Object.getOwnPropertyDescriptor(el, "value") ?? native
  Object.defineProperty(el, "value", {
    configurable: true,
    get() {
      return inner.get!.call(this)
    },
    set(value: string) {
      seen.push(value)
      inner.set!.call(this, value)
    },
  })
}

function Wrapped() {
  const ref = React.useRef<HTMLInputElement>(null)
  const done = React.useRef(false)
  React.useEffect(() => {
    if (ref.current && !done.current) {
      done.current = true
      wrapOnce(ref.current)
    }
  }, [])
  return <Input ref={ref} aria-label="Name" defaultValue="" />
}

// Octane's StrictMode doesn't remount, so <Activity> hiding and showing the
// input again unbinds and binds it, as React's StrictMode remount does.
test("a value wrapper added after the input binds survives a hide and show", async () => {
  const host = document.body.appendChild(document.createElement("div"))
  const page = (mode: "visible" | "hidden") => (
    <Activity mode={mode}>
      <Wrapped />
    </Activity>
  )
  root = createRoot(host)
  await act(async () => root!.render(page("visible")))
  await act(async () => root!.render(page("hidden")))
  await act(async () => root!.render(page("visible")))
  host.querySelector("input")!.value = "x"
  expect(seen).toEqual(["x"])
})
