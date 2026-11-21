import {
  Menu,
  MenuCheckboxItem,
  MenuContent,
  MenuItem,
  MenuItemIndicator,
  MenuTrigger,
} from "@ui-sdk/octane/menu"
import { createRoot } from "octane"
import { countRender, perfItems, perfSize } from "tests/fixtures/perf.ts"

// Every other item reads `highlighted` in its render function, so the counts
// specs can tell plain items' renders from watched ones. The last checkbox
// item changes state only it and its indicator show.
const items = perfItems(perfSize())

function Item({
  item,
  watched,
}: {
  item: (typeof items)[number]
  watched: boolean
}) @{
  <>
    @if (watched) {
      <MenuItem
        className="item"
        value={item.value}
        render={(props, state) => {
          countRender("watched")
          return (
            <div {...props}>
              {(state.highlighted ? "→ " : "") as string}
              {props.children}
            </div>
          )
        }}
      >
        {item.label as string}
      </MenuItem>
    } @else {
      <MenuItem
        className="item"
        value={item.value}
        render={(props) => {
          countRender("plain")
          return <div {...props} />
        }}
      >
        {item.label as string}
      </MenuItem>
    }
  </>
}

function Fixture() @{
  <div class="fixture">
    <button>Before</button>
    <Menu>
      <MenuTrigger>File</MenuTrigger>
      <MenuContent
        className="popup"
        style={{ maxHeight: 320, overflow: "auto" }}
      >
        @for (const item of items; index position; key item.value) {
          <Item item={item} watched={position % 2 === 1} />
        }
        <MenuCheckboxItem
          className="item"
          value="wrap"
          render={(props) => {
            countRender("checkbox")
            return <div {...props} />
          }}
        >
          <MenuItemIndicator>✓</MenuItemIndicator>
          Wrap lines
        </MenuCheckboxItem>
      </MenuContent>
    </Menu>
    <button>After</button>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
