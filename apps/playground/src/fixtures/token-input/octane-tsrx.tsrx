import {
  fromText,
  toText,
  TokenInput,
  TokenInputEditor,
  TokenInputToken,
  TokenInputTokenRemove,
} from "@ui-sdk/octane/token-input"
import {
  type TriggerMenuDataItem,
  TriggerMenu,
  TriggerMenuContent,
  TriggerMenuHint,
  TriggerMenuItem,
  TriggerMenuList,
} from "@ui-sdk/octane/trigger-menu"
import { createRoot, useState } from "octane"
import {
  pendingSelect,
  tokenInputFixture as f,
  tokenInputOptions,
  tokenTriggers,
} from "tests/fixtures/token-input.ts"

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

function Fixture() @{
  const { value, pending, fail, form, otherForm, controlled, ...options } =
    tokenInputOptions()
  const [action, setAction] = useState("")
  const [submitted, setSubmitted] = useState("")
  const [triggers] = useState(tokenTriggers)
  const [initial] = useState(() => fromText(value))
  const [current, setCurrent] = useState(initial)

  <div class="fixture">
    <button>Before</button>
    <form
      class="composer"
      aria-label={f.formLabel}
      onSubmit={(event) => {
        event.preventDefault()
        setSubmitted(String(new FormData(event.currentTarget).get(f.name)))
      }}
    >
      <TokenInput
        {...options}
        name={f.name}
        form={otherForm ? "other" : undefined}
        defaultValue={controlled ? undefined : initial}
        value={controlled ? current : undefined}
        onValueChange={(next, details) => {
          setCurrent(next)
          setAction(`${details.reason}:${toText(next)}`)
        }}
        onSubmit={form ? undefined : (next) => setSubmitted(toText(next))}
        renderToken={(token) => (
          <TokenInputToken className="token">
            {token.label as string}
            <TokenInputTokenRemove> ×</TokenInputTokenRemove>
          </TokenInputToken>
        )}
      >
        <label class="label" id="prompt-label">
          {f.label as string}
        </label>
        <TokenInputEditor
          aria-labelledby="prompt-label"
          className="editor"
          placeholder={f.placeholder}
        />
        <TriggerMenu
          triggers={triggers}
          onSelect={(selected, details) =>
            pending && details.trigger === "@"
              ? pendingSelect({ fail })
              : undefined
          }
        >
          <TriggerMenuHint className="hint" />
          <TriggerMenuContent className="popup list-popup">
            <TriggerMenuList>
              {(state) => (
                <Suggestions items={state.items as TriggerMenuDataItem[]} />
              )}
            </TriggerMenuList>
          </TriggerMenuContent>
        </TriggerMenu>
      </TokenInput>
      <button type="submit">{f.submit as string}</button>
    </form>
    @if (otherForm) {
      <form
        id="other"
        aria-label="Other"
        onSubmit={(event) => {
          event.preventDefault()
          setSubmitted(
            `other:${new FormData(event.currentTarget).get(f.name)}`
          )
        }}
      />
    }
    <textarea aria-label={f.scratch} />
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
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
