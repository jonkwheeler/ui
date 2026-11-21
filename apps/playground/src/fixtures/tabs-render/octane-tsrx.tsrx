import { Tabs, TabsList, TabsPanel, TabsTab } from "@ui-sdk/octane/tabs"
import { createRoot, useState } from "octane"
import { tabsOptions } from "tests/fixtures/page.ts"

function Fixture() @{
  const [action, setAction] = useState("")
  const [reason, setReason] = useState("")
  const { activation } = tabsOptions()

  <div class="fixture">
    <button>Before</button>
    <Tabs
      className="tabs"
      defaultValue="overview"
      activation={activation}
      onValueChange={(value, details) => {
        setAction(value ?? "")
        setReason(details.reason)
      }}
    >
      <TabsList className="tablist" aria-label="Project">
        <TabsTab
          className="tab"
          value="overview"
          render={<a href="#overview" />}
        >
          Overview
        </TabsTab>
        <TabsTab
          className="tab"
          value="activity"
          render={<a href="#activity" />}
        >
          Activity
        </TabsTab>
        <TabsTab
          className="tab"
          value="watched"
          render={(props, state) => (
            <button {...props}>
              {props.children}
              {state.selected && <span aria-hidden> •</span>}
            </button>
          )}
        >
          Watched
        </TabsTab>
        <TabsTab
          value="plain"
          className={(state) =>
            `tab ${state.selected ? "is-selected" : "is-unselected"}`
          }
        >
          Plain
        </TabsTab>
      </TabsList>
      @for (const value of [
          "overview",
          "activity",
          "watched",
          "plain",
        ]; key value) {
        <TabsPanel className="panel" value={value}>
          {`The ${value} panel.`}
        </TabsPanel>
      }
    </Tabs>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
    <output role="status" aria-label="Reason">
      {reason as string}
    </output>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
