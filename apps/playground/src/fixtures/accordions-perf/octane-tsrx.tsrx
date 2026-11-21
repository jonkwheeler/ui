import {
  Accordion,
  AccordionHeader,
  AccordionItem,
  AccordionPanel,
  AccordionTrigger,
} from "@ui-sdk/octane/accordion"
import { createRoot } from "octane"
import { mountWhenAsked, perfSize } from "tests/fixtures/perf.ts"

// An accordion of N items, like a long FAQ.
// Every item starts closed. With ?found, closed panels stay in the page for
// find in page.
const items = Array.from({ length: perfSize(200) }, (_, index) => index)
const found = new URLSearchParams(location.search).has("found")

function Item({ index }: { index: number }) @{
  <AccordionItem className="accordion-item" value={`item-${index}`}>
    <AccordionHeader className="accordion-header">
      <AccordionTrigger className="accordion-trigger">
        {`Question ${index + 1}`}
      </AccordionTrigger>
    </AccordionHeader>
    <AccordionPanel className="accordion-panel">
      {`Answer ${index + 1}`}
    </AccordionPanel>
  </AccordionItem>
}

function Fixture() @{
  <div
    class="fixture"
    style={{ flexDirection: "column", alignItems: "start" }}
  >
    <button>Before</button>
    <Accordion className="accordion" hiddenUntilFound={found}>
      @for (const index of items; key index) {
        <Item index={index} />
      }
    </Accordion>
    <button>After</button>
  </div>
}

function mount(root: HTMLElement) {
  mountWhenAsked(root, (target) => createRoot(target).render(<Fixture />))
}

export { mount }
