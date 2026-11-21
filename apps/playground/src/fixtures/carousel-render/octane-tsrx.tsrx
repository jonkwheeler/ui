import {
  Carousel,
  CarouselContent,
  CarouselIndicator,
  CarouselIndicatorGroup,
  CarouselItem,
  CarouselNext,
  CarouselViewport,
} from "@ui-sdk/octane/carousel"
import { createRoot, useState } from "octane"

const slides = ["One", "Two", "Three"]

function Fixture() @{
  const [action, setAction] = useState("")

  <div class="fixture">
    <button>Before</button>
    <Carousel
      className="carousel"
      aria-label="Photos"
      onPageChange={(page) => setAction(String(page))}
    >
      <CarouselViewport className="carousel-viewport">
        <CarouselContent>
          @for (const slide of slides; key slide) {
            <CarouselItem
              className={(state) =>
                `carousel-slide ${state.active ? "is-active" : "is-inactive"}`
              }
            >
              {slide as string}
            </CarouselItem>
          }
        </CarouselContent>
      </CarouselViewport>
      <CarouselNext
        render={(props, state) => (
          <button {...props}>
            {(state.disabled ? "No more photos" : "Next photo") as string}
          </button>
        )}
      />
      <CarouselIndicatorGroup aria-label="Choose a photo">
        @for (const slide of slides; index position; key slide) {
          <CarouselIndicator
            aria-label={`Photo ${position + 1}`}
            render={<a href={`#photo-${position + 1}`} />}
          >
            {String(position + 1)}
          </CarouselIndicator>
        }
      </CarouselIndicatorGroup>
    </Carousel>
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
