import {
  ScrollArea,
  ScrollAreaContent,
  ScrollAreaScrollbar,
  ScrollAreaThumb,
  ScrollAreaViewport,
} from "@ui-sdk/octane/scroll-area"
import { createRoot } from "octane"
import {
  countRender,
  mountWhenAsked,
  perfItems,
  perfSize,
} from "tests/fixtures/perf.ts"

// A scroll area of N items for the counts specs, with its
// scrollbar always shown. The content, the thumb and every item count their
// renders.
const items = perfItems(perfSize())

function Item({ label }: { label: string }) @{
  countRender("item")

  <p class="scroll-area-item">{label as string}</p>
}

function Fixture() @{
  <div class="fixture scroll-fixture">
    <button>Before</button>
    <ScrollArea className="scroll-area" type="always">
      <ScrollAreaViewport
        className="scroll-area-viewport"
        role="region"
        aria-label="Items"
      >
        <ScrollAreaContent
          render={(props) => {
            countRender("content")
            return <div {...props} />
          }}
        >
          @for (const item of items; key item.value) {
            <Item label={item.label} />
          }
        </ScrollAreaContent>
      </ScrollAreaViewport>
      <ScrollAreaScrollbar className="scroll-area-scrollbar">
        <ScrollAreaThumb
          className="scroll-area-thumb"
          render={(props) => {
            countRender("thumb")
            return <div {...props} />
          }}
        />
      </ScrollAreaScrollbar>
    </ScrollArea>
    <button>After</button>
  </div>
}

function mount(root: HTMLElement) {
  mountWhenAsked(root, (target) => createRoot(target).render(<Fixture />))
}

export { mount }
