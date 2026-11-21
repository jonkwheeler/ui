import {
  ScrollArea,
  ScrollAreaScrollbar,
  ScrollAreaThumb,
  ScrollAreaViewport,
} from "@ui-sdk/octane/scroll-area"
import { createRoot } from "octane"

const notes = Array.from({ length: 40 }, (_, index) => `Note ${index + 1}`)
const renders = ((window as unknown as { renders: { root: number } }).renders =
  { root: 0 })

function Notes({ atEnd }: { atEnd: boolean }) @{
  <>
    <p class="render-status">{(atEnd ? "At end" : "Reading") as string}</p>
    <ScrollAreaViewport
      render={<article />}
      className="scroll-area-viewport"
      role="region"
      aria-label="Notes"
    >
      @for (const note of notes; key note) {
        <p class="scroll-area-item">{note as string}</p>
      }
    </ScrollAreaViewport>
    <ScrollAreaScrollbar className="scroll-area-scrollbar">
      <ScrollAreaThumb className="scroll-area-thumb" />
    </ScrollAreaScrollbar>
  </>
}

// The root rendered as a section, whose content is a function of its state.
// It counts its renders, which only an edge flipping should cause.
function Fixture() @{
  <div class="fixture">
    <button>Before</button>
    <ScrollArea render={<section />} className="scroll-area">
      {(state) => {
        renders.root++
        return <Notes atEnd={state.atEnd} />
      }}
    </ScrollArea>
    <button>After</button>
    <output role="status" aria-label="Last action" />
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
