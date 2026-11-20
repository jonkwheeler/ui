/** @jsxImportSource octane */
import * as React from "octane"
import { createRoot } from "octane"
import { Fixture } from "./octane"

// The same select, rendered from `items`.
function mount(root: HTMLElement) {
  createRoot(root).render(
    <React.StrictMode>
      <Fixture data />
    </React.StrictMode>
  )
}

export { mount }
