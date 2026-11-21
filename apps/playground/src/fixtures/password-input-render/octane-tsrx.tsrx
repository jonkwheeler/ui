import {
  PasswordInput,
  PasswordInputControl,
  PasswordInputToggle,
} from "@ui-sdk/octane/password-input"
import { createRoot, useState } from "octane"

function Fixture() @{
  const [action, setAction] = useState("")

  <div class="fixture">
    <button>Before</button>
    <PasswordInput
      className="password-input"
      onVisibleChange={(visible) => setAction(`visible: ${visible}`)}
    >
      <PasswordInputControl className="input" aria-label="Password" />
      <PasswordInputToggle
        aria-label="Show password"
        render={<span />}
        className={(state) =>
          `password-toggle ${state.visible ? "is-visible" : "is-hidden"}`
        }
      >
        {(state) => (
          <span aria-hidden="true">
            {(state.visible ? "Hide" : "Show") as string}
          </span>
        )}
      </PasswordInputToggle>
    </PasswordInput>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
