import { Tree, TreeGroup, TreeItem, TreeItemLabel } from "@ui-sdk/octane/tree"
import { createRoot } from "octane"
import { mountWhenAsked, perfSize } from "tests/fixtures/perf.ts"

// A tree of N folders of two files each, like a long file explorer, for the
// count gates. Every folder starts collapsed.
const folders = Array.from({ length: perfSize(200) }, (_, index) => index + 1)

function Folder({ n }: { n: number }) @{
  <TreeItem className="tree-item" value={`folder-${n}`}>
    <TreeItemLabel className="tree-label">{`Folder ${n}`}</TreeItemLabel>
    <TreeGroup className="tree-group">
      <TreeItem className="tree-item" value={`folder-${n}/a`}>
        <TreeItemLabel className="tree-label">{`File ${n}a`}</TreeItemLabel>
      </TreeItem>
      <TreeItem className="tree-item" value={`folder-${n}/b`}>
        <TreeItemLabel className="tree-label">{`File ${n}b`}</TreeItemLabel>
      </TreeItem>
    </TreeGroup>
  </TreeItem>
}

function Fixture() @{
  <div
    class="fixture"
    style={{ flexDirection: "column", alignItems: "start" }}
  >
    <button>Before</button>
    <Tree className="tree" aria-label="Folders">
      @for (const n of folders; key n) {
        <Folder n={n} />
      }
    </Tree>
    <button>After</button>
  </div>
}

function mount(root: HTMLElement) {
  mountWhenAsked(root, (target) => createRoot(target).render(<Fixture />))
}

export { mount }
