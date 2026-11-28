import { Menu, MenuContent, MenuItem, MenuTrigger } from "@ui-sdk/octane/menu"
import { NumberInput, NumberInputControl } from "@ui-sdk/octane/number-input"
import { Toggle, ToggleGroup } from "@ui-sdk/octane/toggle"
import {
  Toolbar,
  ToolbarButton,
  ToolbarGroup,
  ToolbarInput,
  ToolbarLink,
  ToolbarSeparator,
  createToolbarController,
} from "@ui-sdk/octane/toolbar"
import { createRoot, useState, type OctaneNode } from "octane"
import {
  toolbarFixture as f,
  toolbarLocked,
  toolbarOptions,
  toolbarRenderedToggle,
} from "tests/fixtures/toolbar.ts"

const controller = createToolbarController()

// Wraps an item in a disabled group while locked, for ?locked.
function Lock({
  label,
  locked,
  children,
}: {
  label: string
  locked: boolean
  children: OctaneNode
}) @{
  <>
    @if (toolbarLocked()) {
      <ToolbarGroup aria-label={label} disabled={locked}>
        {children}
      </ToolbarGroup>
    } @else {
      <>{children}</>
    }
  </>
}

function Group({
  group,
  multiple,
  onAction,
}: {
  group: typeof f.style
  multiple: boolean
  onAction: (action: string) => void
}) @{
  <ToggleGroup
    className="toggle-group"
    aria-label={group.label}
    multiple={multiple}
    defaultValue={group.defaultValue}
    onValueChange={(value) =>
      onAction(`${group.label}: ${value.join(", ") || "none"}`)
    }
  >
    @for (const item of group.items; key item.value) {
      <Toggle
        className="toggle"
        value={item.value}
        disabled={"disabled" in item && item.disabled}
      >
        {item.label as string}
      </Toggle>
    }
  </ToggleGroup>
}

function Fixture() @{
  const [action, setAction] = useState("")
  const [locked, setLocked] = useState(toolbarLocked)

  <div class="fixture">
    <button>Before</button>
    <Toolbar
      className="toolbar"
      aria-label={f.label}
      controller={controller}
      {...toolbarOptions()}
    >
      <Lock label="Locked style" locked={locked}>
        <Group group={f.style} multiple onAction={setAction} />
      </Lock>
      <ToolbarSeparator />
      <Group group={f.alignment} multiple={false} onAction={setAction} />
      <ToolbarSeparator />
      <Menu onAction={(value) => setAction(`font: ${value}`)}>
        <ToolbarButton render={<MenuTrigger />}>
          {f.font.trigger as string}
        </ToolbarButton>
        <MenuContent className="popup">
          @for (const item of f.font.items; key item) {
            <MenuItem className="item" value={item}>
              {item as string}
            </MenuItem>
          }
        </MenuContent>
      </Menu>
      <NumberInput
        defaultValue={f.size.defaultValue}
        onValueChange={(value) => setAction(`size: ${value}`)}
      >
        <ToolbarInput
          render={<NumberInputControl aria-label={f.size.label} />}
        />
      </NumberInput>
      <ToolbarInput
        aria-label={f.comment.label}
        defaultValue={f.comment.defaultValue}
      />
      <ToolbarGroup
        className="toolbar-group"
        aria-label={f.history.label}
        disabled={toolbarLocked() && locked}
      >
        @for (const item of f.history.items; key item.label) {
          <ToolbarButton
            disabled={"disabled" in item && item.disabled}
            onClick={() => setAction(item.label.toLowerCase())}
          >
            {item.label as string}
          </ToolbarButton>
        }
      </ToolbarGroup>
      <Lock label="Locked proofing" locked={locked}>
        @if (toolbarRenderedToggle()) {
          <ToolbarButton
            render={
              <Toggle
                className="toggle"
                onPressedChange={(pressed) =>
                  setAction(`spellcheck: ${pressed ? "on" : "off"}`)
                }
              />
            }
          >
            {f.spellcheck.label as string}
          </ToolbarButton>
        } @else {
          <Toggle
            className="toggle"
            onPressedChange={(pressed) =>
              setAction(`spellcheck: ${pressed ? "on" : "off"}`)
            }
          >
            {f.spellcheck.label as string}
          </Toggle>
        }
      </Lock>
      <Lock label="Locked help" locked={locked}>
        <ToolbarLink href={f.help.href}>{f.help.label as string}</ToolbarLink>
      </Lock>
    </Toolbar>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
    <button onClick={() => controller.focus()}>Focus toolbar</button>
    <button onClick={() => setLocked(false)}>Unlock</button>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
