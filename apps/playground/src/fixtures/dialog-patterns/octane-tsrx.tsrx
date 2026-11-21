import {
  AlertDialog,
  AlertDialogBackdrop,
  AlertDialogClose,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@ui-sdk/octane/alert-dialog"
import {
  createDialogController,
  Dialog,
  DialogBackdrop,
  DialogClose,
  DialogContent,
  DialogShortcut,
  DialogTitle,
  DialogTrigger,
} from "@ui-sdk/octane/dialog"
import { Menu, MenuContent, MenuItem, MenuTrigger } from "@ui-sdk/octane/menu"
import {
  Popover,
  PopoverContent,
  PopoverTitle,
  PopoverTrigger,
} from "@ui-sdk/octane/popover"
import { useShortcut } from "@ui-sdk/octane/shortcuts"
import { createRoot, useRef, useState } from "octane"
import { dialogPatternsFixture as f } from "tests/fixtures/dialog.ts"
import { pendingAction, recordOpenChange } from "./shared"

const rename = createDialogController()

function Fixture() @{
  const [action, setAction] = useState("")
  const [dirty, setDirty] = useState(false)
  const [details, setDetails] = useState(false)
  const field = useRef<HTMLInputElement>(null)
  useShortcut(f.pageShortcut, () => setAction("page shortcut"))
  useShortcut(f.slashShortcut, () => setAction("slash"))
  // Belongs to the dialog, so it runs while the dialog is open and modal.
  useShortcut(f.rename.save, () => setAction("saved"), {
    layer: field,
    allowInInput: true,
  })

  <div class="fixture">
    <button>Before</button>
    <Menu>
      <MenuTrigger shortcut={f.menu.shortcut}>
        {f.menu.trigger as string}
      </MenuTrigger>
      <MenuContent className="menu">
        <MenuItem value="rename" onSelect={() => rename.open()}>
          {f.menu.rename as string}
        </MenuItem>
        <MenuItem value="close">{f.menu.close as string}</MenuItem>
      </MenuContent>
    </Menu>
    <Dialog
      controller={rename}
      dismissible={!dirty}
      persistentElements={["#chat"]}
      onDismissAttempt={({ reason }) => setAction(`attempt:${reason}`)}
      onOpenChange={(open, details) => {
        recordOpenChange("rename", open, details)
        if (!open) {
          setDirty(false)
        }
      }}
    >
      <DialogTrigger shortcut={f.rename.shortcut}>
        {f.rename.trigger as string} <DialogShortcut className="shortcut" />
      </DialogTrigger>
      <DialogBackdrop className="dialog-backdrop" />
      <DialogContent className="dialog">
        <DialogTitle className="title">{f.rename.title as string}</DialogTitle>
        <label class="field">
          {f.rename.field as string}
          <input
            ref={field}
            defaultValue={f.rename.defaultValue}
            onInput={() => setDirty(true)}
          />
        </label>
        <DialogClose>{f.rename.cancel as string}</DialogClose>
      </DialogContent>
    </Dialog>
    <AlertDialog
      onOpenChange={(open, details) =>
        recordOpenChange("delete", open, details)
      }
    >
      <AlertDialogTrigger>{f.remove.trigger as string}</AlertDialogTrigger>
      <AlertDialogBackdrop className="dialog-backdrop" />
      <AlertDialogContent className="dialog">
        <AlertDialogTitle className="title">
          {f.remove.title as string}
        </AlertDialogTitle>
        <AlertDialogDescription className="description">
          {f.remove.description as string}
        </AlertDialogDescription>
        <AlertDialogClose>{f.remove.cancel as string}</AlertDialogClose>
        <AlertDialogClose value="confirm" action={pendingAction}>
          {f.remove.action as string}
        </AlertDialogClose>
      </AlertDialogContent>
    </AlertDialog>
    <label>
      {f.search as string}
      <input />
    </label>
    <button id="chat" onClick={() => setAction("chat")}>
      {f.chat as string}
    </button>
    <Popover container={document.getElementById("popover-root")}>
      <PopoverTrigger shortcut={f.share.shortcut}>
        {f.share.trigger as string}
      </PopoverTrigger>
      <PopoverContent className="popover">
        <PopoverTitle>{f.share.title as string}</PopoverTitle>
        <Menu>
          <MenuTrigger>{f.share.menu as string}</MenuTrigger>
          <MenuContent className="menu">
            <MenuItem value="copy">{f.share.item as string}</MenuItem>
          </MenuContent>
        </Menu>
        <Dialog>
          <DialogTrigger>{f.share.dialog as string}</DialogTrigger>
          <DialogContent className="dialog">
            <DialogTitle className="title">
              {f.share.dialogTitle as string}
            </DialogTitle>
            <DialogClose>{f.share.done as string}</DialogClose>
          </DialogContent>
        </Dialog>
      </PopoverContent>
    </Popover>
    <Menu onAction={(value) => value === "details" && setDetails(true)}>
      <MenuTrigger>{f.details.menu as string}</MenuTrigger>
      <MenuContent className="menu">
        <MenuItem value="details">{f.details.item as string}</MenuItem>
      </MenuContent>
    </Menu>
    <Dialog open={details} onOpenChange={setDetails}>
      <DialogContent className="dialog">
        <DialogTitle className="title">{f.details.title as string}</DialogTitle>
        <DialogClose>{f.details.done as string}</DialogClose>
      </DialogContent>
    </Dialog>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
