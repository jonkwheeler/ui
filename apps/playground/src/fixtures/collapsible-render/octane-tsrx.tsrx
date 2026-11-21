import {
  Collapsible,
  CollapsiblePanel,
  CollapsibleTrigger,
} from "@ui-sdk/octane/collapsible"
import { createRoot, useState } from "octane"

function Fixture() @{
  const [action, setAction] = useState("")

  <div class="fixture">
    <button>Before</button>
    <Collapsible
      className={(state) =>
        `collapsible ${state.open ? "is-open" : "is-closed"}`
      }
      onOpenChange={(open) => setAction(open ? "open" : "closed")}
    >
      <CollapsibleTrigger
        className="collapsible-trigger"
        render={(props, state) => (
          <div {...props}>
            Files<span aria-hidden>{` ${state.open ? "−" : "+"}`}</span>
          </div>
        )}
      />
      <CollapsiblePanel className="collapsible-panel" render={<section />}>
        The files panel.
      </CollapsiblePanel>
    </Collapsible>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
