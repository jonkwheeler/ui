import { Tree, TreeGroup, TreeItem, TreeItemLabel } from "@ui-sdk/octane/tree"
import { createRoot, useState } from "octane"

// The same branch twice, composed and as data, whose children grow on "Add file".
function Fixture() @{
  const [files, setFiles] = useState(["a.ts", "b.ts"])
  const addFile = () =>
    setFiles((files) => [...files, `${"abcdefgh"[files.length]}.ts`])

  <div class="fixture">
    <button>Before</button>
    <Tree className="tree" aria-label="Composed">
      <TreeItem className="tree-item" value="src">
        <TreeItemLabel className="tree-label">src</TreeItemLabel>
        <TreeGroup className="tree-group">
          @for (const file of files; key file) {
            <TreeItem className="tree-item" value={file}>
              <TreeItemLabel className="tree-label">
                {file as string}
              </TreeItemLabel>
            </TreeItem>
          }
        </TreeGroup>
      </TreeItem>
    </Tree>
    <Tree
      className="tree"
      aria-label="Data"
      items={[
        {
          value: "src",
          label: "src",
          children: files.map((file) => ({ value: file, label: file })),
        },
      ]}
    />
    <button onClick={addFile}>Add file</button>
    <button>After</button>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
