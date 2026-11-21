import {
  Popover,
  PopoverClose,
  PopoverContent,
  PopoverTrigger,
} from "@ui-sdk/octane/popover"
import { createRoot } from "octane"
import { perfItems, perfModal, perfSize } from "tests/fixtures/perf.ts"

// Many popovers on one page, like a row action in every row of a table, for
// the counts specs. Only the first one is opened. ?modal opens them modal.
const items = perfItems(perfSize())
const modal = perfModal()

function RowPopover({ label }: { label: string }) @{
  <Popover modal={modal}>
    <PopoverTrigger>{label as string}</PopoverTrigger>
    <PopoverContent className="popup" aria-label={label}>
      {`${label} details.`}
      <PopoverClose>Close</PopoverClose>
    </PopoverContent>
  </Popover>
}

function Fixture() @{
  <div class="fixture" style={{ flexWrap: "wrap" }}>
    <button>Before</button>
    @for (const item of items; key item.value) {
      <RowPopover label={item.label} />
    }
    <button>After</button>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
