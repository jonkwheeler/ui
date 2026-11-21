import { confirm } from "@ui-sdk/octane/alert-dialog"
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogTitle,
  DialogTrigger,
} from "@ui-sdk/octane/dialog"
import { OverlayHost } from "@ui-sdk/octane/overlays"
import {
  Toast,
  ToastAction,
  ToastClose,
  ToastDescription,
  ToastRegion,
  ToastTitle,
  type ToastData,
} from "@ui-sdk/octane/toast"
import { createRoot, useState, type OctaneNode } from "octane"
import { toastFixture, toastOptions, usesHost } from "tests/fixtures/toast.ts"
import { createFixtureToasts } from "./shared"

function HostToast({ toast }: { toast: ToastData<OctaneNode> }) @{
  <Toast className="toast">
    <ToastTitle />
    <ToastDescription />
    <ToastAction />
    @if (toast.cancel) {
      <ToastClose action={toast.cancel.onCancel}>
        {toast.cancel.label}
      </ToastClose>
    }
  </Toast>
}

function Fixture() @{
  const [action, setAction] = useState("")
  // Made here, not at module level, so the server reads each request's URL.
  const [toasts] = useState(() =>
    createFixtureToasts<OctaneNode>((action) => setAction(action))
  )
  const host = usesHost()

  <div class="fixture">
    <button>Before</button>
    <button onClick={toasts.basic}>
      {toastFixture.basic.trigger as string}
    </button>
    <button onClick={toasts.success}>
      {toastFixture.success.trigger as string}
    </button>
    <button onClick={toasts.error}>
      {toastFixture.error.trigger as string}
    </button>
    <button onClick={toasts.promise}>
      {toastFixture.promise.trigger as string}
    </button>
    <Dialog>
      <DialogTrigger>{toastFixture.dialog.trigger as string}</DialogTrigger>
      <DialogContent className="dialog">
        <DialogTitle className="title">
          {toastFixture.dialog.title as string}
        </DialogTitle>
        <button onClick={toasts.basic}>
          {toastFixture.dialog.toast as string}
        </button>
        <DialogClose>{toastFixture.dialog.close as string}</DialogClose>
      </DialogContent>
    </Dialog>
    @if (host) {
      <button
        onClick={async () => {
          const {
            title,
            confirm: confirmLabel,
            cancel,
          } = toastFixture.confirm
          const yes = await confirm({
            title,
            confirmLabel,
            cancelLabel: cancel,
          })
          setAction(yes ? "confirmed" : "declined")
        }}
      >
        {toastFixture.confirm.trigger as string}
      </button>
    }
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
    @if (host) {
      <OverlayHost
        toast={{
          ...toastOptions(),
          className: "toast-region",
          children: (toast) => <HostToast toast={toast} />,
        }}
      />
    } @else {
      <ToastRegion
        toaster={toasts.toast}
        className="toast-region"
        {...toastOptions()}
      >
        {() => (
          <Toast className="toast">
            <ToastTitle className="toast-title" />
            <ToastDescription className="toast-description" />
            <ToastAction className="toast-action" />
            <ToastClose className="toast-close">
              {toastFixture.dismiss as string}
            </ToastClose>
          </Toast>
        )}
      </ToastRegion>
    }
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
