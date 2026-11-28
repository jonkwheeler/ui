/** @jsxImportSource octane */
import * as React from "octane"
import { Tree, TreeGroup, TreeItem, TreeItemLabel } from "../src/tree"

// Longer than React's 5ms time slice, so a hydration that slices yields between a branch and its items.
function Slow() {
  const until = performance.now() + 10
  while (performance.now() < until) {}
  return null
}

function App({ onHydrated }: { onHydrated: () => void }) {
  React.useEffect(onHydrated, [])
  return (
    <Tree aria-label="Files" defaultExpanded={["src", "components"]}>
      <TreeItem value="src">
        <TreeItemLabel>src</TreeItemLabel>
        <TreeGroup>
          <TreeItem value="components">
            <TreeItemLabel>components</TreeItemLabel>
            <TreeGroup>
              <Slow />
              <TreeItem value="button.tsx">
                <TreeItemLabel>button.tsx</TreeItemLabel>
              </TreeItem>
            </TreeGroup>
          </TreeItem>
        </TreeGroup>
      </TreeItem>
    </Tree>
  )
}

export { App }
