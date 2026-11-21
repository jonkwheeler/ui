import {
  Collapsible,
  CollapsiblePanel,
  CollapsibleTrigger,
} from "@ui-sdk/octane/collapsible"
import { createRoot } from "octane"
import { mountWhenAsked, perfSize } from "tests/fixtures/perf.ts"

// N closed collapsibles, like the folders of a long tree.
// With ?found, closed panels stay in the page for find in page.
const items = Array.from({ length: perfSize(200) }, (_, index) => index)
const found = new URLSearchParams(location.search).has("found")

function Fixture() @{
  <div
    class="fixture"
    style={{ flexDirection: "column", alignItems: "start" }}
  >
    <button>Before</button>
    @for (const index of items; key index) {
      <Collapsible className="collapsible-row">
        <CollapsibleTrigger className="collapsible-trigger">
          {`Folder ${index + 1}`}
        </CollapsibleTrigger>
        <CollapsiblePanel
          className="collapsible-panel"
          hiddenUntilFound={found}
        >
          {`Files ${index + 1}`}
        </CollapsiblePanel>
      </Collapsible>
    }
    <button>After</button>
  </div>
}

function mount(root: HTMLElement) {
  mountWhenAsked(root, (target) => createRoot(target).render(<Fixture />))
}

export { mount }
