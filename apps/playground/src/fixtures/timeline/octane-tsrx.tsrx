import {
  Timeline,
  TimelineConnector,
  TimelineDescription,
  TimelineItem,
  TimelineMarker,
  TimelineTime,
  TimelineTitle,
  createTimelineController,
} from "@ui-sdk/octane/timeline"
import { createRoot, useState } from "octane"
import {
  advance,
  timelineFixture as f,
  timelineOptions,
  type TimelineFixtureEvent,
} from "tests/fixtures/timeline.ts"

const controller = createTimelineController()

function Event({ event }: { event: TimelineFixtureEvent }) @{
  <TimelineItem value={event.value} status={event.status}>
    <TimelineMarker />
    <TimelineConnector />
    <TimelineTitle>{event.title as string}</TimelineTitle>
    <TimelineTime dateTime={event.dateTime}>
      {event.time as string}
    </TimelineTime>
    <TimelineDescription>{event.description as string}</TimelineDescription>
    @if (event.link) {
      <a href={event.link.href}>{event.link.label as string}</a>
    }
  </TimelineItem>
}

function Fixture() @{
  const [events, setEvents] = useState<readonly TimelineFixtureEvent[]>(
    f.events
  )

  <div class="fixture">
    <button>Before</button>
    <Timeline
      className="timeline"
      aria-label={f.label}
      controller={controller}
      {...timelineOptions()}
    >
      @for (const event of events; key event.value) {
        <Event event={event} />
      }
    </Timeline>
    <button>After</button>
    <button onClick={() => setEvents([f.added, ...events])}>Add Event</button>
    <button onClick={() => setEvents([...events].reverse())}>Reverse</button>
    <button onClick={() => controller.focus("shipped")}>Focus Current</button>
    <button onClick={() => setEvents(advance(events))}>Advance</button>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
