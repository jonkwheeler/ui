/** @jsxImportSource octane */
import { Menu, MenuTrigger } from "@ui-sdk/octane/menu"
import { createMenuController } from "@ui-sdk/core/menu"
import * as React from "octane"
import { menuOptions } from "tests/fixtures/page.ts"
import { createRoot } from "octane"
import { menuData } from "./data"

const controller = createMenuController()

function Fixture() {
  const [action, setAction] = React.useState("")
  return (
    <div className="fixture">
      <button>Before</button>
      <Menu
        items={menuData}
        onAction={setAction}
        controller={controller}
        {...menuOptions()}
      >
        <MenuTrigger>File</MenuTrigger>
      </Menu>
      <button>After</button>
      <output role="status" aria-label="Last action">
        {action}
      </output>
      <button onClick={() => controller.open({ focus: "first" })}>
        Open with controller
      </button>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(
    <React.StrictMode>
      <Fixture />
    </React.StrictMode>
  )
}

export { mount }
