import {
  ScrollArea,
  ScrollAreaContent,
  ScrollAreaCorner,
  ScrollAreaScrollbar,
  ScrollAreaScrollToEnd,
  ScrollAreaThumb,
  ScrollAreaViewport,
} from "@ui-sdk/octane/scroll-area"
import { createRoot, useState } from "octane"
import {
  scrollAreaFixture,
  scrollAreaOptions,
} from "tests/fixtures/scroll-area.ts"

const { tags, gallery, short, chat } = scrollAreaFixture

function Scrollbar({
  orientation = "vertical",
}: {
  orientation?: "vertical" | "horizontal"
}) @{
  <ScrollAreaScrollbar
    className="scroll-area-scrollbar"
    orientation={orientation}
  >
    <ScrollAreaThumb className="scroll-area-thumb" />
  </ScrollAreaScrollbar>
}

type Message = { text: string; image?: boolean }

function Fixture() @{
  const { native, ...options } = scrollAreaOptions()
  const [messages, setMessages] = useState<Message[]>(
    chat.messages.map((text) => ({ text }))
  )
  const [imagesLoaded, setImagesLoaded] = useState(false)

  <div class="fixture scroll-fixture">
    <button>Before</button>
    <ScrollArea className="scroll-area" {...options}>
      <ScrollAreaViewport
        className="scroll-area-viewport"
        role="region"
        aria-label={tags.label}
      >
        <ScrollAreaContent>
          @for (const item of tags.items; key item) {
            <p class="scroll-area-item">{item as string}</p>
          }
        </ScrollAreaContent>
      </ScrollAreaViewport>
      @if (!native) {
        <Scrollbar />
      }
    </ScrollArea>
    <ScrollArea className="scroll-area is-wide" {...options}>
      <ScrollAreaViewport
        className="scroll-area-viewport"
        role="region"
        aria-label={gallery.label}
      >
        <ScrollAreaContent className="scroll-area-grid">
          @for (const item of gallery.items; key item) {
            <a href={`#${item}`}>{item as string}</a>
          }
        </ScrollAreaContent>
      </ScrollAreaViewport>
      <Scrollbar />
      <Scrollbar orientation="horizontal" />
      <ScrollAreaCorner className="scroll-area-corner" />
    </ScrollArea>
    <ScrollArea className="scroll-area" {...options}>
      <ScrollAreaViewport
        className="scroll-area-viewport"
        role="region"
        aria-label={short.label}
      >
        <ScrollAreaContent>
          @for (const item of short.items; key item) {
            <p class="scroll-area-item">{item as string}</p>
          }
        </ScrollAreaContent>
      </ScrollAreaViewport>
      <Scrollbar />
    </ScrollArea>
    <ScrollArea className="scroll-area is-chat" stickToEnd {...options}>
      <ScrollAreaViewport
        className="scroll-area-viewport"
        role="region"
        aria-label={chat.label}
      >
        <ScrollAreaContent>
          @for (const message of messages; index position; key position) {
            <p class="scroll-area-message">
              {message.text as string}
              @if (message.image) {
                <span
                  role="img"
                  aria-label="Image"
                  style={{
                    display: "block",
                    height: imagesLoaded ? chat.imageHeight : 0,
                  }}
                />
              }
            </p>
          }
        </ScrollAreaContent>
      </ScrollAreaViewport>
      <Scrollbar />
      <ScrollAreaScrollToEnd className="scroll-area-end">
        {chat.jump as string}
      </ScrollAreaScrollToEnd>
    </ScrollArea>
    <button
      onClick={() =>
        setMessages((current) => [
          ...current,
          { text: `Message ${current.length + 1}` },
        ])
      }
    >
      Add message
    </button>
    <button
      onClick={() =>
        setMessages((current) => [
          ...current.slice(0, -1),
          {
            ...current[current.length - 1],
            text: current[current.length - 1].text + chat.streamed,
          },
        ])
      }
    >
      Stream
    </button>
    <button
      onClick={() =>
        setMessages((current) => [
          ...current,
          { text: `Message ${current.length + 1}`, image: true },
        ])
      }
    >
      Add image
    </button>
    <button onClick={() => setImagesLoaded(true)}>Load images</button>
    <button>After</button>
    <output role="status" aria-label="Last action" />
    <div class="scroll-fixture-spacer" />
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
