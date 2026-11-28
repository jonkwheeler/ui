import { createTabsController } from "@ui-sdk/core/tabs"
import {
  Tabs,
  TabsIndicator,
  TabsList,
  TabsPanel,
  TabsTab,
} from "@ui-sdk/octane/tabs"
import { createRoot, useState } from "octane"
import { indicatorOptions, tabsOptions } from "tests/fixtures/page.ts"
import { tabsFixture } from "tests/fixtures/tabs.ts"

const controller = createTabsController()

function Panel({
  tab,
  keepMounted,
}: {
  tab: (typeof tabsFixture.tabs)[number]
  keepMounted?: boolean
}) @{
  <TabsPanel className="panel" value={tab.value} keepMounted={keepMounted}>
    {tab.content as string}
    @if (tab.field) {
      <label>
        {` ${tab.field} `}
        <input type="password" />
      </label>
    }
  </TabsPanel>
}

function Fixture() @{
  const [action, setAction] = useState("")
  const { cancel, keepMounted, ...options } = tabsOptions()

  <div class="fixture">
    <button>Before</button>
    <Tabs
      className="tabs"
      controller={controller}
      {...options}
      onValueChange={(value, details) => {
        if (value === cancel) {
          return details.cancel()
        }
        setAction(value ?? "")
      }}
    >
      <TabsList className="tablist" aria-label={tabsFixture.label}>
        @for (const tab of tabsFixture.tabs; key tab.value) {
          <TabsTab
            className="tab"
            value={tab.value}
            disabled={tab.disabled}
          >
            {tab.label as string}
          </TabsTab>
        }
        <TabsIndicator className="indicator" {...indicatorOptions()} />
      </TabsList>
      @for (const tab of tabsFixture.tabs; key tab.value) {
        <Panel tab={tab} keepMounted={keepMounted} />
      }
    </Tabs>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
    <button onClick={() => controller.select("notifications")}>
      Show notifications
    </button>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
