/** @jsxImportSource octane */
// The "Compose behaviors" docs page, run as written: its files are extracted
// from the page and React's Rendering page, its own tests run, and the React
// component is rendered with Octane.
import { mkdirSync, readFileSync, writeFileSync } from "node:fs"
import path from "node:path"
import * as React from "octane"
import { act, createRoot, type Root } from "octane"
import { octane } from "octane/compiler/vite"
import { createServer } from "vite"
import { afterEach, expect, test } from "vitest"

const docs = path.resolve(
  import.meta.dirname,
  "../../../apps/docs/content/docs"
)
const page = ["core/compose-behaviors.mdx", "react/rendering.mdx"]
  .map((file) => readFileSync(path.join(docs, file), "utf8"))
  .join("\n")
const dir = path.join(import.meta.dirname, ".walkthrough")
mkdirSync(dir, { recursive: true })

// Each file is a code block whose first line names it, like `// rating.ts`.
function extract(name: string, as = name) {
  const block = [...page.matchAll(/```\w+\n([\s\S]*?)```/g)].find((match) =>
    match[1].startsWith(`// ${name}\n`)
  )
  if (!block) {
    throw new Error(`The page has no ${name}`)
  }
  const source = block[1].replace(
    '"@ui-sdk/react/primitive"',
    '"../../src/primitive"'
  )
  writeFileSync(
    path.join(dir, as),
    as.endsWith(".tsx") ? `/** @jsxImportSource octane */\n${source}` : source
  )
}

extract("rating.ts")
extract("rating-react.tsx")
// Not named like a test, so only this file runs it.
extract("rating.test.ts", "rating-test.ts")
// Paths built at runtime, since the files exist only once extracted.
const load = (file: string) => import(/* @vite-ignore */ path.join(dir, file))
await load("rating-test.ts")
type RatingProps = {
  defaultValue?: number
  max?: number
  "aria-label"?: string
  onValueChange?: (value: number, details: { reason: string }) => void
}
const { Rating } = (await load("rating-react.tsx")) as {
  Rating: React.ComponentType<RatingProps>
}

let root: Root | undefined

afterEach(async () => {
  await act(async () => root?.unmount())
  root = undefined
  document.body.replaceChildren()
})

async function render(element: React.ReactElement) {
  const container = document.createElement("div")
  document.body.append(container)
  root = createRoot(container)
  await act(async () => root!.render(element))
  return [...container.querySelectorAll("button")]
}

// Octane renders on the server only from modules compiled for it, so the
// server's HTML comes through Vite's server loader.
async function serverHtml(props: RatingProps) {
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
    const server = await vite.ssrLoadModule(path.join(dir, "rating-react.tsx"))
    return renderToString(server.Rating, props).html as string
  } finally {
    await vite.close()
  }
}

test("the React rating renders a radio group with one tab stop on the server", async () => {
  const html = await serverHtml({
    defaultValue: 2,
    max: 3,
    "aria-label": "Rating",
  })
  expect(html).toContain('role="radiogroup"')
  expect(html.match(/tabindex="0"/g)).toHaveLength(1)
  expect(html).toContain('aria-label="2 stars"')
}, 60_000)

test("all four arrows check, focus and wrap, and a click checks one", async () => {
  const changes: [number, string][] = []
  const stars = await render(
    <Rating
      defaultValue={3}
      aria-label="Rating"
      onValueChange={(value, { reason }) => changes.push([value, reason])}
    />
  )
  stars[2].focus()
  for (const [key, value] of [
    ["ArrowRight", 4],
    ["ArrowDown", 5],
    ["ArrowDown", 1],
    ["ArrowUp", 5],
    ["ArrowLeft", 4],
  ] as const) {
    await act(async () =>
      document.activeElement!.dispatchEvent(
        new KeyboardEvent("keydown", { key, bubbles: true })
      )
    )
    expect(document.activeElement).toBe(stars[value - 1])
    expect(stars[value - 1].getAttribute("aria-checked")).toBe("true")
    expect(stars.map((star) => star.tabIndex)).toEqual(
      stars.map((_, index) => (index === value - 1 ? 0 : -1))
    )
  }
  await act(async () => {
    stars[0].focus()
    stars[0].click()
  })
  expect(changes).toEqual([
    [4, "list-navigation"],
    [5, "list-navigation"],
    [1, "list-navigation"],
    [5, "list-navigation"],
    [4, "list-navigation"],
    [1, "item-press"],
  ])
  expect(stars.map((star) => star.tabIndex)).toEqual([0, -1, -1, -1, -1])
  expect(stars.map((star) => star.hasAttribute("data-filled"))).toEqual([
    true,
    false,
    false,
    false,
    false,
  ])
})
