import { Controller } from "@hotwired/stimulus"
import Compressor from "compressorjs"

export default class extends Controller {
  static targets = [ "input", "info" ]

  compress(event) {
    const file = event.target.files[0];
    if (!file) return;

    if (this.hasInfoTarget) {
      this.infoTarget.textContent = `Procesando: ${file.name}...`
      this.infoTarget.classList.add("text-blue-500")
    }

    new Compressor(file, {
      quality: 0.6, // Baja la calidad al 60%
      maxWidth: 1920, // Limita el ancho máximo (ej. Full HD)
      success: (compressedResult) => {
        // Truco para reemplazar el archivo pesado por el ligero en el input
        let dataTransfer = new DataTransfer();
        dataTransfer.items.add(compressedResult);
        this.inputTarget.files = dataTransfer.files;
        this.dispatch("success", { target: this.inputTarget });
      },
      error(err) {
        console.log(err.message);
      },
    });
  }
}
