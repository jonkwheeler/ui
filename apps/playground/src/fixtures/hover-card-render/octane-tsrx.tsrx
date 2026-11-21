import {
  HoverCard,
  HoverCardContent,
  HoverCardTrigger,
} from "@ui-sdk/octane/hover-card"
import { createRoot } from "octane"

function Fixture() @{
  <div class="fixture">
    <button>Before</button>
    <HoverCard delay={100} closeDelay={100}>
      <HoverCardTrigger
        href="#repo"
        className={(state) => (state.open ? "is-open" : "is-closed")}
        render={(props, state) => (
          <a {...props}>
            ui-sdk <span aria-hidden="true">{state.open ? "▲" : "▼"}</span>
          </a>
        )}
      />
      <HoverCardContent
        className="hover-card"
        render={<section aria-label="Repository" />}
      >
        A headless UI kit.
      </HoverCardContent>
    </HoverCard>
    <button>After</button>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
