/** @jsxImportSource octane */
import { act, createRoot, type Root } from "octane"
import { afterEach, expect, test } from "vitest"
import { Toast, ToastRegion, ToastTitle, createToaster } from "../src/toast"

Element.prototype.getAnimations ??= () => []
HTMLElement.prototype.showPopover ??= function () {}
HTMLElement.prototype.hidePopover ??= function () {}

let root: Root | undefined

afterEach(async () => {
  await act(async () => root?.unmount())
  root = undefined
  document.body.replaceChildren()
})

test("a toast shows where ResizeObserver doesn't exist", async () => {
  expect(typeof ResizeObserver).toBe("undefined")
  const toaster = createToaster()
  const container = document.body.appendChild(document.createElement("div"))
  // React unmounts the tree when a part throws as it binds. Octane logs the
  // error and keeps the toast, so only its report shows the bind failed.
  const errors: unknown[] = []
  root = createRoot(container, {
    onUncaughtError: (error) => errors.push(error),
  })
  await act(async () =>
    root!.render(
      <ToastRegion toaster={toaster}>
        {() => (
          <Toast>
            <ToastTitle />
          </Toast>
        )}
      </ToastRegion>
    )
  )
  await act(async () => {
    toaster("Saved")
  })
  expect(errors).toEqual([])
  expect(container.querySelector('[data-slot="toast"]')?.textContent).toBe(
    "Saved"
  )
})
