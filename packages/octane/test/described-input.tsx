/** @jsxImportSource octane */
import { definePrimitive } from "@ui-sdk/core"
import { createParts } from "../src/primitive"

const described = definePrimitive({
  name: "described",
  state: (_options: {}) => ({}),
  api: () => ({}),
  slots: (slot) => ({
    root: slot<{}, {}>({}),
    control: slot<
      { labelId?: string; descriptionId?: string; errorId?: string },
      {}
    >({
      props: { labelId: "id", descriptionId: "id", errorId: "id" },
      attrs: (_state, { props }) => ({
        "data-label-id": props.labelId,
        "data-description-id": props.descriptionId,
        "data-error-id": props.errorId,
      }),
    }),
  }),
})

const { Root: Described, Control: DescribedControl } = createParts(described, {
  root: "div",
  control: "input",
})

const idNames = ["data-label-id", "data-description-id", "data-error-id"]

// Hydration keeps the server's attributes whatever the client renders, so the
// ids the client rendered are kept here.
const renderedIds: (string | null)[][] = []

function DescribedInput() {
  return (
    <Described>
      <DescribedControl
        render={(props) => {
          renderedIds.push(idNames.map((name) => props[name]))
          return <input {...props} />
        }}
      />
    </Described>
  )
}

export { DescribedInput, idNames, renderedIds }
