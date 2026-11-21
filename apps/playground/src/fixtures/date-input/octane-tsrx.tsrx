import { createDateInputController, DateInput } from "@ui-sdk/octane/date-input"
import { Field, FieldError, FieldLabel } from "@ui-sdk/octane/field"
import { TimeInput } from "@ui-sdk/octane/time-input"
import { createRoot, useState } from "octane"
import {
  dateInputAction,
  dateInputFixture,
  dateInputOptions,
} from "tests/fixtures/date-input.ts"

const controller = createDateInputController()

function Fixture() @{
  const [action, setAction] = useState("")
  const [submitted, setSubmitted] = useState("")
  const { date, time, cancel, ...shared } = dateInputOptions()
  const f = dateInputFixture

  <div class="fixture">
    <button>Before</button>
    <form
      aria-label={f.form.label}
      onSubmit={(event) => {
        event.preventDefault()
        setSubmitted(JSON.stringify([...new FormData(event.currentTarget)]))
      }}
    >
      <Field className="field" name={f.date.name}>
        <FieldLabel>{f.date.label as string}</FieldLabel>
        <DateInput
          className="date-input"
          controller={controller}
          {...date}
          {...shared}
          onValueChange={(value, details) => {
            if (cancel && value === cancel) {
              return details.cancel()
            }
            setAction(dateInputAction.change("date", value, details.reason))
          }}
        />
        <FieldError className="field-error" />
      </Field>
      <Field className="field" name={f.time.name}>
        <FieldLabel>{f.time.label as string}</FieldLabel>
        <TimeInput
          className="date-input"
          {...time}
          {...shared}
          onValueChange={(value, details) =>
            setAction(dateInputAction.change("time", value, details.reason))
          }
        />
      </Field>
      <button type="submit">{f.form.submit as string}</button>
      <button type="reset">{f.form.reset as string}</button>
    </form>
    <button onClick={() => controller.setValue(f.filled)}>Set date</button>
    <button onClick={() => controller.clear()}>Clear date</button>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
    <output aria-label="Submitted">{submitted as string}</output>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
