/** @jsxImportSource octane */
import { act, createRoot, type Root } from "octane"
import { afterEach, expect, test } from "vitest"
import { Separator } from "../src/separator"

let root: Root | undefined

afterEach(async () => {
  await act(async () => root?.unmount())
  root = undefined
  document.body.replaceChildren()
})

test("a separator's rendered element follows a new orientation", async () => {
  const container = document.body.appendChild(document.createElement("div"))
  root = createRoot(container)
  const separator = (orientation: "horizontal" | "vertical") => (
    <Separator
      orientation={orientation}
      render={(props, state) => <hr {...props} title={state.orientation} />}
    />
  )

  await act(async () => root!.render(separator("horizontal")))
  await act(async () => root!.render(separator("vertical")))

  // Octane keeps empty comments around a component's output as anchors.
  expect(container.children).toHaveLength(1)
  expect(container.firstElementChild!.outerHTML).toBe(
    '<hr data-slot="separator" role="separator" aria-orientation="vertical" data-orientation="vertical" title="vertical">'
  )
})
