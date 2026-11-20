import { createSelectController } from "@ui-sdk/core/select"
import { Field, FieldLabel } from "@ui-sdk/octane/field"
import {
  Select,
  SelectClear,
  SelectContent,
  SelectEmpty,
  SelectGroup,
  SelectGroupLabel,
  SelectInput,
  SelectItem,
  SelectItemIndicator,
  SelectItemText,
  SelectLabel,
  SelectList,
  SelectSelectAll,
  SelectSeparator,
  SelectTrigger,
  SelectValue,
  type ListData,
  type SelectProps,
} from "@ui-sdk/octane/select"
import { createRoot, useEffect, useState, type OctaneNode } from "octane"
import { onItemsChange } from "tests/fixtures/items.ts"
import {
  changedItems,
  longItems,
  selectFixture as f,
  selectOptions,
  serializeForm,
} from "tests/fixtures/select.ts"

type Fruit = { value: string; label: string; disabled?: boolean }

const controller = createSelectController<string, boolean>()

function Item({ value, label, disabled }: Fruit) @{
  <SelectItem className="item" value={value} disabled={disabled}>
    <SelectItemText>{label as string}</SelectItemText>
    <SelectItemIndicator className="indicator">✓</SelectItemIndicator>
  </SelectItem>
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

// The list's data, rendered like the composed list: items with their check, groups with their
// labels, and separators.
function DataItems({ items }: { items: ListData }) @{
  <>
    @for (const entry of items; index position; key keyOf(entry, position)) {
      <DataEntry entry={entry} />
    }
  </>
}

function DataEntry({ entry }: { entry: ListData[number] }) @{
  <>
    @if (typeof entry === "string") {
      <Item value={entry} label={entry} />
    } @else if ("value" in entry) {
      <Item {...entry} />
    } @else if (entry.type === "separator") {
      <SelectSeparator className="separator" />
    } @else {
      <SelectGroup>
        <SelectGroupLabel className="label">
          {entry.label as string}
        </SelectGroupLabel>
        <DataItems items={entry.items} />
      </SelectGroup>
    }
  </>
}

// What the list holds: the items, grouped with ?grouped, each group with its own select-all option.
function ListItems({
  list,
  grouped,
  selectAll,
}: {
  list: Fruit[]
  grouped: boolean
  selectAll: boolean
}) @{
  <>
    @if (grouped) {
      <>
        @for (const group of f.groups; index position; key group.label) {
          <>
            @if (position > 0) {
              <SelectSeparator className="separator" />
            }
            <SelectGroup>
              <SelectGroupLabel className="label">
                {group.label as string}
              </SelectGroupLabel>
              @if (selectAll) {
                <SelectSelectAll className="item">
                  {`${f.selectAll} ${group.label}`}
                </SelectSelectAll>
              }
              @for (const item of group.items; key item.value) {
                <Item {...item} />
              }
            </SelectGroup>
          </>
        }
      </>
    } @else {
      <>
        @for (const item of list; key item.value) {
          <Item {...item} />
        }
      </>
    }
  </>
}

// ?wrapped renders the data list through a content part wrapped in a
// component of the app's own, as a styled layer does. The select renders it
// and no list of its own.
function StyledContent() @{
  <SelectContent className="popup list-popup" />
}

function SearchResults({
  items,
  fromData,
  list,
  grouped,
  selectAll,
}: {
  items: ListData
  fromData: boolean
  list: Fruit[]
  grouped: boolean
  selectAll: boolean
}) @{
  <>
    @if (selectAll && !grouped) {
      <SelectSelectAll className="item">
        {f.selectAll as string}
      </SelectSelectAll>
    }
    @if (fromData) {
      <DataItems items={items} />
    } @else {
      <ListItems list={list} grouped={grouped} selectAll={selectAll} />
    }
  </>
}

function DataContent({
  items,
  selectAll,
}: {
  items: ListData
  selectAll: boolean
}) @{
  <>
    @if (selectAll) {
      <SelectSelectAll className="item">
        {f.selectAll as string}
      </SelectSelectAll>
    }
    <DataItems items={items} />
  </>
}

function Fixture({ data = false }: { data?: boolean }) @{
  const wrapped = new URLSearchParams(location.search).has("wrapped")
  const {
    fieldset,
    field,
    grouped,
    cancel,
    align,
    long,
    container,
    search,
    selectAll,
    recent,
    max,
    ...options
  } = selectOptions()
  const [action, setAction] = useState("")
  const [submitted, setSubmitted] = useState("")
  const [list, setList] = useState<Fruit[]>(f.items)
  useEffect(() => onItemsChange(changedItems, setList), [])
  const fromData = data || long || recent
  const items = long
    ? longItems()
    : grouped
      ? [
          {
            type: "group" as const,
            label: f.groups[0].label,
            items: f.groups[0].items,
          },
          { type: "separator" as const },
          {
            type: "group" as const,
            label: f.groups[1].label,
            items: f.groups[1].items,
          },
        ]
      : list

  // Typed here and cast at the spread, since Octane can't read
  // <Select<string, boolean>>: with two JSX type arguments, no part in this
  // file would see its children.
  const props: SelectProps<string, boolean> = {
    ...options,
    name: f.name,
    placeholder: f.placeholder,
    controller,
    container,
    items: fromData || wrapped ? items : undefined,
    emptyItems: recent ? f.recent : undefined,
    onValueChange: (value, details) => {
      if (cancel) {
        return details.cancel()
      }
      setAction(
        `value:${Array.isArray(value) ? value.join(",") : String(value)}`
      )
    },
  }

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
        @if (field) {
          <Field>
            <FieldLabel className="label">{f.label as string}</FieldLabel>
            <SelectTrigger className="trigger" controller={controller}>
              <SelectValue className="value" maxLabels={max} />
              <span aria-hidden="true">▾</span>
            </SelectTrigger>
          </Field>
        }
        <Select {...(props as SelectProps)}>
          @if (!field) {
            <>
              <SelectLabel className="label">
                {f.label as string}
              </SelectLabel>
              <SelectTrigger className="trigger">
                <SelectValue className="value" maxLabels={max} />
                <span aria-hidden="true">▾</span>
              </SelectTrigger>
            </>
          }
          <SelectClear>{f.clear as string}</SelectClear>
          @if (wrapped) {
            <StyledContent />
          } @else if (search) {
            <SelectContent
              className="popup list-popup"
              alignItemWithTrigger={align}
            >
              <SelectInput className="input" aria-label={f.search} />
              <SelectEmpty className="empty">
                {f.empty as string}
              </SelectEmpty>
              <SelectList>
                {(state) => (
                  <SearchResults
                    items={state.items as ListData}
                    fromData={fromData}
                    list={list}
                    grouped={grouped}
                    selectAll={selectAll}
                  />
                )}
              </SelectList>
            </SelectContent>
          } @else if (fromData) {
            <SelectContent className="popup list-popup">
              {(state) => (
                <DataContent
                  items={state.items as ListData}
                  selectAll={selectAll}
                />
              )}
            </SelectContent>
          } @else {
            <SelectContent
              className="popup list-popup"
              alignItemWithTrigger={align}
            >
              @if (selectAll && !grouped) {
                <SelectSelectAll className="item">
                  {f.selectAll as string}
                </SelectSelectAll>
              }
              <ListItems
                list={list}
                grouped={grouped}
                selectAll={selectAll}
              />
            </SelectContent>
          }
        </Select>
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
    <button onClick={() => controller.open()}>Open with controller</button>
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
