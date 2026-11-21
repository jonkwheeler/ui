import { Dialog, DialogContent, DialogTrigger } from "@ui-sdk/octane/dialog"
import { Drawer, DrawerContent, DrawerTrigger } from "@ui-sdk/octane/drawer"
import {
  Menu,
  MenuContent,
  MenuGroup,
  MenuGroupLabel,
  MenuItem,
  MenuTrigger,
} from "@ui-sdk/octane/menu"
import {
  createPopoverController,
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@ui-sdk/octane/popover"
import { createRoot, useState } from "octane"
import {
  contentFor,
  describeChange,
  payloadOf,
  popupPayloadsFixture as fixture,
} from "tests/fixtures/popup-payloads.ts"

type Details = { event?: Event }

const people = createPopoverController<string>()

function MenuPayload({ payload }: { payload: unknown }) @{
  <MenuGroup>
    <MenuGroupLabel>{contentFor(payload) as string}</MenuGroupLabel>
    <MenuItem className="item" value="open">
      {fixture.menu.item as string}
    </MenuItem>
  </MenuGroup>
}

function PopoverPayload({ payload }: { payload: unknown }) @{
  <>
    {contentFor(payload) as string}
    <button
      onClick={() => people.open({ payload: fixture.popover.show.payload })}
    >
      {fixture.popover.show.label as string}
    </button>
  </>
}

function Fixture() @{
  const [lastOpen, setLastOpen] = useState("")
  const [lastPayload, setLastPayload] = useState("")
  // The callbacks every popup reports through.
  const report = (name: string) => ({
    onOpenChange: (open: boolean, { event }: Details) =>
      open && setLastOpen(describeChange(name, "open", event)),
    onPayloadChange: (payload: unknown, { event }: Details) =>
      setLastPayload(describeChange(name, `payload ${payload}`, event)),
  })

  <div class="fixture">
    <button>Before</button>
    <Menu {...report("menu")}>
      @for (const label of fixture.menu.triggers; key label) {
        <MenuTrigger payload={payloadOf(label)}>
          {label as string}
        </MenuTrigger>
      }
      <MenuContent className="popup">
        {(state) => <MenuPayload payload={state.payload} />}
      </MenuContent>
    </Menu>
    <Popover controller={people} {...report("popover")}>
      @for (const label of fixture.popover.triggers; key label) {
        <PopoverTrigger payload={payloadOf(label)}>
          {label as string}
        </PopoverTrigger>
      }
      <PopoverContent className="popup">
        {(state) => <PopoverPayload payload={state.payload} />}
      </PopoverContent>
    </Popover>
    <Dialog modal={false} {...report("dialog")}>
      @for (const label of fixture.dialog.triggers; key label) {
        <DialogTrigger payload={payloadOf(label)}>
          {label as string}
        </DialogTrigger>
      }
      <DialogContent className="dialog">
        {(state) => contentFor(state.payload)}
      </DialogContent>
    </Dialog>
    <Drawer modal={false} {...report("drawer")}>
      @for (const label of fixture.drawer.triggers; key label) {
        <DrawerTrigger payload={payloadOf(label)}>
          {label as string}
        </DrawerTrigger>
      }
      <DrawerContent className="drawer">
        {(state) => contentFor(state.payload)}
      </DrawerContent>
    </Drawer>
    <output role="status" aria-label="Last open">
      {lastOpen as string}
    </output>
    <output role="status" aria-label="Last payload">
      {lastPayload as string}
    </output>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
