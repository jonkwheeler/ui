/** @jsxImportSource octane */
import type * as React from "octane"
import { PopoverTrigger } from "../src/popover"

// An element held in a variable or passed through a prop. Octane also types
// its props in `type`, so typed props need `any` as much as unknown ones do.
declare const link: React.ReactElement<{ href: string }>
declare const untypedLink: React.ReactElement<unknown>
;<PopoverTrigger render={link} />
;<PopoverTrigger render={untypedLink} />
;<PopoverTrigger render={<a href="/home" />} />
