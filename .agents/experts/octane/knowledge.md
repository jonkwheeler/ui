# Octane expert: knowledge

What the Octane expert knows. Part 1 is Octane itself, part 2 is how `@ui-sdk/octane` is built, part 3 is the checklist a review walks. Pinned to what the repo installs: `octane` 0.27.0 with its exact peer `@tsrx/oxc` 0.24.0 (peer range `>=0.20.0`). Octane ships breaking 0.x minors often; when one changes an API below, update this file.

Last checked: 2026-11-27, against `node_modules/octane` 0.27.0 (`dist/*.d.ts`), Octane's `docs/differences-from-react.md` at `octane@0.27.0`, and its changelog from 0.21.0 to 0.27.0. Octane's `docs/differences-from-react.md` is in the Octane repo (octanejs/octane), not the npm package, which ships only a README.

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

- Production builds memoize template regions and cache eligible `const` declarations keyed on the inputs they can see. The docs say an imported helper is "taken at its word". Through 0.27.0 that applies only to imports with a memo proof (`isCompilerMemoImport`): `readIn(handle, () => ...)` compiles to a plain call, and the spike's built, production and dev runs gave identical results. If a later Octane version starts proving these imports, a `let` binding, a member call, or a witnessed snapshot input keeps the read live.
- Non-literal props and children of JSX built in one place and rendered in another are read when the element renders, not when it's built.
- **A hook called inside JSX children breaks.** Through 0.27.0, `<Ctx value={v}>{usePart(...)}</Ctx>` compiles the call into the element's deferred children body. After the first render the hook isn't reached in its scope, so its effects are disconnected and its state updates never show, with no diagnostic. Call the hook into a `const` before `return`. Hoist everywhere: a dev-compile probe counted a hook inside a plain fragment's children (`<>{useHook()}</>`) correctly, but production wasn't checked, so ported tests that write it that way pass on the dev compile only by that observation.
- An uncaught error thrown by an effect or a ref callback never leaves `act()`. It goes to the root's `onUncaughtError`, or `console.error` without one. An effect's error unmounts the tree as in React, but through 0.27.0 a ref callback's leaves it mounted. React 19 unmounts for both, and its `act()` rethrows.
- Vite chooses the production compile path from `vite build`, not `NODE_ENV`, so a built playground and the dev server compile differently.
- Hydration doesn't yield (0.27.0): `hydrateRoot` inside `startTransition` has rendered every component before it returns. A React test that relies on a time slice, with a component that busy-waits past 5ms, passes on Octane whether or not the bug is there.
- A Suspense boundary the server couldn't finish renders on the client in the same hydration pass, in tree order, before the siblings after it (0.27.0). React renders it after the rest hydrates, so a React test that relies on a later sibling binding first passes on Octane whether or not the bug is there.
- A commit attaches every ref before it runs any layout effect (0.27.0, seen on the dev compile). React runs each component's layout effects with its refs, in tree order, so a React test that relies on an earlier sibling's layout effect running before a later sibling's ref binds passes on Octane whether or not the bug is there.
- Components updated together commit in the order their updates were scheduled (since 0.23.1), so siblings that read one store attach refs and run layout effects in tree order, even when one sits inside an `@if` arm.

### Types

- `ReactNode` is `unknown`, so a union like `ReactNode | ((state) => ReactNode)` collapses to `unknown` and the function loses its parameter types. Write children that may be functions as `{} | null | ((state: State) => ReactNode)`.
- `ReactElement<P>` defaults `P` to `any`, and `ElementDescriptor<P>` uses `P` in its `type`, so `ReactElement<{ href: string }>` isn't assignable to `ReactElement<Record<string, any>>`. Code that takes any element types it `ReactElement<any>`.
- `useState` and `useReducer` return `[value, set, get]`. Destructure before passing the pair where a two-item tuple is typed.

### Children

- JSX in `.tsx` stays inspectable descriptors, so `Children`, `cloneElement` and `isValidElement` work as in React.
- Children written inside a `.tsrx` `@{...}` template arrive as compiled render bodies. A component that inspects children must be wrapped in `descriptorChildren(...)` to receive descriptors instead.
- Under a marked part, a render-only `@if` arm or `@for` row arrives as the elements it renders, as `{cond && <X />}` and a keyed `.map()` do (since 0.24.0). An arm or row with setup statements, `@empty`, `@for await`, `@switch` or `@try` still arrives as one element that can't be inspected.
- In a production build, children like text with an expression inside a `.map()` can arrive as a compiled children block: a function, but not a render function. Test a function child with `isChildrenBlock` before calling it. The dev path (and so Vitest) keeps descriptors, so only a built playground shows it.
- The compiler only recognizes `const X = descriptorChildren(function X() {...})` at the top level, with `descriptorChildren` as a named import from `octane`. `React.descriptorChildren(...)` typechecks and runs but is silently ignored. The marker changes nothing for `.tsx` callers, so no `.tsx` spec can catch it missing.

### Server rendering and hydration

- `octane/server` `renderToString(Component, props?, options?)` returns `{ html, css }`, and takes an element in place of the component. Server code is compiled separately from client code, so a module graph compiled for the browser can't render on the server.
- `hydrateRoot(container, Component, props?, options?)` takes the component, or an element. `useId` matches across server and client when both use the same `identifierPrefix`; `createRoot` adds an `r<n>-` namespace.
- Mismatches behave as in React 19: attributes aren't patched, a structural or text mismatch re-renders the nearest boundary on the client, and `onRecoverableError` fires once per boundary. An attribute mismatch, like an id from another `identifierPrefix`, logs `Octane hydration mismatch` only in a dev compile; a production compile logs nothing.

### Compiler ownership

- Octane's Vite plugin has no include option. With `requireDirective: true`, a project `.tsx` is Octane's only when it opens with `/** @jsxImportSource octane */`. Installed and linked packages are Octane's when their `package.json` lists `octane` as a dependency or peer.
- Octane compiles `.tsx` and `.tsrx` fully, never `.jsx`. Published packages ship source; compiled output is tied to Octane's internal runtime and differs between client and server. Since 0.22.0 it imports its helpers from `octane/internal/client` and `octane/internal/server`, and `octane` and `octane/server` export only public API.
- In `.tsrx`, a `var` inside a nested `@{ … }` block or an `@if`, `@for`, `@switch` or `@try` body is error TSRX2030 (since 0.22.0). Use `const` or `let`.
- A plain `.ts` module in a package Octane owns gets hook slotting only: call-site slots and inferred deps, so the `null`-deps rule applies there too. Nothing in it is memoized.

## 2. How `@ui-sdk/octane` is built

- It's a port of `@ui-sdk/react`: the same file names, exports and `createParts` / `usePrimitive` / `usePart` contract. Diff a file against `packages/react/src` before reasoning about it from scratch.
- Every `.tsx` file opens with the `@jsxImportSource octane` pragma, for the compiler and for consumers whose tsconfig targets React.
- Core's `input` handler maps to `onInput`. Native events go straight to core.
- `propNames`, `booleans` and `styleObject` stay: core writes some inline styles itself, and a style string would replace them.
- `mergeProps`, `mergeRefs` and `yieldToAuthor`'s check take every prop shape Octane accepts: a style as text, class values, ref arrays and DOM attribute spellings.
- Effects that must run every commit, such as the one that flushes `runBindWrites`, pass `null` deps.
- Parts that read their children are wrapped in `descriptorChildren`: the roots that call `hasChild` or `learnLabels` (`Menu`, `Select`, `Combobox`, `TreeItem`, `TriggerMenu`, `Autocomplete`, `Command`), and the item texts that mark matches (`SelectItemText`, `ComboboxItemText`, `CommandItemText`, `AutocompleteItemText`). `Field` clones its `render` prop, not its children, and props keep descriptors, so it needs no marker.
- `usePart` and other hooks are called into a `const` before `return`, never inside JSX children.
- A closed root menu sleeps until it's opened or its `api` is read (#1276), so a part reads what it needs during render from `menu.state`, like `nested`, never `menu.api`. A probe of a closed `<Menu>` with a `MenuContent` found it awake while `MenuContent` read `menu.api.root()`, and asleep with `menu.state.nested`. React's `menu-asleep` test renders the parts with `usePart` alone, so it guards core and not this line.
- In `.tsrx`, a part receives a render function of its state only from an arrow written as its sole child (`{(state) => …}`). A call that returns a function compiles to a children block, which `isRenderFunction` passes over. Octane's `docs/differences-from-react.md` covers this under template children.
- The parts that read their children are the `descriptorChildren` ones above. Their `.tsrx` fixtures write what those parts inspect in render-only `@if` arms and `@for` rows, as for every other part.
- The package ships `.tsx` and `.ts` source with `octane` as a peer and no build step of its own.
- Octane focuses an `autoFocus` control when the commit drains, before a parent's ref binds, as React does.
- Octane's synchronous `act()` stays open while it drains, so work a microtask later never warns. The warning is off by default; React's `globalThis.IS_REACT_ACT_ENVIRONMENT = true` turns it on. `setIsOctaneActEnvironment` moved to `octane/internal/client` in 0.22.0 and isn't API. A test that checks work lands inside `act()` compares the container before and after instead of waiting for a warning.
- A limitation React's `decisions.md` lists applies to Octane too unless Octane's says otherwise, so a commit that removes one from React's (and the other frameworks') closes it for Octane as well.
- A React fixture change lands in both Octane twins, `octane.tsx` and `octane-tsrx.tsrx`, and a `react-ssr.tsx` change in `octane-ssr.tsx`. The `.tsrx` twin imports hooks by name from `octane` rather than through `React.*`, and puts `class` on host elements.
- To check a port of one upstream commit, run the specs of the components it touches on `octane` and `octane-tsrx` against a built playground. For a core change, that's every component whose core uses the changed code (search for it, as for `remember: false` in roving focus), not only the spec the commit edits. For a shared core module the script's Octane plan is a minimum (for `listbox-engine.ts` it names only listbox, though six components use it), so the search is required. A fix that only changes data mode (`items` on the root) also runs `octane-data`. `node scripts/affected-specs.mjs --dry --base <the merge's first parent>` prints the specs a merge reaches, every upstream commit it brings in included. For one of several, apply `git diff <commit>^ <commit>` in a detached worktree at the first parent, link the main checkout's `node_modules` into it, apply the Octane port there too (it can reach components upstream's diff doesn't), and plan with `--base HEAD`. Specs named after a feature, like `item-icon.*`, aren't in a component's pattern: add them when a change reaches what they test. `pnpm test:pr` plans against `origin/main`, which on this fork is the whole branch.
- On a loaded machine, `PLAYGROUND_BUILD=1` can pass Playwright's 60-second server timeout. Build with `pnpm --filter playground build`, serve with `PLAYGROUND_PORT=<port> pnpm --filter playground preview`, and Playwright reuses the server on that port.
- When upstream edits a React test because core changed, the Octane twin fails the same way as soon as the merge lands. Run the twin before porting, to confirm it. For a new React test there's no twin yet: revert the core fix briefly and run the port, to see whether it catches the bug on Octane. If React's own test passes with the whole fix reverted, it guards one part of the fix: revert only that part and run both. When the fix is in the adapter, add the ported test first and watch it fail, then port the fix. When the port passes without the fix and React's fails, keep React's lines and record under Settled why it only guards on Octane.
- A new shared-spec test behind a new URL option passes on Octane without testing anything until both fixture twins read the option. Port the fixtures, then revert the core fix briefly to see the test fail.
- ESLint ignores `packages/octane/test`; `pnpm --filter @ui-sdk/octane typecheck` checks those files.
- A shared spec's React-only skip widens to Octane with `reactApi(framework)` from `tests/fixtures.ts`, with "React and Octane" in its reason. A skip that names projects names each one's Octane counterpart too: `react` is `octane` and `octane-tsrx`, `react-ssr` is `octane-ssr`, and `react-data` is `octane-data`.
- A React fixture's controlled text field (`value` with `onChange`) ports to `value` with `onInput`. Octane restores a controlled field's value after an input event as React does, so a spec that skips every framework but React for that runs on Octane too: without #986's core fix, its spec failed on `octane` and `octane-tsrx` as on `react`. Outside a JSX attribute, type the handler's event `React.FormEvent<T>`, the type Octane's JSX gives `onInput`.
- Octane's `act` resolves to the callback's result, as React's does, so `await act(() => agent.act(…))` ports as written.
- A React unit test ports with the pragma, `act` (for `React.act` too) and `createRoot` (or `renderToString` from `octane/server`) from `octane`, no `IS_REACT_ACT_ENVIRONMENT` line or `// @vitest-environment` comment (the `dom` project runs jsdom, the `ssr` project Node), no `StrictMode` expectations, and no `import * as React` once nothing reads `React.`. Only a test that checks `act()`'s warning sets the global, as `act-mount` does. Server-render tests are `*-ssr.test.tsx`, which the package's `ssr` Vitest project compiles for the server, and take `{ html }` from what `renderToString` returns. A DOM test that hydrates server HTML (React's `renderToString` then `hydrateRoot` in one file) moves its components to a `<name>-app.tsx` module that the test imports for the client and loads through `test/server-html.ts`'s `server.load()` for the server's HTML, as `select-value` does.
- Parts bind in their ref callback, so when core throws while a part binds, the part stays rendered and the error is only reported. A React test that catches such a throw by the tree unmounting, or by `act()` rethrowing, ports with `createRoot(container, { onUncaughtError })` collecting errors and an `expect(errors).toEqual([])`, as `toast-without-resize-observer` does.
- A fix that lands in core reaches Octane without an adapter change. Port React's doc comments and tests so the files still diff.
- A React fix to an adapter file ports line for line, keeping the file's Octane differences, like `Placed` being the context itself. Its `eslint-suppressions.json` entry and its changeset don't: `eslint.config.mjs` runs no React hooks rules on Octane files, and changesets skip private packages.

## 3. Review checklist

- [ ] No `.Provider`, no `nativeEvent`, no `react` or `react-dom` import.
- [ ] No hook call inside a plain loop. Per-key ids derive from one `useId`.
- [ ] No hook call inside JSX children (`{usePart(...)}`). Hoist it to a `const` before `return`.
- [ ] Every `useEffect` / `useLayoutEffect` without a deps array is meant to infer; one that must run every commit passes `null`.
- [ ] Text inputs listen with `onInput`; a controlled value without a handler doesn't warn.
- [ ] A helper call that reads live instance state through a stable handle is checked on a built playground, not only the dev server.
- [ ] A new part that inspects its children is wrapped in `descriptorChildren`, as a top-level `const` with a named import, and its `.tsrx` fixture puts what it inspects only in render-only `@if` arms and `@for` rows: no setup statements, `@empty`, `@switch` or `@try`.
- [ ] Code that merges or reads author props handles a style as text, class values, ref arrays and DOM attribute spellings.
- [ ] Children that may be functions are typed `{} | null | fn`, not `ReactNode | fn`, and called only through `isRenderFunction`.
- [ ] A new `.tsx` file opens with the octane pragma.
