/** @jsxImportSource octane */
import { Tree, TreeGroup, TreeItem, TreeItemLabel } from "@ui-sdk/octane/tree"
import * as React from "octane"
import { createRoot } from "octane"

// The same branch twice, composed and as data, whose children grow on "Add file".
function Fixture() {
  const [files, setFiles] = React.useState(["a.ts", "b.ts"])
  const addFile = () =>
    setFiles((files) => [...files, `${"abcdefgh"[files.length]}.ts`])
  return (
    <div className="fixture">
      <button>Before</button>
      <Tree className="tree" aria-label="Composed">
        <TreeItem className="tree-item" value="src">
          <TreeItemLabel className="tree-label">src</TreeItemLabel>
          <TreeGroup className="tree-group">
            {files.map((file) => (
              <TreeItem key={file} className="tree-item" value={file}>
                <TreeItemLabel className="tree-label">{file}</TreeItemLabel>
              </TreeItem>
            ))}
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
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(
    <React.StrictMode>
      <Fixture />
    </React.StrictMode>
  )
}

export { Fixture, mount }
