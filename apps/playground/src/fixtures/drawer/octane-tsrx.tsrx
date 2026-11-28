import {
  createDrawerController,
  Drawer,
  DrawerBackdrop,
  DrawerClose,
  DrawerContent,
  DrawerDescription,
  DrawerHandle,
  DrawerOutlet,
  DrawerShortcut,
  DrawerTitle,
  DrawerTrigger,
} from "@ui-sdk/octane/drawer"
import { createRoot, useState } from "octane"
import {
  drawerFixture,
  drawerOptions,
  drawerParts,
  exposeDrawerFixture,
  recordDrawer,
} from "tests/fixtures/drawer.ts"

const controller = createDrawerController()
// The window holds the specs' hooks, and the server has none.
if (typeof window !== "undefined") {
  exposeDrawerFixture(controller)
}

function Fixture() @{
  // Read here, not at module level, so the server reads each request's URL.
  const parts = drawerParts()
  const [action, setAction] = useState("")
  const [more, setMore] = useState(false)

  <div class="fixture">
    <button>Before</button>
    <Drawer
      controller={controller}
      {...drawerOptions()}
      onOpenChange={(open, details) =>
        recordDrawer(`drawer:${open}:${details.reason}`)
      }
      onSnapPointChange={(snapPoint, details) =>
        recordDrawer(`${snapPoint}:${details.reason}`)
      }
      onDismissAttempt={(details) => recordDrawer(`attempt:${details.reason}`)}
    >
      <DrawerTrigger>{drawerFixture.trigger as string}</DrawerTrigger>
      @if (parts.backdrop) {
        <DrawerBackdrop className="drawer-backdrop" />
      }
      <DrawerContent className="drawer">
        <DrawerHandle className="handle" aria-label={drawerFixture.handle} />
        <DrawerTitle className="title">
          {drawerFixture.title as string}
        </DrawerTitle>
        <DrawerDescription className="description">
          {drawerFixture.description as string}
        </DrawerDescription>
        @if (parts.field) {
          <label class="field">
            {drawerFixture.field as string}
            <input />
          </label>
        }
        @if (parts.scroll) {
          <ul
            class="scroll"
            aria-label={drawerFixture.scroll.label}
            tabIndex={0}
          >
            @for (const item of drawerFixture.scroll
                .items; key item) {
              <li>{item as string}</li>
            }
          </ul>
        }
        @if (parts.grow) {
          <>
            <button onClick={() => setMore(true)}>
              {drawerFixture.grow.button as string}
            </button>
            @if (more) {
              <p class="more">
                {drawerFixture.grow.text as string}
              </p>
            }
          </>
        }
        <div class="actions">
          <button onClick={() => setAction("submit")}>
            {drawerFixture.action as string}
          </button>
          <DrawerClose>{drawerFixture.close as string}</DrawerClose>
        </div>
        @if (parts.nested) {
          <Drawer
            onOpenChange={(open, details) =>
              recordDrawer(`nested:${open}:${details.reason}`)
            }
          >
            <DrawerTrigger>
              {drawerFixture.nested.trigger as string}
            </DrawerTrigger>
            @if (parts.backdrop) {
              <DrawerBackdrop className="drawer-backdrop" />
            }
            <DrawerContent className="drawer">
              <DrawerTitle className="title">
                {drawerFixture.nested.title as string}
              </DrawerTitle>
              <DrawerClose>
                {drawerFixture.nested.close as string}
              </DrawerClose>
            </DrawerContent>
          </Drawer>
        }
      </DrawerContent>
    </Drawer>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
    <button onClick={() => controller.open()}>
      {drawerFixture.controller as string}
    </button>
    <button onClick={() => setAction("page")}>
      {drawerFixture.page as string}
    </button>
    @if (parts.shortcut) {
      <DrawerTrigger
        controller={controller}
        shortcut={drawerFixture.shortcut.keys}
      >
        {drawerFixture.shortcut.trigger as string} <DrawerShortcut />
      </DrawerTrigger>
    }
    @if (parts.outlet) {
      <DrawerOutlet
        controller={controller}
        className="outlet"
        role="region"
        aria-label={drawerFixture.outlet.label}
        keyframes={drawerFixture.outlet.keyframes}
      />
    }
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
