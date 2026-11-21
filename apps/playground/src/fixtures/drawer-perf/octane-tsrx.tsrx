import {
  Drawer,
  DrawerBackdrop,
  DrawerClose,
  DrawerContent,
  DrawerTitle,
  DrawerTrigger,
} from "@ui-sdk/octane/drawer"
import { createRoot } from "octane"
import { drawerOptions } from "tests/fixtures/drawer.ts"
import { perfItems, perfSize } from "tests/fixtures/perf.ts"

// A drawer whose content has many lines, for the counts specs. ?driver picks its driver.
const items = perfItems(perfSize())

function Fixture() @{
  <div class="fixture">
    <button>Before</button>
    <Drawer {...drawerOptions()}>
      <DrawerTrigger>Open</DrawerTrigger>
      <DrawerBackdrop className="drawer-backdrop" />
      <DrawerContent className="drawer">
        <DrawerTitle className="title">Drawer</DrawerTitle>
        @for (const item of items; key item.value) {
          <p>{item.label as string}</p>
        }
        <DrawerClose>Close</DrawerClose>
      </DrawerContent>
    </Drawer>
    <button>After</button>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
