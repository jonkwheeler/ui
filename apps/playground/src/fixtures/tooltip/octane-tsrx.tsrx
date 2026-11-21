import { createTooltipController } from "@ui-sdk/core/tooltip"
import {
  Popover,
  PopoverClose,
  PopoverContent,
  PopoverTitle,
  PopoverTrigger,
} from "@ui-sdk/octane/popover"
import {
  Tooltip,
  TooltipArrow,
  TooltipContent,
  TooltipShortcut,
  TooltipTrigger,
} from "@ui-sdk/octane/tooltip"
import { createRoot, useState } from "octane"
import {
  tooltipContentOptions,
  tooltipFixture,
  tooltipOptions,
  tooltipParts,
} from "tests/fixtures/tooltip.ts"

const controller = createTooltipController()

function ToolbarTooltip({
  item,
  options,
}: {
  item: (typeof tooltipFixture.toolbar)[number]
  options: ReturnType<typeof tooltipOptions>
}) @{
  <Tooltip {...options}>
    <TooltipTrigger>
      <span aria-hidden="true">{item.icon as string}</span>
    </TooltipTrigger>
    <TooltipContent className="tooltip">
      {item.content as string}
    </TooltipContent>
  </Tooltip>
}

function Fixture() @{
  // Read here, not at module level, so the server reads each request's URL.
  const parts = tooltipParts()
  const [action, setAction] = useState("")
  const options = tooltipOptions()
  const { save, toolbar, profile, info, publish, iconPopover } = tooltipFixture

  <div class="fixture tooltip-page">
    <button>Before</button>
    <Tooltip
      {...options}
      controller={controller}
      defaultOpen={parts.open}
      shortcut={save.shortcut}
    >
      <TooltipTrigger
        disabled={parts.nativeDisabled}
        onClick={() => setAction("save")}
      >
        {save.trigger as string}
      </TooltipTrigger>
      <TooltipContent className="tooltip" {...tooltipContentOptions()}>
        <TooltipArrow className="arrow" />
        {save.content as string}
        <TooltipShortcut />
      </TooltipContent>
    </Tooltip>
    <div class="toolbar" role="group" aria-label="Formatting">
      @for (const item of toolbar; key item.content) {
        <ToolbarTooltip item={item} options={options} />
      }
    </div>
    <Popover container={options.container}>
      <Tooltip {...options}>
        <TooltipTrigger
          render={<PopoverTrigger>{profile.trigger as string}</PopoverTrigger>}
        />
        <TooltipContent className="tooltip">
          {profile.content as string}
        </TooltipContent>
      </Tooltip>
      <PopoverContent className="popup" sideOffset={8}>
        <PopoverTitle className="title">
          {profile.popover as string}
        </PopoverTitle>
        <div class="actions">
          <Tooltip {...options}>
            <TooltipTrigger>{profile.help.trigger as string}</TooltipTrigger>
            <TooltipContent className="tooltip">
              {profile.help.content as string}
            </TooltipContent>
          </Tooltip>
          <PopoverClose>{profile.close as string}</PopoverClose>
        </div>
      </PopoverContent>
    </Popover>
    <Tooltip {...options} toggleable>
      <TooltipTrigger aria-label={info.trigger}>
        <span aria-hidden="true">i</span>
      </TooltipTrigger>
      <TooltipContent className="tooltip">
        {info.content as string}
      </TooltipContent>
    </Tooltip>
    @if (parts.disabled) {
      <Tooltip {...options}>
        <TooltipTrigger
          aria-disabled="true"
          onClick={(event) =>
            event.currentTarget.getAttribute("aria-disabled") !==
              "true" && setAction(publish.action)
          }
        >
          {publish.trigger as string}
        </TooltipTrigger>
        <TooltipContent className="tooltip">
          {publish.content as string}
        </TooltipContent>
      </Tooltip>
    }
    @if (parts.iconPopover) {
      <>
        <Popover container={options.container}>
          <Tooltip {...options}>
            <TooltipTrigger
              render={
                <PopoverTrigger>
                  <span aria-hidden="true">
                    {iconPopover.icon as string}
                  </span>
                </PopoverTrigger>
              }
            />
            <TooltipContent className="tooltip">
              {iconPopover.content as string}
            </TooltipContent>
          </Tooltip>
          <PopoverContent className="popup">
            {iconPopover.popover as string}
          </PopoverContent>
        </Popover>
        <Popover container={options.container}>
          <PopoverTrigger>
            <span aria-hidden="true">
              {iconPopover.unnamed as string}
            </span>
          </PopoverTrigger>
          <PopoverContent className="popup">
            {iconPopover.popover as string}
          </PopoverContent>
        </Popover>
      </>
    }
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
    <button onClick={() => controller.open()}>Open with controller</button>
    @if (parts.shortcut) {
      <TooltipTrigger controller={controller}>
        {tooltipFixture.shortcut.trigger as string} <TooltipShortcut />
      </TooltipTrigger>
    }
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
