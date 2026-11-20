/** @jsxImportSource octane */
import {
  Select,
  SelectTrigger,
  SelectValue,
  type SelectController,
  type SelectValueState,
} from "../src/select"

function ExternalValue({
  callback,
  controller,
  count,
}: {
  callback: "className" | "render"
  controller: SelectController<string>
  count: (state: SelectValueState) => number
}) {
  return (
    <>
      <SelectTrigger controller={controller} aria-label="Plan">
        {callback === "className" ? (
          <SelectValue
            placeholder="Choose"
            className={(state) => `selected-${count(state)}`}
          />
        ) : (
          <SelectValue
            placeholder="Choose"
            render={(props, state) => (
              <span {...props} data-count={count(state)} />
            )}
          />
        )}
      </SelectTrigger>
      <Select
        controller={controller}
        items={[{ value: "pro", label: "Pro" }]}
        defaultValue="pro"
      />
    </>
  )
}

export { ExternalValue }
