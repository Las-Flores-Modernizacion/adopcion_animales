import { Controller } from "@hotwired/stimulus"
import Compressor from "compressorjs"

export default class extends Controller {
  static targets = ["input"]

  async compress(event) {
    const files = Array.from(event.target.files)
    if (!files.length) return

    const masterInput = document.querySelector('[data-image-preview-target="master"]')
    if (!masterInput) return

    // 1. Comprimir todos los archivos en paralelo
    const compressedFiles = await Promise.all(
      files.map(file => this.compressSingleFile(file))
    )

    // 2. Acumular con las fotos que ya existían en el input maestro
    const dt = new DataTransfer()
    if (masterInput.files.length) {
      Array.from(masterInput.files).forEach(f => dt.items.add(f))
    }

    compressedFiles.forEach(file => dt.items.add(file))

    // 3. Asignar al input maestro y notificar a ActiveStorage & ImagePreview
    masterInput.files = dt.files
    masterInput.dispatchEvent(new Event("change", { bubbles: true }))

    // Limpiar input auxiliar para poder re-seleccionar la misma foto si se desea
    event.target.value = ""
  }

  compressSingleFile(file) {
    return new Promise((resolve) => {
      new Compressor(file, {
        quality: 0.6,
        maxWidth: 1600,
        maxHeight: 1600,
        convertSize: 1000000,
        success: (compressedResult) => {
          const newFile = new File(
            [compressedResult], 
            file.name.replace(/\.[^/.]+$/, ".jpg"), 
            {
              type: compressedResult.type || "image/jpeg",
              lastModified: Date.now(),
            }
          )
          resolve(newFile)
        },
        error: (err) => {
          console.error("Error comprimiendo archivo:", err)
          resolve(file) // Si falla la compresión, devolvemos el original como fallback
        }
      })
    })
  }
}
