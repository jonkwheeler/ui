import { createAccordionController } from "@ui-sdk/core/accordion"
import {
  Accordion,
  AccordionHeader,
  AccordionItem,
  AccordionPanel,
  AccordionTrigger,
} from "@ui-sdk/octane/accordion"
import { createRoot, useState } from "octane"
import { accordionFixture, describeValue } from "tests/fixtures/accordion.ts"
import { accordionOptions } from "tests/fixtures/page.ts"

const controller = createAccordionController()

function Item({
  item,
  disabled,
  onComplete,
}: {
  item: (typeof accordionFixture.items)[number]
  disabled?: boolean
  onComplete: (complete: string) => void
}) @{
  <AccordionItem
    className="accordion-item"
    value={item.value}
    disabled={disabled}
    onOpenChangeComplete={(open) =>
      onComplete(`${item.value} ${open ? "open" : "closed"}`)
    }
  >
    <AccordionHeader className="accordion-header">
      <AccordionTrigger className="accordion-trigger">
        {item.label as string}
      </AccordionTrigger>
    </AccordionHeader>
    <AccordionPanel className="accordion-panel">
      {item.content as string}
      @if (item.field) {
        <label>
          {` ${item.field} `}
          <input />
        </label>
      }
      @if (item.close) {
        <button onClick={() => controller.close(item.value)}>
          {item.close as string}
        </button>
      }
    </AccordionPanel>
  </AccordionItem>
}

function Fixture() @{
  const [action, setAction] = useState("")
  const [complete, setComplete] = useState("")
  const [warrantyEnabled, setWarrantyEnabled] = useState(false)
  const { cancel, ...options } = accordionOptions()

  <div class="fixture">
    <button>Before</button>
    <Accordion
      className="accordion"
      controller={controller}
      {...options}
      onValueChange={(value, details) => {
        if (
          cancel &&
          value.includes(cancel) &&
          !controller.getValue().includes(cancel)
        ) {
          return details.cancel()
        }
        setAction(describeValue(value))
      }}
    >
      @for (const item of accordionFixture.items; key item.value) {
        <Item
          item={item}
          disabled={item.disabled && !warrantyEnabled}
          onComplete={setComplete}
        />
      }
    </Accordion>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
    <output aria-label="Last completed">{complete as string}</output>
    <button onClick={() => controller.open("support")}>Show support</button>
    <button onClick={() => setWarrantyEnabled((enabled) => !enabled)}>
      Toggle warranty
    </button>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
