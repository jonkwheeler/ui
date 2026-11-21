import {
  Timeline,
  TimelineConnector,
  TimelineDescription,
  TimelineItem,
  TimelineMarker,
  TimelineTime,
  TimelineTitle,
} from "@ui-sdk/octane/timeline"
import { createRoot } from "octane"
import { mountWhenAsked, perfItems, perfSize } from "tests/fixtures/perf.ts"

// A timeline with many events, each with every part, for the counts specs.
const items = perfItems(perfSize())

function Event({ label }: { label: string }) @{
  <TimelineItem>
    <TimelineMarker />
    <TimelineConnector />
    <TimelineTitle>{label as string}</TimelineTitle>
    <TimelineTime dateTime="2026-11-10">Nov 10</TimelineTime>
    <TimelineDescription>Something happened.</TimelineDescription>
  </TimelineItem>
}

function Fixture() @{
  <div class="fixture">
    <button>Before</button>
    <Timeline aria-label="Activity">
      @for (const item of items; key item.value) {
        <Event label={item.label} />
      }
    </Timeline>
    <button>After</button>
  </div>
}

function mount(root: HTMLElement) {
  mountWhenAsked(root, (target) => createRoot(target).render(<Fixture />))
}

export { mount }
