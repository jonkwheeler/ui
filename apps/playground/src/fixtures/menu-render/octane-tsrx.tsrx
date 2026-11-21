import {
  Menu,
  MenuCheckboxItem,
  MenuContent,
  MenuItem,
  MenuTrigger,
} from "@ui-sdk/octane/menu"
import { createRoot, useState } from "octane"

// Counts renders of each custom item, so specs can check what re-renders.
const renders = { watched: 0, plain: 0 }
;(window as unknown as { __renders: typeof renders }).__renders = renders

function Fixture() @{
  const [action, setAction] = useState("")

  <div class="fixture">
    <button>Before</button>
    <Menu onAction={setAction}>
      <MenuTrigger>File</MenuTrigger>
      <MenuContent className="popup">
        <MenuItem className="item" value="docs" render={<a href="#docs" />}>
          Docs
        </MenuItem>
        <MenuItem
          className="item"
          value="watched"
          render={(props, state) => {
            renders.watched++
            return (
              <div {...props}>
                {(state.highlighted ? "→ " : "") as string}
                {props.children}
              </div>
            )
          }}
        >
          Watched
        </MenuItem>
        <MenuItem
          className="item"
          value="plain"
          render={(props) => {
            renders.plain++
            return <div {...props} />
          }}
        >
          Plain
        </MenuItem>
        <MenuCheckboxItem
          value="pinned"
          className={(state) =>
            `item ${state.checked ? "is-checked" : "is-unchecked"}`
          }
        >
          Pinned
        </MenuCheckboxItem>
      </MenuContent>
    </Menu>
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
