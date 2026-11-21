import {
  Popover,
  PopoverClose,
  PopoverContent,
  PopoverTitle,
  PopoverTrigger,
} from "@ui-sdk/octane/popover"
import { createRoot } from "octane"

function Fixture() @{
  <div class="fixture">
    <button>Before</button>
    <Popover>
      <PopoverTrigger
        className={(state) => (state.open ? "is-open" : "is-closed")}
        render={(props, state) => (
          <button {...props}>
            Details <span aria-hidden="true">{state.open ? "▲" : "▼"}</span>
          </button>
        )}
      />
      <PopoverContent className="popup">
        <PopoverTitle render={<h3 />}>Shipping</PopoverTitle>
        <PopoverClose render={<a href="#done" />}>Done</PopoverClose>
      </PopoverContent>
    </Popover>
    <button>After</button>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
