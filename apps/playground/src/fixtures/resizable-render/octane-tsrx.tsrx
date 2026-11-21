import {
  Resizable,
  ResizableHandle,
  ResizablePanel,
} from "@ui-sdk/octane/resizable"
import { createRoot, useState } from "octane"

// How often the first panel's children rendered, for specs that check a drag
// renders nothing that doesn't read the size.
const counts = { renders: 0 }
Object.assign(window, { panelRenders: counts })

function Fixture() @{
  const [action, setAction] = useState("")

  <div class="fixture">
    <button>Before</button>
    <Resizable
      className="resizable"
      onLayoutCommit={(layout) => setAction(`layout:${layout.map(Math.round)}`)}
    >
      <ResizablePanel
        defaultSize={30}
        collapsible
        minSize={10}
        className="resizable-panel"
        role="group"
        aria-label="Files"
      >
        {(state) => {
          counts.renders++
          return (
            <span class="panel-state">
              {(state.collapsed ? "Collapsed" : "Open") as string}
            </span>
          )
        }}
      </ResizablePanel>
      <ResizableHandle
        render={<span />}
        aria-label="Resize files"
        className={(state) =>
          `resizable-handle ${state.dragging ? "is-dragging" : "is-idle"}`
        }
      />
      <ResizablePanel
        className="resizable-panel"
        role="group"
        aria-label="Editor"
      >
        {(state) => (
          <span class="panel-size">{String(Math.round(state.size))}</span>
        )}
      </ResizablePanel>
    </Resizable>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
