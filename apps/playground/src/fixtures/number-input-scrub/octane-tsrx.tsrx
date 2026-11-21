import {
  createNumberInputController,
  NumberInput,
  NumberInputControl,
  NumberInputGroup,
  NumberInputScrubArea,
} from "@ui-sdk/octane/number-input"
import { createRoot, useState } from "octane"
import { numberInputScrubFixture as f } from "tests/fixtures/number-input-scrub.ts"

const controller = createNumberInputController()

function Fixture() @{
  const [action, setAction] = useState("")
  const [commits, setCommits] = useState<string[]>([])

  <div class="fixture">
    <button>Before</button>
    <div role="toolbar" aria-label={f.toolbarLabel} class="row">
      <NumberInputScrubArea
        controller={controller}
        className="number-input-scrub"
      >
        {f.toolbarScrub as string}
      </NumberInputScrubArea>
    </div>
    <table>
      <thead>
        <tr>
          <NumberInputScrubArea
            controller={controller}
            render={<th />}
            className="number-input-scrub"
          >
            {f.headerScrub as string}
          </NumberInputScrubArea>
        </tr>
      </thead>
    </table>
    <NumberInput
      id={f.id}
      controller={controller}
      defaultValue={f.defaultValue}
      min={f.min}
      max={f.max}
      locale="en-US"
      onValueChange={(value) => setAction(String(value))}
      onValueCommit={(value) => setCommits((list) => [...list, String(value)])}
    >
      <NumberInputGroup className="number-input-group">
        <NumberInputScrubArea className="number-input-scrub">
          {f.letterScrub as string}
        </NumberInputScrubArea>
        <NumberInputControl
          aria-label={f.label}
          className="number-input-control"
        />
      </NumberInputGroup>
      <div>
        <div>
          <div>
            <NumberInputScrubArea className="number-input-scrub">
              {f.nestedScrub as string}
            </NumberInputScrubArea>
          </div>
        </div>
      </div>
    </NumberInput>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
    <output role="status" aria-label="Committed">
      {commits.join(" ") as string}
    </output>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
