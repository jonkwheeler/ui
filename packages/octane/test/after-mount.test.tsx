/** @jsxImportSource octane */
// Every option and slot prop follows a change after the first render, in
// Octane's own components, as in packages/core/test/after-mount.test.ts.
import * as React from "octane"
import { act, createRoot, type Root } from "octane"
import { afterEach, describe, expect, test } from "vitest"
import {
  baseOptions,
  type Built,
  changesOf,
  idle,
  markupOf,
  partsOf,
  tabStopProblem,
  title,
  withAttribute,
} from "../../core/test/after-mount"
import { cases, type Case } from "../../core/test/after-mount.cases"

Element.prototype.getAnimations ??= () => []

// Every part Octane ships, by its export name.
const components = new Map<
  string,
  React.ComponentType<Record<string, unknown>>
>()
for (const module of Object.values(
  import.meta.glob("../src/*.tsx", { eager: true })
)) {
  for (const [name, value] of Object.entries(
    module as Record<string, unknown>
  )) {
    if (typeof value === "function" && /^[A-Z]/.test(name)) {
      components.set(
        name,
        value as React.ComponentType<Record<string, unknown>>
      )
    }
  }
}

const octaneIds = /:[0-9a-z-]*in-[0-9a-z]+:|mount-\d+/g

// Octane marks where its blocks start and end with comments, which a page
// doesn't show, so they're left out of `pageOf`'s markup.
function pageOf(container: HTMLElement, history?: readonly string[]) {
  const shown = (el: Node) => {
    const copy = el.cloneNode(true)
    const walker = document.createTreeWalker(copy, NodeFilter.SHOW_COMMENT)
    const comments: Node[] = []
    while (walker.nextNode()) {
      comments.push(walker.currentNode)
    }
    comments.forEach((comment) => comment.parentNode!.removeChild(comment))
    return markupOf(copy, history, octaneIds)
  }
  const portaled = [...document.body.children].filter(
    (el) => el !== container && !el.hasAttribute("data-ui-sdk-announcer")
  )
  return [shown(container), ...portaled.map(shown).sort()].join("\n")
}

// Octane takes React's spelling of a few attributes.
const reactName: Record<string, string> = {
  class: "className",
  for: "htmlFor",
  tabindex: "tabIndex",
}

function element(node: Built, key: number): React.ReactNode {
  if (typeof node === "string") {
    return node
  }
  const children = node.children.map(element)
  const props = Object.fromEntries(
    Object.entries(node.props).map(([name, value]) => [
      reactName[name] ?? name,
      value,
    ])
  )
  const type = node.part
    ? components.get(node.part)!
    : (node.tag ?? React.Fragment)
  return React.createElement(
    type,
    node.part || node.tag ? { ...props, key } : { key },
    ...children
  )
}

const tree = (entry: Case, markup: string, options: Record<string, unknown>) =>
  partsOf(entry, markup, options, (name) => components.has(name)).map(element)

let root: Root | undefined
let container: HTMLElement | undefined

async function render(
  entry: Case,
  markup: string,
  options: Record<string, unknown>
) {
  container ??= document.body.appendChild(document.createElement("div"))
  root ??= createRoot(container)
  await act(async () => root!.render(tree(entry, markup, options)))
  await act(idle)
  return container
}

async function unmount() {
  await act(async () => root?.unmount())
  root = undefined
  container = undefined
  document.body.replaceChildren()
}

afterEach(unmount)

for (const entry of cases) {
  describe(entry.name, () => {
    const { changes } = changesOf(entry)
    for (const change of changes) {
      test.skipIf(title(change) in (entry.skip ?? {}))(
        title(change),
        async () => {
          const base = baseOptions(entry, change)
          const markupAt = (value: unknown) =>
            change.kind === "prop"
              ? withAttribute(entry.markup, change, value)
              : entry.markup
          const optionsAt = (value: unknown) =>
            change.kind === "option" ? { ...base, [change.key]: value } : base

          const fresh = await render(
            entry,
            markupAt(change.to),
            optionsAt(change.to)
          )
          const expected = pageOf(fresh, entry.history)
          const freshProblem = tabStopProblem({ root: fresh })
          await unmount()

          const changed = await render(
            entry,
            markupAt(change.from),
            optionsAt(change.from)
          )
          await render(entry, markupAt(change.to), optionsAt(change.to))
          expect(pageOf(changed, entry.history)).toEqual(expected)
          if (entry.history?.includes("stop") && !freshProblem) {
            expect(tabStopProblem({ root: changed })).toBeUndefined()
          }
        }
      )
    }
  })
}
