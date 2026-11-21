import {
  Combobox,
  ComboboxContent,
  ComboboxInput,
  ComboboxItem,
  ComboboxList,
} from "@ui-sdk/octane/combobox"
import { createRoot } from "octane"
import { countRender, perfItems, perfSize } from "tests/fixtures/perf.ts"

// A long combobox for the counts specs. Every other option
// reads `highlighted` in its render function, so specs can tell plain
// options' renders from watched ones.
const items = perfItems(perfSize())

function Fixture() @{
  <div class="fixture">
    <button>Before</button>
    <Combobox>
      <ComboboxInput aria-label="Search" className="input" />
      <ComboboxContent className="popup list-popup">
        <ComboboxList>
          @for (const item of items; index position; key item.value) {
            @if (position % 2) {
              <ComboboxItem
                className="item"
                value={item.value}
                label={item.label}
                render={(props, state) => {
                  countRender("watched")
                  return (
                    <div {...props}>
                      {state.highlighted ? "→ " : ""}
                      {props.children}
                    </div>
                  )
                }}
              >
                {item.label as string}
              </ComboboxItem>
            } @else {
              <ComboboxItem
                className="item"
                value={item.value}
                label={item.label}
                render={(props) => {
                  countRender("plain")
                  return <div {...props} />
                }}
              >
                {item.label as string}
              </ComboboxItem>
            }
          }
        </ComboboxList>
      </ComboboxContent>
    </Combobox>
    <button>After</button>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
