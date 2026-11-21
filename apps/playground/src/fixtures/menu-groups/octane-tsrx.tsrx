import {
  Menu,
  MenuContent,
  MenuGroup,
  MenuGroupLabel,
  MenuItem,
  MenuTrigger,
} from "@ui-sdk/octane/menu"
import { createRoot, useEffect, useState } from "octane"
import { onItemsChange } from "tests/fixtures/items.ts"
import { changedMenuGroups, menuGroups } from "tests/fixtures/menu-groups.ts"

function Group({ group }: { group: (typeof menuGroups)[number] }) @{
  <MenuGroup>
    <MenuGroupLabel className="label">{group.label as string}</MenuGroupLabel>
    @for (const item of group.items; key item.value) {
      <MenuItem className="item" value={item.value}>
        {item.label as string}
      </MenuItem>
    }
  </MenuGroup>
}

// Groups of items the specs reorder while the menu is open.
function Fixture() @{
  const [groups, setGroups] = useState(menuGroups)
  useEffect(() => onItemsChange(changedMenuGroups, setGroups), [])

  <div class="fixture">
    <button>Before</button>
    <Menu>
      <MenuTrigger>Actions</MenuTrigger>
      <MenuContent className="popup">
        @for (const group of groups; key group.label) {
          <Group group={group} />
        }
      </MenuContent>
    </Menu>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
