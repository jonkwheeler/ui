import {
  Progress,
  ProgressIndicator,
  ProgressLabel,
  ProgressTrack,
  ProgressValue,
} from "@ui-sdk/octane/progress"
import { createRoot, useState, type ComponentProps } from "octane"
import { progressFixture } from "tests/fixtures/progress.ts"

const { upload, loading, files, disk } = progressFixture

function Bar({
  label,
  ...props
}: ComponentProps<typeof Progress> & { label: string }) @{
  <Progress className="gauge" {...props}>
    <ProgressLabel>{label as string}</ProgressLabel>
    <ProgressValue className="gauge-value" />
    <ProgressTrack className="gauge-track">
      <ProgressIndicator className="gauge-indicator" />
    </ProgressTrack>
  </Progress>
}

function Fixture() @{
  const [value, setValue] = useState(upload.value)

  <div class="fixture">
    <button>Before</button>
    <Bar label={upload.label} value={value} />
    <Bar label={loading.label} value={null} />
    <Bar
      label={files.label}
      value={files.value}
      max={files.max}
      getValueLabel={(value) => files.valueLabel(value!)}
    />
    <Bar
      label={disk.label}
      value={disk.value}
      max={disk.max}
      format={disk.format}
    />
    <button
      onClick={() =>
        setValue((current) => Math.min(100, current + upload.step))
      }
    >
      Advance
    </button>
    <button onClick={() => setValue(upload.value)}>Restart</button>
    <button>After</button>
    <output role="status" aria-label="Last action" />
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
