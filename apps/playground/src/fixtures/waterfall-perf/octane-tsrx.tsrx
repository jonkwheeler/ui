import {
  Waterfall,
  WaterfallBar,
  WaterfallCell,
  WaterfallIndicator,
  WaterfallRow,
  WaterfallRowHeader,
} from "@ui-sdk/octane/waterfall"
import { createRoot } from "octane"
import { countRender, mountWhenAsked, perfSize } from "tests/fixtures/perf.ts"
import {
  flatWaterfall,
  longTrace,
  type WaterfallFixtureItem,
} from "tests/fixtures/waterfall.ts"

// A trace of N requests of two spans each, every row rendered, for the count
// gates. Every request starts collapsed, so its spans render hidden.
const trace = longTrace(perfSize(200))
const spans = flatWaterfall(trace)

function Span({ span }: { span: WaterfallFixtureItem }) @{
  <WaterfallRow
    value={span.value}
    render={(props) => {
      countRender("row")
      return <div {...props} />
    }}
  >
    <WaterfallRowHeader>
      @if (span.children) {
        <WaterfallIndicator />
      }
      {span.label as string}
    </WaterfallRowHeader>
    <WaterfallCell>{span.status as string}</WaterfallCell>
    <WaterfallBar
      render={(props) => {
        countRender("bar")
        return <div {...props} />
      }}
    />
  </WaterfallRow>
}

function Fixture() @{
  <div class="fixture">
    <button>Before</button>
    <Waterfall aria-label="Long trace" items={trace}>
      @for (const span of spans; key span.value) {
        <Span span={span} />
      }
    </Waterfall>
    <button>After</button>
  </div>
}

function mount(root: HTMLElement) {
  mountWhenAsked(root, (target) => createRoot(target).render(<Fixture />))
}

export { mount }
