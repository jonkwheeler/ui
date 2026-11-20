/** @jsxImportSource octane */
import { hydrateFixture } from "../../ssr/octane-hydrate"
import { Fixture } from "./octane"

// Server renders, then the client hydrates. Every mismatch Octane reports is
// recorded, and the server's markup is kept under the name the specs read.
async function mount(root: HTMLElement) {
  await hydrateFixture(root, "timeline", Fixture)
  const page = window as unknown as Record<string, unknown>
  page.__serverMarkup = page.__serverHtml
}

export { mount }
