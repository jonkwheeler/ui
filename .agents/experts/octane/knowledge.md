# Octane expert: knowledge

What the Octane expert knows. Part 1 is Octane itself, part 2 is how `@ui-sdk/octane` is built, part 3 is the checklist a review walks. Pinned to what the repo installs: `octane` 0.20.0 with its exact peer `@tsrx/oxc` 0.23.0 (peer range `>=0.20.0`). Octane ships breaking 0.x minors often; when one changes an API below, update this file.

Last checked: 2026-11-20, against `node_modules/octane` 0.20.0 (`dist/*.d.ts`) and Octane's `docs/differences-from-react.md` on `main` (0.21.0).

## 1. Octane, as its docs write it

Octane has React's component and hooks API and compiles it to direct DOM code. React habits that read differently:

| React                                   | Octane                                                                                                                       |
| --------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| Hooks keep call order                   | Hooks are keyed by call site. A hook inside a plain `for`/`while` loop is a compile error; `useId()` per key needs one call. |
| Omitted deps array runs every render    | Omitted deps are inferred from what the callback captures. `null` means every render; `[]` means once.                       |
| `Context.Provider`                      | Removed. The context is the provider: `<Ctx value={...}>`. A lowercase local like `context` compiles as a host element.      |
| `onChange` per keystroke                | `onInput` per edit; `onChange` is the native `change` on commit. Checkbox, radio and select keep `onChange`.                 |
| Synthetic events, `event.nativeEvent`   | Handlers get the native `Event`. No `nativeEvent`, no `isDefaultPrevented()`; read `event.defaultPrevented`.                 |
| `react-dom` `createPortal`, `flushSync` | Both come from `octane`.                                                                                                     |
| `StrictMode` double-invokes             | `StrictMode` is a pass-through. No double render, no effect replay.                                                          |
| `Profiler`, `forwardRef`, `createRef`   | Not implemented. Refs are props; callback, object and array refs all work, and a callback ref may return a cleanup.          |
| `style` object, `className` string      | Also `style` as text, `className` as clsx-style class values, and DOM spellings like `autocomplete` beside `autoComplete`.   |
| Server Components, `"use client"`       | No Server Components. The directive means nothing.                                                                           |

### Rendering and memoization

- Production builds memoize template regions and cache eligible `const` declarations keyed on the inputs they can see. The docs say an imported helper is "taken at its word". In 0.20.0 that applies only to imports with a memo proof (`isCompilerMemoImport`): `readIn(handle, () => ...)` compiles to a plain call, and the spike's built, production and dev runs gave identical results. If a later Octane version starts proving these imports, a `let` binding, a member call, or a witnessed snapshot input keeps the read live.
- Non-literal props and children of JSX built in one place and rendered in another are read when the element renders, not when it's built.
- **A hook called inside JSX children breaks.** In 0.20.0, `<Ctx value={v}>{usePart(...)}</Ctx>` compiles the call into the element's deferred children body. After the first render the hook isn't reached in its scope, so its effects are disconnected and its state updates never show, with no diagnostic. Call the hook into a `const` before `return`. A hook in a JSX prop (`<Part field={useFieldControl()} />`) compiles inline in the render body and is fine.
- Vite chooses the production compile path from `vite build`, not `NODE_ENV`, so a built playground and the dev server compile differently.

### Types

- `ReactNode` is `unknown`, so a union like `ReactNode | ((state) => ReactNode)` collapses to `unknown` and the function loses its parameter types. Write children that may be functions as `{} | null | ((state: State) => ReactNode)`.
- `ReactElement<P>` defaults `P` to `any`, and `ElementDescriptor<P>` uses `P` in its `type`, so `ReactElement<{ href: string }>` isn't assignable to `ReactElement<Record<string, any>>`. Code that takes any element types it `ReactElement<any>`.
- `useState` and `useReducer` return `[value, set, get]`. Destructure before passing the pair where a two-item tuple is typed.

### Children

- JSX in `.tsx` stays inspectable descriptors, so `Children`, `cloneElement` and `isValidElement` work as in React.
- Children written inside a `.tsrx` `@{...}` template arrive as compiled render bodies. A component that inspects children must be wrapped in `descriptorChildren(...)` to receive descriptors instead.
- In a production build, children like text with an expression inside a `.map()` can arrive as a compiled children block: a function, but not a render function. Test a function child with `isChildrenBlock` before calling it. The dev path (and so Vitest) keeps descriptors, so only a built playground shows it.
- The compiler only recognizes `const X = descriptorChildren(function X() {...})` at the top level, with `descriptorChildren` as a named import from `octane`. `React.descriptorChildren(...)` typechecks and runs but is silently ignored. The marker changes nothing for `.tsx` callers, so no `.tsx` spec can catch it missing.

### Server rendering and hydration

- `octane/server` `renderToString(Component, props?, options?)` returns `{ html, css }`, and takes an element in place of the component. Server code is compiled separately from client code, so a module graph compiled for the browser can't render on the server.
- `hydrateRoot(container, Component, props?, options?)` takes the component, or an element. `useId` matches across server and client when both use the same `identifierPrefix`; `createRoot` adds an `r<n>-` namespace.
- Mismatches behave as in React 19: attributes aren't patched, a structural or text mismatch re-renders the nearest boundary on the client, and `onRecoverableError` fires once per boundary.

### Compiler ownership

- Octane's Vite plugin has no include option. With `requireDirective: true`, a project `.tsx` is Octane's only when it opens with `/** @jsxImportSource octane */`. Installed and linked packages are Octane's when their `package.json` lists `octane` as a dependency or peer.
- Octane compiles `.tsx` and `.tsrx` fully, never `.jsx`. Published packages ship source; compiled output is tied to Octane's internal runtime and differs between client and server.

## 2. How `@ui-sdk/octane` is built

- It's a port of `@ui-sdk/react`: the same file names, exports and `createParts` / `usePrimitive` / `usePart` contract. Diff a file against `packages/react/src` before reasoning about it from scratch.
- Every `.tsx` file opens with the `@jsxImportSource octane` pragma, for the compiler and for consumers whose tsconfig targets React.
- Core's `input` handler maps to `onInput`. Native events go straight to core.
- `propNames`, `booleans` and `styleObject` stay: core writes some inline styles itself, and a style string would replace them.
- `mergeProps`, `mergeRefs` and `yieldToAuthor`'s check take every prop shape Octane accepts: a style as text, class values, ref arrays and DOM attribute spellings.
- Effects that must run every commit, such as the one that flushes `runBindWrites`, pass `null` deps.
- Parts that read their children are wrapped in `descriptorChildren`: the roots that call `hasChild` or `learnLabels` (`Menu`, `Select`, `Combobox`, `TreeItem`, `TriggerMenu`, `Autocomplete`, `Command`), and the item texts that mark matches (`SelectItemText`, `ComboboxItemText`, `CommandItemText`, `AutocompleteItemText`). `Field` clones its `render` prop, not its children, and props keep descriptors, so it needs no marker.
- `usePart` and other hooks are called into a `const` before `return`, never inside JSX children.
- The package ships `.tsx` and `.ts` source with `octane` as a peer and no build step of its own.
- Octane's synchronous `act()` stays open while it drains, so work a microtask later never warns. The warning is off by default; `setIsOctaneActEnvironment(true)` from `octane` turns it on. A test that checks work lands inside `act()` compares the container before and after instead of waiting for a warning.
- A React unit test ports with the pragma, `act` and `createRoot` (or `renderToString` from `octane/server`) from `octane`, no `IS_REACT_ACT_ENVIRONMENT`, and no `StrictMode` expectations. Server-render tests are `*-ssr.test.tsx`, which the package's `ssr` Vitest project compiles for the server.
- A fix that lands in core reaches Octane without an adapter change. Port React's doc comments and tests so the files still diff.

## 3. Review checklist

- [ ] No `.Provider`, no `nativeEvent`, no `react` or `react-dom` import.
- [ ] No hook call inside a plain loop. Per-key ids derive from one `useId`.
- [ ] No hook call inside JSX children (`{usePart(...)}`). Hoist it to a `const` before `return`.
- [ ] Every `useEffect` / `useLayoutEffect` without a deps array is meant to infer; one that must run every commit passes `null`.
- [ ] Text inputs listen with `onInput`; a controlled value without a handler doesn't warn.
- [ ] A helper call that reads live instance state through a stable handle is checked on a built playground, not only the dev server.
- [ ] A new part that inspects its children is wrapped in `descriptorChildren`, as a top-level `const` with a named import.
- [ ] Code that merges or reads author props handles a style as text, class values, ref arrays and DOM attribute spellings.
- [ ] Children that may be functions are typed `{} | null | fn`, not `ReactNode | fn`, and called only through `isRenderFunction`.
- [ ] A new `.tsx` file opens with the octane pragma.
