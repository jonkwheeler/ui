# Octane expert: decisions

What's already decided for `@ui-sdk/octane`, so a review doesn't raise it again.

Last reviewed: `45ab232b` (2026-11-19, the spike: the shared layer plus Menu, Select, Combobox, Tree and Popover).

Mirrors `packages/react` at `b4dbe882`. Each upstream commit after it that touches a file Octane has ported, or a ported component's React fixture, is ported too, and this line moves to it. Commits that need nothing are listed below.

Upstream commits with nothing to port:

- `c0a383f9` (#501): resolves React's Flight lazy placeholder in `render` elements. Octane has no Server Components, and its own `lazy()` returns an ordinary component, so `cloneElement` already works.
- `92653572` (#675): empties `followTree`'s list of detached elements once a popup unmounts, since React keeps the unmounted fiber, whose ref reaches the list, for a while. Octane keeps nothing of an unmounted component: without the change, a popup's element was collected right after unmount in dev and production compiles. After unmount the list is reachable only through one of its own elements, whose descriptor Octane keeps on the node.
- `9b0f80fc` (#682): `resolveLazy` unwraps every lazy wrapper, since `next dev` nests the Flight placeholder two deep. Octane never ported `resolveLazy` (see `c0a383f9`), so there's nothing to change.

## Settled

- **A port of `@ui-sdk/react`, file for file.** Same names, exports, JSDoc and stability labels, so every file diffs against React's. Octane-only APIs and `.tsrx` stay out.
- **`import * as React from "octane"`.** Kept as `React` so the namespace calls match React's files line for line, as Octane's own Base UI port does.
- **Source ships, not a build.** Every `.tsx` opens with the octane pragma and the package peers on `octane >=0.20.0`. An open lower bound like `@ui-sdk/react`'s `react >=19`, since Octane's 0.x minors break often and a caret range would fail installs. The nightly canary catches what the open range lets through.
- **`<Ctx value>` for every context.** Octane removed `.Provider`. Lowercase locals that hold a context are renamed to a capital before rendering.
- **One `useId` per root.** Per-slot ids derive from it (`${id}-${key}`), since Octane rejects a hook inside a loop.
- **`null` deps on effects that run every commit.** Octane infers omitted deps. The `runBindWrites` effect in `usePrimitive` captures only an import, so omitted deps infer `[]` and only the mount gets flushed: `act-mount.test.tsx`'s later-commit case fails without `null`.
- **`onInput` for core's `input` event and the controlled-value no-op.** Native events go to core as they are.
- **`propNames`, `booleans` and `styleObject` stay.** A style string would replace the inline styles core writes itself.
- **Hooks never inside JSX children.** Six sites in `menu`, `tree` and `combobox`, plus `Field` and `FieldSet`, call `usePart` into a `const` first. See "Known and open" for why.
- **`descriptorChildren` on `Menu`, `Select`, `Combobox` and `TreeItem`.** As a top-level `const` with a named import, the only form the compiler reads. Not on `Field`: it clones its `render` prop, and props keep descriptors.
- **`isRenderFunction(children)`, never `typeof children === "function"`.** On Octane's production compile path, children like text written inside a `.map()` (`<Part>Tip {tip}</Part>`) arrive as a compiled children block, a function that isn't a render function of state. Calling it crashed the `forms` and `tooltips-perf` fixtures (`reading 'block'`). Vitest compiles the dev path, so only built-playground specs catch it. The helper in `render-element.ts` adds `!isChildrenBlock(children)`.
- **Children typed `{} | null | fn`.** Octane's `ReactNode` is `unknown`, so `ReactNode | fn` would erase the function's state type.
- **`useState` destructured before passing on.** It returns three items in Octane.
- **No `Profiler` in fixtures.** Only React's spec reads the commit counter it fed.
- **`shimMissingExports` for the Octane server bundle only** (`apps/playground/ssr-plugin.ts`). Every `octane.tsx` fixture exports `mount`, which imports `createRoot`, and `octane/server` has no `createRoot`. The server never calls `mount`, so the shim's `undefined` is never read; splitting `mount` out of every fixture would diverge them from React's.
- **`requireDirective` in the shared playground.** Octane's Vite plugin has no include option, and without it would compile every `.tsx`, React's and Solid's fixtures included.

- **`octane-portal` leaves out `menu.spec`'s shadow-root click test.** With the trigger moved into a shadow root and the content portaled to `#portal-root` outside it, the content's `aria-labelledby` can't reach the trigger, so the menu has no name and `getByRole("menu", { name: "File" })` finds nothing. The menu does open and stay open. Vue's portaled menu is unnamed the same way; no upstream project runs the pair, since React skips the test and only React has a portal project.

## Unit tests dropped from React's suite

`packages/octane/test` ports every React test file. These cases don't apply to Octane:

- `lifecycle`: "StrictMode's thrown-away instance is never observed, so scope and secrets hold", "StrictMode's thrown-away TriggerMenu never follows the editor" and "an open dialog rendered into a container stays shown through StrictMode's second run of its effects". Octane's `StrictMode` is a pass-through, so no render is thrown away and no effect runs twice.
- `lazy-render`: "a part renders a render element inside two lazy wrappers". That nesting is the Flight client's, and Octane has no Server Components.

`value-wrapper-strict-mode` keeps its file but tests a hide and show through `<Activity>`, the unbind and rebind Octane does have.

## Known and open (don't report again, check whether fixed)

- **Octane miscompiles a hook inside JSX children** (0.20.0). `<Ctx value={v}>{useHook()}</Ctx>` runs the hook in a deferred children body: after the first render its effects disconnect and its state updates never show, with no diagnostic. Repro: a `useCounter` hook rendered inline stays at `0` after two clicks, and its layout effect cleans up and never sets up again; the hoisted form counts to `2`. The port hoists every such call. Report to octanejs/octane; remove nothing until a fixed release ships.
- **`combobox.items` "a content with no children renders items that arrive while it's open" skips on Octane.** The spec gates it with `!framework.startsWith("react")`, although the Octane fixture keeps `?late`. Widening the gate belongs to the shared-spec helper, not a spec edit here.
- **`menu.spec` "moving from a submenu trigger straight to another item highlights that item" is load-sensitive.** It failed once at load average 10 to 22 (the item highlighted but didn't take focus), then passed 3 of 3 against a served build.
- **Modal side-effect specs are load-sensitive.** `menu.enhancements` "with modal true, the page scroll is locked and restored exactly" and `popover.enhancements` "modal popovers make the rest of the page inert…" and "live regions keep announcing…" read `inert` and `overflow` right after the popup shows. They failed under full-suite load on Octane and on React, and passed 10 of 10 in isolation on both. Not an Octane gap.
- **The playground's client build takes about 2s longer** (median 8.8s against 6.6s) with Octane's plugin loaded, which checks every module for the pragma.
- **`popup.tsx`'s tree-following tracks nothing for a popup that mounts visible.** Octane's portal appends its nodes before `TreeEffect`'s insertion effect runs, so `placed` sees no change and the list holds only the element its ref gave. A portaled popup inside a hidden `<Activity>` still ends up `display: none`, so nothing visible breaks. Recheck with `cached-page`.
- **Octane throws `props is not defined` from `<Activity>` children** (0.20.0). A component whose first parameter isn't an identifier named `props` (destructured, or none), rendering `<Activity>` with a component or `{expression}` child, compiles a body that reads `props`. `function A() { return <Activity mode="visible"><Child /></Activity> }` throws; `function C(props) {...}` works. The adapter never renders `<Activity>`, so only app code hits it; `lifecycle.test.tsx` and `concurrent.test.tsx` use a `props` parameter. Report to octanejs/octane.
- **Octane's scoped children resolver pins a disposed block** (0.20.0, unchanged on `main`). `createScopedResolver` (`runtime/context.ts` on Octane `main`, ~line 836) stores `resolvedScope = scope` on the first read even when there were no context reads, and its fast path never reads it again. So an element with expression children, made once by a parent that outlives a popup (`<MenuItem>{item.label}</MenuItem>` under a mounted Menu), keeps the first-opened popup's subtree alive. `leaks.spec`'s 200-open check fails for menu, combobox and autocomplete (4 to 8 detached parts). The fix is `resolvedScope = nextReads === null ? null : scope`; patched in the browser, all three stay flat. `tests/fixtures.ts` lists the three as Octane known gaps, expected to fail, until a release ships the fix. Report and PR to octanejs/octane.
- **Octane drops `/* @__PURE__ */` annotations** (0.20.0). `const SelectItemIcon = /* @__PURE__ */ notLabel(...)` compiles to a bare call, so every select and combobox page keeps core's `lists/item-icon`, in `pnpm size` and in apps alike. The annotation goes whatever the call's argument is. `scripts/size.mjs` leaves Octane out of `minimalChecked` until a release keeps it. Report to octanejs/octane.
- **Octane hydration keeps mismatched ids without a warning.** With a different `identifierPrefix`, the client computes new ids and the DOM keeps the server's. SSR fixtures must hydrate with the same prefix the server used.
- **Pinned to `octane` 0.20.0.** 0.21.0 is the newest release old enough for `minimumReleaseAge` from 2026-11-19T22:44Z; bump then and recheck.

## Revisit

- If a later Octane release proves imported helpers memoizable, `readIn`, `presentIn` and `slotIn` reads may go stale in production builds. The spike's `octane.spike` spec and a production-build run catch it.
