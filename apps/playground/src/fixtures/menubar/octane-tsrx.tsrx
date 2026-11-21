import {
  Menu,
  MenuCheckboxItem,
  MenuContent,
  MenuItem,
  MenuRadioGroup,
  MenuRadioItem,
  MenuSeparator,
  MenuSub,
  MenuSubContent,
  MenuSubTrigger,
  MenuTrigger,
} from "@ui-sdk/octane/menu"
import { Menubar, createMenubarController } from "@ui-sdk/octane/menubar"
import { createRoot, useState } from "octane"
import { menubarFixture as f, menubarOptions } from "tests/fixtures/menubar.ts"

const controller = createMenubarController()
// The window holds the specs' hooks, and the server has none.
if (typeof window !== "undefined") {
  ;(window as unknown as { __menubar: typeof controller }).__menubar =
    controller
}

function Fixture() @{
  const [action, setAction] = useState("")

  <div class="fixture">
    <button>Before</button>
    <Menubar
      className="menubar"
      aria-label={f.label}
      controller={controller}
      {...menubarOptions()}
    >
      <Menu onAction={setAction}>
        <MenuTrigger>{f.file.trigger as string}</MenuTrigger>
        <MenuContent className="popup">
          @for (const item of f.file.items; key item.value) {
            <MenuItem
              className="item"
              value={item.value}
              shortcut={item.shortcut}
            >
              {item.label as string}
            </MenuItem>
          }
          <MenuSub>
            <MenuSubTrigger className="item">
              {f.file.share.trigger as string}
            </MenuSubTrigger>
            <MenuSubContent className="popup">
              @for (const item of f.file.share.items; key item.value) {
                <MenuItem className="item" value={item.value}>
                  {item.label as string}
                </MenuItem>
              }
            </MenuSubContent>
          </MenuSub>
          <MenuSeparator className="separator" />
          <MenuItem className="item" value={f.file.print.value}>
            {f.file.print.label as string}
          </MenuItem>
        </MenuContent>
      </Menu>
      <Menu onAction={setAction}>
        <MenuTrigger>{f.edit.trigger as string}</MenuTrigger>
        <MenuContent className="popup">
          @for (const item of f.edit.items; key item.value) {
            <MenuItem
              className="item"
              value={item.value}
              disabled={item.disabled}
            >
              {item.label as string}
            </MenuItem>
          }
        </MenuContent>
      </Menu>
      <Menu
        onCheckedChange={(checked, { value }) =>
          setAction(`${value}: ${checked ? "on" : "off"}`)
        }
      >
        <MenuTrigger shortcut={f.view.shortcut}>
          {f.view.trigger as string}
        </MenuTrigger>
        <MenuContent className="popup">
          @for (const item of f.view.checkboxes; key item.value) {
            <MenuCheckboxItem
              className="item"
              value={item.value}
              defaultChecked={item.defaultChecked}
            >
              {item.label as string}
            </MenuCheckboxItem>
          }
        </MenuContent>
      </Menu>
      <Menu>
        <MenuTrigger>{f.profiles.trigger as string}</MenuTrigger>
        <MenuContent className="popup">
          <MenuRadioGroup
            defaultValue={f.profiles.defaultValue}
            onValueChange={(value) => setAction(`profile: ${value}`)}
          >
            @for (const item of f.profiles.items; key item.value) {
              <MenuRadioItem className="item" value={item.value}>
                {item.label as string}
              </MenuRadioItem>
            }
          </MenuRadioGroup>
        </MenuContent>
      </Menu>
      <Menu onAction={setAction}>
        <MenuTrigger disabled>{f.help.trigger as string}</MenuTrigger>
        <MenuContent className="popup">
          @for (const item of f.help.items; key item.value) {
            <MenuItem className="item" value={item.value}>
              {item.label as string}
            </MenuItem>
          }
        </MenuContent>
      </Menu>
    </Menubar>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
