import {
  Autocomplete,
  AutocompleteContent,
  AutocompleteEmpty,
  AutocompleteInput,
  AutocompleteItem,
  AutocompleteItemIcon,
  AutocompleteItemText,
  AutocompleteLabel,
  AutocompleteList,
} from "@ui-sdk/octane/autocomplete"
import {
  Combobox,
  ComboboxContent,
  ComboboxInput,
  ComboboxItem,
  ComboboxItemIcon,
  ComboboxItemText,
  ComboboxLabel,
  ComboboxList,
  ComboboxValueIcon,
} from "@ui-sdk/octane/combobox"
import {
  Command,
  CommandEmpty,
  CommandInput,
  CommandItem,
  CommandItemIcon,
  CommandItemText,
  CommandList,
} from "@ui-sdk/octane/command"
import {
  Menu,
  MenuContent,
  MenuItem,
  MenuItemIcon,
  MenuTrigger,
} from "@ui-sdk/octane/menu"
import {
  NavigationMenu,
  NavigationMenuItem,
  NavigationMenuLink,
  NavigationMenuLinkIcon,
  NavigationMenuList,
} from "@ui-sdk/octane/navigation-menu"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectItemIcon,
  SelectLabel,
  SelectTrigger,
  SelectValue,
  SelectValueIcon,
} from "@ui-sdk/octane/select"
import { Tabs, TabsList, TabsTab, TabsTabIcon } from "@ui-sdk/octane/tabs"
import { Toggle, ToggleGroup, ToggleIcon } from "@ui-sdk/octane/toggle"
import { createRoot, useState } from "octane"
import {
  icons,
  iconsFixture as f,
  iconsOptions,
  type IconName,
} from "tests/fixtures/item-icons.ts"

function Svg({ name }: { name: IconName }) @{
  <svg
    viewBox="0 0 16 16"
    width="16"
    height="16"
    fill="none"
    stroke="currentColor"
  >
    <title>{icons[name].title as string}</title>
    <path d={icons[name].path} />
  </svg>
}

// What an entry's icon part holds: its SVG or its emoji.
function Glyph({
  entry,
}: {
  entry: { icon?: IconName; emoji?: string }
}) @{
  <>
    @if (entry.icon) {
      <Svg name={entry.icon} />
    } @else if (entry.emoji) {
      <>{entry.emoji as string}</>
    }
  </>
}

function Fixture() @{
  const [action, setAction] = useState("")
  const { unnamed, select, combobox } = iconsOptions()

  <div class="fixture icons-fixture">
    <button>Before</button>

    <Menu onAction={(value) => setAction(`menu:${value}`)}>
      <MenuTrigger className="trigger">{f.menu.trigger as string}</MenuTrigger>
      <MenuContent className="popup">
        @for (const item of f.menu.items; key item.value) {
          <MenuItem value={item.value}>
            @if (item.icon || item.emoji) {
              <MenuItemIcon mirror={item.mirror}>
                <Glyph entry={item} />
              </MenuItemIcon>
            }
            {item.label as string}
          </MenuItem>
        }
        <MenuItem
          value={f.menu.iconOnly.value}
          aria-label={f.menu.iconOnly.label}
        >
          <MenuItemIcon>
            <Glyph entry={f.menu.iconOnly} />
          </MenuItemIcon>
        </MenuItem>
        @if (unnamed) {
          <MenuItem value={f.unnamed.value}>
            <MenuItemIcon>
              <Svg name={f.unnamed.icon} />
            </MenuItemIcon>
          </MenuItem>
        }
      </MenuContent>
    </Menu>

    <Select
      placeholder={f.select.placeholder}
      defaultValue={select}
      onValueChange={(value) => setAction(`select:${value}`)}
    >
      <SelectLabel className="label">{f.select.label as string}</SelectLabel>
      <SelectTrigger className="trigger">
        <SelectValueIcon className="value-icon" />
        <SelectValue className="value" />
      </SelectTrigger>
      <SelectContent className="popup list-popup">
        {/* A select labels its value from the items it finds among its
        children, and it can't see inside an @for block. */}
        {f.select.items.map((item) => (
          <SelectItem key={item.value} className="item" value={item.value}>
            {(item.icon || item.emoji) && (
              <SelectItemIcon>
                <Glyph entry={item} />
              </SelectItemIcon>
            )}
            {item.label as string}
          </SelectItem>
        ))}
      </SelectContent>
    </Select>

    <Combobox
      defaultValue={combobox}
      onValueChange={(value) => setAction(`combobox:${value}`)}
    >
      <ComboboxLabel className="label">
        {f.combobox.label as string}
      </ComboboxLabel>
      <ComboboxValueIcon className="value-icon" />
      <ComboboxInput className="input" />
      <ComboboxContent className="popup list-popup">
        <ComboboxList>
          {/* A combobox labels its value from the items it finds among its
          children, and it can't see inside an @for block. */}
          {f.combobox.items.map((item) => (
            <ComboboxItem key={item.value} className="item" value={item.value}>
              {(item.icon || item.emoji) && (
                <ComboboxItemIcon>
                  <Glyph entry={item} />
                </ComboboxItemIcon>
              )}
              <ComboboxItemText>{item.label as string}</ComboboxItemText>
            </ComboboxItem>
          ))}
        </ComboboxList>
      </ComboboxContent>
    </Combobox>

    <Autocomplete>
      <AutocompleteLabel className="label">
        {f.autocomplete.label as string}
      </AutocompleteLabel>
      <AutocompleteInput className="input" />
      <AutocompleteContent className="popup list-popup">
        <AutocompleteEmpty className="empty">No results</AutocompleteEmpty>
        <AutocompleteList>
          @for (const item of f.autocomplete.items; key item.value) {
            <AutocompleteItem className="item" value={item.label}>
              <AutocompleteItemIcon>
                <Glyph entry={item} />
              </AutocompleteItemIcon>
              <AutocompleteItemText>
                {item.label as string}
              </AutocompleteItemText>
            </AutocompleteItem>
          }
        </AutocompleteList>
      </AutocompleteContent>
    </Autocomplete>

    <Command
      className="command"
      onAction={(value) => setAction(`command:${value}`)}
    >
      <CommandInput className="input" aria-label={f.command.label} />
      <CommandEmpty className="empty">No results</CommandEmpty>
      <CommandList className="command-list">
        @for (const item of f.command.items; key item.value) {
          <CommandItem className="item" value={item.value}>
            @if (item.icon || item.emoji) {
              <CommandItemIcon>
                <Glyph entry={item} />
              </CommandItemIcon>
            }
            <CommandItemText>{item.label as string}</CommandItemText>
          </CommandItem>
        }
      </CommandList>
    </Command>

    <Tabs className="tabs">
      <TabsList className="tablist" aria-label={f.tabs.label}>
        @for (const tab of f.tabs.tabs; key tab.value) {
          <TabsTab className="tab" value={tab.value}>
            <TabsTabIcon>
              <Glyph entry={tab} />
            </TabsTabIcon>
            {tab.label as string}
          </TabsTab>
        }
        <TabsTab
          className="tab"
          value={f.tabs.iconOnly.value}
          aria-label={f.tabs.iconOnly.label}
        >
          <TabsTabIcon>
            <Glyph entry={f.tabs.iconOnly} />
          </TabsTabIcon>
        </TabsTab>
      </TabsList>
    </Tabs>

    <ToggleGroup aria-label={f.toggles.label} className="toggle-group">
      <Toggle className="toggle" value={f.toggles.bold.value}>
        <ToggleIcon>
          <Glyph entry={f.toggles.bold} />
        </ToggleIcon>
        {f.toggles.bold.label as string}
      </Toggle>
      <Toggle
        className="toggle"
        value={f.toggles.iconOnly.value}
        aria-label={f.toggles.iconOnly.label}
      >
        <ToggleIcon>
          <Glyph entry={f.toggles.iconOnly} />
        </ToggleIcon>
      </Toggle>
    </ToggleGroup>

    <NavigationMenu aria-label={f.navigation.label} className="nav-menu">
      <NavigationMenuList className="nav-list">
        @for (const link of f.navigation.links; key link.value) {
          <NavigationMenuItem value={link.value}>
            <NavigationMenuLink
              href={`#${link.value}`}
              className="nav-link"
            >
              <NavigationMenuLinkIcon mirror={link.mirror}>
                <Glyph entry={link} />
              </NavigationMenuLinkIcon>
              {link.label as string}
            </NavigationMenuLink>
          </NavigationMenuItem>
        }
      </NavigationMenuList>
    </NavigationMenu>

    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
