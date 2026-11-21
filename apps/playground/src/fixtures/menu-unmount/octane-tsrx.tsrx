import { Menu, MenuContent, MenuItem, MenuTrigger } from "@ui-sdk/octane/menu"
import { createRoot, useState } from "octane"

function Fixture() @{
  const [open, setOpen] = useState(false)

  <div class="fixture">
    <button>Before</button>
    <Menu open={open} onOpenChange={setOpen}>
      <MenuTrigger>Actions</MenuTrigger>
      @if (open) {
        <MenuContent className="popup fill-in">
          <MenuItem className="item" value="rename">
            Rename
          </MenuItem>
          <MenuItem className="item" value="delete">
            Delete
          </MenuItem>
        </MenuContent>
      }
    </Menu>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
