/** @jsxImportSource octane */
import {
  Autocomplete,
  AutocompleteContent,
  AutocompleteInput,
  AutocompleteItem,
  AutocompleteList,
} from "../src/autocomplete"
import { ColorPicker, ColorPickerInput } from "../src/color-picker"
import {
  Combobox,
  ComboboxContent,
  ComboboxInput,
  ComboboxItem,
  ComboboxList,
} from "../src/combobox"
import { Command, CommandInput, CommandItem, CommandList } from "../src/command"
import { DatePicker, DatePickerInput } from "../src/date-picker"
import { NumberInput, NumberInputControl } from "../src/number-input"
import { TokenInput, TokenInputEditor } from "../src/token-input"

type Handlers = Record<string, (...args: any[]) => void>

const fruits = ["Apple", "Banana", "Cherry"]

function FruitCombobox(handlers: Handlers) {
  return (
    <Combobox {...handlers}>
      <ComboboxInput aria-label="Fruit" />
      <ComboboxContent>
        <ComboboxList>
          {fruits.map((fruit) => (
            <ComboboxItem key={fruit} value={fruit}>
              {fruit}
            </ComboboxItem>
          ))}
        </ComboboxList>
      </ComboboxContent>
    </Combobox>
  )
}

function CustomCombobox(handlers: Handlers) {
  return (
    <Combobox allowCustomValue {...handlers}>
      <ComboboxInput aria-label="Fruit" />
      <ComboboxContent>
        <ComboboxList>
          <ComboboxItem value="Apple">Apple</ComboboxItem>
        </ComboboxList>
      </ComboboxContent>
    </Combobox>
  )
}

function FruitAutocomplete(handlers: Handlers) {
  return (
    <Autocomplete {...handlers}>
      <AutocompleteInput aria-label="Fruit" />
      <AutocompleteContent>
        <AutocompleteList>
          {fruits.map((fruit) => (
            <AutocompleteItem key={fruit} value={fruit}>
              {fruit}
            </AutocompleteItem>
          ))}
        </AutocompleteList>
      </AutocompleteContent>
    </Autocomplete>
  )
}

function ActionCommand() {
  return (
    <Command>
      <CommandInput aria-label="Search" />
      <CommandList>
        <CommandItem value="copy">Copy</CommandItem>
        <CommandItem value="paste">Paste</CommandItem>
      </CommandList>
    </Command>
  )
}

function Quantity(handlers: Handlers) {
  return (
    <NumberInput {...handlers}>
      <NumberInputControl aria-label="Quantity" />
    </NumberInput>
  )
}

function DateField(handlers: Handlers) {
  return (
    <DatePicker locale="en-US" {...handlers}>
      <DatePickerInput aria-label="Date" />
    </DatePicker>
  )
}

function ColorField(handlers: Handlers) {
  return (
    <ColorPicker defaultValue="#ff0000" {...handlers}>
      <ColorPickerInput aria-label="Color" />
    </ColorPicker>
  )
}

function GermanQuantity(handlers: Handlers) {
  return (
    <div lang="de">
      <NumberInput {...handlers}>
        <NumberInputControl aria-label="Menge" />
      </NumberInput>
    </div>
  )
}

function AppleCombobox(handlers: Handlers) {
  return (
    <Combobox defaultValue="Apple" {...handlers}>
      <ComboboxInput aria-label="Fruit" />
      <ComboboxContent>
        <ComboboxList>
          {fruits.map((fruit) => (
            <ComboboxItem key={fruit} value={fruit}>
              {fruit}
            </ComboboxItem>
          ))}
        </ComboboxList>
      </ComboboxContent>
    </Combobox>
  )
}

const a = { type: "file", value: "src/a.ts", label: "a.ts" }
const b = { type: "file", value: "src/b.ts", label: "b.ts" }

function ExplainPrompt(handlers: Handlers) {
  return (
    <TokenInput defaultValue={["Explain ", a]} {...handlers}>
      <TokenInputEditor aria-label="Prompt" />
    </TokenInput>
  )
}

function ComparePrompt(handlers: Handlers) {
  return (
    <TokenInput defaultValue={["Compare ", a, " and ", b]} {...handlers}>
      <TokenInputEditor aria-label="Prompt" />
    </TokenInput>
  )
}

export {
  a,
  ActionCommand,
  AppleCombobox,
  b,
  ColorField,
  ComparePrompt,
  CustomCombobox,
  DateField,
  ExplainPrompt,
  FruitAutocomplete,
  FruitCombobox,
  GermanQuantity,
  Quantity,
}
