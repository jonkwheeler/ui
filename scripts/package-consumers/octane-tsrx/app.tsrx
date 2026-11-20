import {
  Combobox,
  ComboboxContent,
  ComboboxInput,
  ComboboxItem,
  ComboboxList,
} from "@ui-sdk/octane/combobox"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectList,
  SelectTrigger,
  SelectValue,
} from "@ui-sdk/octane/select"

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
  </>
}

export { App }
