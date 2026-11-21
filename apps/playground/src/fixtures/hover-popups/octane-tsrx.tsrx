import {
  HoverCard,
  HoverCardContent,
  HoverCardTrigger,
} from "@ui-sdk/octane/hover-card"
import { Popover, PopoverContent, PopoverTrigger } from "@ui-sdk/octane/popover"
import { Tooltip, TooltipContent, TooltipTrigger } from "@ui-sdk/octane/tooltip"
import { createRoot, useState } from "octane"
import {
  describeChange,
  hoverPopupsFixture as fixture,
} from "tests/fixtures/hover-popups.ts"

function Fixture() @{
  const [change, setChange] = useState("")

  <div class="fixture">
    <button>Before</button>
    <Tooltip
      delay={0}
      onOpenChange={(open, { event }) =>
        open && setChange(describeChange("tooltip", "open", event))
      }
      onPayloadChange={(payload, { event }) =>
        setChange(describeChange("tooltip", `payload ${payload}`, event))
      }
    >
      @for (const day of fixture.days; key day) {
        <TooltipTrigger payload={day.toLowerCase()}>
          {day as string}
        </TooltipTrigger>
      }
      <TooltipContent className="tooltip">
        {(state) => `Tip for ${state.payload}`}
      </TooltipContent>
    </Tooltip>
    <HoverCard
      delay={0}
      closeDelay={0}
      onOpenChange={(open, { event }) =>
        open && setChange(describeChange("hover card", "open", event))
      }
      onPayloadChange={(payload, { event }) =>
        setChange(describeChange("hover card", `payload ${payload}`, event))
      }
    >
      @for (const person of fixture.people; key person) {
        <HoverCardTrigger
          href={`#${person}`}
          payload={person.toLowerCase()}
        >
          {person as string}
        </HoverCardTrigger>
      }
      <HoverCardContent className="hover-card">
        {(state) => `Card for ${state.payload}`}
      </HoverCardContent>
    </HoverCard>
    <Popover
      openOnHover
      delay={0}
      closeDelay={0}
      onOpenChange={(open, { event }) =>
        open && setChange(describeChange("popover", "open", event))
      }
    >
      <PopoverTrigger>{fixture.popover.trigger as string}</PopoverTrigger>
      <PopoverContent className="popup">
        {fixture.popover.content as string}
      </PopoverContent>
    </Popover>
    <output role="status" aria-label="Last change">
      {change as string}
    </output>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
