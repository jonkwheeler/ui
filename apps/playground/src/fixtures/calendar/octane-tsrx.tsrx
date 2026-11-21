import {
  Calendar,
  CalendarGrid,
  CalendarHeading,
  CalendarMonthSelect,
  CalendarNext,
  CalendarPrevious,
  CalendarYearSelect,
  createCalendarController,
  type CalendarValue,
} from "@ui-sdk/octane/calendar"
import { createRoot, useState } from "octane"
import {
  calendarAction,
  calendarFixture,
  calendarOptions,
} from "tests/fixtures/calendar.ts"

const controller = createCalendarController()

function Fixture() @{
  const { controlled, selects, lang, defaultValue, defaultMonth, ...options } =
    calendarOptions()
  const [action, setAction] = useState("")
  const [value, setValue] = useState<CalendarValue>(defaultValue)
  const [month, setMonth] = useState(
    defaultMonth ?? calendarFixture.today.slice(0, 7)
  )
  const f = calendarFixture
  const offsets = Array.from({ length: options.months ?? 1 }, (_, n) => n)

  <div class="fixture" lang={lang}>
    <button>Before</button>
    <Calendar
      className="calendar"
      today={f.today}
      controller={controller}
      {...options}
      {...(controlled ? { value, month } : { defaultValue, defaultMonth })}
      onValueChange={(next, details) => {
        setValue(next)
        setAction(calendarAction("value", next, details.reason))
      }}
      onMonthChange={(next, details) => {
        setMonth(next)
        setAction(calendarAction("month", next, details.reason))
      }}
    >
      <div class="calendar-header">
        <CalendarPrevious className="calendar-step" />
        <CalendarHeading className="calendar-heading" />
        @if (selects) {
          <>
            <CalendarMonthSelect />
            <CalendarYearSelect />
          </>
        }
        <CalendarNext className="calendar-step" />
      </div>
      <div class="calendar-months">
        @for (const offset of offsets; key offset) {
          <CalendarGrid offset={offset} className="calendar-grid" />
        }
      </div>
    </Calendar>
    <button onClick={() => controller.focus(f.controller.date)}>
      {f.controller.label as string}
    </button>
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
