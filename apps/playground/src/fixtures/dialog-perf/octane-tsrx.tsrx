import {
  Dialog,
  DialogBackdrop,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogTitle,
  DialogTrigger,
} from "@ui-sdk/octane/dialog"
import { createRoot } from "octane"
import { perfItems, perfSize } from "tests/fixtures/perf.ts"

// Many dialogs on one page, like a delete confirmation in every row of a
// table, for the counts specs. Only the first one is opened.
const items = perfItems(perfSize())

function DeleteDialog({ label }: { label: string }) @{
  <Dialog>
    <DialogTrigger>{`Delete ${label}`}</DialogTrigger>
    <DialogBackdrop className="dialog-backdrop" />
    <DialogContent className="dialog">
      <DialogTitle className="title">{`Delete ${label}?`}</DialogTitle>
      <DialogDescription className="description">
        This can't be undone.
      </DialogDescription>
      <div class="actions">
        <DialogClose>Cancel</DialogClose>
        <button>Delete</button>
      </div>
    </DialogContent>
  </Dialog>
}

function Fixture() @{
  <div class="fixture" style={{ flexWrap: "wrap" }}>
    <button>Before</button>
    @for (const item of items; key item.value) {
      <DeleteDialog label={item.label} />
    }
    <button>After</button>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
