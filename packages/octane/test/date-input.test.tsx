/** @jsxImportSource octane */
import * as React from "octane"
import { act, createRoot, type Root } from "octane"
import { octane } from "octane/compiler/vite"
import { createServer } from "vite"
import { afterEach, expect, test, vi } from "vitest"
import { DateInput, DateInputSegment } from "../src/date-input"
import { Field, FieldLabel } from "../src/field"
import { TimeInput } from "../src/time-input"

let root: Root | undefined

afterEach(async () => {
  await act(async () => root?.unmount())
  document.body.innerHTML = ""
})

async function render(node: React.ReactElement) {
  const container = document.body.appendChild(document.createElement("div"))
  root = createRoot(container)
  await act(async () => root!.render(node))
  return container
}

const segment = (container: HTMLElement, type: string) =>
  container.querySelector<HTMLInputElement>(`input[data-type="${type}"]`)!

async function type(text: string) {
  for (const char of text) {
    await act(async () => {
      document.activeElement!.dispatchEvent(
        new InputEvent("beforeinput", {
          inputType: "insertText",
          data: char,
          bubbles: true,
          cancelable: true,
        })
      )
    })
  }
}

const shown = (container: HTMLElement) =>
  [...container.querySelector('[role="group"]')!.children]
    .filter(
      (node) => !(node instanceof HTMLInputElement && node.type === "hidden")
    )
    .map((node) =>
      node instanceof HTMLInputElement ? node.value : node.textContent
    )
    .join("")
    .replace(/\s/g, " ")

// Octane renders on the server only from modules compiled for it, so the
// server's HTML comes through Vite's server loader.
async function serverHtml(props: React.ComponentProps<typeof DateInput>) {
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
    const server = await vite.ssrLoadModule("../src/date-input.tsx")
    return renderToString(server.DateInput, props).html as string
  } finally {
    await vite.close()
  }
}

test("the server renders each segment as an input with its value, and the hidden input", async () => {
  const server = document.createElement("div")
  server.innerHTML = await serverHtml({
    defaultValue: "2026-11-02",
    name: "start",
    locale: "en-US",
  })
  expect(
    server.querySelectorAll('[role="group"] [role="spinbutton"]')
  ).toHaveLength(3)
  expect(segment(server, "month").getAttribute("value")).toBe("11")
  expect(segment(server, "year").getAttribute("value")).toBe("2026")
  const hidden = server.querySelector<HTMLInputElement>('input[type="hidden"]')!
  expect([hidden.name, hidden.getAttribute("value")]).toEqual([
    "start",
    "2026-11-02",
  ])
}, 60_000)

test("typing a date fills the segments and reports the ISO value once", async () => {
  const onValueChange = vi.fn()
  const container = await render(
    <DateInput locale="en-US" onValueChange={onValueChange} />
  )
  segment(container, "month").focus()
  await type("11042026")
  expect(onValueChange.mock.calls.map(([value]) => value)).toEqual([
    "2026-11-04",
  ])
  expect(shown(container)).toBe("11/04/2026")
  expect(
    container.querySelector<HTMLInputElement>('input[type="hidden"]')!.value
  ).toBe("2026-11-04")
})

test("a controlled value follows its owner", async () => {
  function Controlled() {
    const [value, setValue] = React.useState<string | null>("09:30")
    return (
      <>
        <TimeInput
          value={value}
          onValueChange={setValue}
          hourCycle={24}
          locale="en-US"
        />
        <output>{value}</output>
      </>
    )
  }
  const container = await render(<Controlled />)
  segment(container, "minute").focus()
  await act(async () => {
    document.activeElement!.dispatchEvent(
      new KeyboardEvent("keydown", {
        key: "ArrowUp",
        bubbles: true,
        cancelable: true,
      })
    )
  })
  expect(container.querySelector("output")!.textContent).toBe("09:31")
  expect(segment(container, "minute").value).toBe("31")
})

test("a field's label names the group and focuses its first segment", async () => {
  const container = await render(
    <Field>
      <FieldLabel>Start date</FieldLabel>
      <DateInput locale="en-US" />
    </Field>
  )
  const group = container.querySelector('[role="group"]')!
  const label = container.querySelector("label")!
  expect(group.getAttribute("aria-labelledby")).toContain(label.id)
  await act(async () => label.click())
  expect(document.activeElement).toBe(segment(container, "month"))
})

test("children can render the segments themselves", async () => {
  const container = await render(
    <DateInput defaultValue="2026-11-02" locale="en-US">
      {({ segments }) =>
        segments.map((item) => (
          <DateInputSegment
            key={item.key}
            segment={item}
            className={`segment-${item.type}`}
          />
        ))
      }
    </DateInput>
  )
  expect(container.querySelector(".segment-month")).toBe(
    segment(container, "month")
  )
  expect(container.querySelector(".segment-literal")!.textContent).toBe("/")
})
