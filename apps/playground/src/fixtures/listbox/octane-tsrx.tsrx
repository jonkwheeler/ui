import {
  createListboxController,
  Listbox,
  ListboxGroup,
  ListboxGroupLabel,
  ListboxItem,
  ListboxItemIcon,
  ListboxItemIndicator,
  ListboxSeparator,
} from "@ui-sdk/octane/listbox"
import { createRoot, useEffect, useState, type OctaneNode } from "octane"
import { onItemsChange } from "tests/fixtures/items.ts"
import {
  changedToppings,
  listboxAction,
  listboxData,
  listboxFixture as f,
  listboxOptions,
  longToppings,
  type ListboxFixtureItem,
} from "tests/fixtures/listbox.ts"
import { serializeForm } from "tests/fixtures/select.ts"

const controller = createListboxController<string, boolean>()

function Item({ value, label, disabled }: ListboxFixtureItem) @{
  <ListboxItem className="item" value={value} disabled={disabled}>
    <ListboxItemIcon className="icon" />
    {label as string}
    <ListboxItemIndicator className="indicator">✓</ListboxItemIndicator>
  </ListboxItem>
}

// The items, or the groups with ?grouped.
function Items({
  grouped,
  long,
  list,
}: {
  grouped: boolean
  long: boolean
  list: ListboxFixtureItem[]
}) @{
  <>
    @if (long) {
      <>
        @for (const item of longToppings(); key item.value) {
          <Item {...item} />
        }
      </>
    } @else if (!grouped) {
      <>
        @for (const item of list; key item.value) {
          <Item {...item} />
        }
      </>
    } @else {
      <>
        @for (const group of f.groups; index position; key group.label) {
          <>
            @if (position > 0) {
              <ListboxSeparator className="separator" />
            }
            <ListboxGroup className="group">
              <ListboxGroupLabel className="label">
                {group.label as string}
              </ListboxGroupLabel>
              @for (const item of group.items; key item.value) {
                <Item {...item} />
              }
            </ListboxGroup>
          </>
        }
      </>
    }
  </>
}

function Fixture({ data = false }: { data?: boolean }) @{
  const {
    fieldset,
    grouped,
    cancel,
    long,
    controlled,
    defaultValue,
    ...options
  } = listboxOptions()
  const [action, setAction] = useState("")
  const [reason, setReason] = useState("")
  const [submitted, setSubmitted] = useState("")
  const [list, setList] = useState<ListboxFixtureItem[]>(f.items)
  useEffect(() => onItemsChange(changedToppings, setList), [])
  const [value, setValue] = useState<string | string[] | null>(
    defaultValue ?? (options.multiple ? [] : null)
  )
  <div class="fixture">
    <button>Before</button>
    <form
      class="select-form"
      aria-label={f.formLabel}
      onSubmit={(event) => {
        event.preventDefault()
        setSubmitted(serializeForm(event.currentTarget))
      }}
    >
      <Wrap fieldset={fieldset}>
        <Listbox<string, boolean>
          {...options}
          {...(controlled ? { value } : { defaultValue })}
          className="listbox"
          aria-label={f.label}
          name={f.name}
          controller={controller}
          items={
            data
              ? long
                ? longToppings()
                : grouped
                  ? listboxData(true)
                  : list
              : undefined
          }
          onValueChange={(next, details) => {
            setReason(details.reason)
            if (cancel) {
              return details.cancel()
            }
            setValue(next)
            setAction(listboxAction(next))
          }}
        >
          <Items grouped={grouped} long={long} list={list} />
        </Listbox>
      </Wrap>
      <button type="submit">Submit</button>
      <button type="reset">Reset</button>
    </form>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
    <output role="status" aria-label="Reason">
      {reason as string}
    </output>
    <output role="status" aria-label="Submitted">
      {submitted as string}
    </output>
    <button onClick={() => controller.clear()}>{f.clear as string}</button>
    <button onClick={() => controller.selectAll()}>
      {f.selectAll as string}
    </button>
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
