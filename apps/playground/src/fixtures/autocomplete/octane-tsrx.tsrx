import { useAsyncOptions } from "@ui-sdk/octane/async-options"
import {
  Autocomplete,
  AutocompleteClear,
  AutocompleteContent,
  AutocompleteEmpty,
  AutocompleteGroup,
  AutocompleteGroupLabel,
  AutocompleteInput,
  AutocompleteItem,
  AutocompleteItemText,
  AutocompleteLabel,
  AutocompleteList,
  AutocompleteSeparator,
  AutocompleteStatus,
  AutocompleteTrigger,
  type ListData,
} from "@ui-sdk/octane/autocomplete"
import { createRoot, useEffect, useState, type OctaneNode } from "octane"
import {
  autocompleteFixture as f,
  autocompleteOptions,
  changedItems,
  searchFruits,
} from "tests/fixtures/autocomplete.ts"
import { onItemsChange } from "tests/fixtures/items.ts"
import { serializeForm } from "tests/fixtures/select.ts"

type Fruit = {
  value: string
  label: string
  keywords?: string[]
  disabled?: boolean
}

function keyOf(entry: ListData[number], position: number) {
  if (typeof entry === "string") {
    return entry
  }
  if ("value" in entry) {
    return entry.value
  }
  return entry.type === "separator" ? `separator-${position}` : entry.label
}

// The list's data, rendered like the composed list: items, and groups with their labels.
function DataItems({
  items,
  highlight,
}: {
  items: ListData
  highlight: boolean
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
  entry: ListData[number]
  highlight: boolean
}) @{
  <>
    @if (typeof entry === "string") {
      <FruitItem
        item={{ value: entry, label: entry }}
        highlight={highlight}
      />
    } @else if ("value" in entry) {
      <FruitItem item={entry} highlight={highlight} />
    } @else if (entry.type === "separator") {
      <AutocompleteSeparator />
    } @else {
      <AutocompleteGroup>
        <AutocompleteGroupLabel className="label">
          {entry.label as string}
        </AutocompleteGroupLabel>
        <DataItems items={entry.items} highlight={highlight} />
      </AutocompleteGroup>
    }
  </>
}

function FruitItem({
  item,
  highlight,
}: {
  item: Fruit
  highlight: boolean
}) @{
  <AutocompleteItem className="item" {...item}>
    @if (highlight) {
      <AutocompleteItemText>{item.label as string}</AutocompleteItemText>
    } @else {
      <>{item.label as string}</>
    }
  </AutocompleteItem>
}

function Fixture({ data = false }: { data?: boolean }) @{
  const {
    fieldset,
    grouped,
    async,
    late,
    container,
    highlight,
    recent,
    nostatus,
    ...options
  } = autocompleteOptions()
  const [action, setAction] = useState("")
  const [submitted, setSubmitted] = useState("")
  const remote = useAsyncOptions(searchFruits, { immediate: async })
  const [list, setList] = useState<Fruit[]>(f.items)
  // With ?late, there are no items until the first change.
  const [arrived, setArrived] = useState(false)
  useEffect(
    () =>
      onItemsChange(changedItems, (items) => {
        setList(items)
        setArrived(true)
      }),
    []
  )
  const fromData = data || async || recent
  const items = async
    ? remote.items
    : grouped
      ? f.groups.map((group) => ({
          type: "group" as const,
          label: group.label,
          items: group.items,
        }))
      : list

  <div class="fixture">
    <button>Before</button>
    <form
      class="select-form"
      aria-label={f.formLabel}
      onSubmit={(event) => {
        event.preventDefault()
        setSubmitted(serializeForm(event.currentTarget as HTMLFormElement))
      }}
    >
      <Wrap fieldset={fieldset}>
        <Autocomplete
          {...options}
          name={f.name}
          container={container}
          items={
            late ? (arrived ? items : undefined) : fromData ? items : undefined
          }
          emptyItems={recent ? f.recent : undefined}
          filter={async ? false : undefined}
          status={async ? remote.status : undefined}
          onValueChange={(value, details) => {
            setAction(`value:${value}:${details.reason}`)
            if (async) {
              remote.setQuery(value)
            }
          }}
          onSubmit={(value) => setAction(`submit:${value}`)}
        >
          <AutocompleteLabel className="label">
            {f.label as string}
          </AutocompleteLabel>
          <AutocompleteInput className="input" />
          <AutocompleteTrigger aria-label={f.trigger}>▾</AutocompleteTrigger>
          <AutocompleteClear>{f.clear as string}</AutocompleteClear>
          {/* The autocomplete renders a content of its own while it sees none
          among its children, and it can't see inside an @if block. */}
          {late && <AutocompleteContent className="popup list-popup" />}
          @if (!late) {
            <AutocompleteContent className="popup list-popup">
              @if (!nostatus) {
                <AutocompleteStatus className="status">
                  {(state) => (state.loading ? "Loading…" : "")}
                </AutocompleteStatus>
              }
              <AutocompleteEmpty className="empty">
                {f.empty as string}
              </AutocompleteEmpty>
              @if (fromData) {
                <AutocompleteList>
                  {(state) => (
                    <DataItems
                      items={state.items as ListData}
                      highlight={highlight}
                    />
                  )}
                </AutocompleteList>
              } @else {
                <AutocompleteList>
                  @if (grouped) {
                    <>
                      @for (const group of f.groups; key group.label) {
                        <AutocompleteGroup>
                          <AutocompleteGroupLabel className="label">
                            {group.label as string}
                          </AutocompleteGroupLabel>
                          @for (const item of group.items; key item.value) {
                            <AutocompleteItem
                              className="item"
                              value={item.value}
                              label={item.label}
                            >
                              {
                                item.label as string
                              }
                            </AutocompleteItem>
                          }
                        </AutocompleteGroup>
                      }
                    </>
                  } @else {
                    <>
                      @for (const item of list; key item.value) {
                        <FruitItem
                          item={item}
                          highlight={highlight}
                        />
                      }
                    </>
                  }
                </AutocompleteList>
              }
            </AutocompleteContent>
          }
        </Autocomplete>
      </Wrap>
      <button type="submit">Submit</button>
      <button type="reset">Reset</button>
    </form>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
    <output role="status" aria-label="Submitted">
      {submitted as string}
    </output>
  </div>
}

// A disabled fieldset around the control, with ?fieldset.
function Wrap({
  fieldset,
  children,
}: {
  fieldset: boolean
  children: OctaneNode
}) @{
  <>
    @if (fieldset) {
      <fieldset disabled>{children}</fieldset>
    } @else {
      <>{children}</>
    }
  </>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
