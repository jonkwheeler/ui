import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandGroupLabel,
  CommandInput,
  CommandItem,
  CommandItemText,
  CommandList,
  CommandPage,
  CommandSeparator,
  CommandShortcut,
  CommandStatus,
  type CommandData,
  type CommandDataItem,
} from "@ui-sdk/octane/command"
import { createRoot, useState } from "octane"
import {
  commandData,
  commandFixture as f,
  commandOptions,
  runAction,
} from "tests/fixtures/command.ts"
import { longItems } from "tests/fixtures/select.ts"

type Suggestion = (typeof f.groups)[number]["items"][number]

function Suggested({
  item,
  unvalued,
  highlight,
}: {
  item: Suggestion
  unvalued: boolean
  highlight: boolean
}) @{
  <CommandItem
    className="item"
    value={unvalued ? undefined : item.value}
    keywords={"keywords" in item ? item.keywords : undefined}
    disabled={"disabled" in item ? item.disabled : undefined}
    shortcut={"shortcut" in item ? item.shortcut : undefined}
    page={"page" in item ? item.page : undefined}
  >
    @if (highlight) {
      <CommandItemText>{item.label as string}</CommandItemText>
    } @else {
      <>{item.label as string}</>
    }
    @if ("shortcut" in item) {
      <CommandShortcut className="shortcut" />
    }
  </CommandItem>
}

function keyOf(entry: CommandData[number], position: number) {
  if (typeof entry === "string") {
    return entry
  }
  if (!("type" in entry)) {
    return entry.value
  }
  return entry.type === "separator"
    ? `separator-${position}`
    : (entry.label ?? String(position))
}

// The data's commands, groups and separators, styled like the composed ones.
function DataCommands({
  items,
  highlight,
}: {
  items: CommandData
  highlight?: boolean
}) @{
  <>
    @for (const entry of items; index position; key keyOf(entry, position)) {
      <DataEntry entry={entry} highlight={highlight} />
    }
  </>
}

function DataEntry({
  entry,
  highlight,
}: {
  entry: CommandData[number]
  highlight?: boolean
}) @{
  <>
    @if (
      typeof entry !== "string" &&
      "type" in entry
    ) {
      @if (entry.type === "separator") {
        <CommandSeparator className="separator" />
      } @else {
        <CommandGroup>
          @if (entry.label) {
            <CommandGroupLabel className="label">
              {entry.label as string}
            </CommandGroupLabel>
          }
          <DataCommands items={entry.items} highlight={highlight} />
        </CommandGroup>
      }
    } @else {
      <DataCommand
        command={
          typeof entry === "string"
            ? { value: entry, label: entry }
            : entry
        }
        highlight={highlight}
      />
    }
  </>
}

function DataCommand({
  command,
  highlight,
}: {
  command: CommandDataItem
  highlight?: boolean
}) @{
  <CommandItem
    className="item"
    value={command.value}
    label={command.label}
    keywords={command.keywords}
    disabled={command.disabled}
    shortcut={command.shortcut}
  >
    @if (highlight) {
      <CommandItemText>{command.label as string}</CommandItemText>
    } @else {
      <>{command.label as string}</>
    }
    @if (command.shortcut) {
      <CommandShortcut className="shortcut" />
    }
  </CommandItem>
}

function Fixture({ data = false }: { data?: boolean }) @{
  const { slow, fail, long, highlight, unvalued, ...options } = commandOptions()
  const [action, setAction] = useState("")
  const [lastHighlight, setLastHighlight] = useState("")
  const [items] = useState(() =>
    long ? longItems() : data ? commandData() : undefined
  )
  const onAction = (value: string) => {
    setAction(`action:${value}`)
    return runAction(slow, fail)
  }

  <div class="fixture">
    <button>Before</button>
    <Command
      {...options}
      className="command"
      items={items}
      onAction={onAction}
      onValueChange={(value, details) =>
        setLastHighlight(`${value}:${details.reason}`)
      }
    >
      <CommandInput className="input" aria-label={f.input} />
      <CommandEmpty className="empty">{f.empty as string}</CommandEmpty>
      <CommandStatus className="status">
        {(state) => (state.loading ? "Loading…" : "")}
      </CommandStatus>
      @if (items) {
        <CommandList className="command-list">
          {(state) => (
            <DataCommands items={state.items} highlight={highlight} />
          )}
        </CommandList>
      } @else {
        <CommandList className="command-list">
          <CommandPage>
            @for (const group of f.groups; index position; key group.label) {
              <>
                @if (position > 0) {
                  <CommandSeparator className="separator" />
                }
                <CommandGroup>
                  <CommandGroupLabel className="label">
                    {group.label as string}
                  </CommandGroupLabel>
                  @for (const item of group.items; key item.value) {
                    <Suggested
                      item={item}
                      unvalued={unvalued}
                      highlight={highlight}
                    />
                  }
                </CommandGroup>
              </>
            }
          </CommandPage>
          <CommandPage value="theme">
            @for (const item of f.theme; key item.value) {
              <CommandItem className="item" value={item.value}>
                {item.label as string}
              </CommandItem>
            }
          </CommandPage>
        </CommandList>
      }
    </Command>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
    <output role="status" aria-label="Last highlight">
      {lastHighlight as string}
    </output>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
