import {
  createImageCropperController,
  ImageCropper,
  ImageCropperFlip,
  ImageCropperGrid,
  ImageCropperHandle,
  ImageCropperImage,
  ImageCropperRotate,
  ImageCropperSelection,
  ImageCropperViewport,
  ImageCropperZoom,
} from "@ui-sdk/octane/image-cropper"
import { createRoot, useState } from "octane"
import {
  describeCrop,
  imageCropperFixture,
} from "tests/fixtures/image-cropper.ts"
import { imageCropperOptions } from "tests/fixtures/page.ts"

const controller = createImageCropperController()

function Fixture() @{
  const [action, setAction] = useState("")
  const [committed, setCommitted] = useState("")
  const { cancel, ...options } = imageCropperOptions()

  <div class="fixture">
    <button type="button">Before</button>
    <ImageCropper
      aria-label={imageCropperFixture.label}
      src={imageCropperFixture.src}
      controller={controller}
      {...options}
      onCropChange={(crop, details) => {
        if (cancel && details.reason !== "image-load") {
          return details.cancel()
        }
        setAction(`${describeCrop(crop)}:${details.reason}`)
      }}
      onCropCommit={(crop, details) =>
        setCommitted(`${describeCrop(crop)}:${details.reason}`)
      }
    >
      <ImageCropperViewport>
        <ImageCropperImage alt={imageCropperFixture.alt} />
        <ImageCropperSelection>
          <ImageCropperGrid />
        </ImageCropperSelection>
        @for (const position of imageCropperFixture.handles; key position) {
          <ImageCropperHandle position={position} />
        }
      </ImageCropperViewport>
      <ImageCropperZoom />
      <ImageCropperRotate>Rotate</ImageCropperRotate>
      <ImageCropperFlip>Flip</ImageCropperFlip>
    </ImageCropper>
    <button type="button">After</button>
    <button
      type="button"
      onClick={() =>
        controller.setCrop({ x: 0, y: 0, width: 100, height: 100 })
      }
    >
      Use corner
    </button>
    <output role="status" aria-label="Last action">
      {action as string}
    </output>
    <output aria-label="Committed">{committed as string}</output>
  </div>
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
