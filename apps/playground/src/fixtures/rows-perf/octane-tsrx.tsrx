import { Menu, MenuContent, MenuItem, MenuTrigger } from "@ui-sdk/octane/menu"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@ui-sdk/octane/select"
import { Tooltip, TooltipContent, TooltipTrigger } from "@ui-sdk/octane/tooltip"
import { createRoot } from "octane"
import {
  countRender,
  mountWhenAsked,
  perfItems,
  perfOptions,
  perfSize,
} from "tests/fixtures/perf.ts"

// Rows like a table's, each with a closed menu, select and tooltip, for the
// counts specs. Every part counts its renders by kind, so specs
// can tell what mounting a row renders.
const rows = perfItems(perfSize(200))
const options = perfItems(perfOptions())
const actions = ["Rename", "Duplicate", "Delete"]

function Row({ label }: { label: string }) @{
  <div class="row" style={{ display: "flex", gap: 8 }}>
    <Menu>
      <MenuTrigger
        render={(props) => {
          countRender("trigger")
          return <button {...props} />
        }}
      >
        {`Menu ${label}`}
      </MenuTrigger>
      <MenuContent className="popup">
        @for (const action of actions; key action) {
          <MenuItem
            className="item"
            value={action}
            render={(props) => {
              countRender("menuItem")
              return <div {...props} />
            }}
          >
            {action as string}
          </MenuItem>
        }
      </MenuContent>
    </Menu>
    <Select defaultValue={options[0].value}>
      <SelectTrigger
        aria-label={`Select ${label}`}
        className="trigger"
        render={(props) => {
          countRender("trigger")
          return <button {...props} />
        }}
      >
        <SelectValue
          render={(props) => {
            countRender("value")
            return <span {...props} />
          }}
        />
      </SelectTrigger>
      <SelectContent className="popup list-popup">
        {/* A select labels its value from the items it finds among its
        children, and it can't see inside an @for block. */}
        {options.map((option) => (
          <SelectItem
            key={option.value}
            className="item"
            value={option.value}
            label={option.label}
            render={(props) => {
              countRender("option")
              return <div {...props} />
            }}
          >
            {option.label as string}
          </SelectItem>
        ))}
      </SelectContent>
    </Select>
    <Tooltip>
      <TooltipTrigger
        render={(props) => {
          countRender("trigger")
          return <button {...props} />
        }}
      >
        {`Tip ${label}`}
      </TooltipTrigger>
      <TooltipContent
        className="tooltip"
        render={(props) => {
          countRender("tooltip")
          return <div {...props} />
        }}
      >
        {`Hint ${label}`}
      </TooltipContent>
    </Tooltip>
  </div>
}

function Fixture() @{
  <div
    class="fixture"
    style={{ flexDirection: "column", alignItems: "start" }}
  >
    <button>Before</button>
    @for (const row of rows; key row.value) {
      <Row label={row.label.slice(5)} />
    }
    <button>After</button>
  </div>
}

function mount(root: HTMLElement) {
  mountWhenAsked(root, (target) => createRoot(target).render(<Fixture />))
}

export { mount }
