import { bindScrollPicker } from "@ui-sdk/core"
import { Listbox, ListboxItem } from "@ui-sdk/octane/listbox"
import { createRoot, useCallback, useState } from "octane"
import {
  pickerFixtures,
  type PickerFixture,
} from "tests/fixtures/listbox-picker.ts"

function Picker({ picker }: { picker: PickerFixture }) @{
  const [value, setValue] = useState<string | null>(picker.defaultValue)
  const [changes, setChanges] = useState<string[]>([])
  const choose = useCallback((next: string | null) => {
    setValue(next)
    setChanges((current) => [...current, String(next)])
  }, [])
  const bind = useCallback(
    (el: HTMLDivElement) =>
      bindScrollPicker(el, {
        onSelect: (index) => choose(picker.items[index].value),
      }),
    [choose, picker]
  )

  <>
    <Listbox
      ref={bind}
      className="picker"
      aria-label={picker.label}
      orientation={picker.orientation}
      keepInView={false}
      value={value}
      onValueChange={choose}
    >
      @for (const item of picker.items; key item.value) {
        <ListboxItem
          className="picker-item"
          value={item.value}
          disabled={item.disabled}
        >
          {item.value as string}
        </ListboxItem>
      }
    </Listbox>
    <output role="status" aria-label={`${picker.label} changes`}>
      {changes.join(",") as string}
    </output>
  </>
}

function Fixture() @{
  <div class="fixture">
    <button>Before</button>
    @for (const picker of pickerFixtures; key picker.label) {
      <Picker picker={picker} />
    }
    <button>After</button>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
