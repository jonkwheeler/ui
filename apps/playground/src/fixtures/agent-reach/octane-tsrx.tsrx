import { Button } from "@ui-sdk/octane/button"
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogTitle,
  DialogTrigger,
} from "@ui-sdk/octane/dialog"
import { Input } from "@ui-sdk/octane/input"
import { createRoot, useState } from "octane"
import { agentReachFixture } from "tests/fixtures/agent-reach.ts"

const { shown, hidden, inert, dialog } = agentReachFixture

function Controls({
  name,
  onAction,
}: {
  name: string
  onAction: (action: string) => void
}) @{
  <>
    <Input
      aria-label={`${name} field`}
      onValueChange={() => onAction(`${name} set`)}
    />
    <Button onClick={() => onAction(`${name} pressed`)}>
      {`${name} button`}
    </Button>
  </>
}

function Fixture() @{
  const [action, setAction] = useState("")

  <div class="fixture">
    <button>Before</button>
    <section>
      <Controls name={shown} onAction={setAction} />
    </section>
    @for (const { name, props } of hidden; key name) {
      @if (name === "Details") {
        <details>
          <summary>More</summary>
          <Controls name={name} onAction={setAction} />
        </details>
      } @else {
        <section {...props}>
          <Controls name={name} onAction={setAction} />
        </section>
      }
    }
    <section inert>
      <Controls name={inert} onAction={setAction} />
    </section>
    <Dialog>
      <DialogTrigger>{dialog.trigger as string}</DialogTrigger>
      <DialogContent className="dialog">
        <DialogTitle className="title">{dialog.title as string}</DialogTitle>
        <Controls name={dialog.name} onAction={setAction} />
        <DialogClose>Close</DialogClose>
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

export { Fixture, mount }
