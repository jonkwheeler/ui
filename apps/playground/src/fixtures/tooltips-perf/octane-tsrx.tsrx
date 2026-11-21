import { Tooltip, TooltipContent, TooltipTrigger } from "@ui-sdk/octane/tooltip"
import { createRoot } from "octane"
import { countRender, mountWhenAsked, perfSize } from "tests/fixtures/perf.ts"

// Keyboard focus opens a tooltip at once, so Tab shows each in turn. Triggers
// and contents count their renders, so the counts specs can tell what a focus
// move rendered.
const tips = Array.from({ length: perfSize() }, (_, index) => index + 1)

function Tip({ tip }: { tip: number }) @{
  <div class="tooltip-row">
    <Tooltip delay={0}>
      <TooltipTrigger
        className="tooltip-trigger"
        render={(props) => {
          countRender("trigger")
          return <button {...props} />
        }}
      >
        {`Tip ${tip}`}
      </TooltipTrigger>
      <TooltipContent
        className="tooltip"
        render={(props) => {
          countRender("tooltip")
          return <div {...props} />
        }}
      >
        {`Hint ${tip}`}
      </TooltipContent>
    </Tooltip>
  </div>
}

function Fixture() @{
  <div class="fixture tooltip-page" style={{ flexWrap: "wrap" }}>
    <button>Before</button>
    @for (const tip of tips; key tip) {
      <Tip tip={tip} />
    }
    <button>After</button>
  </div>
}

function mount(root: HTMLElement) {
  mountWhenAsked(root, (target) => createRoot(target).render(<Fixture />))
}

export { mount }
