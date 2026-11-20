import { Textarea } from "@ui-sdk/octane/textarea"
import {
  type TriggerMenuDataItem,
  TriggerMenu,
  TriggerMenuContent,
  TriggerMenuEmpty,
  TriggerMenuHint,
  TriggerMenuInput,
  TriggerMenuItem,
  TriggerMenuList,
  TriggerMenuStatus,
} from "@ui-sdk/octane/trigger-menu"
import { createRoot, useId, useState } from "octane"
import {
  fixtureTriggers,
  selectAction,
  triggerMenuFixture as f,
  triggerMenuOptions,
} from "tests/fixtures/trigger-menu.ts"

function Suggestions({ items }: { items: TriggerMenuDataItem[] }) @{
  <>
    @for (const item of items; key item.value) {
      <TriggerMenuItem
        value={item.value}
        label={item.label}
        disabled={item.disabled}
        className="item"
      >
        {item.label as string}
      </TriggerMenuItem>
    }
  </>
}

function Composer({
  name,
  onAction,
  onOpen,
}: {
  name: string
  onAction: (action: string) => void
  onOpen: (open: string) => void
}) @{
  const { input, textarea, empty, autoHighlight } = triggerMenuOptions()
  const [triggers] = useState(fixtureTriggers)
  const id = useId()

  <TriggerMenu
    triggers={triggers}
    autoHighlight={autoHighlight}
    onOpenChange={(open, details) => onOpen(`${open}:${details.reason}`)}
    onSelect={(value, details) =>
      onAction(selectAction(value, details.arguments))
    }
  >
    <label class="label" htmlFor={id}>
      {name as string}
    </label>
    <TriggerMenuInput
      id={id}
      name="message"
      className="input"
      render={
        input ? <input /> : textarea ? <Textarea autoResize /> : undefined
      }
    />
    <TriggerMenuHint className="hint" />
    <TriggerMenuStatus className="status" />
    <TriggerMenuContent className="popup list-popup">
      @if (empty) {
        <TriggerMenuEmpty className="empty">
          {f.empty as string}
        </TriggerMenuEmpty>
      }
      <TriggerMenuList>
        {(state) => (
          <Suggestions items={state.items as TriggerMenuDataItem[]} />
        )}
      </TriggerMenuList>
    </TriggerMenuContent>
  </TriggerMenu>
}

function Fixture() @{
  const { twice } = triggerMenuOptions()
  const [action, setAction] = useState("")
  const [open, setOpen] = useState("")
  const [submitted, setSubmitted] = useState("")

  <div class="fixture">
    <button>Before</button>
    <form
      class="composer"
      aria-label={f.formLabel}
      onSubmit={(event) => {
        event.preventDefault()
        const form = event.currentTarget as HTMLFormElement
        setSubmitted(String(new FormData(form).get("message")))
      }}
    >
      <Composer name={f.label} onAction={setAction} onOpen={setOpen} />
      @if (twice) {
        <Composer name="Second" onAction={setAction} onOpen={setOpen} />
      }
      <button type="submit">{f.submit as string}</button>
    </form>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
    <output role="status" aria-label="Open">
      {open as string}
    </output>
    <output role="status" aria-label="Submitted">
      {submitted as string}
    </output>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
