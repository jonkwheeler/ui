/** @jsxImportSource octane */
import { hydrateFixture } from "../../ssr/octane-hydrate"
import { Fixture } from "./octane"

// Server renders, then the client hydrates. Every mismatch Octane reports is recorded.
function mount(root: HTMLElement) {
  return hydrateFixture(root, "avatar", Fixture)
}

export { mount }
