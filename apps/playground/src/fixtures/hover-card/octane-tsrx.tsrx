import {
  HoverCard,
  HoverCardArrow,
  HoverCardContent,
  HoverCardTrigger,
} from "@ui-sdk/octane/hover-card"
import { createRoot, useState } from "octane"
import {
  hoverCardContentOptions,
  hoverCardFixture,
  hoverCardOptions,
} from "tests/fixtures/hover-card.ts"

function Fixture() @{
  const [action, setAction] = useState("")
  const fixture = hoverCardFixture

  <div class="fixture">
    <button>Before</button>
    <HoverCard
      {...hoverCardOptions()}
      onOpenChange={(open, { reason }) =>
        setAction(`${open ? "open" : "close"}: ${reason}`)
      }
    >
      <HoverCardTrigger href={fixture.href}>
        {fixture.trigger as string}
      </HoverCardTrigger>
      <HoverCardContent className="hover-card" {...hoverCardContentOptions()}>
        <HoverCardArrow className="arrow" />
        <p>
          <strong>{fixture.name as string}</strong>
        </p>
        <p>{fixture.bio as string}</p>
        <a href={fixture.linkHref}>{fixture.link as string}</a>
      </HoverCardContent>
    </HoverCard>
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
