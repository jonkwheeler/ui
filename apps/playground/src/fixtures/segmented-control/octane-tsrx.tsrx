import {
  createSegmentedControlController,
  SegmentedControl,
  SegmentedControlIndicator,
  SegmentedControlItem,
} from "@ui-sdk/octane/segmented-control"
import { createRoot, useState } from "octane"
import {
  indicatorOptions,
  segmentedControlOptions,
} from "tests/fixtures/page.ts"
import { segmentedControlFixture } from "tests/fixtures/segmented-control.ts"

const controller = createSegmentedControlController()

const entries = (form: HTMLFormElement) =>
  Array.from(new FormData(form), ([key, value]) => `${key}=${value}`).join("&")

function Fixture() @{
  const [action, setAction] = useState("")
  const [submitted, setSubmitted] = useState("")
  const { cancel, ...options } = segmentedControlOptions()

  <form
    class="fixture"
    onSubmit={(event) => {
      event.preventDefault()
      setSubmitted(entries(event.currentTarget))
    }}
  >
    <button type="button">Before</button>
    <SegmentedControl
      aria-label={segmentedControlFixture.label}
      name={segmentedControlFixture.name}
      controller={controller}
      {...options}
      onValueChange={(value, details) => {
        if (value === cancel) {
          return details.cancel()
        }
        setAction(`${value}:${details.reason}`)
      }}
    >
      <SegmentedControlIndicator {...indicatorOptions()} />
      @for (const item of segmentedControlFixture.items; key item.value) {
        <SegmentedControlItem
          value={item.value}
          disabled={item.disabled}
        >
          {item.label as string}
        </SegmentedControlItem>
      }
    </SegmentedControl>
    <button type="button">After</button>
    <button type="submit">Save</button>
    <button type="reset">Reset</button>
    <button type="button" onClick={() => controller.setValue("calendar")}>
      Show calendar
    </button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
    <output aria-label="Submitted">{submitted as string}</output>
  </form>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
