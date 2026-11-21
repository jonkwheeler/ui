import {
  createWaterfallController,
  Waterfall,
  WaterfallAxis,
  WaterfallBar,
  WaterfallCell,
  WaterfallColumnHeader,
  WaterfallHeaderRow,
  WaterfallIndicator,
  WaterfallMark,
  WaterfallRow,
  WaterfallRowHeader,
} from "@ui-sdk/octane/waterfall"
import { createRoot, useState } from "octane"
import {
  describeWaterfall,
  flatWaterfall,
  waterfallFixture,
  waterfallOptions,
  type WaterfallFixtureItem,
} from "tests/fixtures/waterfall.ts"

const controller = createWaterfallController()
const spans = flatWaterfall(waterfallFixture.items)

function Span({ span }: { span: WaterfallFixtureItem }) @{
  <WaterfallRow value={span.value}>
    <WaterfallRowHeader>
      @if (span.children) {
        <WaterfallIndicator />
      }
      {span.label as string}
    </WaterfallRowHeader>
    <WaterfallCell>{span.status as string}</WaterfallCell>
    <WaterfallBar />
  </WaterfallRow>
}

function Fixture() @{
  const [action, setAction] = useState("")
  const { cancel, range: startRange, ...options } = waterfallOptions()
  const [range, setRange] = useState(startRange)

  <div class="fixture">
    <button>Before</button>
    <Waterfall
      aria-label={waterfallFixture.label}
      items={waterfallFixture.items}
      controller={controller}
      range={range}
      {...options}
      onValueChange={(value) => setAction(describeWaterfall("selected", value))}
      onExpandedChange={(expanded, details) => {
        if (
          cancel &&
          expanded.includes(cancel) &&
          !controller.isExpanded(cancel)
        ) {
          return details.cancel()
        }
        setAction(describeWaterfall("expanded", expanded))
      }}
    >
      <WaterfallHeaderRow>
        <WaterfallColumnHeader>Name</WaterfallColumnHeader>
        <WaterfallColumnHeader>Status</WaterfallColumnHeader>
        <WaterfallColumnHeader aria-label="Timeline">
          <WaterfallAxis />
          <WaterfallMark time={waterfallFixture.mark.time}>
            {waterfallFixture.mark.label as string}
          </WaterfallMark>
        </WaterfallColumnHeader>
      </WaterfallHeaderRow>
      @for (const span of spans; key span.value) {
        <Span span={span} />
      }
    </Waterfall>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
    <button onClick={() => controller.expandAll()}>Expand all</button>
    <button onClick={() => controller.collapseAll()}>Collapse all</button>
    <button onClick={() => controller.reveal("flags")}>Reveal flags</button>
    <button onClick={() => setRange([500, 1000])}>Zoom</button>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
