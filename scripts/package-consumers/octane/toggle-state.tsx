import { Toggle } from "@ui-sdk/octane/toggle"

// Neither `state` has an annotation: under `strict` each fails as an implicit
// `any` unless the packed types give it the toggle's state. Octane's
// `ReactNode` is `unknown`, so children typed with it would lose theirs.
function BoldToggles() {
  return (
    <>
      <Toggle
        aria-label="Bold"
        defaultPressed
        render={(props, state) => (
          <button {...props} data-on={state.pressed ? "" : undefined} />
        )}
      />
      <Toggle aria-label="Italic">
        {(state) => (state.pressed ? "Italic on" : "Italic off")}
      </Toggle>
    </>
  )
}

export { BoldToggles }
