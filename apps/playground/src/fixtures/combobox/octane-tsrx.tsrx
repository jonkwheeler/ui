import { useAsyncOptions } from "@ui-sdk/octane/async-options"
import {
  Combobox,
  ComboboxChip,
  ComboboxChipRemove,
  ComboboxChips,
  ComboboxChipsOverflow,
  ComboboxClear,
  ComboboxContent,
  ComboboxCreate,
  ComboboxEmpty,
  ComboboxGroup,
  ComboboxGroupLabel,
  ComboboxInput,
  ComboboxItem,
  ComboboxItemIndicator,
  ComboboxItemText,
  ComboboxLabel,
  ComboboxList,
  ComboboxSelectAll,
  ComboboxSeparator,
  ComboboxStatus,
  ComboboxTrigger,
  ComboboxValue,
  type ListData,
} from "@ui-sdk/octane/combobox"
import { createRoot, useEffect, useState, type OctaneNode } from "octane"
import {
  cancelsValue,
  changedItems,
  comboboxFixture as f,
  comboboxOptions,
  createDelay,
  searchCountries,
  searchCountryPages,
} from "tests/fixtures/combobox.ts"
import { onItemsChange } from "tests/fixtures/items.ts"
import { longItems, serializeForm } from "tests/fixtures/select.ts"

type Country = {
  value: string
  label: string
  keywords?: string[]
  disabled?: boolean
}

function Item({
  value,
  label,
  keywords,
  disabled,
  highlight,
}: Country & { highlight: boolean }) @{
  <ComboboxItem
    className="item"
    value={value}
    label={label}
    keywords={keywords}
    disabled={disabled}
  >
    @if (highlight) {
      <ComboboxItemText>{label as string}</ComboboxItemText>
    } @else {
      <>{label as string}</>
    }
    <ComboboxItemIndicator className="indicator">✓</ComboboxItemIndicator>
  </ComboboxItem>
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

// The list's data, rendered like the composed list: items with their check, and groups with their labels.
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
      <Item value={entry} label={entry} highlight={highlight} />
    } @else if ("value" in entry) {
      <Item {...entry} highlight={highlight} />
    } @else if (entry.type === "separator") {
      <ComboboxSeparator />
    } @else {
      <ComboboxGroup>
        <ComboboxGroupLabel className="label">
          {entry.label as string}
        </ComboboxGroupLabel>
        <DataItems items={entry.items} highlight={highlight} />
      </ComboboxGroup>
    }
  </>
}

function DataList({
  items,
  highlight,
  selectAll,
  create,
  onCreate,
}: {
  items: ListData
  highlight: boolean
  selectAll: boolean
  create: boolean
  onCreate: (query: string) => Promise<void>
}) @{
  <>
    @if (selectAll) {
      <ComboboxSelectAll className="item">
        {f.selectAll as string}
      </ComboboxSelectAll>
    }
    <DataItems items={items} highlight={highlight} />
    @if (create) {
      <ComboboxCreate className="item" onCreate={onCreate} />
    }
  </>
}

// One chip per selected value.
function Chips({ labels }: { labels: Map<string, string> }) @{
  <ComboboxValue>
    {({ value }) => <ChipList values={value as string[]} labels={labels} />}
  </ComboboxValue>
}

function ChipList({
  values,
  labels,
}: {
  values: string[]
  labels: Map<string, string>
}) @{
  <>
    @for (const item of values; key item) {
      <ComboboxChip className="chip" value={item}>
        {(labels.get(item) ?? item) as string}
        <ComboboxChipRemove
          aria-label={`Remove ${labels.get(item) ?? item}`}
        >
          ×
        </ComboboxChipRemove>
      </ComboboxChip>
    }
  </>
}

function Fixture({ data = false }: { data?: boolean }) @{
  const {
    fieldset,
    grouped,
    create,
    slow,
    async,
    long,
    late,
    container,
    highlight,
    recent,
    selectAll,
    overflow,
    pages,
    nostatus,
    summary,
    labelsFromItems,
    cancel,
    ...options
  } = comboboxOptions()
  const [action, setAction] = useState("")
  const [submitted, setSubmitted] = useState("")
  const [created, setCreated] = useState<{ value: string; label: string }[]>([])
  const [list, setList] = useState<Country[]>(f.items)
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
  const remote = useAsyncOptions(pages ? searchCountryPages : searchCountries, {
    immediate: async || pages,
  })
  const fromData = data || async || long || recent || pages
  const items =
    async || pages
      ? remote.items
      : long
        ? longItems()
        : grouped
          ? [
              {
                type: "group" as const,
                label: f.groups[0].label,
                items: f.groups[0].items,
              },
              {
                type: "group" as const,
                label: f.groups[1].label,
                items: f.groups[1].items,
              },
            ]
          : [...list, ...created]
  const onCreate = async (query: string) => {
    setAction(`create:${query}`)
    await createDelay(slow)
    setCreated((list) => [
      ...list,
      { value: query.toLowerCase(), label: query },
    ])
  }
  const labels = new Map(
    [...f.items, ...list, ...created].map((item) => [item.value, item.label])
  )
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
        <Combobox<string, boolean>
          {...options}
          name={f.name}
          container={container}
          items={
            late ? (arrived ? items : undefined) : fromData ? items : undefined
          }
          emptyItems={recent ? f.recent : undefined}
          filter={async || pages ? false : undefined}
          status={async || pages ? remote.status : undefined}
          onLoadMore={pages ? remote.loadMore : undefined}
          itemToLabel={
            labelsFromItems ? undefined : (value) => labels.get(value) ?? value
          }
          onValueChange={(value, details) => {
            if (cancelsValue(value, cancel)) {
              return details.cancel()
            }
            setAction(
              `value:${Array.isArray(value) ? value.join(",") : String(value)}`
            )
          }}
          onQueryChange={(query) => (async || pages) && remote.setQuery(query)}
        >
          <ComboboxLabel className="label">{f.label as string}</ComboboxLabel>
          @if (options.multiple) {
            <ComboboxChips
              className={overflow ? "chips chips-line" : "chips"}
            >
              <Chips labels={labels} />
              @if (overflow) {
                <ComboboxChipsOverflow className="chips-overflow" />
              }
              <ComboboxInput className="input" />
            </ComboboxChips>
          } @else {
            <ComboboxInput className="input" />
          }
          @if (summary) {
            <output aria-label={f.summary}>
              <ComboboxValue maxLabels={summary} />
            </output>
          }
          <ComboboxTrigger aria-label={f.trigger}>▾</ComboboxTrigger>
          <ComboboxClear>{f.clear as string}</ComboboxClear>
          @if (late) {
            <ComboboxContent className="popup list-popup" />
          } @else {
            <ComboboxContent
              className={
                pages ? "popup list-popup list-short" : "popup list-popup"
              }
            >
              @if (!nostatus) {
                <ComboboxStatus className="status">
                  {(state) =>
                    state.loading
                      ? pages
                        ? "Loading more…"
                        : "Loading…"
                      : ""
                  }
                </ComboboxStatus>
              }
              <ComboboxEmpty className="empty">
                {f.empty as string}
              </ComboboxEmpty>
              @if (fromData) {
                <ComboboxList>
                  {(state) => (
                    <DataList
                      items={state.items as ListData}
                      highlight={highlight}
                      selectAll={selectAll}
                      create={create}
                      onCreate={onCreate}
                    />
                  )}
                </ComboboxList>
              } @else {
                <ComboboxList>
                  @if (
                    selectAll &&
                    !grouped
                  ) {
                    <ComboboxSelectAll className="item">
                      {f.selectAll as string}
                    </ComboboxSelectAll>
                  }
                  @if (grouped) {
                    <>
                      @for (const group of f.groups; key group.label) {
                        <ComboboxGroup>
                          <ComboboxGroupLabel className="label">
                            {group.label as string}
                          </ComboboxGroupLabel>
                          @if (
                            selectAll
                          ) {
                            <ComboboxSelectAll className="item">
                              {`${f.selectAll} ${group.label}`}
                            </ComboboxSelectAll>
                          }
                          @for (const item of group.items; key item.value) {
                            <Item
                              {...item}
                              highlight={
                                highlight
                              }
                            />
                          }
                        </ComboboxGroup>
                      }
                    </>
                  } @else {
                    <>
                      @for (const item of [
                          ...list,
                          ...created,
                        ]; key item.value) {
                        <Item
                          {...item}
                          highlight={highlight}
                        />
                      }
                    </>
                  }
                  @if (create) {
                    <ComboboxCreate
                      className="item"
                      onCreate={onCreate}
                    />
                  }
                </ComboboxList>
              }
            </ComboboxContent>
          }
        </Combobox>
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
