/** @jsxImportSource octane */
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogTitle,
  DialogTrigger,
} from "@ui-sdk/octane/dialog"
import { Menu, MenuTrigger } from "@ui-sdk/octane/menu"
import * as React from "octane"
import { createRoot } from "octane"
import { casesData } from "./data"

function Fixture() {
  const [action, setAction] = React.useState("")
  const [align, setAlign] = React.useState("left")
  const [journal, setJournal] = React.useState(false)
  const [shortcuts, setShortcuts] = React.useState(true)
  return (
    <div className="fixture">
      <button>Before</button>
      <Menu
        items={casesData({ align, journal })}
        itemShortcuts={shortcuts}
        onAction={setAction}
      >
        <MenuTrigger>Edit</MenuTrigger>
      </Menu>
      <button onClick={() => setAlign("right")}>Align right</button>
      <button onClick={() => setJournal(true)}>Add journal</button>
      <button onClick={() => setShortcuts(false)}>Turn off shortcuts</button>
      <button>After</button>
      <input aria-label="Notes" />
      <Dialog>
        <DialogTrigger>Open dialog</DialogTrigger>
        <DialogContent className="dialog">
          <DialogTitle className="title">Settings</DialogTitle>
          <DialogClose>Close</DialogClose>
        </DialogContent>
      </Dialog>
      <output role="status" aria-label="Last action">
        {action}
      </output>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
