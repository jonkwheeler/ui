import {
  Field,
  FieldDescription,
  FieldError,
  FieldLabel,
} from "@ui-sdk/octane/field"
import {
  FileInput,
  FileInputDropzone,
  FileInputItem,
  FileInputItemRemove,
  FileInputList,
  FileInputTrigger,
  type FileInputValueChangeDetails,
  type FileRejection,
} from "@ui-sdk/octane/file-input"
import { createRoot, useRef, useState } from "octane"
import {
  describeChange,
  fileInputFixture as f,
  fileInputOptions,
  serializeFiles,
} from "tests/fixtures/file-input.ts"

function Zone({ dragging }: { dragging: boolean }) @{
  <>
    <p>{(dragging ? f.zone.dragging : f.zone.text) as string}</p>
    <FileInputTrigger>{f.trigger.label as string}</FileInputTrigger>
  </>
}

function Item({ file }: { file: File }) @{
  <>
    <span>{file.name as string}</span>
    <FileInputItemRemove>×</FileInputItemRemove>
  </>
}

function Fixture() @{
  const options = fileInputOptions()
  const [action, setAction] = useState("")
  const [count, setCount] = useState(0)
  const [submitted, setSubmitted] = useState("")
  const [attachments, setAttachments] = useState<File[]>([])
  const note = useRef<HTMLTextAreaElement>(null)
  // A change counts as an action, and shows its rejections too. Rejections
  // without a change only show. Both callbacks run in the same task.
  const changed = useRef(false)
  const callbacks = (kind: string) => ({
    onValueChange: (value: File[], details: FileInputValueChangeDetails) => {
      if (options.cancel) {
        details.cancel()
      }
      changed.current = true
      queueMicrotask(() => (changed.current = false))
      setAction(describeChange(kind, details))
      setCount((current) => current + 1)
      const ignored =
        options.ignoreRemovals && details.reason === "remove-press"
      if (kind === "attachments" && !details.canceled && !ignored) {
        setAttachments(value)
      }
    },
    onReject: (rejected: FileRejection[], details: { reason: string }) => {
      if (!changed.current) {
        setAction(describeChange(kind, { ...details, rejected }))
      }
    },
  })

  <div class="fixture">
    <button>Before</button>
    <form
      class="form"
      id={f.formId}
      aria-label={f.formLabel}
      onSubmit={(event) => {
        event.preventDefault()
        setSubmitted(serializeFiles(event.currentTarget))
      }}
    >
      <Field>
        <FieldLabel>{f.field.label as string}</FieldLabel>
        <FileInput
          name={options.name}
          accept={f.attachments.accept}
          multiple={options.multiple}
          maxFiles={options.maxFiles}
          maxSize={f.attachments.maxSize}
          minSize={f.attachments.minSize}
          required={options.required}
          disabled={options.disabled}
          {...(options.controlled && { value: attachments })}
          {...callbacks("attachments")}
          className="file-input"
        >
          <FileInputDropzone
            className="zone"
            role="group"
            aria-label={f.zone.label}
            pasteTarget={() => note.current}
          >
            {(state) => <Zone dragging={state.dragging} />}
          </FileInputDropzone>
          <FileInputList aria-label={f.list.label} className="file-list">
            <FileInputItem className="file-item">
              {({ file }) => <Item file={file} />}
            </FileInputItem>
          </FileInputList>
        </FileInput>
        <FieldDescription>{f.field.description as string}</FieldDescription>
        <FieldError className="field-error" match="valueMissing">
          {f.field.error as string}
        </FieldError>
      </Field>
      <label>
        {f.note.label as string}
        <textarea ref={note} name={f.note.name} />
      </label>
      <div class="row">
        <button type="submit">Send</button>
        <button type="reset">Reset</button>
      </div>
    </form>
    <FileInput
      accept={f.avatar.accept}
      capture={f.avatar.capture}
      {...callbacks("avatar")}
    >
      <FileInputTrigger>{f.avatar.label as string}</FileInputTrigger>
    </FileInput>
    <FileInput directory {...callbacks("folder")}>
      <FileInputTrigger>{f.folder.label as string}</FileInputTrigger>
    </FileInput>
    @if (options.page) {
      <FileInput multiple {...callbacks("page")}>
        <FileInputDropzone
          className="page-zone"
          role="group"
          aria-label={f.page.label}
          target="document"
        >
          {f.page.text as string}
        </FileInputDropzone>
      </FileInput>
    }
    <button>After</button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
    <output role="status" aria-label="Actions">
      {String(count)}
    </output>
    <output role="status" aria-label="Submitted">
      {submitted as string}
    </output>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
