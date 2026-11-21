import {
  Carousel,
  CarouselContent,
  CarouselIndicator,
  CarouselIndicatorGroup,
  CarouselItem,
  CarouselNext,
  CarouselPlayToggle,
  CarouselPrevious,
  CarouselViewport,
  createCarouselController,
} from "@ui-sdk/octane/carousel"
import { createRoot, useState, type CSSProperties } from "octane"
import { carouselFixture, carouselOptions } from "tests/fixtures/carousel.ts"

const controller = createCarouselController()

function Slide({
  slide,
  index,
}: {
  slide: (typeof carouselFixture.slides)[number]
  index: number
}) @{
  <CarouselItem className="carousel-slide">
    <p>{slide.title as string}</p>
    <a href={`?product=${index + 1}`}>{slide.link as string}</a>
    @if (index === 2) {
      <label>
        {` ${carouselFixture.field} `}
        <input />
      </label>
    }
  </CarouselItem>
}

function Fixture() @{
  const [action, setAction] = useState("")
  const [reason, setReason] = useState("")
  const [rested, setRested] = useState("")
  const { perView, cancel, playToggle, controlled, options } = carouselOptions()
  const [page, setPage] = useState(1)

  <div class="fixture">
    <button>Before</button>
    <Carousel
      className="carousel"
      aria-label={carouselFixture.label}
      style={{ "--per-view": perView } as CSSProperties}
      controller={controller}
      {...options}
      {...(controlled && { page })}
      onPageChange={(page, details) => {
        if (page === cancel) {
          return details.cancel()
        }
        if (controlled) {
          setPage(page)
        }
        setAction(String(page))
        setReason(details.reason)
      }}
      onPageChangeComplete={(page) => setRested(String(page))}
    >
      @if (playToggle) {
        <CarouselPlayToggle className="carousel-toggle">
          {(state) =>
            state.playing ? carouselFixture.stop : carouselFixture.start
          }
        </CarouselPlayToggle>
      }
      <CarouselViewport className="carousel-viewport">
        <CarouselContent className="carousel-content">
          @for (const slide of carouselFixture.slides; index position; key slide.title) {
            <Slide slide={slide} index={position} />
          }
        </CarouselContent>
      </CarouselViewport>
      <div class="carousel-controls">
        <CarouselPrevious className="carousel-step">
          {carouselFixture.previous as string}
        </CarouselPrevious>
        <CarouselNext className="carousel-step">
          {carouselFixture.next as string}
        </CarouselNext>
      </div>
      <CarouselIndicatorGroup
        className="carousel-controls"
        aria-label={carouselFixture.indicators}
      >
        @for (const slide of carouselFixture.slides; index position; key slide.title) {
          <CarouselIndicator
            className="carousel-indicator"
            aria-label={carouselFixture.indicator(position + 1)}
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
    <output aria-label="Last reason">{reason as string}</output>
    <output aria-label="Rested on">{rested as string}</output>
    <button onClick={() => controller.setPage(4)}>Show page 4</button>
    @if (controlled) {
      <button onClick={() => setPage(3)}>Show page 3 by prop</button>
    }
    <CarouselNext controller={controller}>Next from outside</CarouselNext>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
