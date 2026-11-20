/** @jsxImportSource octane */
import {
  Autocomplete,
  AutocompleteContent,
  AutocompleteInput,
  AutocompleteLabel,
} from "@ui-sdk/octane/autocomplete"
import {
  Combobox,
  ComboboxContent,
  ComboboxInput,
  ComboboxLabel,
} from "@ui-sdk/octane/combobox"
import {
  Select,
  SelectContent,
  SelectLabel,
  SelectTrigger,
  SelectValue,
} from "@ui-sdk/octane/select"
import {
  TriggerMenu,
  TriggerMenuContent,
  TriggerMenuInput,
  TriggerMenuList,
} from "@ui-sdk/octane/trigger-menu"
import * as React from "octane"
import { createRoot } from "octane"
import { wrappedContentFixture as f } from "tests/fixtures/wrapped-content.ts"

// Data roots whose content sits inside a fragment or a wrapping element. Each
// renders that content, and no second list of its own.
function Fixture() {
  return (
    <div className="fixture">
      <button>Before</button>
      <Select items={f.items}>
        <SelectLabel>{f.select}</SelectLabel>
        <SelectTrigger>
          <SelectValue />
        </SelectTrigger>
        <>
          <SelectContent className="popup" />
        </>
      </Select>
      <Combobox items={f.items}>
        <ComboboxLabel>{f.combobox}</ComboboxLabel>
        <ComboboxInput />
        <div>
          <ComboboxContent className="popup" />
        </div>
      </Combobox>
      <Autocomplete items={f.items}>
        <AutocompleteLabel>{f.autocomplete}</AutocompleteLabel>
        <AutocompleteInput />
        <div>
          <AutocompleteContent className="popup" />
        </div>
      </Autocomplete>
      <TriggerMenu triggers={[{ char: "@", items: f.items }]}>
        <TriggerMenuInput aria-label={f.triggerMenu} />
        <>
          <TriggerMenuContent className="popup">
            <TriggerMenuList />
          </TriggerMenuContent>
        </>
      </TriggerMenu>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(
    <React.StrictMode>
      <Fixture />
    </React.StrictMode>
  )
}

export { Fixture, mount }
