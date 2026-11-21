import {
  DatePicker,
  DatePickerContent,
  DatePickerHint,
  DatePickerInput,
  DatePickerTrigger,
} from "@ui-sdk/octane/date-picker"
import {
  Field,
  FieldDescription,
  FieldError,
  FieldLabel,
} from "@ui-sdk/octane/field"
import { createRoot, useState } from "octane"
import {
  datePickerFieldFixture as f,
  datePickerFieldOptions,
  datePickerFixture,
} from "tests/fixtures/date-picker.ts"

function Fixture() @{
  const { required, disabled } = datePickerFieldOptions()
  const [submitted, setSubmitted] = useState("")
  const [shown, setShown] = useState(true)

  <div class="fixture">
    <button>Before</button>
    <form
      onSubmit={(event) => {
        event.preventDefault()
        setSubmitted(JSON.stringify([...new FormData(event.currentTarget)]))
      }}
    >
      <Field
        className="field"
        name={datePickerFixture.name}
        disabled={disabled}
      >
        <FieldLabel>{f.label as string}</FieldLabel>
        @if (shown) {
          <DatePicker
            className="date-picker"
            today={datePickerFixture.today}
            required={required}
          >
            <DatePickerInput />
            <DatePickerTrigger />
            <DatePickerHint className="date-picker-hint" />
            <DatePickerContent className="date-picker-content" />
          </DatePicker>
        }
        <FieldDescription>{f.description as string}</FieldDescription>
        <FieldError className="field-error" />
      </Field>
      <button type="submit">Submit</button>
      <button type="button" onClick={() => setShown(false)}>
        Remove date picker
      </button>
    </form>
    <output role="status" aria-label="Submitted">
      {submitted as string}
    </output>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
