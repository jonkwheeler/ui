import { Tabs, TabsList, TabsPanel, TabsTab } from "@ui-sdk/octane/tabs"
import { createRoot, useState } from "octane"
import { perfItems, perfSize } from "tests/fixtures/perf.ts"

// Many tabs for the counts specs.
const items = perfItems(perfSize())

// `?controlled` keeps the value in this component, which renders again on
// every change, like an app that shows the selected tab elsewhere.
const controlled = new URLSearchParams(location.search).has("controlled")

function Fixture() @{
  const [value, setValue] = useState<string>(items[0].value)

  <div class="fixture">
    <button>Before</button>
    <Tabs
      className="tabs"
      {...(controlled
        ? {
            value,
            onValueChange: (next: string | null) =>
              setValue(next ?? items[0].value),
          }
        : { defaultValue: items[0].value })}
    >
      <TabsList
        className="tablist"
        aria-label="Pages"
        style={{ flexWrap: "wrap" }}
      >
        @for (const item of items; key item.value) {
          <TabsTab className="tab" value={item.value}>
            {item.label as string}
          </TabsTab>
        }
      </TabsList>
      @for (const item of items; key item.value) {
        <TabsPanel className="panel" value={item.value}>
          {`${item.label} content.`}
        </TabsPanel>
      }
    </Tabs>
    @if (controlled) {
      <p>{`Showing ${value}`}</p>
    }
    <button>After</button>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
