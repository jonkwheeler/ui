/** @jsxImportSource octane */
import { Select, SelectTrigger, SelectValue } from "../src/select"

function LabelledTrigger() {
  return (
    <>
      <span id="fruit">Fruit</span>
      <Select items={["Apple", "Pear"]}>
        <SelectTrigger aria-labelledby="fruit">
          <SelectValue />
        </SelectTrigger>
      </Select>
    </>
  )
}

export { LabelledTrigger }
