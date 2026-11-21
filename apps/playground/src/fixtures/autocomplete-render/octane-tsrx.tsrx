import {
  Autocomplete,
  AutocompleteContent,
  AutocompleteInput,
  AutocompleteItem,
  AutocompleteLabel,
  AutocompleteList,
  AutocompleteTrigger,
} from "@ui-sdk/octane/autocomplete"
import { createRoot } from "octane"
import { autocompleteFixture as f } from "tests/fixtures/autocomplete.ts"

// Parts rendered as other elements, with render functions and class names of state.
function Fixture() @{
  <div class="fixture">
    <button>Before</button>
    <Autocomplete name={f.name}>
      <AutocompleteLabel className="label">
        {f.label as string}
      </AutocompleteLabel>
      <AutocompleteInput
        className={(state) => `input ${state.open ? "is-open" : "is-closed"}`}
      />
      <AutocompleteTrigger aria-label={f.trigger}>▾</AutocompleteTrigger>
      <AutocompleteContent className="popup list-popup">
        <AutocompleteList>
          <AutocompleteItem
            className="item"
            value="docs"
            label="Docs"
            render={<a href="#docs" />}
          >
            Docs
          </AutocompleteItem>
          @for (const item of f.items.slice(0, 3); key item.value) {
            <AutocompleteItem
              className="item"
              value={item.value}
              label={item.label}
              render={(props, state) => (
                <div {...props}>
                  {`${item.label}${state.highlighted ? " ←" : ""}`}
                </div>
              )}
            />
          }
        </AutocompleteList>
      </AutocompleteContent>
    </Autocomplete>
    <button>After</button>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
