import { Toolbar, ToolbarButton } from "@ui-sdk/octane/toolbar"
import { createRoot } from "octane"
import { mountWhenAsked, perfItems, perfSize } from "tests/fixtures/perf.ts"

// A toolbar with many buttons for the counts specs.
const items = perfItems(perfSize())

function Fixture() @{
  <div class="fixture">
    <button>Before</button>
    <Toolbar
      className="toolbar"
      aria-label="Formatting"
      style={{ flexWrap: "wrap" }}
    >
      @for (const item of items; key item.value) {
        <ToolbarButton>{item.label as string}</ToolbarButton>
      }
    </Toolbar>
    <button>After</button>
  </div>
}

function mount(root: HTMLElement) {
  mountWhenAsked(root, (target) => createRoot(target).render(<Fixture />))
}

export { mount }
