import {
  AlertDialog,
  AlertDialogBackdrop,
  AlertDialogClose,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogTitle,
  AlertDialogTrigger,
  createConfirm,
} from "@ui-sdk/octane/alert-dialog"
import {
  createDialogController,
  Dialog,
  DialogBackdrop,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogShortcut,
  DialogTitle,
  DialogTrigger,
} from "@ui-sdk/octane/dialog"
import { createRoot, useState } from "octane"
import {
  alertDialogFixture,
  alertDialogOptions,
  dialogContentOptions,
  dialogFixture,
  dialogOptions,
  dialogParts,
} from "tests/fixtures/dialog.ts"
import { exposeDialogFixture, recordOpenChange } from "./shared"

const controller = createDialogController()
const confirm = createConfirm()
// The window holds the specs' hooks, and the server has none.
if (typeof window !== "undefined") {
  exposeDialogFixture(controller, confirm)
}

function Fixture() @{
  // Read here, not at module level, so the server reads each request's URL.
  const parts = dialogParts()
  const [action, setAction] = useState("")
  const [triggerShown, setTriggerShown] = useState(true)

  <div class="fixture">
    <button>Before</button>
    <Dialog
      controller={controller}
      {...dialogOptions()}
      onOpenChange={(open, details) => {
        recordOpenChange("dialog", open, details)
        if (!open && details.returnValue) {
          setAction(details.returnValue)
        }
      }}
    >
      @if (triggerShown) {
        <DialogTrigger>{dialogFixture.trigger as string}</DialogTrigger>
      }
      @if (parts.backdrop) {
        <DialogBackdrop className="dialog-backdrop" />
      }
      <DialogContent className="dialog" {...dialogContentOptions()}>
        @if (parts.title) {
          <DialogTitle className="title">
            {dialogFixture.title as string}
          </DialogTitle>
        }
        <DialogDescription className="description">
          {dialogFixture.description as string}
        </DialogDescription>
        <label class="field">
          {dialogFixture.field as string}
          <input defaultValue={dialogFixture.defaultValue} />
        </label>
        @if (parts.long) {
          <p class="long">{dialogFixture.long as string}</p>
        }
        <div class="actions">
          <button onClick={() => setAction("save")}>
            {dialogFixture.action as string}
          </button>
          <DialogClose>{dialogFixture.close as string}</DialogClose>
          @if (parts.removable) {
            <button onClick={() => setTriggerShown(false)}>
              {dialogFixture.remove as string}
            </button>
          }
        </div>
        @if (parts.form) {
          <form method="dialog">
            <button value={dialogFixture.form.value}>
              {dialogFixture.form.label as string}
            </button>
          </form>
        }
        @if (parts.nested) {
          <Dialog
            defaultOpen={parts.nestedOpen}
            onOpenChange={(open, details) =>
              recordOpenChange("nested", open, details)
            }
          >
            <DialogTrigger>
              {dialogFixture.nested.trigger as string}
            </DialogTrigger>
            @if (parts.backdrop) {
              <DialogBackdrop className="dialog-backdrop" />
            }
            <DialogContent className="dialog">
              <DialogTitle className="title">
                {dialogFixture.nested.title as string}
              </DialogTitle>
              <DialogClose>
                {dialogFixture.nested.close as string}
              </DialogClose>
            </DialogContent>
          </Dialog>
        }
      </DialogContent>
    </Dialog>
    <AlertDialog controller={confirm.controller} {...alertDialogOptions()}>
      <AlertDialogTrigger>
        {alertDialogFixture.trigger as string}
      </AlertDialogTrigger>
      @if (parts.backdrop) {
        <AlertDialogBackdrop className="dialog-backdrop" />
      }
      <AlertDialogContent className="dialog">
        <AlertDialogTitle className="title">
          {alertDialogFixture.title as string}
        </AlertDialogTitle>
        <AlertDialogDescription className="description">
          {alertDialogFixture.description as string}
        </AlertDialogDescription>
        <div class="actions">
          <AlertDialogClose>
            {alertDialogFixture.cancel as string}
          </AlertDialogClose>
          <AlertDialogClose value="confirm" onClick={() => setAction("delete")}>
            {alertDialogFixture.action as string}
          </AlertDialogClose>
        </div>
      </AlertDialogContent>
    </AlertDialog>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
    <button onClick={() => controller.open()}>Open with controller</button>
    @if (parts.shortcut) {
      <DialogTrigger
        controller={controller}
        shortcut={dialogFixture.shortcut.keys}
      >
        {dialogFixture.shortcut.trigger as string} <DialogShortcut />
      </DialogTrigger>
    }
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
