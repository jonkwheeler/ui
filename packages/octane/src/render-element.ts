import * as React from "octane"

// Whether a handler marked its event handled. Handlers also take values, like
// an `onOpenChange` its `open`.
function prevented(event: unknown) {
  return !!(event as { defaultPrevented?: boolean } | undefined)
    ?.defaultPrevented
}

// Octane compiles some children, like text written in a list in a production
// build, into a block that is a function but not a render function of state.
// check-code: allow return-type a type predicate narrows children for callers.
function isRenderFunction<T>(
  children: T
): children is Extract<T, (...args: any[]) => unknown> {
  return typeof children === "function" && !React.isChildrenBlock(children)
}

// Parts render the same few styles again and again, so each text is parsed
// once, into an object Octane only reads. The cache empties when it fills,
// since a drag writes a new position on every move.
const styles = new Map<string, Record<string, string>>()

function styleObject(css: string) {
  let style = styles.get(css)
  if (style) {
    return style
  }
  style = {}
  for (const declaration of css.split(";")) {
    const index = declaration.indexOf(":")
    if (index === -1) {
      continue
    }
    const name = declaration.slice(0, index).trim()
    style[
      name.startsWith("--")
        ? name
        : name.replace(/-(\w)/g, (_, char: string) => char.toUpperCase())
    ] = declaration.slice(index + 1).trim()
  }
  if (styles.size >= 500) {
    styles.clear()
  }
  styles.set(css, style)
  return style
}

/**
 * Later props win, except where they combine: className, style and ref, and
 * event handlers, where the later one runs first and can call
 * preventDefault() to skip the earlier. Undefined never replaces a value.
 * @stable
 */
function mergeProps(...sources: Record<string, any>[]) {
  const result: Record<string, any> = {}
  for (const source of sources) {
    for (const key in source) {
      const value = source[key]
      if (value === undefined) {
        continue
      }
      const earlier = result[key]
      if (earlier === undefined) {
        result[key] = value
      } else if (key === "className" && earlier) {
        // Octane composes an array of class values, like clsx.
        result.className =
          typeof earlier === "string" && typeof value === "string"
            ? `${earlier} ${value}`
            : [earlier, value]
      } else if (key === "style" && earlier) {
        result.style = mergeStyles(earlier, value)
      } else if (key === "ref" && earlier) {
        result.ref = mergeRefs(earlier, value)
      } else if (
        /^on[A-Z]/.test(key) &&
        typeof earlier === "function" &&
        typeof value === "function"
      ) {
        result[key] = (...args: unknown[]) => {
          value(...args)
          if (!prevented(args[0])) {
            earlier(...args)
          }
        }
      } else {
        result[key] = value
      }
    }
  }
  return result
}

// Styles merge, and a function of the part's state stays a function, so a
// part's own inline styles never drop a user's style function. Octane also
// takes a style as text.
function mergeStyles(earlier: unknown, later: unknown) {
  const resolve = (style: unknown, state?: unknown) => {
    const value = typeof style === "function" ? style(state) : style
    return typeof value === "string" ? styleObject(value) : value
  }
  if (typeof earlier !== "function" && typeof later !== "function") {
    return { ...resolve(earlier), ...resolve(later) }
  }
  return (state: unknown) => ({
    ...resolve(earlier, state),
    ...resolve(later, state),
  })
}

const mergedRefs = new WeakMap<
  object,
  WeakMap<object, (el: unknown) => () => void>
>()

function setRef(ref: React.Ref<unknown>, el: unknown) {
  if (typeof ref === "function") {
    return ref(el)
  }
  if (ref) {
    ;(ref as React.RefObject<unknown>).current = el
  }
}

/**
 * Stable for the same pair of refs, so Octane does not detach and reattach.
 * Octane runs the cleanup it returns instead of passing null, so each ref's
 * own cleanup runs, and a ref without one gets null.
 */
function mergeRefs(a: React.Ref<unknown>, b: React.Ref<unknown>) {
  if (!a || !b) {
    return a ?? b
  }
  let inner = mergedRefs.get(a)
  if (!inner) {
    mergedRefs.set(a, (inner = new WeakMap()))
  }
  let merged = inner.get(b)
  if (!merged) {
    // Octane also takes an array of refs.
    const refs = [a, b].flat() as React.Ref<unknown>[]
    merged = (el: unknown) => {
      const cleanups = refs.map((ref) => setRef(ref, el))
      return () =>
        cleanups.forEach((cleanup, index) =>
          typeof cleanup === "function" ? cleanup() : setRef(refs[index], null)
        )
    }
    inner.set(b, merged)
  }
  return merged
}

/**
 * A part's `render` prop: an element that receives the part's props, or a
 * function of the props and the part's state that returns one.
 * @stable
 */
type RenderProp<State = {}> =
  | React.ReactElement<any>
  | ((props: Record<string, any>, state: State) => React.ReactElement)

/**
 * Renders an element with no primitive behind it that takes a `render` prop,
 * like a wrapper of your own: the tag, or the element or function passed as
 * `render`, which gets the props. Class name, style and children functions
 * resolve against `state`. Parts of a primitive use `createParts` or `usePart`.
 *
 * @example
 * function Card({ render, ...props }: PartProps<"div">) {
 *   return renderElement("div", { ...props, "data-card": "" }, render)
 * }
 * @stable
 */
function renderElement<State>(
  tag: string,
  props: Record<string, any>,
  render?: RenderProp<State>,
  state: State = {} as State
) {
  if (typeof props.className === "function") {
    props = { ...props, className: props.className(state) }
  }
  if (typeof props.style === "function") {
    props = { ...props, style: props.style(state) }
  }
  if (isRenderFunction(props.children)) {
    props = { ...props, children: props.children(state) }
  }
  if (typeof render === "function") {
    return render(props, state)
  }
  if (render) {
    // The element's own props merge in: its handlers run before the part's.
    return React.cloneElement(
      render,
      mergeProps(props, render.props as Record<string, any>)
    )
  }
  return React.createElement(tag, props)
}

export {
  isRenderFunction,
  mergeProps,
  mergeRefs,
  renderElement,
  styleObject,
  type RenderProp,
}
