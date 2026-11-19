/** @jsxImportSource octane */
import type { Primitive } from "@ui-sdk/core"
import { portalTarget } from "@ui-sdk/core/renderer"
import * as React from "octane"
import { useControllerTarget } from "./controller-target"
import { mergeRefs } from "./render-element"
import {
  HandleScope,
  presentIn,
  renderElement,
  slotIn,
  useNearest,
  type PrimitiveHandle,
  type RenderProp,
} from "./use-primitive"

// Where a popup renders: an element or fragment, or nothing to render in place.
type PopupContainer = Element | DocumentFragment | null | undefined

// The container the nearest popup above renders into. Popups inside it render
// there too, like a menu inside a portaled popover, unless they name their own.
const InheritedContainer = React.createContext<PopupContainer>(undefined)

// A popup's container: its own, else the one the popup around it renders into.
function usePopupContainer(own: PopupContainer) {
  const inherited = React.useContext(InheritedContainer)
  return own ?? inherited
}

// A popup's own container: the content's, else its root's.
function useOwnContainer(
  own: PopupContainer,
  root: React.Context<PopupContainer>
) {
  const fromRoot = React.useContext(root)
  return own ?? fromRoot
}

// Renders a popup in place, in the top layer, or into its container. Without
// top layer support, it goes to the body. Popups inside inherit the container.
function renderPopup(element: React.ReactElement, container: PopupContainer) {
  return <Popup element={element} container={container} />
}

function Popup({
  element,
  container,
}: {
  element: React.ReactElement
  container: PopupContainer
}) {
  const target = portalTarget(container)
  const [tree] = React.useState(followTree)
  // A tree rendered hidden attaches no refs and runs no layout effects, but
  // insertion effects run once the portal appended the popup, so the popup is
  // found in its container and hides unless its tree shows.
  React.useInsertionEffect(() => {
    if (target) {
      tree.placed(target)
    }
  }, [tree, target])
  // A part's element carries the part's ref in its props, joined here by the one that follows the tree.
  const part = element as React.ReactElement<{ ref?: React.Ref<unknown> }>
  const tracked = React.cloneElement(part, {
    ref: mergeRefs(part.props.ref ?? null, tree.track),
  })
  const content = container ? (
    <InheritedContainer value={container}>{tracked}</InheritedContainer>
  ) : (
    tracked
  )
  return (
    <>
      <TreeEffect tree={tree} target={target} />
      {target ? React.createPortal(content, target) : content}
    </>
  )
}

// Hides a popup with the tree it renders in, like a hidden <Activity> or a
// Suspense fallback, and shows it again with the tree, so a popup in the top
// layer never stays shown and focused over what replaced its tree.
function followTree() {
  // The popup's elements: what the portal appended, and the element its ref
  // gets. A render can add elements of its own around the popup's.
  let els: HTMLElement[] = []
  let isShown = false
  let show: (() => void) | undefined
  let lastBefore: ChildNode | null = null
  // A microtask later, so a cleanup and run again in one go don't count.
  const hideLater = () =>
    queueMicrotask(() => {
      if (isShown || show) {
        return
      }
      const shows = els.filter((el) => el.isConnected).map(hide)
      if (shows.length) {
        show = () => shows.forEach((run) => run())
      }
    })
  const track = (next: unknown) => {
    if (next instanceof HTMLElement && !els.includes(next)) {
      els = [...els.filter((el) => el.isConnected), next]
    }
  }
  return {
    // The ref for the popup's element. Octane lets go of it while the tree is hidden, so it's kept.
    track,
    // Notes the container's last node before the portal appends the popup to it.
    placing(target: Element | DocumentFragment) {
      lastBefore = target.lastChild
    },
    // The nodes the portal appended after that one, if the popup rendered
    // any. A render that waits a commit to render an element adds none, and
    // the last node then belongs to someone else. They hide unless the tree shows.
    placed(target: Element | DocumentFragment) {
      if (target.lastChild === lastBefore) {
        return
      }
      // A node that left in the same commit no longer marks where they start, so the last one stands for them.
      const first = !lastBefore
        ? target.firstChild
        : lastBefore.parentNode === target
          ? lastBefore.nextSibling
          : target.lastChild
      for (let node = first; node; node = node.nextSibling) {
        track(node)
      }
      if (!isShown) {
        hideLater()
      }
    },
    shown() {
      isShown = true
      show?.()
      show = undefined
    },
    hidden() {
      isShown = false
      hideLater()
    },
  }
}

// Tells the follower when the tree shows or hides. A component before the
// popup, since effects run in tree order, so the popup shows before its parts
// bind or take focus, and `placing` notes the container before the portal.
function TreeEffect({
  tree,
  target,
}: {
  tree: ReturnType<typeof followTree>
  target: Element | DocumentFragment | null
}) {
  React.useInsertionEffect(() => {
    if (target) {
      tree.placing(target)
    }
  }, [tree, target])
  React.useLayoutEffect(() => {
    tree.shown()
    return tree.hidden
  }, [tree])
  return null
}

// Hides an element with `display: none` unless it's hidden already, and takes
// it and its popups out of the top layer. Focus leaves first, or the browser
// moves it back where it was before the popup opened. Returns what shows it.
function hide(el: HTMLElement) {
  const doc = el.ownerDocument
  if (el.contains(doc.activeElement)) {
    ;(doc.activeElement as HTMLElement).blur()
  }
  for (const popover of [
    el,
    ...el.querySelectorAll<HTMLElement>("[popover]"),
  ]) {
    try {
      popover.hidePopover()
    } catch {}
  }
  const { style } = el
  if (style.display === "none") {
    return () => {}
  }
  const value = style.getPropertyValue("display")
  const priority = style.getPropertyPriority("display")
  style.setProperty("display", "none", "important")
  return () => style.setProperty("display", value, priority)
}

/**
 * A popup content's `render`: the content, inside the full-screen viewport a
 * sheet sits in while its `viewport` slot is present: always for a drawer,
 * and for a popup while it presents as a sheet. The viewport is what goes
 * into the top layer. Its attributes are a subset of the content's, so the
 * content's render keeps it current.
 */
function sheetViewport<State>(
  popup: PrimitiveHandle<Primitive>,
  render?: RenderProp<State>
) {
  return (props: Record<string, any>, state: State) => {
    const element = renderElement("div", props, render, state)
    return presentIn(popup, "viewport") ? (
      <div {...slotIn(popup, "viewport", {})}>{element}</div>
    ) : (
      element
    )
  }
}

/**
 * Where an input renders while its popup presents as a sheet: in a header the
 * content renders at its top. The root keeps the header element, the content
 * renders it with `sheetHeader`, and the input renders into it with
 * `inSheetHeader`, so there's one input at a time.
 */
const SheetHeaderContext = /* @__PURE__ */ React.createContext<
  [HTMLElement | null, (header: HTMLElement | null) => void]
>([null, () => {}])

/** The header at the top of a sheet's content, while the popup's `header` slot is present. */
function sheetHeader(
  popup: PrimitiveHandle<Primitive>,
  setHeader: (header: HTMLElement | null) => void
) {
  return presentIn(popup, "header") ? (
    <div {...slotIn(popup, "header", {}, { ref: setHeader })} />
  ) : null
}

/** Renders an input into the sheet's header while there is one. */
function inSheetHeader(
  element: React.ReactElement,
  header: HTMLElement | null
) {
  return header ? React.createPortal(element, header) : element
}

/**
 * A part that can sit outside its component, like a trigger in a table row:
 * its children render with the instance `controller` connects them to, once
 * that one mounts, or else with the nearest instance of `primitive`, and
 * `fallback` renders until there is one. `fallback` is a function, so a
 * connected part never builds it.
 */
function Connected({
  primitive,
  controller,
  fallback,
  children,
}: {
  primitive: Primitive
  controller: object | undefined
  fallback: () => React.ReactNode
  children: React.ReactNode
}) {
  const nearest = useNearest(primitive)
  const handle = useControllerTarget(controller, nearest)
  if (!handle) {
    return fallback()
  }
  // Always in a scope of its own with a controller, so its element stays when
  // that controller's instance takes over from the nearest one.
  return controller ? (
    <HandleScope handle={handle}>{children}</HandleScope>
  ) : (
    children
  )
}

export { useControllerEntry, useControllerTarget } from "./controller-target"

export {
  Connected,
  inSheetHeader,
  type PopupContainer,
  renderPopup,
  sheetHeader,
  SheetHeaderContext,
  sheetViewport,
  useOwnContainer,
  usePopupContainer,
}
