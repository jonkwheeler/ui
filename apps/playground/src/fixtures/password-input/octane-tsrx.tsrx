import { Field, FieldDescription, FieldLabel } from "@ui-sdk/octane/field"
import {
  createPasswordInputController,
  PasswordInput,
  PasswordInputControl,
  PasswordInputToggle,
} from "@ui-sdk/octane/password-input"
import { createRoot, useState } from "octane"
import {
  passwordInputAction,
  passwordInputFixture,
  passwordInputOptions,
} from "tests/fixtures/password-input.ts"

const reveal = createPasswordInputController()

function Fixture() @{
  const { controlled, cancel, ...options } = passwordInputOptions()
  const [action, setAction] = useState("")
  const [visible, setVisible] = useState(!!options.defaultVisible)
  const { form, email, password } = passwordInputFixture

  <div class="fixture">
    <button>Before</button>
    <form
      aria-label={form.label}
      class="password-form"
      onSubmit={(event) => {
        event.preventDefault()
        const field = event.currentTarget.elements.namedItem(
          password.name
        ) as HTMLInputElement
        setAction(passwordInputAction.submit(field.type))
      }}
    >
      <fieldset>
        <legend>{form.account as string}</legend>
        <label>
          {`${email.label} `}
          <input
            class="input"
            name={email.name}
            defaultValue={email.defaultValue}
          />
        </label>
        <Field>
          <FieldLabel>{password.label as string}</FieldLabel>
          <PasswordInput
            className="password-input"
            name={password.name}
            controller={reveal}
            {...options}
            {...(controlled && { visible, defaultVisible: undefined })}
            onVisibleChange={(next, details) => {
              if (cancel) {
                return details.cancel()
              }
              setVisible(next)
              setAction(passwordInputAction.visible(next, details.reason))
            }}
          >
            <PasswordInputControl className="input" />
            <PasswordInputToggle
              className="password-toggle"
              aria-label={password.toggle}
            >
              <span aria-hidden="true">👁</span>
            </PasswordInputToggle>
          </PasswordInput>
          <FieldDescription>{password.description as string}</FieldDescription>
        </Field>
        <p class="caps-lock">{password.capsLock as string}</p>
      </fieldset>
      <button type="submit">{form.submit as string}</button>
      <button type="reset">{form.reset as string}</button>
    </form>
    <button onClick={() => reveal.toggleVisible()}>
      {passwordInputFixture.controller as string}
    </button>
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
