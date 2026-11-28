import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@ui-sdk/octane/select"
import { createRoot } from "octane"
import {
  countRender,
  mountWhenAsked,
  perfItems,
  perfSize,
} from "tests/fixtures/perf.ts"

// A long select for the counts specs. Every other option reads
// `highlighted` in its render function, so specs can tell plain options'
// renders from watched ones.
const items = perfItems(perfSize())

function Fixture() @{
  <div class="fixture">
    <button>Before</button>
    <Select defaultValue={items[0].value}>
      <SelectTrigger aria-label="Pick" className="trigger">
        <SelectValue />
      </SelectTrigger>
      <SelectContent className="popup list-popup">
        @for (const item of items; index position; key item.value) {
          @if (position % 2) {
            <SelectItem
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
            </SelectItem>
          } @else {
            <SelectItem
              className="item"
              value={item.value}
              label={item.label}
              render={(props) => {
                countRender("plain")
                return <div {...props} />
              }}
            >
              {item.label as string}
            </SelectItem>
          }
        }
      </SelectContent>
    </Select>
    <button>After</button>
  </div>
}

function mount(root: HTMLElement) {
  mountWhenAsked(root, (target) => createRoot(target).render(<Fixture />))
}

export { mount }
