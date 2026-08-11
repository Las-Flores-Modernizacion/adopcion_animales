import { Controller } from "@hotwired/stimulus"
import Compressor from "compressorjs"

export default class extends Controller {
  static targets = ["input"]

  compress(event) {
    const files = Array.from(event.target.files)
    if (!files.length) return

    const masterInput = document.querySelector('[data-image-preview-target="master"]')

    files.forEach((file) => {
      new Compressor(file, {
        quality: 0.6,
        maxWidth: 1600,
        maxHeight: 1600,
        convertSize: 1000000,
        success: (compressedResult) => {
          const newFile = new File([compressedResult], file.name.replace(/\.[^/.]+$/, ".jpg"), {
            type: compressedResult.type || "image/jpeg",
            lastModified: Date.now(),
          })

          if (masterInput) {
            const dataTransfer = new DataTransfer()

            if (masterInput.files.length) {
              Array.from(masterInput.files).forEach(f => dataTransfer.items.add(f))
            }

            dataTransfer.items.add(newFile)
            masterInput.files = dataTransfer.files

            masterInput.dispatchEvent(new Event("change", { bubbles: true }))
          }

          event.target.value = ""
        },
        error(err) {
          console.error("Error al comprimir la imagen:", err.message)
        },
      })
    })
  }
}
