import {
  Autocomplete,
  AutocompleteContent,
  AutocompleteInput,
  AutocompleteItem,
  AutocompleteItemText,
  AutocompleteList,
} from "@ui-sdk/octane/autocomplete"
import {
  Combobox,
  ComboboxContent,
  ComboboxInput,
  ComboboxItem,
  ComboboxItemText,
  ComboboxList,
} from "@ui-sdk/octane/combobox"
import {
  Command,
  CommandInput,
  CommandItem,
  CommandItemText,
  CommandList,
} from "@ui-sdk/octane/command"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectItemText,
  SelectList,
  SelectTrigger,
  SelectValue,
} from "@ui-sdk/octane/select"

function PlanItems() @{
  <>
    <SelectItem value="basic">
      <SelectItemText>Basic plan</SelectItemText>
    </SelectItem>
    <SelectItem value="pro">
      <SelectItemText>Pro plan</SelectItemText>
    </SelectItem>
  </>
}

function CountryItems() @{
  <>
    <ComboboxItem value="de">
      <ComboboxItemText>Germany</ComboboxItemText>
    </ComboboxItem>
    <ComboboxItem value="fr">
      <ComboboxItemText>France</ComboboxItemText>
    </ComboboxItem>
  </>
}

function ActionItems() @{
  <>
    <CommandItem value="copy">
      <CommandItemText>Copy text</CommandItemText>
    </CommandItem>
    <CommandItem value="paste">
      <CommandItemText>Paste text</CommandItemText>
    </CommandItem>
  </>
}

function FruitItems() @{
  <>
    <AutocompleteItem value="ap">
      <AutocompleteItemText>Apple</AutocompleteItemText>
    </AutocompleteItem>
    <AutocompleteItem value="ba">
      <AutocompleteItemText>Banana</AutocompleteItemText>
    </AutocompleteItem>
  </>
}

function App() @{
  <>
    <Select defaultValue="pro">
      <SelectTrigger aria-label="Plan">
        <SelectValue placeholder="Choose a plan" />
      </SelectTrigger>
      <SelectContent>
        <SelectList>
          <SelectItem value="basic">Basic plan</SelectItem>
          <SelectItem value="pro">Pro plan</SelectItem>
        </SelectList>
      </SelectContent>
    </Select>
    <Combobox defaultValue="fr">
      <ComboboxInput aria-label="Country" />
      <ComboboxContent>
        <ComboboxList>
          <ComboboxItem value="de">Germany</ComboboxItem>
          <ComboboxItem value="fr">France</ComboboxItem>
        </ComboboxList>
      </ComboboxContent>
    </Combobox>
    <Select defaultOpen>
      <SelectTrigger aria-label="Upgrade">
        <SelectValue placeholder="Choose a plan" />
      </SelectTrigger>
      <SelectContent>
        <SelectList>
          <PlanItems />
        </SelectList>
      </SelectContent>
    </Select>
    <Combobox defaultOpen>
      <ComboboxInput aria-label="Ship to" />
      <ComboboxContent>
        <ComboboxList>
          <CountryItems />
        </ComboboxList>
      </ComboboxContent>
    </Combobox>
    <Command>
      <CommandInput aria-label="Run a command" />
      <CommandList>
        <ActionItems />
      </CommandList>
    </Command>
    <Autocomplete defaultOpen>
      <AutocompleteInput aria-label="Fruit" />
      <AutocompleteContent>
        <AutocompleteList>
          <FruitItems />
        </AutocompleteList>
      </AutocompleteContent>
    </Autocomplete>
  </>
}

export { App }
