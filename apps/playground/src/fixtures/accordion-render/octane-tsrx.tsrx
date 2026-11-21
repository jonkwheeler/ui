import {
  Accordion,
  AccordionHeader,
  AccordionItem,
  AccordionPanel,
  AccordionTrigger,
} from "@ui-sdk/octane/accordion"
import { createRoot, useState } from "octane"
import { describeValue } from "tests/fixtures/accordion.ts"

function Fixture() @{
  const [action, setAction] = useState("")

  <div class="fixture">
    <button>Before</button>
    <Accordion
      className="accordion"
      defaultValue={["overview"]}
      onValueChange={(value) => setAction(describeValue(value))}
    >
      <AccordionItem
        value="overview"
        className={(state) =>
          `accordion-item ${state.open ? "is-open" : "is-closed"}`
        }
      >
        <AccordionHeader className="accordion-header" render={<h2 />}>
          <AccordionTrigger
            className="accordion-trigger"
            render={(props, state) => (
              <button {...props}>
                {props.children}
                <span aria-hidden>{` ${state.open ? "−" : "+"}`}</span>
                <span class="index" hidden>
                  {String(state.index)}
                </span>
              </button>
            )}
          >
            Overview
          </AccordionTrigger>
        </AccordionHeader>
        <AccordionPanel className="accordion-panel" render={<section />}>
          The overview panel.
        </AccordionPanel>
      </AccordionItem>
      <AccordionItem value="details" className="accordion-item">
        <AccordionHeader className="accordion-header">
          <AccordionTrigger className="accordion-trigger" render={<div />}>
            Details
          </AccordionTrigger>
        </AccordionHeader>
        <AccordionPanel className="accordion-panel">
          The details panel.
        </AccordionPanel>
      </AccordionItem>
    </Accordion>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
