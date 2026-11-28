import {
  Accordion,
  AccordionHeader,
  AccordionItem,
  AccordionPanel,
  AccordionTrigger,
} from "@ui-sdk/octane/accordion"
import {
  Autocomplete,
  AutocompleteContent,
  AutocompleteInput,
  AutocompleteItem,
  AutocompleteList,
} from "@ui-sdk/octane/autocomplete"
import {
  Collapsible,
  CollapsiblePanel,
  CollapsibleTrigger,
} from "@ui-sdk/octane/collapsible"
import {
  Combobox,
  ComboboxContent,
  ComboboxInput,
  ComboboxItem,
  ComboboxList,
} from "@ui-sdk/octane/combobox"
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogTitle,
  DialogTrigger,
} from "@ui-sdk/octane/dialog"
import {
  Drawer,
  DrawerBackdrop,
  DrawerClose,
  DrawerContent,
  DrawerDescription,
  DrawerTitle,
  DrawerTrigger,
} from "@ui-sdk/octane/drawer"
import {
  HoverCard,
  HoverCardContent,
  HoverCardTrigger,
} from "@ui-sdk/octane/hover-card"
import { Menu, MenuContent, MenuItem, MenuTrigger } from "@ui-sdk/octane/menu"
import {
  Popover,
  PopoverClose,
  PopoverContent,
  PopoverTrigger,
} from "@ui-sdk/octane/popover"
import {
  Resizable,
  ResizableHandle,
  ResizablePanel,
} from "@ui-sdk/octane/resizable"
import {
  ScrollArea,
  ScrollAreaContent,
  ScrollAreaScrollbar,
  ScrollAreaThumb,
  ScrollAreaViewport,
} from "@ui-sdk/octane/scroll-area"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@ui-sdk/octane/select"
import {
  Slider,
  SliderControl,
  SliderIndicator,
  SliderThumb,
  SliderTrack,
} from "@ui-sdk/octane/slider"
import {
  Tabs,
  TabsIndicator,
  TabsList,
  TabsPanel,
  TabsTab,
} from "@ui-sdk/octane/tabs"
import { Toolbar, ToolbarButton } from "@ui-sdk/octane/toolbar"
import { Tooltip, TooltipContent, TooltipTrigger } from "@ui-sdk/octane/tooltip"
import { Tree } from "@ui-sdk/octane/tree"
import { Waterfall } from "@ui-sdk/octane/waterfall"
import { createRoot, useState } from "octane"
import {
  exposeLayers,
  leakComponent,
  leakTreeItems,
  leakWaterfallItems,
  perfItems,
} from "tests/fixtures/perf.ts"

// One component for the leak specs, picked with ?component=, and a button
// that mounts and unmounts it. The scroll area hides its scrollbars soon after
// the pointer leaves, so the spec sees them show and hide without waiting long.
const items = perfItems(3)
const lines = perfItems(30)

function MenuLeak() @{
  <Menu>
    <MenuTrigger>Open</MenuTrigger>
    <MenuContent className="popup">
      @for (const item of items; key item.value) {
        <MenuItem className="item" value={item.value}>
          {item.label as string}
        </MenuItem>
      }
    </MenuContent>
  </Menu>
}

function SelectLeak() @{
  <Select defaultValue={items[0].value}>
    <SelectTrigger aria-label="Open" className="trigger">
      <SelectValue />
    </SelectTrigger>
    <SelectContent className="popup list-popup">
      @for (const item of items; key item.value) {
        <SelectItem
          className="item"
          value={item.value}
          label={item.label}
        >
          {item.label as string}
        </SelectItem>
      }
    </SelectContent>
  </Select>
}

function ComboboxLeak() @{
  <Combobox>
    <ComboboxInput aria-label="Open" className="input" />
    <ComboboxContent className="popup list-popup">
      <ComboboxList>
        @for (const item of items; key item.value) {
          <ComboboxItem
            className="item"
            value={item.value}
            label={item.label}
          >
            {item.label as string}
          </ComboboxItem>
        }
      </ComboboxList>
    </ComboboxContent>
  </Combobox>
}

function AutocompleteLeak() @{
  <Autocomplete>
    <AutocompleteInput aria-label="Open" className="input" />
    <AutocompleteContent className="popup list-popup">
      <AutocompleteList>
        @for (const item of items; key item.value) {
          <AutocompleteItem className="item" value={item.label}>
            {item.label as string}
          </AutocompleteItem>
        }
      </AutocompleteList>
    </AutocompleteContent>
  </Autocomplete>
}

function PopoverLeak() @{
  <Popover>
    <PopoverTrigger>Open</PopoverTrigger>
    <PopoverContent className="popup" aria-label="Details">
      Details.
      <PopoverClose>Close</PopoverClose>
    </PopoverContent>
  </Popover>
}

function DialogLeak() @{
  <Dialog>
    <DialogTrigger>Open</DialogTrigger>
    <DialogContent className="dialog">
      <DialogTitle className="title">Delete it?</DialogTitle>
      <DialogDescription className="description">
        This can't be undone.
      </DialogDescription>
      <DialogClose>Cancel</DialogClose>
    </DialogContent>
  </Dialog>
}

function DrawerLeak() @{
  <Drawer>
    <DrawerTrigger>Open</DrawerTrigger>
    <DrawerBackdrop className="backdrop" />
    <DrawerContent className="dialog">
      <DrawerTitle className="title">Move goal</DrawerTitle>
      <DrawerDescription className="description">
        Set your daily goal.
      </DrawerDescription>
      <DrawerClose>Cancel</DrawerClose>
    </DrawerContent>
  </Drawer>
}

function TooltipLeak() @{
  <Tooltip>
    <TooltipTrigger>Open</TooltipTrigger>
    <TooltipContent className="tooltip">A hint.</TooltipContent>
  </Tooltip>
}

function HoverCardLeak() @{
  <HoverCard delay={0}>
    <HoverCardTrigger href="#profile">Open</HoverCardTrigger>
    <HoverCardContent className="hover-card-content">
      A profile.
    </HoverCardContent>
  </HoverCard>
}

function SliderLeak() @{
  <Slider name="volume" defaultValue={50}>
    <SliderControl className="slider-control">
      <SliderTrack className="slider-track">
        <SliderIndicator className="slider-indicator" />
        <SliderThumb className="slider-thumb" aria-label="Volume" />
      </SliderTrack>
    </SliderControl>
  </Slider>
}

function AccordionLeak() @{
  <Accordion>
    <AccordionItem value="first">
      <AccordionHeader>
        <AccordionTrigger className="accordion-trigger">Open</AccordionTrigger>
      </AccordionHeader>
      <AccordionPanel className="accordion-panel">An answer.</AccordionPanel>
    </AccordionItem>
    <AccordionItem value="second">
      <AccordionHeader>
        <AccordionTrigger className="accordion-trigger">
          Second
        </AccordionTrigger>
      </AccordionHeader>
      <AccordionPanel className="accordion-panel">
        Another answer.
      </AccordionPanel>
    </AccordionItem>
  </Accordion>
}

function CollapsibleLeak() @{
  <Collapsible>
    <CollapsibleTrigger>Open</CollapsibleTrigger>
    <CollapsiblePanel className="collapsible-panel">Details.</CollapsiblePanel>
  </Collapsible>
}

function TabsLeak() @{
  <Tabs className="tabs" defaultValue={items[0].value}>
    <TabsList className="tablist" aria-label="Pages">
      @for (const item of items; key item.value) {
        <TabsTab className="tab" value={item.value}>
          {item.label as string}
        </TabsTab>
      }
      <TabsIndicator className="indicator" />
    </TabsList>
    @for (const item of items; key item.value) {
      <TabsPanel className="panel" value={item.value}>
        {`${item.label} content.`}
      </TabsPanel>
    }
  </Tabs>
}

function ToolbarLeak() @{
  <Toolbar className="toolbar" aria-label="Formatting">
    @for (const item of items; key item.value) {
      <ToolbarButton>{item.label as string}</ToolbarButton>
    }
  </Toolbar>
}

function TreeLeak() @{
  <Tree className="tree" aria-label="Files" items={leakTreeItems()} />
}

function WaterfallLeak() @{
  <Waterfall
    className="waterfall"
    aria-label="Trace"
    items={leakWaterfallItems()}
  />
}

function ResizableLeak() @{
  <Resizable className="resizable">
    <ResizablePanel id="first" defaultSize={50} className="resizable-panel" />
    <ResizableHandle className="resizable-handle" aria-label="Handle" />
    <ResizablePanel id="second" defaultSize={50} className="resizable-panel" />
  </Resizable>
}

function ScrollAreaLeak() @{
  <ScrollArea className="scroll-area" scrollHideDelay={50}>
    <ScrollAreaViewport
      className="scroll-area-viewport"
      role="region"
      aria-label="Items"
    >
      <ScrollAreaContent>
        @for (const line of lines; key line.value) {
          <p class="scroll-area-item">{line.label as string}</p>
        }
      </ScrollAreaContent>
    </ScrollAreaViewport>
    <ScrollAreaScrollbar className="scroll-area-scrollbar">
      <ScrollAreaThumb className="scroll-area-thumb" />
    </ScrollAreaScrollbar>
  </ScrollArea>
}

const components = {
  menu: MenuLeak,
  select: SelectLeak,
  combobox: ComboboxLeak,
  autocomplete: AutocompleteLeak,
  popover: PopoverLeak,
  dialog: DialogLeak,
  drawer: DrawerLeak,
  tooltip: TooltipLeak,
  "hover-card": HoverCardLeak,
  slider: SliderLeak,
  accordion: AccordionLeak,
  collapsible: CollapsibleLeak,
  tabs: TabsLeak,
  toolbar: ToolbarLeak,
  tree: TreeLeak,
  waterfall: WaterfallLeak,
  resizable: ResizableLeak,
  "scroll-area": ScrollAreaLeak,
}

function Fixture() @{
  const [mounted, setMounted] = useState(true)
  const Component = components[leakComponent()]

  <div class="fixture">
    <button>Before</button>
    @if (mounted) {
      <Component />
    }
    <button onClick={() => setMounted((value) => !value)}>Toggle</button>
  </div>
}

function mount(root: HTMLElement) {
  exposeLayers()
  createRoot(root).render(<Fixture />)
}

export { mount }
