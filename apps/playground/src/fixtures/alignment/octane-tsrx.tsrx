import {
  createMenuController,
  Menu,
  MenuCheckboxItem,
  MenuContent,
  MenuContextTrigger,
  MenuItem,
  MenuItemIndicator,
  MenuRadioGroup,
  MenuRadioItem,
  MenuTrigger,
  type MenuDataItem,
} from "@ui-sdk/octane/menu"
import {
  createPopoverController,
  Popover,
  PopoverContent,
  PopoverTitle,
} from "@ui-sdk/octane/popover"
import {
  createTabsController,
  Tabs,
  TabsList,
  TabsPanel,
  TabsTab,
} from "@ui-sdk/octane/tabs"
import { createRoot, useState } from "octane"
import {
  alignmentFixture,
  alignmentOptions,
  renderCounter,
} from "tests/fixtures/alignment.ts"

const rowMenu = createMenuController<string>()
const details = createPopoverController<string>()
const sections = createTabsController()
const count = renderCounter()

const dataItems: MenuDataItem[] = [
  { type: "checkbox", value: "grid", label: "Grid" },
  {
    type: "radio-group",
    name: "sort",
    items: [
      { value: "name", label: "Name" },
      { value: "date", label: "Date" },
    ],
  },
]

function RowActions({
  payload,
  showDetails,
}: {
  payload: unknown
  showDetails: (payload: string) => void
}) @{
  <>
    <div class="payload">{`Row ${payload}`}</div>
    @for (const item of alignmentFixture.rowActions; key item.value) {
      <MenuItem
        className="item"
        value={item.value}
        onSelect={() => {
          if (item.value === "details") {
            showDetails(String(rowMenu.getPayload()))
          }
        }}
      >
        {item.label as string}
      </MenuItem>
    }
  </>
}

function DetailsForm({ payload }: { payload: unknown }) @{
  <form method="dialog">
    <PopoverTitle className="title">Details</PopoverTitle>
    <p class="payload">{`Details for ${payload}`}</p>
    <button value="save">Save</button>
    <button value="cancel">Cancel</button>
  </form>
}

function keyOf(entry: MenuDataItem, position: number) {
  if (entry.type === "checkbox") {
    return entry.value
  }
  if (entry.type === "radio-group") {
    return entry.name
  }
  return `entry-${position}`
}

function DataEntry({ entry }: { entry: MenuDataItem }) @{
  <>
    @if (entry.type === "checkbox") {
      <MenuCheckboxItem className="item" value={entry.value}>
        <MenuItemIndicator className="indicator">✓</MenuItemIndicator>
        {entry.label as string}
      </MenuCheckboxItem>
    } @else if (entry.type === "radio-group") {
      <MenuRadioGroup name={entry.name}>
        @for (const radio of entry.items; key radio.value) {
          <MenuRadioItem className="item" value={radio.value}>
            <MenuItemIndicator className="indicator">
              •
            </MenuItemIndicator>
            {radio.label as string}
          </MenuRadioItem>
        }
      </MenuRadioGroup>
    }
  </>
}

function Fixture() @{
  const [action, setAction] = useState("")
  const [result, setResult] = useState("")
  const [complete, setComplete] = useState("")
  const [change, setChange] = useState("")
  const [tabChanges, setTabChanges] = useState(0)
  const { keepMounted } = alignmentOptions()

  const showDetails = (payload: string) =>
    details
      .open({ payload })
      .then((closed) =>
        setResult(`${closed.reason}:${closed.returnValue ?? ""}`)
      )

  <div class="fixture">
    <button>Before</button>

    <ul class="rows">
      @for (const row of alignmentFixture.rows; key row) {
        <li>
          {`Row ${row}`}
          <MenuTrigger
            controller={rowMenu}
            payload={row}
            aria-label={`Actions for ${row}`}
          >
            …
          </MenuTrigger>
        </li>
      }
    </ul>
    <Menu
      controller={rowMenu}
      onAction={(value) => setAction(`${value}:${rowMenu.getPayload()}`)}
      onOpenChangeComplete={(open) => setComplete(open ? "open" : "closed")}
    >
      <MenuContent className="popup" keepMounted={keepMounted}>
        {(state) => (
          <RowActions payload={state.payload} showDetails={showDetails} />
        )}
      </MenuContent>
    </Menu>

    <Popover controller={details} modal="trap-focus">
      <PopoverContent className="popup">
        {(state) => <DetailsForm payload={state.payload} />}
      </PopoverContent>
    </Popover>
    <button onClick={() => showDetails("button")}>Show details</button>

    <Menu onAction={setAction}>
      <MenuContextTrigger className="canvas">Canvas</MenuContextTrigger>
      <MenuContent className="popup">
        @for (const item of alignmentFixture.canvasActions; key item.value) {
          <MenuItem className="item" value={item.value}>
            {item.label as string}
          </MenuItem>
        }
      </MenuContent>
    </Menu>

    <Menu
      items={dataItems}
      onCheckedChange={(checked, details) =>
        setChange(`checked:${details.value}:${checked}`)
      }
      onValueChange={(value, details) =>
        setChange(`value:${details.group}:${value}`)
      }
    >
      <MenuTrigger>Data</MenuTrigger>
      {/* The data's items, rendered with the fixture's classes. */}
      <MenuContent className="popup">
        @for (const entry of dataItems; index position; key keyOf(entry, position)) {
          <DataEntry entry={entry} />
        }
      </MenuContent>
    </Menu>

    <Menu>
      <MenuTrigger>View</MenuTrigger>
      <MenuContent className="popup">
        @for (const value of ["ruler", "guides"]; key value) {
          <MenuCheckboxItem className={() => count(value)} value={value}>
            <MenuItemIndicator className="indicator">✓</MenuItemIndicator>
            {(value === "ruler" ? "Ruler" : "Guides") as string}
          </MenuCheckboxItem>
        }
      </MenuContent>
    </Menu>

    <Tabs
      className="tabs"
      controller={sections}
      hiddenUntilFound
      onValueChange={() => setTabChanges((count) => count + 1)}
    >
      <TabsList className="tablist scrolling" aria-label="Sections">
        @for (const section of alignmentFixture.sections; key section) {
          <TabsTab className="tab" value={section.toLowerCase()}>
            {section as string}
          </TabsTab>
        }
      </TabsList>
      @for (const section of alignmentFixture.sections; key section) {
        <TabsPanel className="panel" value={section.toLowerCase()}>
          {`The ${section} section`}
        </TabsPanel>
      }
    </Tabs>
    <button onClick={() => sections.select("hotel")}>
      Show the last section
    </button>

    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
    <output aria-label="Last result">{result as string}</output>
    <output aria-label="Last complete">{complete as string}</output>
    <output aria-label="Last change">{change as string}</output>
    <output aria-label="Tab changes">{String(tabChanges)}</output>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
