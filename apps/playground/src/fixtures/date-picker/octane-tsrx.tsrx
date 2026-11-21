import {
  DatePicker,
  DatePickerClear,
  DatePickerContent,
  DatePickerHint,
  DatePickerInput,
  DatePickerPreset,
  DatePickerTrigger,
  CalendarGrid,
  CalendarHeading,
  CalendarNext,
  CalendarPrevious,
} from "@ui-sdk/octane/date-picker"
import { createRoot, useState } from "octane"
import {
  datePickerAction,
  datePickerFixture,
  datePickerOptions,
} from "tests/fixtures/date-picker.ts"

function Fixture() @{
  const { lang, ...options } = datePickerOptions()
  const [action, setAction] = useState("")
  const [submitted, setSubmitted] = useState("")
  const f = datePickerFixture
  const range = options.mode === "range"
  const preset = range ? f.rangePreset : f.preset

  <div class="fixture" lang={lang}>
    <button>Before</button>
    <form
      onSubmit={(event) => {
        event.preventDefault()
        setSubmitted(JSON.stringify([...new FormData(event.currentTarget)]))
      }}
    >
      <label htmlFor="date-start">
        {(range ? "Stay" : "Due date") as string}
      </label>
      <DatePicker
        className="date-picker"
        today={f.today}
        name={range ? undefined : f.name}
        startName={range ? "start" : undefined}
        endName={range ? "end" : undefined}
        {...options}
        onValueChange={(next, details) =>
          setAction(datePickerAction("value", next, details.reason))
        }
        onOpenChange={(next, details) =>
          setAction(datePickerAction("open", next, details.reason))
        }
      >
        <DatePickerInput
          id="date-start"
          aria-label={range ? "Start date" : undefined}
        />
        @if (range) {
          <DatePickerInput end aria-label="End date" />
        }
        <DatePickerTrigger />
        <DatePickerClear>Clear</DatePickerClear>
        <DatePickerHint className="date-picker-hint" />
        <DatePickerContent className="date-picker-content">
          <div class="calendar-header">
            <CalendarPrevious className="calendar-step" />
            <CalendarHeading className="calendar-heading" />
            <CalendarNext className="calendar-step" />
          </div>
          <CalendarGrid className="calendar-grid" />
          <DatePickerPreset value={preset.value as never}>
            {preset.label as string}
          </DatePickerPreset>
        </DatePickerContent>
      </DatePicker>
      <button type="submit">Submit</button>
      <button type="reset">Reset</button>
    </form>
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
