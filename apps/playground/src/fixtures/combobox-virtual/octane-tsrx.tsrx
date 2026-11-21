import {
  Combobox,
  ComboboxContent,
  ComboboxInput,
  ComboboxItem,
  ComboboxLabel,
  ComboboxList,
} from "@ui-sdk/octane/combobox"
import { createRoot, useRef, useState } from "octane"
import { longItems, scrollForRow, visibleRows } from "tests/fixtures/select.ts"

const items = longItems()
const row = 32
const height = 240

function Rows({
  visible,
  scrollTop,
}: {
  visible: { value: string; label: string }[]
  scrollTop: number
}) @{
  const { start, end } = visibleRows(scrollTop, height, visible.length, row)

  <div style={{ height: visible.length * row, position: "relative" }}>
    @for (const item of visible.slice(start, end); index offset; key item.value) {
      <ComboboxItem
        className="item"
        value={item.value}
        label={item.label}
        index={start + offset}
        style={{
          position: "absolute",
          top: (start + offset) * row,
          height: row,
          left: 0,
          right: 0,
        }}
      >
        {item.label as string}
      </ComboboxItem>
    }
  </div>
}

// 10,000 items, rendering only the rows in view. The combobox navigates and
// filters every item, and tells the list which row to scroll to.
function Fixture() @{
  const scroller = useRef<HTMLDivElement>(null)
  const [scrollTop, setScrollTop] = useState(0)

  <div class="fixture">
    <button>Before</button>
    <Combobox
      items={items}
      onHighlight={(value, { index }) => {
        const el = scroller.current
        if (el && index >= 0) {
          el.scrollTop = scrollForRow(index, el.scrollTop, height, row)
        }
      }}
    >
      <ComboboxLabel className="label">Item</ComboboxLabel>
      <ComboboxInput className="input" />
      <ComboboxContent className="popup">
        <div
          ref={scroller}
          class="long-list"
          style={{ height }}
          onScroll={(event) => setScrollTop(event.currentTarget.scrollTop)}
        >
          <ComboboxList style={{ position: "relative", height: "auto" }}>
            {(state) => (
              <Rows
                visible={state.items as { value: string; label: string }[]}
                scrollTop={scrollTop}
              />
            )}
          </ComboboxList>
        </div>
      </ComboboxContent>
    </Combobox>
    <button>After</button>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
