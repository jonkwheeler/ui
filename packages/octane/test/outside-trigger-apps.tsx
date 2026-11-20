/** @jsxImportSource octane */
import { Dialog, DialogTrigger, type DialogController } from "../src/dialog"
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
  type PopoverController,
} from "../src/popover"

function OwnDialog({ controller }: { controller: DialogController }) {
  return (
    <Dialog controller={controller}>
      <DialogTrigger controller={controller}>Open</DialogTrigger>
    </Dialog>
  )
}

function OtherPopover({ controller }: { controller: PopoverController }) {
  return (
    <>
      <Popover>
        <PopoverTrigger controller={controller} id="trigger">
          Open
        </PopoverTrigger>
      </Popover>
      <Popover controller={controller}>
        <PopoverContent id="other-content" />
      </Popover>
    </>
  )
}

export { OtherPopover, OwnDialog }
