/** @jsxImportSource octane */
import {
  Resizable,
  ResizableHandle,
  ResizablePanel,
} from "@ui-sdk/octane/resizable"
import { Fragment } from "octane"
import { createRoot } from "octane"
import { countRender, perfItems, perfSize } from "tests/fixtures/perf.ts"

// The first two panels take a quarter each, so the first handle has room to
// move. Every other panel reads its size in its render function, so the counts
// specs can tell plain panels' renders from watched ones, like the second.
const panels = perfItems(perfSize())

function Fixture() {
  return (
    <div className="fixture">
      <button>Before</button>
      <Resizable className="resizable-perf">
        {panels.map((panel, index) => (
          <Fragment key={panel.value}>
            {index > 0 && (
              <ResizableHandle
                className="resizable-perf-handle"
                aria-label={`Handle ${index}`}
                render={(props) => {
                  countRender("handle")
                  return <div {...props} />
                }}
              />
            )}
            {index % 2 ? (
              <ResizablePanel
                id={panel.value}
                defaultSize={index < 2 ? 25 : undefined}
                className="resizable-panel"
                render={(props, state) => {
                  countRender("watched")
                  return (
                    <div {...props} data-size={Math.round(state.size)}>
                      {panel.label}
                    </div>
                  )
                }}
              />
            ) : (
              <ResizablePanel
                id={panel.value}
                defaultSize={index < 2 ? 25 : undefined}
                className="resizable-panel"
                render={(props) => {
                  countRender("plain")
                  return <div {...props}>{panel.label}</div>
                }}
              />
            )}
          </Fragment>
        ))}
      </Resizable>
      <button>After</button>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
