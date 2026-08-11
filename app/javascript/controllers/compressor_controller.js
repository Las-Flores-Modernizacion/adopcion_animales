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
        maxWidth: 1600, // 1600px es óptimo para celular/pantallas web
        maxHeight: 1600,
        convertSize: 1000000, // Convierte PNGs grandes a JPEG automáticamente
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

            // Notificamos a ActiveStorage / ImagePreview que el input maestro cambió
            masterInput.dispatchEvent(new Event("change", { bubbles: true }))
          }

          this.dispatch("success", { target: this.inputTarget })
        },
        error(err) {
          console.error("Error al comprimir la imagen:", err.message)
        },
      })
    })
  }
}
