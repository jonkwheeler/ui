import { createCollapsibleController } from "@ui-sdk/core/collapsible"
import {
  Collapsible,
  CollapsiblePanel,
  CollapsibleTrigger,
} from "@ui-sdk/octane/collapsible"
import { createRoot, useState } from "octane"
import { collapsibleFixture as fixture } from "tests/fixtures/collapsible.ts"
import { collapsibleOptions } from "tests/fixtures/page.ts"

const controller = createCollapsibleController()

function Fixture() @{
  const [action, setAction] = useState("")
  const [reason, setReason] = useState("")
  const [source, setSource] = useState("")
  const [complete, setComplete] = useState("")
  const { cancel, keepMounted, hiddenUntilFound, ...options } =
    collapsibleOptions()

  <div class="fixture">
    <button>Before</button>
    <Collapsible
      className="collapsible"
      controller={controller}
      {...options}
      onOpenChange={(open, details) => {
        if (cancel === (open ? "open" : "close")) {
          return details.cancel()
        }
        setAction(open ? "open" : "closed")
        setReason(details.reason)
        setSource(details.source)
      }}
      onOpenChangeComplete={(open) => setComplete(open ? "open" : "closed")}
    >
      <CollapsibleTrigger className="collapsible-trigger">
        {fixture.trigger as string}
      </CollapsibleTrigger>
      <CollapsiblePanel
        className="collapsible-panel"
        keepMounted={keepMounted}
        hiddenUntilFound={hiddenUntilFound}
      >
        <p>{fixture.content as string}</p>
        <label>
          {`${fixture.field} `}
          <input />
        </label>
        <button onClick={() => controller.close()}>
          {fixture.close as string}
        </button>
      </CollapsiblePanel>
    </Collapsible>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
    <output aria-label="Last reason">{reason as string}</output>
    <output aria-label="Last source">{source as string}</output>
    <output aria-label="Last completed">{complete as string}</output>
    <button onClick={() => controller.toggle()}>
      {fixture.controller as string}
    </button>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
