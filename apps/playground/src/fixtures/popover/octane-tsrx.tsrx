import { createPopoverController } from "@ui-sdk/core/popover"
import { Menu, MenuContent, MenuItem, MenuTrigger } from "@ui-sdk/octane/menu"
import {
  Popover,
  PopoverArrow,
  PopoverClose,
  PopoverContent,
  PopoverDescription,
  PopoverShortcut,
  PopoverTitle,
  PopoverTrigger,
} from "@ui-sdk/octane/popover"
import { createRoot, useState } from "octane"
import {
  popoverContentOptions,
  popoverFixture,
  popoverOptions,
  popoverParts,
} from "tests/fixtures/popover.ts"

const controller = createPopoverController()

function Fixture() @{
  // Read here, not at module level, so the server reads each request's URL.
  const parts = popoverParts()
  const [action, setAction] = useState("")
  const [triggerShown, setTriggerShown] = useState(true)
  const options = popoverOptions()

  <div class="fixture">
    <button>Before</button>
    <Popover controller={controller} {...options}>
      @if (triggerShown) {
        <PopoverTrigger
          shortcut={
            parts.shortcut ? popoverFixture.shortcut.trigger : undefined
          }
        >
          {popoverFixture.trigger as string}
          @if (parts.shortcut) {
            <PopoverShortcut />
          }
        </PopoverTrigger>
      }
      <PopoverContent
        className="popup"
        sideOffset={8}
        {...popoverContentOptions()}
      >
        <PopoverArrow className="arrow" />
        @if (parts.title) {
          <PopoverTitle className="title">
            {popoverFixture.title as string}
          </PopoverTitle>
        }
        <PopoverDescription className="description">
          {popoverFixture.description as string}
        </PopoverDescription>
        <label class="field">
          {popoverFixture.field as string}
          <input defaultValue={popoverFixture.defaultValue} />
        </label>
        <div class="actions">
          <button onClick={() => setAction("save")}>
            {popoverFixture.action as string}
            @if (parts.shortcut) {
              <PopoverShortcut shortcut={popoverFixture.shortcut.save} />
            }
          </button>
          <PopoverClose>{popoverFixture.close as string}</PopoverClose>
          @if (parts.removable) {
            <button onClick={() => setTriggerShown(false)}>
              {popoverFixture.remove as string}
            </button>
          }
        </div>
        @if (parts.menu) {
          <Menu container={options.container} onAction={setAction}>
            <MenuTrigger>
              {popoverFixture.menu.trigger as string}
            </MenuTrigger>
            <MenuContent className="popup">
              @for (const item of popoverFixture.menu
                  .items; key item.value) {
                <MenuItem value={item.value} className="item">
                  {item.label as string}
                </MenuItem>
              }
            </MenuContent>
          </Menu>
        }
        @if (parts.nested) {
          <Popover>
            <PopoverTrigger>
              {popoverFixture.nested.trigger as string}
            </PopoverTrigger>
            <PopoverContent className="popup">
              <PopoverTitle className="title">
                {popoverFixture.nested.title as string}
              </PopoverTitle>
              <button onClick={() => setAction("archive")}>
                {popoverFixture.nested.action as string}
              </button>
            </PopoverContent>
          </Popover>
        }
      </PopoverContent>
    </Popover>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
    <button onClick={() => controller.open()}>Open with controller</button>
    @if (parts.shortcut) {
      <PopoverTrigger
        controller={controller}
        shortcut={popoverFixture.shortcut.remote.keys}
      >
        {popoverFixture.shortcut.remote.trigger as string}
        <PopoverShortcut />
      </PopoverTrigger>
    }
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
