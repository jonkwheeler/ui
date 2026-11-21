import { Field, FieldLabel } from "@ui-sdk/octane/field"
import { Radio, RadioGroup, RadioIndicator } from "@ui-sdk/octane/radio"
import { createRoot, useState } from "octane"
import {
  fieldRadiosFixture as f,
  fieldRadiosOptions,
} from "tests/fixtures/field.ts"

function Size({
  size,
  fieldDisabled,
  disabled,
}: {
  size: (typeof f.sizes)[number]
  fieldDisabled: boolean
  disabled: boolean
}) @{
  <Field className="row" disabled={fieldDisabled}>
    <Radio className="radio" value={size.value} disabled={disabled}>
      <RadioIndicator className="radio-indicator" />
    </Radio>
    <FieldLabel>{size.label as string}</FieldLabel>
  </Field>
}

function Fixture() @{
  const { disabledField } = fieldRadiosOptions()
  const [firstDisabled, setFirstDisabled] = useState(false)

  <div class="fixture">
    <button>Before</button>
    <Field>
      <FieldLabel>{f.label as string}</FieldLabel>
      <RadioGroup className="form" name={f.name}>
        @for (const size of f.sizes; index position; key size.value) {
          <Size
            size={size}
            fieldDisabled={position === 0 && disabledField}
            disabled={position === 0 && firstDisabled}
          />
        }
      </RadioGroup>
    </Field>
    <button>After</button>
    <button onClick={() => setFirstDisabled((disabled) => !disabled)}>
      {f.disableFirst as string}
    </button>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
