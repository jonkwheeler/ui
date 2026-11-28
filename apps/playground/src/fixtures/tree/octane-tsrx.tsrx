import {
  createTreeController,
  Tree,
  TreeGroup,
  TreeItem,
  TreeItemCheckbox,
  TreeItemIndicator,
  TreeItemLabel,
} from "@ui-sdk/octane/tree"
import { createRoot, useState } from "octane"
import { treeOptions } from "tests/fixtures/page.ts"
import {
  describeTree,
  treeFixture,
  type TreeFixtureItem,
} from "tests/fixtures/tree.ts"

const controller = createTreeController()

function Items({
  items,
  checkable,
}: {
  items: TreeFixtureItem[]
  checkable: boolean
}) @{
  <>
    @for (const item of items; key item.value) {
      <FileItem item={item} checkable={checkable} />
    }
  </>
}

function FileItem({
  item,
  checkable,
}: {
  item: TreeFixtureItem
  checkable: boolean
}) @{
  <TreeItem className="tree-item" value={item.value} disabled={item.disabled}>
    @if (item.children) {
      <TreeItemIndicator className="tree-indicator">▸</TreeItemIndicator>
    }
    @if (checkable) {
      <TreeItemCheckbox className="tree-checkbox" />
    }
    <TreeItemLabel
      className="tree-label"
      render={item.href ? <a href={item.href} /> : undefined}
    >
      {item.label as string}
    </TreeItemLabel>
    @if (item.children) {
      <TreeGroup className="tree-group">
        <Items items={item.children} checkable={checkable} />
      </TreeGroup>
    }
  </TreeItem>
}

function Fixture() @{
  const [action, setAction] = useState("")
  const { cancel, ...options } = treeOptions()

  <div class="fixture">
    <button>Before</button>
    <Tree
      className="tree"
      aria-label={treeFixture.label}
      controller={controller}
      {...options}
      onValueChange={(value) => setAction(describeTree("selected", value))}
      onExpandedChange={(expanded, details) => {
        if (
          cancel &&
          expanded.includes(cancel) &&
          !controller.isExpanded(cancel)
        ) {
          return details.cancel()
        }
        setAction(describeTree("expanded", expanded))
      }}
      onCheckedChange={(checked) => setAction(describeTree("checked", checked))}
      onAction={(value) => setAction(describeTree("action", value))}
    >
      <Items items={treeFixture.items} checkable={options.checkable} />
    </Tree>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
    <button onClick={() => controller.expandAll()}>Expand all</button>
    <button onClick={() => controller.collapseAll()}>Collapse all</button>
    <button onClick={() => controller.reveal("dialog.tsx")}>
      Reveal dialog
    </button>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, Items, mount }
