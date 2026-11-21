import { Field, FieldDescription, FieldLabel } from "@ui-sdk/octane/field"
import {
  NumberInput,
  NumberInputDecrement,
  NumberInputGroup,
  NumberInputIncrement,
  NumberInputControl,
  NumberInputScrubArea,
} from "@ui-sdk/octane/number-input"
import { createRoot, useState } from "octane"
import {
  numberInputFixture as f,
  numberInputOptions,
  serialize,
} from "tests/fixtures/number-input.ts"

function Fixture() @{
  const options = numberInputOptions()
  const [action, setAction] = useState("")
  const [commits, setCommits] = useState<string[]>([])
  const [submitted, setSubmitted] = useState("")
  const [quantity, setQuantity] = useState<number | null>(options.quantity)
  // Records a change, or cancels it when the URL asks.
  const report = (
    name: string,
    value: number | null,
    details: { cancel: () => void }
  ) => {
    if (options.cancel === name) {
      return details.cancel()
    }
    setAction(`${name}:${String(value)}`)
  }
  const commit = (name: string) => (value: number | null) =>
    setCommits((list) => [...list, `${name}:${String(value)}`])
  const shared = {
    wheel: options.wheel,
    disabled: options.disabled,
    readOnly: options.readOnly,
    locale: options.locale,
  }

  <div class="fixture">
    <button>Before</button>
    <form
      class="form"
      aria-label={f.formLabel}
      onSubmit={(event) => {
        event.preventDefault()
        setSubmitted(serialize(event.currentTarget))
      }}
    >
      {/* The field names the quantity, so the field's name reaches the form. */}
      <Field name={f.quantity.name}>
        <FieldLabel>{f.quantity.label as string}</FieldLabel>
        <NumberInput
          {...shared}
          min={f.quantity.min}
          max={f.quantity.max}
          required={options.required}
          {...(options.controlled
            ? { value: quantity }
            : { defaultValue: options.quantity })}
          onValueChange={(value, details) => {
            report(f.quantity.name, value, details)
            if (!details.canceled) {
              setQuantity(value)
            }
          }}
          onValueCommit={commit(f.quantity.name)}
        >
          <NumberInputGroup className="number-input-group">
            <NumberInputDecrement aria-label={f.quantity.decrement}>
              −
            </NumberInputDecrement>
            <NumberInputControl className="number-input-control" />
            <NumberInputIncrement
              aria-label={f.quantity.increment}
              disabled={options.disabledIncrement}
            >
              +
            </NumberInputIncrement>
          </NumberInputGroup>
        </NumberInput>
        <FieldDescription>{f.quantity.description as string}</FieldDescription>
      </Field>

      <Field>
        <FieldLabel>{f.amount.label as string}</FieldLabel>
        <NumberInput
          {...shared}
          name={f.amount.name}
          defaultValue={f.amount.defaultValue}
          min={options.amountMin}
          step={f.amount.step}
          format={{ style: "currency", currency: f.amount.currency }}
          onValueChange={(value, details) =>
            report(f.amount.name, value, details)
          }
          onValueCommit={commit(f.amount.name)}
        >
          <NumberInputScrubArea className="number-input-scrub">
            {f.amount.scrub as string}
          </NumberInputScrubArea>
          <NumberInputGroup className="number-input-group">
            <NumberInputDecrement aria-label={f.amount.decrement}>
              −
            </NumberInputDecrement>
            <NumberInputControl className="number-input-control" />
            <NumberInputIncrement aria-label={f.amount.increment}>
              +
            </NumberInputIncrement>
          </NumberInputGroup>
        </NumberInput>
      </Field>

      <div class="row">
        <button type="submit">Save</button>
        <button type="reset">Reset</button>
      </div>
    </form>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
    <output role="status" aria-label="Committed">
      {commits.join(" ") as string}
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
