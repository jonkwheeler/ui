import {
  AlertDialog,
  AlertDialogBackdrop,
  AlertDialogClose,
  AlertDialogContent,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@ui-sdk/octane/alert-dialog"
import {
  Dialog,
  DialogBackdrop,
  DialogClose,
  DialogContent,
  DialogTitle,
  DialogTrigger,
} from "@ui-sdk/octane/dialog"
import {
  Drawer,
  DrawerBackdrop,
  DrawerClose,
  DrawerContent,
  DrawerTitle,
  DrawerTrigger,
} from "@ui-sdk/octane/drawer"
import {
  Popover,
  PopoverClose,
  PopoverContent,
  PopoverTitle,
  PopoverTrigger,
} from "@ui-sdk/octane/popover"
import { Activity, createRoot, useState, type ElementType } from "octane"
import { presentationOption } from "tests/fixtures/presentation.ts"

// Two pages under <Activity>. The profile page's popup (?popup=dialog|alert-dialog|drawer|popover,
// ?container=id, ?presentation=sheet) leaves for the other page while open,
// the way a link in it would.
const params = new URLSearchParams(location.search)
const container = params.has("container")
  ? document.getElementById(params.get("container")!)
  : undefined
const popup = params.get("popup") ?? "dialog"

// The popup's title, a field to type in, a way to leave the page, and Close.
function Fields({
  Title,
  Close,
  onLeave,
}: {
  Title: ElementType
  Close: ElementType
  onLeave: () => void
}) @{
  <>
    <Title className="title">Edit profile</Title>
    <label class="field">
      Name
      <input />
    </label>
    <div class="actions">
      <button onClick={onLeave}>Leave page</button>
      <Close>Close</Close>
    </div>
  </>
}

function ProfilePage({ onLeave }: { onLeave: () => void }) @{
  <>
    @if (popup === "alert-dialog") {
      <AlertDialog container={container}>
        <AlertDialogTrigger>Edit profile</AlertDialogTrigger>
        <AlertDialogBackdrop className="dialog-backdrop" />
        <AlertDialogContent className="dialog">
          <Fields
            Title={AlertDialogTitle}
            Close={AlertDialogClose}
            onLeave={onLeave}
          />
        </AlertDialogContent>
      </AlertDialog>
    } @else if (popup === "drawer") {
      <Drawer container={container}>
        <DrawerTrigger>Edit profile</DrawerTrigger>
        <DrawerBackdrop className="dialog-backdrop" />
        <DrawerContent className="drawer">
          <Fields
            Title={DrawerTitle}
            Close={DrawerClose}
            onLeave={onLeave}
          />
        </DrawerContent>
      </Drawer>
    } @else if (popup === "popover") {
      <Popover container={container} modal {...presentationOption()}>
        <PopoverTrigger>Edit profile</PopoverTrigger>
        <PopoverContent className="popup">
          <Fields
            Title={PopoverTitle}
            Close={PopoverClose}
            onLeave={onLeave}
          />
        </PopoverContent>
      </Popover>
    } @else {
      <Dialog container={container} {...presentationOption()}>
        <DialogTrigger>Edit profile</DialogTrigger>
        <DialogBackdrop className="dialog-backdrop" />
        <DialogContent className="dialog">
          <Fields
            Title={DialogTitle}
            Close={DialogClose}
            onLeave={onLeave}
          />
        </DialogContent>
      </Dialog>
    }
  </>
}

// Octane 0.20.0 needs a `props` parameter to compile <Activity> children.
function Fixture(props: object) @{
  const [page, setPage] = useState<"profile" | "other">("profile")

  <div class="fixture">
    <button>Before</button>
    <Activity mode={page === "profile" ? "visible" : "hidden"}>
      <section>
        <ProfilePage onLeave={() => setPage("other")} />
      </section>
    </Activity>
    <Activity mode={page === "other" ? "visible" : "hidden"}>
      <section>
        <button onClick={() => setPage("profile")}>Back to profile</button>
      </section>
    </Activity>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
